// language: Dart, file: settings_provider.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/overlay/services/mode_ritual_coordinator.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:owl/features/settings/data/api_key_manager.dart';
export 'package:owl/features/settings/presentation/model_discovery_provider.dart';

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
      case 'openrouter':
        defaultModel = 'meta-llama/llama-3.3-70b-instruct';
        break;
      case 'sambanova':
        defaultModel = 'Meta-Llama-3.3-70B-Instruct';
        break;
      case 'xkiro':
        defaultModel = 'deepseek/deepseek-v4.1-flash';
        break;
      case 'groq':
        defaultModel = 'llama-3.3-70b-versatile';
        break;
      case 'gemini':
      default:
        defaultModel = 'gemini-3-flash-preview';
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

  void toggleShowOnlyFreeModels(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(showOnlyFreeModels: value));
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
    HapticHelper.globalEnabled = value;
    if (value) {
      HapticFeedback.selectionClick();
    }
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

  Future<ModeRitualResult?> togglePerformanceOptimization(
    bool value, {
    int? gameTargetFps,
  }) async {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(performanceOptimization: value));
    return _applyModeWithRitual(value, gameTargetFps: gameTargetFps);
  }

  /// Hardware apply + portable focus ritual (DND / Wi‑Fi / immersion).
  Future<ModeRitualResult?> _applyModeWithRitual(
    bool isPerf, {
    int? gameTargetFps,
  }) async {
    await applyPersistedHardwareState(gameTargetFps: gameTargetFps);
    final target =
        isPerf ? resolvePerformanceTargetFps(gameTargetFps: gameTargetFps) : 60;
    try {
      return await ModeRitualCoordinator.instance.apply(
        prefs: _prefs,
        settings: state,
        isPerformance: isPerf,
        targetFps: target,
        patch: (fn) {
          // Silent patch — haptic already fired on toggle.
          _persist(fn(state));
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Public ritual re-entry for UI that wants the toast message.
  Future<ModeRitualResult?> runModeRitual({
    required bool isPerformance,
    int? gameTargetFps,
  }) {
    return _applyModeWithRitual(isPerformance, gameTargetFps: gameTargetFps);
  }

  /// Performance ceiling: active game target → gpuFpsTarget → 120.
  int resolvePerformanceTargetFps({int? gameTargetFps}) {
    if (gameTargetFps != null && gameTargetFps > 0) return gameTargetFps;
    final fromGpu = int.tryParse(state.gpuFpsTarget.trim());
    if (fromGpu != null && fromGpu > 0) return fromGpu;
    return 120;
  }

  /// Re-read settings from SharedPreferences (overlay isolate after shown).
  void reloadFromDisk() {
    if (_prefs == null) return;
    state = _loadInitialSettings(_prefs);
  }

  /// Apply an immediate mode hint before prefs reload finishes.
  void applySessionModeHint(bool isPerformance) {
    if (state.performanceOptimization == isPerformance) return;
    state = state.copyWith(performanceOptimization: isPerformance);
  }

  /// Re-applies persisted hardware-affecting state to the FPS tracker and
  /// the native layer. Invoked once at boot (see main.dart) and on every
  /// performance toggle. Never throws: channel errors are contained, so
  /// tests run platform-free with zero native leakage.
  Future<void> applyPersistedHardwareState({int? gameTargetFps}) async {
    HapticHelper.globalEnabled = state.hapticsEnabled;
    final isPerf = state.performanceOptimization;
    final target =
        isPerf ? resolvePerformanceTargetFps(gameTargetFps: gameTargetFps) : 60;
    RealTimeFpsTracker.instance.setModeTarget(target);
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _gamesChannel.invokeMethod('setPerformanceMode', {
        'isPerformance': isPerf,
        'targetFps': target,
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

  Future<void> toggleGuardianVisionEnabled(bool value) async {
    HapticFeedback.selectionClick();
    if (value) {
      try {
        final hasPerm =
            await _gamesChannel.invokeMethod<bool>('hasScreenCapturePermission') ??
                false;
        if (!hasPerm) {
          await _gamesChannel
              .invokeMethod<bool>('requestScreenCapturePermission');
        }
        await _gamesChannel
            .invokeMethod('setGuardianVisionEnabled', {'enabled': true});
      } catch (_) {}
    } else {
      try {
        await _gamesChannel
            .invokeMethod('setGuardianVisionEnabled', {'enabled': false});
      } catch (_) {}
    }
    _persist(state.copyWith(guardianVisionEnabled: value));
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

