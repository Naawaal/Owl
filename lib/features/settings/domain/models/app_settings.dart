// language: Dart, file: app_settings.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:owl/features/ai_coach/ai_coach.dart';

/// Immutable user application preferences and hardware feedback configuration.
@immutable
class AppSettings {
  /// Theme mode (system default, light, or dark).
  final ThemeMode themeMode;

  /// Whether countdown alerts and tactical chimes play sound.
  final bool soundEnabled;

  /// Whether countdown warning and urgent states trigger haptic vibration pulses.
  final bool hapticsEnabled;

  /// Currently selected game profile ID (e.g. 'wild_rift', 'mlbb', 'pokemon_unite').
  final String selectedGameId;

  /// Active AI provider selected for tactical advice.
  final AIProvider activeAiProvider;

  /// Global transparency level of the floating HUD overlay (0.2 - 1.0).
  final double overlayOpacity;

  /// Global scaling multiplier of the floating HUD overlay (0.6 - 1.5).
  final double overlayScale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.selectedGameId = 'wild_rift',
    this.activeAiProvider = AIProvider.gemini,
    this.overlayOpacity = 0.85,
    this.overlayScale = 1.0,
  });

  /// Factory default settings configuration.
  static const AppSettings defaultSettings = AppSettings();

  /// Creates a copy of this [AppSettings] with specified fields replaced.
  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? selectedGameId,
    AIProvider? activeAiProvider,
    double? overlayOpacity,
    double? overlayScale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      selectedGameId: selectedGameId ?? this.selectedGameId,
      activeAiProvider: activeAiProvider ?? this.activeAiProvider,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      overlayScale: overlayScale ?? this.overlayScale,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'selectedGameId': selectedGameId,
      'activeAiProvider': activeAiProvider.name,
      'overlayOpacity': overlayOpacity,
      'overlayScale': overlayScale,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final themeModeStr = map['themeMode'] as String?;
    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return AppSettings(
      themeMode: themeMode,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      selectedGameId: map['selectedGameId'] as String? ?? 'wild_rift',
      activeAiProvider: AIProvider.values.firstWhere(
        (p) => p.name == map['activeAiProvider'],
        orElse: () => AIProvider.gemini,
      ),
      overlayOpacity: (map['overlayOpacity'] as num?)?.toDouble() ?? 0.85,
      overlayScale: (map['overlayScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      AppSettings.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          soundEnabled == other.soundEnabled &&
          hapticsEnabled == other.hapticsEnabled &&
          selectedGameId == other.selectedGameId &&
          activeAiProvider == other.activeAiProvider &&
          overlayOpacity == other.overlayOpacity &&
          overlayScale == other.overlayScale;

  @override
  int get hashCode => Object.hash(
        themeMode,
        soundEnabled,
        hapticsEnabled,
        selectedGameId,
        activeAiProvider,
        overlayOpacity,
        overlayScale,
      );

  @override
  String toString() =>
      'AppSettings(theme: ${themeMode.name}, game: $selectedGameId, provider: ${activeAiProvider.name}, sound: $soundEnabled, haptics: $hapticsEnabled)';
}
