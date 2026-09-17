// language: Dart, file: packages/owl_storage/lib/storage/secure_storage_service.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owl_core/owl_core.dart';

/// Supported Bring-Your-Own-Key (BYOK) AI providers for Owl on-device tactical coaching.
enum AIProvider {
  gemini('Gemini', 'Google Gemini Flash / Pro'),
  openAI('OpenAI', 'OpenAI GPT-4o / Mini'),
  anthropic('Anthropic', 'Anthropic Claude 3.5 Sonnet'),
  deepSeek('DeepSeek', 'DeepSeek-V3 / R1'),
  sambanova('SambaNova', 'SambaNova Systems SN40L'),
  xkiro('xKiro', 'xKiro Unified AI Gateway'),
  groq('Groq', 'Groq Ultra-fast LPU');

  final String label;
  final String description;

  const AIProvider(this.label, this.description);

  /// Key identifier used in secure storage
  String get storageKey => 'owl_byok_${name.toLowerCase()}';
}

/// Provider for raw [FlutterSecureStorage] configured with hardened platform encryption.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
});

/// Provider for [SecureStorageService].
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(storage);
});

/// Service managing sensitive BYOK API keys via Hardware Keystore / Keyring.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  /// Retrieve the API key for a specified [AIProvider]. Returns null if not set.
  Future<String?> getApiKey(AIProvider provider) async {
    try {
      final key = await _storage.read(key: provider.storageKey);
      if (key == null || key.trim().isEmpty) {
        return null;
      }
      return key.trim();
    } catch (e) {
      throw StorageException.readFailed(provider.storageKey, e);
    }
  }

  /// Persist an API key securely for a specified [AIProvider].
  Future<void> saveApiKey(AIProvider provider, String key) async {
    try {
      final sanitized = key.trim();
      if (sanitized.isEmpty) {
        await deleteApiKey(provider);
        return;
      }
      await _storage.write(
        key: provider.storageKey,
        value: sanitized,
      );
    } catch (e) {
      throw StorageException.writeFailed(provider.storageKey, e);
    }
  }

  /// Remove the stored API key for a specified [AIProvider].
  Future<void> deleteApiKey(AIProvider provider) async {
    try {
      await _storage.delete(key: provider.storageKey);
    } catch (e) {
      throw StorageException.deleteFailed(provider.storageKey, e);
    }
  }

  /// Checks whether an active API key is set for the given provider.
  Future<bool> hasApiKey(AIProvider provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }

  /// Returns a map of all providers and whether an API key is stored.
  Future<Map<AIProvider, bool>> getProviderStatus() async {
    final status = <AIProvider, bool>{};
    for (final provider in AIProvider.values) {
      status[provider] = await hasApiKey(provider);
    }
    return status;
  }

  /// Purges all BYOK keys from secure hardware storage.
  Future<void> clearAllApiKeys() async {
    try {
      for (final provider in AIProvider.values) {
        await _storage.delete(key: provider.storageKey);
      }
    } catch (e) {
      throw StorageException(
        message: 'Failed to clear secure API keys from hardware storage.',
        code: 'SECURE_STORAGE_CLEAR_FAILED',
        details: e,
      );
    }
  }
}
