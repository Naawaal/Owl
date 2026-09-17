// language: Dart, file: claude_inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import '../sse_stream_reader.dart';
import 'inference_client.dart';

/// Anthropic Claude inference over `api.anthropic.com/v1/messages`.
/// Key travels as the `x-api-key` header and never appears in logs.
///
/// Note: Anthropic exposes no key-only listing endpoint, so verification
/// uses a minimal 1-token ping (the documented cheap-auth-check fallback).
final class ClaudeInferenceClient extends BaseInferenceClient {
  ClaudeInferenceClient(super.api);

  static const String _baseUrl = 'https://api.anthropic.com/v1';

  /// System framing applied around every tactical prompt.
  static const String systemPrompt =
      'You are a real-time MOBA tactical HUD coach. '
      'Keep every callout short enough to read mid-fight.';

  @override
  String get providerId => 'claude';

  Options _authed(String apiKey) => Options(headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      });

  @override
  Future<KeyVerification> verifyKey({
    required String apiKey,
    required String model,
  }) {
    // No listing endpoint exists: verify with a minimal 1-token ping.
    return guardVerify(
      withTimeout(
        api.post(
          '$_baseUrl/messages',
          options: _authed(apiKey),
          data: {
            'model': model,
            'max_tokens': 1,
            'messages': [
              {'role': 'user', 'content': 'ok'},
            ],
          },
        ),
        const Duration(seconds: 20),
      ),
      apiKey: apiKey,
    );
  }

  @override
  Future<String> generate({
    required String apiKey,
    required String model,
    required String prompt,
    String? base64Image,
    Duration? timeout,
  }) async {
    final tail = maskApiKey(apiKey);
    try {
      final response = await withTimeout(
        api.post(
          '$_baseUrl/messages',
          options: _authed(apiKey),
          data: _requestBody(
            model: model,
            prompt: prompt,
            base64Image: base64Image,
            stream: false,
          ),
        ),
        timeout,
      );
      return extractText(response.data, maskedKeyTail: tail);
    } catch (e) {
      throw mapError(e, maskedKeyTail: tail);
    }
  }

  @override
  Stream<String> generateStream({
    required String apiKey,
    required String model,
    required String prompt,
    String? base64Image,
    Duration? timeout,
  }) async* {
    final tail = maskApiKey(apiKey);
    final budget = timeout ?? defaultTimeout;
    try {
      final body = await withTimeout(
        api.postStream(
          '$_baseUrl/messages',
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          data: _requestBody(
            model: model,
            prompt: prompt,
            base64Image: base64Image,
            stream: true,
          ),
        ),
        timeout,
      );
      final deltas = SseStreamReader.extractDataStream(body.stream).map(
        (data) => extractDelta(data),
      );
      yield* deltas.timeout(
        budget,
        onTimeout: (sink) => sink.addError(
          InferenceException(
            failure: InferenceFailure.timeout,
            message:
                'Provider stream stalled after ${budget.inSeconds}s of silence.',
          ),
        ),
      );
    } catch (e) {
      throw mapError(e, maskedKeyTail: tail);
    }
  }

  Map<String, Object?> _requestBody({
    required String model,
    required String prompt,
    String? base64Image,
    required bool stream,
  }) {
    final Object userContent;
    if (base64Image != null && base64Image.isNotEmpty) {
      userContent = [
        {
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': 'image/jpeg',
            'data': base64Image,
          },
        },
        {'type': 'text', 'text': prompt},
      ];
    } else {
      userContent = prompt;
    }

    return {
      'model': model,
      'max_tokens': 256,
      'system': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userContent},
      ],
      'stream': stream,
    };
  }

  /// Extracts text from a `messages` response (`content` blocks).
  static String extractText(
    dynamic data, {
    required String maskedKeyTail,
  }) {
    try {
      final content = (data as Map)['content'] as List;
      final text = content
          .map((block) => (block as Map)['text']?.toString() ?? '')
          .join();
      if (text.trim().isEmpty) {
        throw const FormatException('empty content');
      }
      return text;
    } catch (e) {
      throw InferenceException(
        failure: InferenceFailure.unknown,
        message: 'Unexpected Claude response shape (key $maskedKeyTail).',
      );
    }
  }

  /// Extracts the text delta from one SSE `data:` JSON chunk
  /// (`content_block_delta` events carry `delta.text`).
  static String extractDelta(String data) {
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      if (decoded['type'] != 'content_block_delta') return '';
      final delta = decoded['delta'] as Map;
      return delta['text']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
