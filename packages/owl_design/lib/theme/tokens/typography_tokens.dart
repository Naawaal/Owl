// language: Dart, file: typography_tokens.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

/// ============================================================================
/// TYPOGRAPHY TOKENS
/// Single permanent typeface: Outfit — UI text, telemetry, and numerals alike.
/// Console, HUD, toolbox, and settings roles with prototype-derived metrics.
/// Gradient treatments (gold headline) are applied at the call site via
/// ShaderMask; tokens define the underlying size, weight, and spacing.
/// ============================================================================
abstract final class TypographyTokens {
  /// The sole typeface of the design system.
  static String get uiFontFamily => GoogleFonts.outfit().fontFamily!;

  /// Objective and respawn timer (28sp, bold).
  static TextStyle get displayTimer => GoogleFonts.outfit(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
        color: ColorTokens.textPrimary,
      );

  /// Large hero timer / game clock (36sp, extra-bold).
  static TextStyle get displayTimerLarge => GoogleFonts.outfit(
        fontSize: 36.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
        color: ColorTokens.textPrimary,
      );

  /// Compact HUD timer badge (18sp, bold).
  static TextStyle get displayTimerSmall => GoogleFonts.outfit(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.1,
        color: ColorTokens.textPrimary,
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

  /// Tactical HUD label for uppercase identifiers (11sp, bold, letter spacing +1.2px).
  /// Designed for e.g. "DRAGON 00:24", "BARON VULNERABLE", "ULTIMATE READY".
  static TextStyle get tacticalLabel => GoogleFonts.outfit(
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.2,
        color: ColorTokens.textSecondary,
      );

  /// Tactical metric values (13sp, bold, letter spacing +0.2px).
  static TextStyle get tacticalValue => GoogleFonts.outfit(
        fontSize: 13.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// Micro badge & pill tag label (10sp, bold, letter spacing +1.0px).
  static TextStyle get tacticalBadge => GoogleFonts.outfit(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        height: 1.1,
        color: ColorTokens.textPrimary,
      );

  /// Action button text (14sp, semi-bold, letter spacing +0.5px).
  static TextStyle get buttonText => GoogleFonts.outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
        color: ColorTokens.buttonPrimaryFg,
      );

  /// Console status-bar micro readout, e.g. battery / CPU percent (11.5sp, semi-bold).
  static TextStyle get statusMicro => GoogleFonts.outfit(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.2,
        color: ColorComponentTokens.statusFg,
      );

  /// Telemetry chip badge, e.g. the CPU tag (8sp, bold, letter spacing +0.2px).
  static TextStyle get telemetryBadge => GoogleFonts.outfit(
        fontSize: 8.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1.1,
        color: ColorComponentTokens.cpuBadgeFg,
      );

  /// Sidebar section label, e.g. "ACTIVE MVP CATEGORIES" (10sp, bold, +0.8px).
  static TextStyle get sectionLabel => GoogleFonts.outfit(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        height: 1.2,
        color: ColorTokens.consoleDim,
      );

  /// Play-wing title (19sp, extra-bold, letter spacing +0.4px).
  static TextStyle get playWingTitle => GoogleFonts.outfit(
        fontSize: 19.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        height: 1.2,
        color: ColorComponentTokens.playWingFg,
      );

  /// Play-wing subtitle (10.5sp, medium, height 1.3).
  static TextStyle get playWingSubtitle => GoogleFonts.outfit(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        height: 1.3,
        color: ColorComponentTokens.playWingSubFg,
      );

  /// Hero cinematic gold headline (24sp, black, letter spacing +0.5px).
  /// Pair with a ShaderMask gold gradient at the call site.
  static TextStyle get heroHeadline => GoogleFonts.outfit(
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        height: 1.1,
        color: ColorComponentTokens.playWingFg,
      );

  /// Purple subpill label (9.5sp, extra-bold, letter spacing +1.0px).
  static TextStyle get subpillLabel => GoogleFonts.outfit(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        height: 1.2,
        color: ColorComponentTokens.subpillFg,
      );

  /// Triple-kill badge label (9.5sp, black, letter spacing +0.3px).
  static TextStyle get tripleKillLabel => GoogleFonts.outfit(
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.3,
        height: 1.1,
        color: ColorComponentTokens.tripleKillFg,
      );

  /// Dialog title (15sp, extra-bold).
  static TextStyle get dialogTitle => GoogleFonts.outfit(
        fontSize: 15.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.0,
        height: 1.25,
        color: ColorTokens.textPrimary,
      );

  /// Dialog body copy (12sp, regular, height 1.4).
  static TextStyle get dialogBody => GoogleFonts.outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.4,
        color: const Color(0xCCFFFFFF),
      );

