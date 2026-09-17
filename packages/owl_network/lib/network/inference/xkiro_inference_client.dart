// language: Dart, file: xkiro_inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:dio/dio.dart';
import '../sse_stream_reader.dart';
import 'inference_client.dart';
import 'openai_inference_client.dart';

/// xKiro unified AI gateway inference client over `https://api.xkiro.com/v1`.
/// The chat API is OpenAI-compatible, aggregating multiple frontier models.
final class XKiroInferenceClient extends BaseInferenceClient {
  XKiroInferenceClient(super.api);

  static const String _baseUrl = 'https://api.xkiro.com/v1';

  @override
  String get providerId => 'xkiro';

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
    return guardVerify(
      api.get(
        '$_baseUrl/models',
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
    String? base64Image,
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
    String? base64Image,
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
