// language: Dart, file: settings_provider.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl_network/owl_network.dart';
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

/// Typed outcome of a settings persist attempt.
enum SettingsPersistResult { ok, storageUnavailable, writeFailed }

/// StateNotifier that manages and persists all Owl tactical settings.
class GameTurboSettingsNotifier extends StateNotifier<GameTurboSettings> {
  final SharedPreferences? _prefs;
  static const String _storageKey = 'owl_game_turbo_settings_v2';
  static const int _schemaVersion = 3;
  static const MethodChannel _gamesChannel = MethodChannel('com.example.owl/games');

  /// Set by the settings UI to surface write failures (snackbar/toast).
  void Function(String message)? onPersistError;

  String? _lastPersistError;

  /// Last persist failure message, if any. Null when the last write succeeded.
  String? get lastPersistError => _lastPersistError;

  GameTurboSettingsNotifier(this._prefs)
      : super(_loadInitialSettings(_prefs));

  static GameTurboSettings _loadInitialSettings(SharedPreferences? prefs) {
    if (prefs == null) return GameTurboSettings.defaultSettings;
    try {
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return GameTurboSettings.defaultSettings;
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded['version'] == _schemaVersion &&
            decoded['settings'] is Map) {
          return GameTurboSettings.fromMap(
            Map<String, dynamic>.from(decoded['settings'] as Map),
          );
        }
        if (!decoded.containsKey('version')) {
          // Legacy unversioned v2 payload: accept once, rewrite on next write.
          return GameTurboSettings.fromMap(decoded);
        }
        // Unknown or newer schema: defaults, never partial application.
      }
    } catch (_) {
      // Fallback on corrupt json
    }
    return GameTurboSettings.defaultSettings;
  }

  Future<bool> _persist(GameTurboSettings next) async {
    state = next;
    _lastPersistError = null;
    if (_prefs == null) {
      _reportPersistError(
        'Settings storage unavailable — change kept for this session only.',
      );
      return false;
    }
    try {
      final envelope = {
        'version': _schemaVersion,
        'settings': next.toMap(),
      };
      final ok = await _prefs.setString(_storageKey, jsonEncode(envelope));
      if (!ok) {
        _reportPersistError(
          'Could not save settings — change kept for this session only.',
        );
        return false;
      }
      return true;
    } catch (_) {
      _reportPersistError(
        'Could not save settings — change kept for this session only.',
      );
      return false;
    }
  }

  void _reportPersistError(String message) {
    _lastPersistError = message;
    try {
      onPersistError?.call(message);
    } catch (_) {}
  }

  /// Clears the last persist error, if any.
  void clearPersistError() {
    _lastPersistError = null;
  }

  /// Rewrites a legacy unversioned payload in the v3 envelope, preserving
  /// current values. Idempotent: newer, current, and corrupt payloads are
  /// left untouched.
  Future<void> migrateLegacyPayloadIfNeeded() async {
    if (_prefs == null) return;
    try {
      final raw = _prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> &&
          !decoded.containsKey('version') &&
          decoded.containsKey('activeAiProvider')) {
        await _persist(state);
      }
    } catch (_) {}
  }

  // --- Category 1: General Preferences ---
  // Note: theme is owned by themeModeProvider (owl_theme_mode), not this blob.

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
    // Fire-and-forget is safe: errors are contained inside.
    unawaited(applyPersistedHardwareState());
  }

  /// Re-applies persisted hardware-affecting state to the FPS tracker and
  /// the native layer. Invoked once at boot (see main.dart) and on every
  /// performance toggle. Never throws: channel errors are contained, so
  /// tests run platform-free with zero native leakage.
  Future<void> applyPersistedHardwareState() async {
    final isPerf = state.performanceOptimization;
    RealTimeFpsTracker.instance.setModeTarget(isPerf ? 120 : 60);
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _gamesChannel.invokeMethod('setPerformanceMode', {
        'isPerformance': isPerf,
        'targetFps': isPerf ? 120 : 60,
      });
    } catch (_) {}
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

  // --- GPU Settings Screen (global profile) ---

  void setGpuFpsTarget(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuFpsTarget: value));
  }

  void setGpuResolution(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuResolution: value));
  }

  void setGpuMsaa(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuMsaa: value));
  }

  void setGpuAniso(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuAniso: value));
  }

  void setGpuColorStyle(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuColorStyle: value));
  }

  void toggleGpuDynamicContrast(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuDynamicContrast: value));
  }

  void toggleGpuHorizonBrightness(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuHorizonBrightness: value));
  }

  void setGpuTouchSampling(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuTouchSampling: value));
  }

  void setGpuSkillPrecision(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuSkillPrecision: value));
  }

  void setGpuMistouchRejection(String value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuMistouchRejection: value));
  }

  void toggleGpuThreatRadar(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuThreatRadar: value));
  }

  void toggleGpuObjectiveRings(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuObjectiveRings: value));
  }

  void toggleGpuSmiteThreshold(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(gpuSmiteThreshold: value));
  }

  /// Resets only the GPU settings screen profile to defaults.
  void resetGpuSettings() {
    HapticFeedback.mediumImpact();
    _persist(state.copyWith(
      gpuFpsTarget: '120',
      gpuResolution: '1080p',
      gpuMsaa: '4X',
      gpuAniso: '8X',
      gpuColorStyle: 'Vibrant HDR',
      gpuDynamicContrast: true,
      gpuHorizonBrightness: true,
      gpuTouchSampling: '720Hz Ultra',
      gpuSkillPrecision: 'Extreme',
      gpuMistouchRejection: 'Medium',
      gpuThreatRadar: true,
      gpuObjectiveRings: true,
      gpuSmiteThreshold: true,
    ));
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
        return 'deepseek/deepseek-chat';
      case 'gemini':
      default:
        return 'gemini-2.0-flash';
    }
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
