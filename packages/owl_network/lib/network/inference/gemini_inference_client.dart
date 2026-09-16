// language: Dart, file: gemini_inference_client.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';
import 'dart:convert';

import '../sse_stream_reader.dart';
import 'inference_client.dart';

/// Google Gemini inference over the `generativelanguage.googleapis.com`
/// REST API. Key travels as the documented `?key=` query parameter and
/// never appears in logs (see [maskApiKey]).
final class GeminiInferenceClient extends BaseInferenceClient {
  GeminiInferenceClient(super.api);

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  @override
  String get providerId => 'gemini';

  @override
  Future<KeyVerification> verifyKey({
    required String apiKey,
    required String model,
  }) {
    return guardVerify(
      api.get(
        '$_baseUrl/models',
        queryParameters: {'key': apiKey, 'pageSize': 5},
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
          '$_baseUrl/models/$model:generateContent',
          queryParameters: {'key': apiKey},
          data: _requestBody(prompt),
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
    Duration? timeout,
  }) async* {
    final tail = maskApiKey(apiKey);
    final budget = timeout ?? defaultTimeout;
    try {
      final body = await withTimeout(
        api.postStream(
          '$_baseUrl/models/$model:streamGenerateContent',
          queryParameters: {'alt': 'sse', 'key': apiKey},
          data: _requestBody(prompt),
        ),
        timeout,
      );
      final deltas = SseStreamReader.extractDataStream(body.stream).map(
        (data) => extractDelta(data, maskedKeyTail: tail),
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

  Map<String, Object?> _requestBody(String prompt) {
    return {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'maxOutputTokens': 256,
        'temperature': 0.7,
      },
    };
  }

  /// Extracts joined response text from a `generateContent` payload.
  static String extractText(
    dynamic data, {
    required String maskedKeyTail,
  }) {
    try {
      final candidates = (data as Map)['candidates'] as List;
      final parts =
          ((candidates.first as Map)['content'] as Map)['parts'] as List;
      final text = parts
          .map((part) => (part as Map)['text']?.toString() ?? '')
          .join();
      if (text.trim().isEmpty) {
        throw const FormatException('empty text');
      }
      return text;
    } catch (e) {
      throw InferenceException(
        failure: InferenceFailure.unknown,
        message: 'Unexpected Gemini response shape (key $maskedKeyTail).',
      );
    }
  }

  /// Extracts the text delta from one SSE `data:` JSON chunk.
  static String extractDelta(
    String data, {
    required String maskedKeyTail,
  }) {
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List;
      final parts =
          ((candidates.first as Map)['content'] as Map)['parts'] as List;
      return parts
          .map((part) => (part as Map)['text']?.toString() ?? '')
          .join();
    } catch (_) {
      return '';
    }
  }
}
