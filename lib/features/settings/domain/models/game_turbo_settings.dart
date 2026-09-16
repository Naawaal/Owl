// language: Dart, file: game_turbo_settings.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/foundation.dart';

/// Immutable model representing Xiaomi HyperOS Game Turbo application settings.
///
/// Encapsulates all 4 core categories:
/// 1. General Settings (Game Turbo Master, Shortcuts, Edge Anchor, Content Recs, Hide from Home)
/// 2. Performance Mode (Optimization, Wi-Fi Boost, Memory Purge, Spatial Audio)
/// 3. Game DND (Restrict Floating, Restrict Buttons/Gestures, Hands-free Calls)
/// 4. Guardian AI Core (Tactical Engine, Inference Backend, Voice Callouts, Missing Radar)
@immutable
class GameTurboSettings {
  // --- Category 1: General Settings ---
  final bool gameTurboMaster;
  final bool inGameShortcuts;
  final String shortcutEdgePosition;
  final bool contentRecommendations;
  final bool hideGamesFromHomeScreen;

  // --- Category 2: Performance Mode ---
  final bool performanceOptimization;
  final bool wifiSpeedBoost;
  final bool aggressiveMemoryCleanup;
  final bool spatialAudio;

  // --- Category 3: Game DND ---
  final bool restrictFloatingNotifications;
  final bool restrictButtonsAndGestures;
  final bool answerCallsHandsFree;

  // --- Category 4: Guardian AI Core ---
  final bool guardianTacticalEngine;
  final String aiInferenceBackend;
  final bool tacticalAudioCallouts;
  final bool enemyMissingRadar;

  const GameTurboSettings({
    this.gameTurboMaster = true,
    this.inGameShortcuts = true,
    this.shortcutEdgePosition = 'Top-Left',
    this.contentRecommendations = true,
    this.hideGamesFromHomeScreen = false,
    this.performanceOptimization = true,
    this.wifiSpeedBoost = true,
    this.aggressiveMemoryCleanup = true,
    this.spatialAudio = true,
    this.restrictFloatingNotifications = true,
    this.restrictButtonsAndGestures = true,
    this.answerCallsHandsFree = true,
    this.guardianTacticalEngine = true,
    this.aiInferenceBackend = 'Local NPU',
    this.tacticalAudioCallouts = true,
    this.enemyMissingRadar = true,
  });

  /// Factory default configuration calibrated for Xiaomi Game Turbo 2026.
  static const GameTurboSettings defaultSettings = GameTurboSettings();

  GameTurboSettings copyWith({
    bool? gameTurboMaster,
    bool? inGameShortcuts,
    String? shortcutEdgePosition,
    bool? contentRecommendations,
    bool? hideGamesFromHomeScreen,
    bool? performanceOptimization,
    bool? wifiSpeedBoost,
    bool? aggressiveMemoryCleanup,
    bool? spatialAudio,
    bool? restrictFloatingNotifications,
    bool? restrictButtonsAndGestures,
    bool? answerCallsHandsFree,
    bool? guardianTacticalEngine,
    String? aiInferenceBackend,
    bool? tacticalAudioCallouts,
    bool? enemyMissingRadar,
  }) {
    return GameTurboSettings(
      gameTurboMaster: gameTurboMaster ?? this.gameTurboMaster,
      inGameShortcuts: inGameShortcuts ?? this.inGameShortcuts,
      shortcutEdgePosition: shortcutEdgePosition ?? this.shortcutEdgePosition,
      contentRecommendations:
          contentRecommendations ?? this.contentRecommendations,
      hideGamesFromHomeScreen:
          hideGamesFromHomeScreen ?? this.hideGamesFromHomeScreen,
      performanceOptimization:
          performanceOptimization ?? this.performanceOptimization,
      wifiSpeedBoost: wifiSpeedBoost ?? this.wifiSpeedBoost,
      aggressiveMemoryCleanup:
          aggressiveMemoryCleanup ?? this.aggressiveMemoryCleanup,
      spatialAudio: spatialAudio ?? this.spatialAudio,
      restrictFloatingNotifications:
          restrictFloatingNotifications ?? this.restrictFloatingNotifications,
      restrictButtonsAndGestures:
          restrictButtonsAndGestures ?? this.restrictButtonsAndGestures,
      answerCallsHandsFree: answerCallsHandsFree ?? this.answerCallsHandsFree,
      guardianTacticalEngine:
          guardianTacticalEngine ?? this.guardianTacticalEngine,
      aiInferenceBackend: aiInferenceBackend ?? this.aiInferenceBackend,
      tacticalAudioCallouts:
          tacticalAudioCallouts ?? this.tacticalAudioCallouts,
      enemyMissingRadar: enemyMissingRadar ?? this.enemyMissingRadar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameTurboMaster': gameTurboMaster,
      'inGameShortcuts': inGameShortcuts,
      'shortcutEdgePosition': shortcutEdgePosition,
      'contentRecommendations': contentRecommendations,
      'hideGamesFromHomeScreen': hideGamesFromHomeScreen,
      'performanceOptimization': performanceOptimization,
      'wifiSpeedBoost': wifiSpeedBoost,
      'aggressiveMemoryCleanup': aggressiveMemoryCleanup,
      'spatialAudio': spatialAudio,
      'restrictFloatingNotifications': restrictFloatingNotifications,
      'restrictButtonsAndGestures': restrictButtonsAndGestures,
      'answerCallsHandsFree': answerCallsHandsFree,
      'guardianTacticalEngine': guardianTacticalEngine,
      'aiInferenceBackend': aiInferenceBackend,
      'tacticalAudioCallouts': tacticalAudioCallouts,
      'enemyMissingRadar': enemyMissingRadar,
    };
  }

