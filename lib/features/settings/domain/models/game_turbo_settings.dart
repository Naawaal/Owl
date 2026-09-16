// language: Dart, file: game_turbo_settings.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';

/// Comprehensive settings model for the Owl MOBA AI Tactical Companion.
///
/// Encapsulates:
/// 1. General Preferences (Theme mode, interface language)
/// 2. AI Provider & Models (Cloud LLM providers and active model checkpoints)
/// 3. Assistant & Tactical AI (Live HUD/post-match mode, coaching depth, Auto/manual role, sensitivity, tactical toggles)
/// 4. Voice & Alerts (TTS voice alerts, alert priority, cooldown buffer, audio protection, haptics)
/// 5. Assistant Performance (Companion workload profiles, adaptive throttling, thermal guard, latency HUD)
/// 6. Overlay & Runtime System Compatibility
@immutable
class GameTurboSettings {
  // --- Category 1: General Preferences ---
  final ThemeMode themeMode;
  final String interfaceLanguage;

  // --- Category 2: AI Provider & Models ---
  final String activeAiProvider;
  final String activeModel;

  // --- Category 3: Assistant & Tactical AI ---
  final String assistantMode;
  final String coachingLevel;
  final String preferredRole;
  final String warningSensitivity;
  final bool explainRecommendations;
  final bool missingEnemyAlerts;
  final bool overextensionRadar;
  final bool objectiveTimers;
  final bool laneWaveAdvice;

  // --- Category 4: Voice & Alerts ---
  final bool voiceAlertsEnabled;
  final String alertPriority;
  final int speechCooldownSeconds;
  final bool avoidInterruptingGameAudio;
  final bool hapticsEnabled;

  // --- Category 5: Assistant Performance ---
  final String performanceMode;
  final bool adaptiveWorkload;
  final bool thermalProtection;
  final bool showInGameLatencyHud;

  // --- Overlay & Runtime System Integration ---
  final bool gameTurboMaster;
  final bool inGameShortcuts;
  final String shortcutEdgePosition;
  final bool performanceOptimization;
  final bool wifiSpeedBoost;
  final bool restrictFloatingNotifications;
  final bool restrictButtonsAndGestures;
  final bool guardianTacticalEngine;

  const GameTurboSettings({
    // General
    this.themeMode = ThemeMode.dark,
    this.interfaceLanguage = 'en',

    // AI Provider & Models
    this.activeAiProvider = 'gemini',
    this.activeModel = 'gemini-2.0-flash',

    // Assistant & Tactical AI
    this.assistantMode = 'live',
    this.coachingLevel = 'intermediate',
    this.preferredRole = 'auto',
    this.warningSensitivity = 'balanced',
    this.explainRecommendations = true,
    this.missingEnemyAlerts = true,
    this.overextensionRadar = true,
    this.objectiveTimers = true,
    this.laneWaveAdvice = true,

    // Voice & Alerts
    this.voiceAlertsEnabled = true,
    this.alertPriority = 'criticalOnly',
    this.speechCooldownSeconds = 8,
    this.avoidInterruptingGameAudio = true,
    this.hapticsEnabled = true,

    // Assistant Performance
    this.performanceMode = 'balanced',
    this.adaptiveWorkload = true,
    this.thermalProtection = true,
    this.showInGameLatencyHud = true,

    // Overlay & Integration
    this.gameTurboMaster = true,
    this.inGameShortcuts = true,
    this.shortcutEdgePosition = 'Top-Left',
    this.performanceOptimization = true,
    this.wifiSpeedBoost = true,
    this.restrictFloatingNotifications = true,
    this.restrictButtonsAndGestures = true,
    this.guardianTacticalEngine = true,
  });

  /// Factory default configuration calibrated for Owl MOBA AI Tactical Companion.
  static const GameTurboSettings defaultSettings = GameTurboSettings();

