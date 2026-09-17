// language: Dart, file: inference_client_factory.dart, target: Flutter / Owl MOBA HUD
import '../api_client.dart';

import 'claude_inference_client.dart';
import 'gemini_inference_client.dart';
import 'groq_inference_client.dart';
import 'inference_client.dart';
import 'openai_inference_client.dart';
import 'openrouter_inference_client.dart';
import 'sambanova_inference_client.dart';
import 'xkiro_inference_client.dart';

/// Resolves a settings provider id to its [InferenceClient].
/// Unknown ids fall back to Gemini. The settings `deepseek` entry addresses
/// DeepSeek models through the OpenRouter gateway.
InferenceClient inferenceClientFor({
  required String providerId,
  required ApiClient api,
}) {
  switch (providerId) {
    case 'openai':
      return OpenAiInferenceClient(api);
    case 'claude':
      return ClaudeInferenceClient(api);
    case 'deepseek':
    case 'openrouter':
      return OpenRouterInferenceClient(api);
    case 'sambanova':
      return SambaNovaInferenceClient(api);
    case 'xkiro':
      return XKiroInferenceClient(api);
    case 'groq':
      return GroqInferenceClient(api);
    case 'gemini':
    default:
      return GeminiInferenceClient(api);
  }
}
