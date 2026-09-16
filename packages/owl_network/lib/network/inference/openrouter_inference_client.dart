// language: Dart, file: openrouter_inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:dio/dio.dart';
import '../sse_stream_reader.dart';
import 'inference_client.dart';
import 'openai_inference_client.dart';

/// OpenRouter unified-gateway inference. The chat API is OpenAI-compatible,
/// so request/response parsing is shared with [OpenAiInferenceClient];
/// only the base URL, headers, and key verification differ.
///
/// Also serves the settings `deepseek` entry, which addresses DeepSeek
/// models through this gateway.
final class OpenRouterInferenceClient extends BaseInferenceClient {
  OpenRouterInferenceClient(super.api);

  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  @override
  String get providerId => 'openrouter';

  Options _authed(String apiKey) => Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://owl-companion.local',
        'X-Title': 'Owl MOBA Companion',
      });

  @override
  Future<KeyVerification> verifyKey({
    required String apiKey,
    required String model,
  }) {
    // Dedicated key-check endpoint: 200 with key info, 401/403 otherwise.
    return guardVerify(
      api.get(
        '$_baseUrl/auth/key',
        options: _authed(apiKey),
      ),
      apiKey: apiKey,
    );
  }

  @override
  Future<String> generate({
    required String apiKey,
    required String model,
    required String prompt,
    Duration? timeout,
  }) async {
    final tail = maskApiKey(apiKey);
    try {
      final response = await withTimeout(
        api.post(
          '$_baseUrl/chat/completions',
          options: _authed(apiKey),
          data: {
            'model': model,
            'messages': [
              {
                'role': 'system',
                'content': OpenAiInferenceClient.systemPrompt,
              },
              {'role': 'user', 'content': prompt},
            ],
            'max_tokens': 256,
            'temperature': 0.7,
            'stream': false,
          },
        ),
        timeout,
      );
      return OpenAiInferenceClient.extractText(
        response.data,
        maskedKeyTail: tail,
      );
    } catch (e) {
      throw mapError(e, maskedKeyTail: tail);
    }
  }

  @override
  Stream<String> generateStream({
    required String apiKey,
    required String model,
    required String prompt,
    Duration? timeout,
  }) async* {
    final tail = maskApiKey(apiKey);
    final budget = timeout ?? defaultTimeout;
    try {
      final body = await withTimeout(
        api.postStream(
          '$_baseUrl/chat/completions',
          headers: {
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://owl-companion.local',
            'X-Title': 'Owl MOBA Companion',
          },
          data: {
            'model': model,
            'messages': [
              {
                'role': 'system',
                'content': OpenAiInferenceClient.systemPrompt,
              },
              {'role': 'user', 'content': prompt},
            ],
            'max_tokens': 256,
            'temperature': 0.7,
            'stream': true,
          },
        ),
        timeout,
      );
      final deltas = SseStreamReader.extractDataStream(body.stream).map(
        (data) => OpenAiInferenceClient.extractDelta(data),
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
}