  /// Dialog action label (12sp, bold).
  static TextStyle get dialogAction => GoogleFonts.outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
        height: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// GPU tab label (11.5sp, semi-bold, letter spacing +0.2px).
  static TextStyle get gpuTabLabel => GoogleFonts.outfit(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: ColorComponentTokens.gpuTabLabel,
      );

  /// Settings row title (14sp, semi-bold, letter spacing +0.1px).
  static TextStyle get settingsRowTitle => GoogleFonts.outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
        color: ColorComponentTokens.settingsRowTitle,
      );

  /// Settings row description (11.5sp, regular, height 1.4).
  static TextStyle get settingsRowDesc => GoogleFonts.outfit(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.4,
        color: ColorComponentTokens.settingsRowDesc,
      );

  /// Reactor gauge FPS numerals (22sp, extra-bold).
  static TextStyle get gaugeNumerals => GoogleFonts.outfit(
        fontSize: 22.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.0,
        color: ColorTokens.textPrimary,
      );

  /// Gauge caption micro-label (7.5sp, extra-bold, letter spacing +0.8px).
  static TextStyle get gaugeCaption => GoogleFonts.outfit(
        fontSize: 7.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        height: 1.1,
        color: const Color(0xB3FFFFFF),
      );

  /// Objective timer readout, e.g. "00:38" (11.5sp, extra-bold).
  static TextStyle get objectiveTime => GoogleFonts.outfit(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.0,
        height: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// Objective name label (8sp, bold).
  static TextStyle get objectiveName => GoogleFonts.outfit(
        fontSize: 8.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1.1,
        color: ColorTokens.textSecondary,
      );

  /// Secure key input text (11.5sp, medium).
  static TextStyle get keyInput => GoogleFonts.outfit(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        height: 1.3,
        color: ColorComponentTokens.keyInputText,
      );

  // ==========================================================================
  // THEME-AWARE RESOLVERS
  // Same metrics as the base role; dark returns the base style verbatim
  // (pixel-identical), light remaps the baked dark color to its theme role.
  // Use these in any screen that supports both themes.
  // ==========================================================================

  static TextStyle headlineOf(BuildContext context) =>
      _resolve(context, headline, (c) => c.textPrimary);

  static TextStyle titleSmallOf(BuildContext context) =>
      _resolve(context, titleSmall, (c) => c.textPrimary);

  static TextStyle bodySmallOf(BuildContext context) =>
      _resolve(context, bodySmall, (c) => c.textMuted);

  static TextStyle tacticalBadgeOf(BuildContext context) =>
      _resolve(context, tacticalBadge, (c) => c.textPrimary);

  static TextStyle buttonTextOf(BuildContext context) =>
      _resolve(context, buttonText, (c) => c.buttonPrimaryFg);

  static TextStyle statusMicroOf(BuildContext context) =>
      _resolve(context, statusMicro, (c) => c.textPrimary);

  static TextStyle dialogTitleOf(BuildContext context) =>
      _resolve(context, dialogTitle, (c) => c.textPrimary);

  static TextStyle dialogBodyOf(BuildContext context) => _resolve(
      context, dialogBody, (c) => c.textPrimary.withValues(alpha: 0.8));

  static TextStyle dialogActionOf(BuildContext context) =>
      _resolve(context, dialogAction, (c) => c.textPrimary);

  static TextStyle settingsRowTitleOf(BuildContext context) =>
      _resolve(context, settingsRowTitle, (c) => c.textPrimary);

  static TextStyle settingsRowDescOf(BuildContext context) =>
      _resolve(context, settingsRowDesc, (c) => c.consoleMuted);

  static TextStyle keyInputOf(BuildContext context) =>
      _resolve(context, keyInput, (c) => c.keyInputText);

  static TextStyle sectionLabelOf(BuildContext context) =>
      _resolve(context, sectionLabel, (c) => c.consoleDim);

  static TextStyle _resolve(
    BuildContext context,
    TextStyle base,
    Color Function(OwlColors colors) light,
  ) {
    final colors = ColorTokens.of(context);
    if (colors.isDark) return base;
    return base.copyWith(color: light(colors));
  }
}
