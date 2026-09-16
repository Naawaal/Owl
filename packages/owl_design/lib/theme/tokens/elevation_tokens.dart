// language: Dart, file: elevation_tokens.dart, target: Flutter / Owl MOBA HUD
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';

/// ============================================================================
/// ELEVATION & GLOW TOKENS
/// Neon tactical blooms, danger telemetry glows, and glassmorphic blur filters.
/// Replaces generic Material drop-shadows with sharp HUD depth.
/// ============================================================================
abstract final class ElevationTokens {
  // Glassmorphic Backdrop Blur Constants
  static const double glassSigmaX = 10.0;
  static const double glassSigmaY = 10.0;
  static const double glassSigmaDense = 16.0;
  static const double glassSigmaSubtle = 6.0;

  /// Default BackdropFilter image filter for tactical glass panels.
  static ui.ImageFilter get glassFilter => ui.ImageFilter.blur(
        sigmaX: glassSigmaX,
        sigmaY: glassSigmaY,
      );

  /// Dense backdrop filter for high-contrast modal overlays.
  static ui.ImageFilter get glassFilterDense => ui.ImageFilter.blur(
        sigmaX: glassSigmaDense,
        sigmaY: glassSigmaDense,
      );

  /// Subtle backdrop filter for fast-scrolling HUD pills.
  static ui.ImageFilter get glassFilterSubtle => ui.ImageFilter.blur(
        sigmaX: glassSigmaSubtle,
        sigmaY: glassSigmaSubtle,
      );

  // Subtle Border Shadow (1px pseudo-border for deep surfaces)
  static const BoxShadow subtleBorder = BoxShadow(
    color: Color(0x1AF8FAFC), // 10% Cool White
    blurRadius: 1.0,
    spreadRadius: 0.0,
  );

  // Floating Card Ambient Shadow
  static const BoxShadow cardAmbient = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 12.0,
    offset: Offset(0, 4),
  );

  // Tactical Neon Cyan Glows
  static const BoxShadow glowCyan = BoxShadow(
    color: Color(0x5900F5D4), // ~35% Neon Cyan
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow glowCyanSubtle = BoxShadow(
    color: Color(0x2600F5D4), // ~15% Neon Cyan
    blurRadius: 8.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow glowCyanIntense = BoxShadow(
    color: Color(0x9900F5D4), // ~60% Neon Cyan
    blurRadius: 16.0,
    spreadRadius: 1.0,
  );

  // Electric Purple Glows
  static const BoxShadow glowPurple = BoxShadow(
    color: Color(0x597928CA), // ~35% Electric Purple
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow glowPurpleSubtle = BoxShadow(
    color: Color(0x267928CA),
    blurRadius: 8.0,
    spreadRadius: 0.0,
  );

  // Danger Red Glow (Urgent timers, low HP, critical cooldowns)
  static const BoxShadow glowDanger = BoxShadow(
    color: Color(0x66FF453A), // ~40% Alert Crimson
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow glowDangerIntense = BoxShadow(
    color: Color(0x99FF453A), // ~60% Alert Crimson
    blurRadius: 16.0,
    spreadRadius: 1.5,
  );

  // Amber Warning Glow (Objectives spawning soon, warning states)
  static const BoxShadow glowWarning = BoxShadow(
    color: Color(0x59FF9F0A), // ~35% Tactical Amber
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  // Emerald Green Glow (Active buff, ultimate ready, victory state)
  static const BoxShadow glowSuccess = BoxShadow(
    color: Color(0x5930D158), // ~35% Emerald Live
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  // Pre-composed Shadow Arrays for Widgets
  static const List<BoxShadow> glassCardShadows = [
    subtleBorder,
    cardAmbient,
  ];

  static const List<BoxShadow> cyanActiveShadows = [
    subtleBorder,
    glowCyan,
  ];

  static const List<BoxShadow> dangerUrgentShadows = [
    subtleBorder,
    glowDanger,
  ];

  static const List<BoxShadow> warningShadows = [
    subtleBorder,
    glowWarning,
  ];

  // Console Treatments (Game Space Console & Toolbox provenance)
  static const BoxShadow playWingSide = BoxShadow(
    color: Color(0x73007AFF), // 45% Turbo Blue, left-anchored
    blurRadius: 30.0,
    spreadRadius: 0.0,
    offset: Offset(-8, 0),
  );

  static const BoxShadow playWingSideLight = BoxShadow(
    color: Color(0x26007AFF), // 15% Turbo Blue
    blurRadius: 16.0,
    spreadRadius: 0.0,
    offset: Offset(-4, 0),
  );

  static const BoxShadow heroBloom = BoxShadow(
    color: Color(0x407C3AED), // 25% Console Purple bloom
    blurRadius: 35.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow heroBloomLight = BoxShadow(
    color: Color(0x147C3AED), // 8% Console Purple bloom
    blurRadius: 20.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow heroDeep = BoxShadow(
    color: Color(0xD9000000), // 85% Black cinematic depth
    blurRadius: 50.0,
    spreadRadius: 0.0,
    offset: Offset(0, 20),
  );

  static const BoxShadow heroDeepLight = BoxShadow(
    color: Color(0x140F172A), // 8% Slate 900 cinematic depth
    blurRadius: 28.0,
    spreadRadius: 0.0,
    offset: Offset(0, 10),
  );

  static const BoxShadow goldBadge = BoxShadow(
    color: Color(0x80FFD700), // 50% Cinematic Gold
    blurRadius: 10.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow gaugeRed = BoxShadow(
    color: Color(0x99E63946), // 60% Turbo Red reactor glow
    blurRadius: 22.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow toolboxDeep = BoxShadow(
    color: Color(0xE6000000), // 90% Black floating depth
    blurRadius: 30.0,
    spreadRadius: 0.0,
    offset: Offset(0, 8),
  );

  static const BoxShadow toolboxDeepLight = BoxShadow(
    color: Color(0x1A0F172A), // 10% Slate 900 floating depth
    blurRadius: 24.0,
    spreadRadius: 0.0,
    offset: Offset(0, 8),
  );

  /// Returns theme-aware hero card shadows (avoids heavy dark smudge in light mode).
  static List<BoxShadow> heroShadows(bool isLight) => isLight
      ? const [heroDeepLight, heroBloomLight]
      : const [heroDeep, heroBloom];

  /// Returns theme-aware play-wing shadow.
  static BoxShadow playWingShadow(bool isLight) =>
      isLight ? playWingSideLight : playWingSide;

  /// Returns theme-aware floating toolbox shadow.
  static BoxShadow toolboxShadow(bool isLight) =>
      isLight ? toolboxDeepLight : toolboxDeep;

  static const BoxShadow radarGlow = BoxShadow(
    color: Color(0x4D007AFF), // 30% Turbo Blue threat lens
    blurRadius: 25.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow modePerfGlow = BoxShadow(
    color: Color(0x8CE63946), // 55% Turbo Red mode pill
    blurRadius: 14.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow chipActiveGlow = BoxShadow(
    color: Color(0x73007AFF), // 45% Turbo Blue active chip/switch
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow catIndicatorGlow = BoxShadow(
    color: Color(0x73007AFF), // 45% Turbo Blue category indicator
    blurRadius: 10.0,
    spreadRadius: 0.0,
  );

  // Pre-composed Console Shadow Arrays
  static const List<BoxShadow> consoleHeroShadows = [
    heroDeep,
    heroBloom,
  ];

  static const List<BoxShadow> playWingShadows = [
    playWingSide,
  ];

  static const List<BoxShadow> goldBadgeShadows = [
    goldBadge,
  ];
}
