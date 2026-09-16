// language: Dart, file: settings_provider.dart, target: Flutter / Owl Game Turbo
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central reactive provider for Xiaomi Game Turbo settings.
final gameTurboSettingsProvider =
    StateNotifierProvider<GameTurboSettingsNotifier, GameTurboSettings>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    // Graceful fallback for test environments or uninitialized scopes
  }
  return GameTurboSettingsNotifier(prefs);
});

/// StateNotifier that manages and persists all Game Turbo application settings.
class GameTurboSettingsNotifier extends StateNotifier<GameTurboSettings> {
  final SharedPreferences? _prefs;
  static const String _storageKey = 'owl_game_turbo_settings_v1';

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

  // --- Category 1: General Settings ---

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

  void toggleContentRecommendations(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(contentRecommendations: value));
  }

  void toggleHideGamesFromHomeScreen(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(hideGamesFromHomeScreen: value));
  }

  // --- Category 2: Performance Mode ---

  void togglePerformanceOptimization(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(performanceOptimization: value));
  }

  void toggleWifiSpeedBoost(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(wifiSpeedBoost: value));
  }

  void toggleAggressiveMemoryCleanup(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(aggressiveMemoryCleanup: value));
  }

  void toggleSpatialAudio(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(spatialAudio: value));
  }

  // --- Category 3: Game DND ---

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

  void toggleAnswerCallsHandsFree(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(answerCallsHandsFree: value));
  }

  // --- Category 4: Guardian AI Core ---

  void toggleGuardianTacticalEngine(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(guardianTacticalEngine: value));
  }

  void setAiInferenceBackend(String backend) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(aiInferenceBackend: backend));
  }

  void toggleTacticalAudioCallouts(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(tacticalAudioCallouts: value));
  }

  void toggleEnemyMissingRadar(bool value) {
    HapticFeedback.selectionClick();
    _persist(state.copyWith(enemyMissingRadar: value));
  }

  void resetToDefaults() {
    HapticFeedback.mediumImpact();
    _persist(GameTurboSettings.defaultSettings);
  }
}