  GameTurboSettings copyWith({
    ThemeMode? themeMode,
    String? interfaceLanguage,
    String? activeAiProvider,
    String? activeModel,
    String? assistantMode,
    String? coachingLevel,
    String? preferredRole,
    String? warningSensitivity,
    bool? explainRecommendations,
    bool? missingEnemyAlerts,
    bool? overextensionRadar,
    bool? objectiveTimers,
    bool? laneWaveAdvice,
    bool? voiceAlertsEnabled,
    String? alertPriority,
    int? speechCooldownSeconds,
    bool? avoidInterruptingGameAudio,
    bool? hapticsEnabled,
    String? performanceMode,
    bool? adaptiveWorkload,
    bool? thermalProtection,
    bool? showInGameLatencyHud,
    bool? gameTurboMaster,
    bool? inGameShortcuts,
    String? shortcutEdgePosition,
    bool? performanceOptimization,
    bool? wifiSpeedBoost,
    bool? restrictFloatingNotifications,
    bool? restrictButtonsAndGestures,
    bool? guardianTacticalEngine,
  }) {
    return GameTurboSettings(
      themeMode: themeMode ?? this.themeMode,
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      activeAiProvider: activeAiProvider ?? this.activeAiProvider,
      activeModel: activeModel ?? this.activeModel,
      assistantMode: assistantMode ?? this.assistantMode,
      coachingLevel: coachingLevel ?? this.coachingLevel,
      preferredRole: preferredRole ?? this.preferredRole,
      warningSensitivity: warningSensitivity ?? this.warningSensitivity,
      explainRecommendations:
          explainRecommendations ?? this.explainRecommendations,
      missingEnemyAlerts: missingEnemyAlerts ?? this.missingEnemyAlerts,
      overextensionRadar: overextensionRadar ?? this.overextensionRadar,
      objectiveTimers: objectiveTimers ?? this.objectiveTimers,
      laneWaveAdvice: laneWaveAdvice ?? this.laneWaveAdvice,
      voiceAlertsEnabled: voiceAlertsEnabled ?? this.voiceAlertsEnabled,
      alertPriority: alertPriority ?? this.alertPriority,
      speechCooldownSeconds:
          speechCooldownSeconds ?? this.speechCooldownSeconds,
      avoidInterruptingGameAudio:
          avoidInterruptingGameAudio ?? this.avoidInterruptingGameAudio,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      performanceMode: performanceMode ?? this.performanceMode,
      adaptiveWorkload: adaptiveWorkload ?? this.adaptiveWorkload,
      thermalProtection: thermalProtection ?? this.thermalProtection,
      showInGameLatencyHud: showInGameLatencyHud ?? this.showInGameLatencyHud,
      gameTurboMaster: gameTurboMaster ?? this.gameTurboMaster,
      inGameShortcuts: inGameShortcuts ?? this.inGameShortcuts,
      shortcutEdgePosition: shortcutEdgePosition ?? this.shortcutEdgePosition,
      performanceOptimization:
          performanceOptimization ?? this.performanceOptimization,
      wifiSpeedBoost: wifiSpeedBoost ?? this.wifiSpeedBoost,
      restrictFloatingNotifications:
          restrictFloatingNotifications ?? this.restrictFloatingNotifications,
      restrictButtonsAndGestures:
          restrictButtonsAndGestures ?? this.restrictButtonsAndGestures,
      guardianTacticalEngine:
          guardianTacticalEngine ?? this.guardianTacticalEngine,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'interfaceLanguage': interfaceLanguage,
      'activeAiProvider': activeAiProvider,
      'activeModel': activeModel,
      'assistantMode': assistantMode,
      'coachingLevel': coachingLevel,
      'preferredRole': preferredRole,
      'warningSensitivity': warningSensitivity,
      'explainRecommendations': explainRecommendations,
      'missingEnemyAlerts': missingEnemyAlerts,
      'overextensionRadar': overextensionRadar,
      'objectiveTimers': objectiveTimers,
      'laneWaveAdvice': laneWaveAdvice,
      'voiceAlertsEnabled': voiceAlertsEnabled,
      'alertPriority': alertPriority,
      'speechCooldownSeconds': speechCooldownSeconds,
      'avoidInterruptingGameAudio': avoidInterruptingGameAudio,
      'hapticsEnabled': hapticsEnabled,
      'performanceMode': performanceMode,
      'adaptiveWorkload': adaptiveWorkload,
      'thermalProtection': thermalProtection,
      'showInGameLatencyHud': showInGameLatencyHud,
      'gameTurboMaster': gameTurboMaster,
      'inGameShortcuts': inGameShortcuts,
      'shortcutEdgePosition': shortcutEdgePosition,
      'performanceOptimization': performanceOptimization,
      'wifiSpeedBoost': wifiSpeedBoost,
      'restrictFloatingNotifications': restrictFloatingNotifications,
      'restrictButtonsAndGestures': restrictButtonsAndGestures,
      'guardianTacticalEngine': guardianTacticalEngine,
    };
  }

