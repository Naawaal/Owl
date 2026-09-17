// language: Dart, file: inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:owl_core/owl_core.dart';

import '../api_client.dart';

/// Failure kinds for inference operations. Surfaced to UI and budgets;
/// never carries key material.
enum InferenceFailure { auth, network, timeout, rateLimited, unknown }

/// Typed inference error. [message] is safe to display: it never contains
/// key material (see [maskApiKey]).
class InferenceException implements Exception {
  final InferenceFailure failure;
  final String message;
  final int? statusCode;

  const InferenceException({
    required this.failure,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'InferenceException($failure): $message';
}

/// Result of a key verification attempt with measured latency.
class KeyVerification {
  final bool ok;
  final int latencyMs;
  final InferenceFailure? failure;

  const KeyVerification.ok(this.latencyMs)
      : ok = true,
        failure = null;

  const KeyVerification.failed(this.failure)
      : ok = false,
        latencyMs = 0;
}

/// Masks an API key for UI and diagnostics: at most the last 4 characters.
String maskApiKey(String key) {
  final trimmed = key.trim();
  if (trimmed.length <= 4) return '****';
  return '***${trimmed.substring(trimmed.length - 4)}';
}

/// Provider inference contract: key verification, single-shot generation,
/// and streaming generation. Implementations must never log full keys.
abstract class InferenceClient {
  /// Settings provider id this client serves
  /// ('gemini' | 'openai' | 'claude' | 'openrouter' | 'deepseek').
  String get providerId;

  /// Verifies [apiKey] with a cheap read-only call; measures wall-clock
  /// latency. Never throws for expected failures — returns them instead.
  Future<KeyVerification> verifyKey({
    required String apiKey,
    required String model,
  });

  /// Single-shot text generation. Throws [InferenceException] on failure.
  Future<String> generate({
    required String apiKey,
    required String model,
    required String prompt,
    String? base64Image,
    Duration? timeout,
  });

  /// Streaming text generation yielding incremental text deltas.
  /// Throws [InferenceException] on failure.
  Stream<String> generateStream({
    required String apiKey,
    required String model,
    required String prompt,
    String? base64Image,
    Duration? timeout,
  });
}

/// Shared behavior for provider clients: timeout application, latency
/// measurement, and error mapping. Key injection stays per-provider
/// (query param vs bearer vs vendor headers differ).
abstract base class BaseInferenceClient implements InferenceClient {
  BaseInferenceClient(this._api);

  final ApiClient _api;

  ApiClient get api => _api;

  /// Default per-request budget when callers pass no explicit timeout.
  Duration get defaultTimeout => AppConstants.networkTimeout;

  /// Runs [task], returning its value with elapsed milliseconds.
  Future<({Object? value, int latencyMs})> _measure(
    Future<Object?> task,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final value = await task;
      return (value: value, latencyMs: stopwatch.elapsedMilliseconds);
    } finally {
      stopwatch.stop();
    }
  }

  /// Applies [timeout] to [task]; maps timeout expiry to [InferenceFailure.timeout].
  Future<T> withTimeout<T>(Future<T> task, Duration? timeout) {
    final budget = timeout ?? defaultTimeout;
    return task.timeout(
      budget,
      onTimeout: () => throw InferenceException(
        failure: InferenceFailure.timeout,
        message: 'Provider request timed out after ${budget.inSeconds}s.',
      ),
    );
  }

  /// Maps transport errors to typed failures. Messages reference only the
  /// masked key tail — never full key material.
  InferenceException mapError(Object error, {required String maskedKeyTail}) {
    if (error is InferenceException) return error;
    if (error is NetworkException) {
      final code = error.statusCode;
      if (code == 401 || code == 403) {
        return InferenceException(
          failure: InferenceFailure.auth,
          message: 'Provider rejected the key $maskedKeyTail (HTTP $code).',
          statusCode: code,
        );
      }
      if (code == 429) {
        return const InferenceException(
          failure: InferenceFailure.rateLimited,
          message: 'Provider rate limit reached. Try again shortly.',
          statusCode: 429,
        );
      }
      if (error.code == 'NETWORK_TIMEOUT') {
        return const InferenceException(
          failure: InferenceFailure.timeout,
          message: 'Provider request timed out.',
        );
      }
      if (error.code == 'NO_INTERNET') {
        return const InferenceException(
          failure: InferenceFailure.network,
          message: 'No network connection.',
        );
      }
      return InferenceException(
        failure: InferenceFailure.unknown,
        message: 'Provider request failed${code != null ? ' (HTTP $code)' : ''}.',
        statusCode: code,
      );
    }
    if (error is DioException) {
      // Raw dio errors that escaped ApiClient mapping.
      return const InferenceException(
        failure: InferenceFailure.network,
        message: 'Network request failed.',
      );
    }
    return InferenceException(
      failure: InferenceFailure.unknown,
      message: 'Unexpected inference error: $error',
    );
  }

  /// Measures a verification [task], returning ok/failed without throwing.
  Future<KeyVerification> guardVerify(
    Future<Object?> task, {
    required String apiKey,
  }) async {
    final tail = maskApiKey(apiKey);
    try {
      final result = await _measure(task);
      return KeyVerification.ok(result.latencyMs);
    } on NetworkException catch (e) {
      return KeyVerification.failed(
        mapError(e, maskedKeyTail: tail).failure,
      );
    } on InferenceException catch (e) {
      return KeyVerification.failed(e.failure);
    } catch (_) {
      return const KeyVerification.failed(InferenceFailure.unknown);
    }
  }
}
