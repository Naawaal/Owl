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
    color: Color(0x66FF0055), // ~40% Crimson Red
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  static const BoxShadow glowDangerIntense = BoxShadow(
    color: Color(0x99FF0055), // ~60% Crimson Red
    blurRadius: 16.0,
    spreadRadius: 1.5,
  );

  // Amber Warning Glow (Objectives spawning soon, warning states)
  static const BoxShadow glowWarning = BoxShadow(
    color: Color(0x59FFB703), // ~35% Amber Warning
    blurRadius: 12.0,
    spreadRadius: 0.0,
  );

  // Emerald Green Glow (Active buff, ultimate ready, victory state)
  static const BoxShadow glowSuccess = BoxShadow(
    color: Color(0x5906D6A0), // ~35% Emerald Green
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
}
