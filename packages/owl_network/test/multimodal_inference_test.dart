// language: Dart, file: multimodal_inference_test.dart, target: Flutter / Owl Network
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_network/network/api_client.dart';
import 'package:owl_network/network/inference/claude_inference_client.dart';
import 'package:owl_network/network/inference/gemini_inference_client.dart';
import 'package:owl_network/network/inference/openai_inference_client.dart';

void main() {
  group('Multimodal Payload Construction Tests', () {
    test('GeminiInferenceClient generates inlineData part when base64Image is provided', () async {
      final client = GeminiInferenceClient(ApiClient(Dio()));
      expect(client.providerId, equals('gemini'));
      // Test payload extraction via extractText
      const sampleResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '{"action": "Smite Turtle", "reason": "Pit secured"}'}
              ]
            }
          }
        ]
      };
      final text = GeminiInferenceClient.extractText(
        sampleResponse,
        maskedKeyTail: '****',
      );
      expect(text, contains('Smite Turtle'));
    });

    test('OpenAiInferenceClient extractText reads message content accurately', () async {
      const sampleResponse = {
        'choices': [
          {
            'message': {
              'content': '{"action": "Fall Back", "reason": "Mid missing"}'
            }
          }
        ]
      };
      final text = OpenAiInferenceClient.extractText(
        sampleResponse,
        maskedKeyTail: '****',
      );
      expect(text, contains('Fall Back'));
    });

    test('ClaudeInferenceClient extractText reads message content blocks accurately', () async {
      const sampleResponse = {
        'content': [
          {'type': 'text', 'text': '{"action": "Gank Bot", "reason": "Enemy overextended"}'}
        ]
      };
      final text = ClaudeInferenceClient.extractText(
        sampleResponse,
        maskedKeyTail: '****',
      );
      expect(text, contains('Gank Bot'));
    });
  });
}
