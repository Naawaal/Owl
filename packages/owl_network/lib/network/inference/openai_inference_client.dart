// language: Dart, file: openai_inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import '../sse_stream_reader.dart';
import 'inference_client.dart';

/// OpenAI inference over `api.openai.com/v1` (`chat/completions`).
/// Key travels as a `Bearer` header and never appears in logs.
final class OpenAiInferenceClient extends BaseInferenceClient {
  OpenAiInferenceClient(super.api);

  static const String _baseUrl = 'https://api.openai.com/v1';

  /// System framing applied around every tactical prompt.
  static const String systemPrompt =
      'You are a real-time MOBA tactical HUD coach. '
      'Keep every callout short enough to read mid-fight.';

  @override
  String get providerId => 'openai';

  Options _authed(String apiKey) => Options(headers: {
        'Authorization': 'Bearer $apiKey',
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
          '$_baseUrl/chat/completions',
          headers: {'Authorization': 'Bearer $apiKey'},
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
    if (base64Image != null &&
        base64Image.isNotEmpty &&
        (model.contains('vision') || model.contains('4o'))) {
      userContent = [
        {'type': 'text', 'text': prompt},
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
          },
        },
      ];
    } else {
      userContent = prompt;
    }

    return {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userContent},
      ],
      'stream': stream,
      'max_tokens': 256,
      'temperature': 0.7,
    };
  }

  /// Extracts the assistant message from a `chat/completions` payload.
  static String extractText(
    dynamic data, {
    required String maskedKeyTail,
  }) {
    try {
      final choices = (data as Map)['choices'] as List;
      final message = ((choices.first as Map)['message'] as Map);
      final text = message['content']?.toString() ?? '';
      if (text.trim().isEmpty) {
        throw const FormatException('empty content');
      }
      return text;
    } catch (e) {
      throw InferenceException(
        failure: InferenceFailure.unknown,
        message: 'Unexpected OpenAI response shape (key $maskedKeyTail).',
      );
    }
  }

  /// Extracts the text delta from one SSE `data:` JSON chunk.
  static String extractDelta(String data) {
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final choices = decoded['choices'] as List;
      final delta = ((choices.first as Map)['delta'] as Map);
      return delta['content']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