  factory GameTurboSettings.fromMap(Map<String, dynamic> map) {
    return GameTurboSettings(
      gameTurboMaster: map['gameTurboMaster'] as bool? ?? true,
      inGameShortcuts: map['inGameShortcuts'] as bool? ?? true,
      shortcutEdgePosition:
          map['shortcutEdgePosition'] as String? ?? 'Top-Left',
      contentRecommendations:
          map['contentRecommendations'] as bool? ?? true,
      hideGamesFromHomeScreen:
          map['hideGamesFromHomeScreen'] as bool? ?? false,
      performanceOptimization:
          map['performanceOptimization'] as bool? ?? true,
      wifiSpeedBoost: map['wifiSpeedBoost'] as bool? ?? true,
      aggressiveMemoryCleanup:
          map['aggressiveMemoryCleanup'] as bool? ?? true,
      spatialAudio: map['spatialAudio'] as bool? ?? true,
      restrictFloatingNotifications:
          map['restrictFloatingNotifications'] as bool? ?? true,
      restrictButtonsAndGestures:
          map['restrictButtonsAndGestures'] as bool? ?? true,
      answerCallsHandsFree: map['answerCallsHandsFree'] as bool? ?? true,
      guardianTacticalEngine:
          map['guardianTacticalEngine'] as bool? ?? true,
      aiInferenceBackend: map['aiInferenceBackend'] as String? ?? 'Local NPU',
      tacticalAudioCallouts:
          map['tacticalAudioCallouts'] as bool? ?? true,
      enemyMissingRadar: map['enemyMissingRadar'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory GameTurboSettings.fromJson(Map<String, dynamic> json) =>
      GameTurboSettings.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTurboSettings &&
          runtimeType == other.runtimeType &&
          gameTurboMaster == other.gameTurboMaster &&
          inGameShortcuts == other.inGameShortcuts &&
          shortcutEdgePosition == other.shortcutEdgePosition &&
          contentRecommendations == other.contentRecommendations &&
          hideGamesFromHomeScreen == other.hideGamesFromHomeScreen &&
          performanceOptimization == other.performanceOptimization &&
          wifiSpeedBoost == other.wifiSpeedBoost &&
          aggressiveMemoryCleanup == other.aggressiveMemoryCleanup &&
          spatialAudio == other.spatialAudio &&
          restrictFloatingNotifications ==
              other.restrictFloatingNotifications &&
          restrictButtonsAndGestures == other.restrictButtonsAndGestures &&
          answerCallsHandsFree == other.answerCallsHandsFree &&
          guardianTacticalEngine == other.guardianTacticalEngine &&
          aiInferenceBackend == other.aiInferenceBackend &&
          tacticalAudioCallouts == other.tacticalAudioCallouts &&
          enemyMissingRadar == other.enemyMissingRadar;

  @override
  int get hashCode => Object.hashAll([
        gameTurboMaster,
        inGameShortcuts,
        shortcutEdgePosition,
        contentRecommendations,
        hideGamesFromHomeScreen,
        performanceOptimization,
        wifiSpeedBoost,
        aggressiveMemoryCleanup,
        spatialAudio,
        restrictFloatingNotifications,
        restrictButtonsAndGestures,
        answerCallsHandsFree,
        guardianTacticalEngine,
        aiInferenceBackend,
        tacticalAudioCallouts,
        enemyMissingRadar,
      ]);
}
