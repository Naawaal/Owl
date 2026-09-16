// language: Dart, file: typography_tokens.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

/// ============================================================================
/// TYPOGRAPHY TOKENS
/// Precision typography for tactical HUD overlays, objective timers, and AI telemetry.
/// Monospaced tabular figures via JetBrains Mono / Space Grotesk.
/// High-legibility UI text via Inter.
/// ============================================================================
abstract final class TypographyTokens {
  // Primary Tactical Monospace & UI Fonts
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;
  static String get uiFontFamily => GoogleFonts.outfit().fontFamily!;

  /// Monospaced objective and respawn timer (28sp, bold, tabular figures).
  static TextStyle get displayTimer => GoogleFonts.jetBrainsMono(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
        color: ColorTokens.textPrimary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.slashedZero(),
        ],
      );

  /// Large hero timer / game clock (36sp, bold, tabular figures).
  static TextStyle get displayTimerLarge => GoogleFonts.jetBrainsMono(
        fontSize: 36.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
        color: ColorTokens.textPrimary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.slashedZero(),
        ],
      );

  /// Compact HUD timer badge (18sp, bold, tabular figures).
  static TextStyle get displayTimerSmall => GoogleFonts.jetBrainsMono(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.1,
        color: ColorTokens.textPrimary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.slashedZero(),
        ],
      );

  /// Screen headline & major section titles (20sp, semi-bold, letter spacing -0.5px).
  static TextStyle get headline => GoogleFonts.outfit(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: ColorTokens.textPrimary,
      );

  /// Medium card headers & modal titles (16sp, medium).
  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
        height: 1.3,
        color: ColorTokens.textPrimary,
      );

  /// Tactical card subheads (14sp, semi-bold).
  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: ColorTokens.textPrimary,
      );

  /// Standard body text & telemetry readouts (14sp, regular).
  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.45,
        color: ColorTokens.textSecondary,
      );

  /// Compact secondary descriptions & footnotes (12sp, regular).
  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
        color: ColorTokens.textMuted,
      );

  /// Tactical HUD label for uppercase identifiers (11sp, bold, monospace, letter spacing +1.2px).
  /// Designed for e.g. "DRAGON 00:24", "BARON VULNERABLE", "ULTIMATE READY".
  static TextStyle get tacticalLabel => GoogleFonts.jetBrainsMono(
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.2,
        color: ColorTokens.textSecondary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
        ],
      );

  /// Tactical monospaced metric values (13sp, bold, monospace, tabular numbers).
  static TextStyle get tacticalValue => GoogleFonts.jetBrainsMono(
        fontSize: 13.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1.2,
        color: ColorTokens.textPrimary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
        ],
      );

  /// Micro badge & pill tag label (10sp, bold, uppercase, letter spacing +1.0px).
  static TextStyle get tacticalBadge => GoogleFonts.jetBrainsMono(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        height: 1.1,
        color: ColorTokens.textPrimary,
        fontFeatures: const [
          FontFeature.tabularFigures(),
        ],
      );

  /// Action button text (14sp, semi-bold, uppercase tracking +0.5px).
  static TextStyle get buttonText => GoogleFonts.outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
        color: ColorTokens.buttonPrimaryFg,
      );
}