  factory GameTurboSettings.fromMap(Map<String, dynamic> map) {
    final themeStr = map['themeMode'] as String?;
    final theme = switch (themeStr) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    return GameTurboSettings(
      themeMode: theme,
      interfaceLanguage: map['interfaceLanguage'] as String? ?? 'en',
      activeAiProvider: map['activeAiProvider'] as String? ?? 'gemini',
      activeModel: map['activeModel'] as String? ?? 'gemini-2.0-flash',
      assistantMode: map['assistantMode'] as String? ?? 'live',
      coachingLevel: map['coachingLevel'] as String? ?? 'intermediate',
      preferredRole: map['preferredRole'] as String? ?? 'auto',
      warningSensitivity: map['warningSensitivity'] as String? ?? 'balanced',
      explainRecommendations:
          map['explainRecommendations'] as bool? ?? true,
      missingEnemyAlerts: map['missingEnemyAlerts'] as bool? ?? true,
      overextensionRadar: map['overextensionRadar'] as bool? ?? true,
      objectiveTimers: map['objectiveTimers'] as bool? ?? true,
      laneWaveAdvice: map['laneWaveAdvice'] as bool? ?? true,
      voiceAlertsEnabled: map['voiceAlertsEnabled'] as bool? ?? true,
      alertPriority: map['alertPriority'] as String? ?? 'criticalOnly',
      speechCooldownSeconds: map['speechCooldownSeconds'] as int? ?? 8,
      avoidInterruptingGameAudio:
          map['avoidInterruptingGameAudio'] as bool? ?? true,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      performanceMode: map['performanceMode'] as String? ?? 'balanced',
      adaptiveWorkload: map['adaptiveWorkload'] as bool? ?? true,
      thermalProtection: map['thermalProtection'] as bool? ?? true,
      showInGameLatencyHud: map['showInGameLatencyHud'] as bool? ?? true,
      gameTurboMaster: map['gameTurboMaster'] as bool? ?? true,
      inGameShortcuts: map['inGameShortcuts'] as bool? ?? true,
      shortcutEdgePosition:
          map['shortcutEdgePosition'] as String? ?? 'Top-Left',
      performanceOptimization:
          map['performanceOptimization'] as bool? ?? true,
      wifiSpeedBoost: map['wifiSpeedBoost'] as bool? ?? true,
      restrictFloatingNotifications:
          map['restrictFloatingNotifications'] as bool? ?? true,
      restrictButtonsAndGestures:
          map['restrictButtonsAndGestures'] as bool? ?? true,
      guardianTacticalEngine:
          map['guardianTacticalEngine'] as bool? ?? true,
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
          themeMode == other.themeMode &&
          interfaceLanguage == other.interfaceLanguage &&
          activeAiProvider == other.activeAiProvider &&
          activeModel == other.activeModel &&
          assistantMode == other.assistantMode &&
          coachingLevel == other.coachingLevel &&
          preferredRole == other.preferredRole &&
          warningSensitivity == other.warningSensitivity &&
          explainRecommendations == other.explainRecommendations &&
          missingEnemyAlerts == other.missingEnemyAlerts &&
          overextensionRadar == other.overextensionRadar &&
          objectiveTimers == other.objectiveTimers &&
          laneWaveAdvice == other.laneWaveAdvice &&
          voiceAlertsEnabled == other.voiceAlertsEnabled &&
          alertPriority == other.alertPriority &&
          speechCooldownSeconds == other.speechCooldownSeconds &&
          avoidInterruptingGameAudio == other.avoidInterruptingGameAudio &&
          hapticsEnabled == other.hapticsEnabled &&
          performanceMode == other.performanceMode &&
          adaptiveWorkload == other.adaptiveWorkload &&
          thermalProtection == other.thermalProtection &&
          showInGameLatencyHud == other.showInGameLatencyHud &&
          gameTurboMaster == other.gameTurboMaster &&
          inGameShortcuts == other.inGameShortcuts &&
          shortcutEdgePosition == other.shortcutEdgePosition &&
          performanceOptimization == other.performanceOptimization &&
          wifiSpeedBoost == other.wifiSpeedBoost &&
          restrictFloatingNotifications ==
              other.restrictFloatingNotifications &&
          restrictButtonsAndGestures == other.restrictButtonsAndGestures &&
          guardianTacticalEngine == other.guardianTacticalEngine;

  @override
  int get hashCode => Object.hashAll([
        themeMode,
        interfaceLanguage,
        activeAiProvider,
        activeModel,
        assistantMode,
        coachingLevel,
        preferredRole,
        warningSensitivity,
        explainRecommendations,
        missingEnemyAlerts,
        overextensionRadar,
        objectiveTimers,
        laneWaveAdvice,
        voiceAlertsEnabled,
        alertPriority,
        speechCooldownSeconds,
        avoidInterruptingGameAudio,
        hapticsEnabled,
        performanceMode,
        adaptiveWorkload,
        thermalProtection,
        showInGameLatencyHud,
        gameTurboMaster,
        inGameShortcuts,
        shortcutEdgePosition,
        performanceOptimization,
        wifiSpeedBoost,
        restrictFloatingNotifications,
        restrictButtonsAndGestures,
        guardianTacticalEngine,
      ]);
}
