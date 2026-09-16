// language: Dart, file: settings_provider.dart, target: Flutter / Owl MOBA Companion
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central reactive provider for Owl MOBA companion settings.
final gameTurboSettingsProvider =
    StateNotifierProvider<GameTurboSettingsNotifier, GameTurboSettings>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    // Graceful fallback for tests or uninitialized scopes
  }
  return GameTurboSettingsNotifier(prefs);
});

/// StateNotifier that manages and persists all Owl tactical settings.
class GameTurboSettingsNotifier extends StateNotifier<GameTurboSettings> {
  final SharedPreferences? _prefs;
  static const String _storageKey = 'owl_game_turbo_settings_v2';

  GameTurboSettingsNotifier(this._prefs)
      : super(_loadInitialSettings(_prefs));

  static GameTurboSettings _loadInitialSettings(SharedPreferences? prefs) {
    if (prefs == null) return GameTurboSettings.defaultSettings;
    try {
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return GameTurboSettings.fromMap(map);
      }
    } catch (_) {
      // Fallback on corrupt json
    }
    return GameTurboSettings.defaultSettings;
  }

  Future<void> _persist(GameTurboSettings next) async {
    state = next;
    if (_prefs == null) return;
    try {
      final jsonStr = jsonEncode(next.toMap());
      await _prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  // --- Category 1: General Preferences ---

  void setThemeMode(ThemeMode mode) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(themeMode: mode));
  }

  void setInterfaceLanguage(String languageCode) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(interfaceLanguage: languageCode));
  }

  // --- Category 2: AI Provider & Models ---

  void setActiveAiProvider(String provider) {
    HapticFeedback.selectionClick();
    String defaultModel;
    switch (provider) {
      case 'openai':
        defaultModel = 'gpt-4o-mini';
        break;
      case 'claude':
        defaultModel = 'claude-3-5-haiku';
        break;
      case 'deepseek':
        defaultModel = 'deepseek/deepseek-chat';
        break;
      case 'gemini':
      default:
        defaultModel = 'gemini-2.0-flash';
        break;
    }
    _persist(state.copyWith(
      activeAiProvider: provider,
      activeModel: defaultModel,
    ));
  }

  void setActiveModel(String model) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(activeModel: model));
  }

  // --- Category 3: Assistant & Tactical AI ---

  void setAssistantMode(String mode) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(assistantMode: mode));
  }

  void setCoachingLevel(String level) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(coachingLevel: level));
  }

  void setPreferredRole(String role) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(preferredRole: role));
  }

  void setWarningSensitivity(String sensitivity) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(warningSensitivity: sensitivity));
  }

  void toggleExplainRecommendations(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(explainRecommendations: value));
  }

  void toggleMissingEnemyAlerts(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(missingEnemyAlerts: value));
  }

  void toggleOverextensionRadar(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(overextensionRadar: value));
  }

  void toggleObjectiveTimers(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(objectiveTimers: value));
  }

  void toggleLaneWaveAdvice(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(laneWaveAdvice: value));
  }

  // --- Category 4: Voice & Alerts ---

  void toggleVoiceAlerts(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(voiceAlertsEnabled: value));
  }

  void setAlertPriority(String priority) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(alertPriority: priority));
  }

  void setSpeechCooldownSeconds(int seconds) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(speechCooldownSeconds: seconds));
  }

  void toggleAvoidInterruptingGameAudio(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(avoidInterruptingGameAudio: value));
  }

  void toggleHaptics(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(hapticsEnabled: value));
  }

  // --- Category 5: Assistant Performance ---

  void setPerformanceMode(String mode) {
    HapticFeedback.selectionClick();
    final isPerf = mode != 'saver';
    _persist(state.copyWith(
      performanceMode: mode,
      performanceOptimization: isPerf,
    ));
  }

  void toggleAdaptiveWorkload(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(adaptiveWorkload: value));
  }

  void toggleThermalProtection(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(thermalProtection: value));
  }

  void toggleShowInGameLatencyHud(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(showInGameLatencyHud: value));
  }

  // --- Overlay & Runtime Compatibility ---

  void toggleGameTurboMaster(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gameTurboMaster: value));
  }

  void toggleInGameShortcuts(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(inGameShortcuts: value));
  }

  void setShortcutEdgePosition(String position) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(shortcutEdgePosition: position));
  }

  void togglePerformanceOptimization(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(performanceOptimization: value));
  }

  void toggleWifiSpeedBoost(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(wifiSpeedBoost: value));
  }

  void toggleRestrictFloatingNotifications(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(restrictFloatingNotifications: value));
  }

  void toggleRestrictButtonsAndGestures(bool value) {
    HapticFeedback.selectionClick();
    if (value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _persist(state.copyWith(restrictButtonsAndGestures: value));
  }

  void toggleGuardianTacticalEngine(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(guardianTacticalEngine: value));
  }

  void resetToDefaults() {
    HapticFeedback.mediumImpact();
    _persist(GameTurboSettings.defaultSettings);
  }
}

/// Provider managing secure API keys per cloud provider with format validation.
final apiKeyManagerProvider = Provider<ApiKeyManager>((ref) {
  SecureStorageService? secureStorage;
  try {
    secureStorage = ref.watch(secureStorageServiceProvider);
  } catch (_) {}
  return ApiKeyManager(secureStorage);
});

/// Service class managing secure API keys and validation logic.
class ApiKeyManager {
  final SecureStorageService? _secureStorage;
  static final Map<String, String> _memoryCache = {};

  ApiKeyManager(this._secureStorage);

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
        if (sanitized.length < 15) {
          return 'Invalid API key length for OpenRouter/DeepSeek';
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

  /// Simulates an authenticated ping to verify key latency.
  Future<int> testConnection(String provider, String key) async {
    final validationError = validateKeyFormat(provider, key);
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Simulate network round-trip handshake
    await Future.delayed(const Duration(milliseconds: 320));
    final baseLatency = switch (provider) {
      'gemini' => 38,
      'openai' => 110,
      'claude' => 135,
      _ => 90,
    };
    return baseLatency + (DateTime.now().millisecond % 15);
  }

  AIProvider _mapToStorageProvider(String provider) {
    switch (provider) {
      case 'openai':
        return AIProvider.openAI;
      case 'claude':
        return AIProvider.anthropic;
      case 'deepseek':
        return AIProvider.deepSeek;
      case 'gemini':
      default:
        return AIProvider.gemini;
    }
  }
}
