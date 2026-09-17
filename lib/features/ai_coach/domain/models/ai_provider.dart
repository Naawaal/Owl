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
  openrouter,

  /// SambaNova Systems (reconfigurable dataflow accelerator).
  sambanova,

  /// xKiro unified AI gateway (free and premium models).
  xkiro,

  /// GroqCloud ultra-fast LPU inference.
  groq;

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
      case AIProvider.sambanova:
        return 'SambaNova';
      case AIProvider.xkiro:
        return 'xKiro';
      case AIProvider.groq:
        return 'Groq';
    }
  }

  /// Recommended default model identifier for fast tactical turnarounds.
  String get defaultModel {
    switch (this) {
      case AIProvider.gemini:
        return 'gemini-3-flash-preview';
      case AIProvider.openai:
        return 'gpt-4o-mini';
      case AIProvider.claude:
        return 'claude-3-5-haiku-20241022';
      case AIProvider.openrouter:
        return 'meta-llama/llama-3.3-70b-instruct';
      case AIProvider.sambanova:
        return 'Meta-Llama-3.3-70B-Instruct';
      case AIProvider.xkiro:
        return 'deepseek/deepseek-v4.1-flash';
      case AIProvider.groq:
        return 'openai/gpt-oss-120b';
    }
  }

  /// List of verified models available for this provider.
  List<String> get availableModels {
    switch (this) {
      case AIProvider.gemini:
        return const [
          'gemini-3-flash-preview',
          'gemini-2.5-flash',
          'gemini-3.5-flash',
          'gemini-2.5-pro',
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
      case AIProvider.sambanova:
        return const [
          'Meta-Llama-3.3-70B-Instruct',
          'DeepSeek-R1-0528',
          'DeepSeek-V3.1',
          'openai/gpt-oss-120b',
          'MiniMax-M2.7',
        ];
      case AIProvider.xkiro:
        return const [
          'deepseek/deepseek-v4.1-flash',
          'qwen/qwen3.8-max',
          'qwen/qwen3.7-flash:free',
          'google/gemini-2.5-flash',
          'openai/gpt-5.6-luna',
          'z-ai/glm-5.3-flash',
          'anthropic/claude-haiku-4.5',
          'minimax/minimax-m3:free',
        ];
      case AIProvider.groq:
        return const [
          'openai/gpt-oss-120b',
          'openai/gpt-oss-20b',
          'qwen/qwen3.6-27b',
          'meta-llama/llama-3.3-70b-instruct',
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
      case AIProvider.sambanova:
        return 'owl_api_key_sambanova';
      case AIProvider.xkiro:
        return 'owl_api_key_xkiro';
      case AIProvider.groq:
        return 'owl_api_key_groq';
    }
  }
}
