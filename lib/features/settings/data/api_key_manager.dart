// language: Dart, file: api_key_manager.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl_network/owl_network.dart';
import 'package:owl_storage/owl_storage.dart';

/// Provider managing secure API keys per cloud provider with format validation.
final apiKeyManagerProvider = Provider<ApiKeyManager>((ref) {
  SecureStorageService? secureStorage;
  try {
    secureStorage = ref.watch(secureStorageServiceProvider);
  } catch (_) {}
  ApiClient? api;
  try {
    api = ref.watch(apiClientProvider);
  } catch (_) {}
  return ApiKeyManager(secureStorage, api);
});

/// Service class managing secure API keys and validation logic.
class ApiKeyManager {
  final SecureStorageService? _secureStorage;
  final ApiClient? _apiClient;
  static final Map<String, String> _memoryCache = {};

  ApiKeyManager(this._secureStorage, [this._apiClient]);

  /// Validates the format of an API key for a specified provider.
  String? validateKeyFormat(String provider, String key) {
    final sanitized = key.trim();
    if (sanitized.isEmpty) {
      return 'API key cannot be empty';
    }

    switch (provider) {
      case 'gemini':
        if (!sanitized.startsWith('AIza') && sanitized.length < 20) {
          return 'Google Gemini keys typically start with "AIza"';
        }
        break;
      case 'openai':
        if (!sanitized.startsWith('sk-') || sanitized.length < 20) {
          return 'OpenAI keys must begin with "sk-"';
        }
        break;
      case 'claude':
        if (!sanitized.startsWith('sk-ant-') && sanitized.length < 20) {
          return 'Anthropic keys typically begin with "sk-ant-"';
        }
        break;
      case 'deepseek':
      case 'openrouter':
        if (sanitized.length < 15) {
          return 'Invalid API key length for OpenRouter/DeepSeek';
        }
        break;
      case 'sambanova':
        if (sanitized.length < 15) {
          return 'Invalid API key length for SambaNova';
        }
        break;
      case 'xkiro':
        if (sanitized.length < 15) {
          return 'Invalid API key length for xKiro';
        }
        break;
      case 'groq':
        if (!sanitized.startsWith('gsk_') || sanitized.length < 20) {
          return 'Groq API keys must begin with "gsk_"';
        }
        break;
    }
    return null;
  }

  /// Retrieves stored API key for the provider.
  Future<String?> getApiKey(String provider) async {
    if (_secureStorage != null) {
      try {
        final provEnum = _mapToStorageProvider(provider);
        return await _secureStorage.getApiKey(provEnum);
      } catch (_) {}
    }
    return _memoryCache[provider];
  }

  /// Stores API key securely.
  Future<void> saveApiKey(String provider, String key) async {
    final sanitized = key.trim();
    _memoryCache[provider] = sanitized;
    if (_secureStorage != null) {
      try {
        final provEnum = _mapToStorageProvider(provider);
        await _secureStorage.saveApiKey(provEnum, sanitized);
      } catch (_) {}
    }
  }

  /// Verifies [key] against the live provider with a cheap read-only call.
  /// Returns measured round-trip latency in milliseconds.
  /// Throws on format errors, auth failures, and network failures with
  /// distinct messages. Never logs key material (see `maskApiKey`).
  Future<int> testConnection(String provider, String key,
      {String? model}) async {
    final validationError = validateKeyFormat(provider, key);
    if (validationError != null) {
      throw Exception(validationError);
    }
    final api = _apiClient;
    if (api == null) {
      throw Exception('Network client unavailable in this context.');
    }

    final client = inferenceClientFor(providerId: provider, api: api);
    final result = await client.verifyKey(
      apiKey: key.trim(),
      model: model ?? _defaultModelFor(provider),
    );
    if (result.ok) return result.latencyMs;

    switch (result.failure) {
      case InferenceFailure.auth:
        throw Exception(
          'Authentication failed for ${maskApiKey(key)}. Check the key and try again.',
        );
      case InferenceFailure.network:
        throw Exception(
          'No network connection. Check connectivity and try again.',
        );
      case InferenceFailure.timeout:
        throw Exception(
          'Verification timed out. Check connectivity and try again.',
        );
      case InferenceFailure.rateLimited:
        throw Exception(
          'Provider rate limit reached. Wait a moment and try again.',
        );
      case InferenceFailure.unknown:
      case null:
        throw Exception('Key verification failed. Try again.');
    }
  }

  String _defaultModelFor(String provider) {
    switch (provider) {
      case 'openai':
        return 'gpt-4o-mini';
      case 'claude':
        return 'claude-3-5-haiku-20241022';
      case 'deepseek':
      case 'openrouter':
        return 'meta-llama/llama-3.3-70b-instruct';
      case 'sambanova':
        return 'Meta-Llama-3.3-70B-Instruct';
      case 'xkiro':
        return 'deepseek/deepseek-v4.1-flash';
      case 'groq':
        return 'llama-3.3-70b-versatile';
      case 'gemini':
      default:
        return 'gemini-3-flash-preview';
    }
  }

  AIProvider _mapToStorageProvider(String provider) {
    switch (provider) {
      case 'openai':
        return AIProvider.openAI;
      case 'claude':
        return AIProvider.anthropic;
      case 'deepseek':
      case 'openrouter':
        return AIProvider.deepSeek;
      case 'sambanova':
        return AIProvider.sambanova;
      case 'xkiro':
        return AIProvider.xkiro;
      case 'groq':
        return AIProvider.groq;
      case 'gemini':
      default:
        return AIProvider.gemini;
    }
  }
}
