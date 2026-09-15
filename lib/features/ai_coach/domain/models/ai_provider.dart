// language: Dart, file: ai_provider.dart, target: Flutter / Owl MOBA HUD

/// Supported AI LLM providers for live in-game tactical coaching recommendations.
enum AIProvider {
  /// Google Gemini (optimized for low-latency gaming inference via Flash models).
  gemini,

  /// OpenAI GPT models.
  openai,

  /// Anthropic Claude models.
  claude,

  /// OpenRouter unified inference gateway (supports Llama, DeepSeek, Mistral, etc.).
  openrouter;

  /// User-facing display name.
  String get displayName {
    switch (this) {
      case AIProvider.gemini:
        return 'Google Gemini';
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.claude:
        return 'Anthropic Claude';
      case AIProvider.openrouter:
        return 'OpenRouter';
    }
  }

  /// Recommended default model identifier for fast tactical turnarounds.
  String get defaultModel {
    switch (this) {
      case AIProvider.gemini:
        return 'gemini-2.0-flash';
      case AIProvider.openai:
        return 'gpt-4o-mini';
      case AIProvider.claude:
        return 'claude-3-5-haiku-20241022';
      case AIProvider.openrouter:
        return 'meta-llama/llama-3.3-70b-instruct';
    }
  }

  /// List of verified models available for this provider.
  List<String> get availableModels {
    switch (this) {
      case AIProvider.gemini:
        return const [
          'gemini-2.0-flash',
          'gemini-1.5-flash',
          'gemini-1.5-pro',
        ];
      case AIProvider.openai:
        return const [
          'gpt-4o-mini',
          'gpt-4o',
          'gpt-4-turbo',
        ];
      case AIProvider.claude:
        return const [
          'claude-3-5-haiku-20241022',
          'claude-3-5-sonnet-20241022',
          'claude-3-opus-20240229',
        ];
      case AIProvider.openrouter:
        return const [
          'meta-llama/llama-3.3-70b-instruct',
          'deepseek/deepseek-chat',
          'google/gemini-2.0-flash-001',
          'anthropic/claude-3.5-sonnet',
        ];
    }
  }

  /// Standard environment variable or storage key name for API credentials.
  String get apiKeyStorageKey {
    switch (this) {
      case AIProvider.gemini:
        return 'owl_api_key_gemini';
      case AIProvider.openai:
        return 'owl_api_key_openai';
      case AIProvider.claude:
        return 'owl_api_key_claude';
      case AIProvider.openrouter:
        return 'owl_api_key_openrouter';
    }
  }
}
