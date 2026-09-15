// language: Dart, file: color_tokens.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';

/// ============================================================================
/// LAYER 1: PRIMITIVE TOKENS (Raw colors & base units)
/// Immutable physical color constants. Never used directly in UI widgets.
/// ============================================================================
abstract final class ColorPrimitives {
  // Deep Backgrounds (Dark / OLED)
  static const Color oledBlack = Color(0xFF08090C);
  static const Color deepSlate = Color(0xFF11141A);
  static const Color elevatedDark = Color(0xFF181D26);

  // Tactical Neons & Accents (Dark)
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color electricPurple = Color(0xFF7928CA);

  // Xiaomi HyperOS Game Turbo OEM Tokens
  static const Color turboBlue = Color(0xFF007AFF);
  static const Color turboBlueLight = Color(0xFF389BFF);
  static const Color turboRed = Color(0xFFD32F2F);
  static const Color turboCrimson = Color(0xFFE63946);
  static const Color turboOrange = Color(0xFFFF7B00);
  static const Color turboDarkSlate = Color(0xFF10141E);
  static const Color turboObsidian = Color(0xFF07090F);

  // Status & Telemetry Indicators
  static const Color amberWarning = Color(0xFFFFB703);
  static const Color crimsonRed = Color(0xFFFF0055);
  static const Color emeraldGreen = Color(0xFF06D6A0);

  // Monochromes & Contrasts
  static const Color coolWhite = Color(0xFFF8FAFC);
  static const Color slateGray = Color(0xFF94A3B8);
  static const Color mutedZinc = Color(0xFF475569);

  // Translucent Dark Glass Fills
  static const Color glassDeepSlate85 = Color(0xD911141A);
  static const Color glassDeepSlate75 = Color(0xBF11141A);
  static const Color glassDeepSlate65 = Color(0xA611141A);

  static const Color glassElevated85 = Color(0xD9181D26);
  static const Color glassElevated75 = Color(0xBF181D26);
  static const Color glassElevated65 = Color(0xA6181D26);

  static const Color glassOled85 = Color(0xD908090C);
  static const Color glassOled75 = Color(0xBF08090C);
  static const Color glassOled65 = Color(0xA608090C);

  // Translucent Borders & Overlays
  static const Color glassWhite05 = Color(0x0DF8FAFC);
  static const Color glassWhite10 = Color(0x1AF8FAFC);
  static const Color glassWhite15 = Color(0x26F8FAFC);
  static const Color glassWhite20 = Color(0x33F8FAFC);

  // Tactical Neon Glass Accents
  static const Color glassCyan15 = Color(0x2600F5D4);
  static const Color glassCyan25 = Color(0x4000F5D4);
  static const Color glassPurple15 = Color(0x267928CA);
  static const Color glassPurple25 = Color(0x407928CA);
  static const Color glassRed15 = Color(0x26FF0055);
  static const Color glassRed25 = Color(0x40FF0055);
  static const Color glassAmber15 = Color(0x26FFB703);
  static const Color glassAmber25 = Color(0x40FFB703);
  static const Color glassGreen15 = Color(0x2606D6A0);
  static const Color glassGreen25 = Color(0x4006D6A0);

  // Light Mode Primitives (Modern Minimalist / Linear / Scandinavian)
  static const Color canvasLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceCardLight = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLightStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Calibrated Light Mode Accents (High Contrast AA)
  static const Color accentCyanLight = Color(0xFF0284C7); // Sky 600
  static const Color accentCyanLightBg = Color(0xFF0EA5E9); // Sky 500
  static const Color accentPurpleLight = Color(0xFF7C3AED); // Violet 600
  static const Color alertWarningLight = Color(0xFFD97706); // Amber 600
  static const Color alertDangerLight = Color(0xFFE11D48); // Rose 600
  static const Color alertSuccessLight = Color(0xFF059669); // Emerald 600

  // Translucent Light Glass Fills
  static const Color glassWhite95 = Color(0xF2FFFFFF);
  static const Color glassWhite90 = Color(0xE6FFFFFF);
  static const Color glassWhite70 = Color(0xB3FFFFFF);
  static const Color glassDarkBorder10 = Color(0x1A0F172A);
  static const Color glassDarkBorder20 = Color(0x330F172A);
}

/// ============================================================================
/// LAYER 2: SEMANTIC TOKENS (Contextual role mappings - Dark default)
/// ============================================================================
abstract final class ColorSemantics {
  static const Color backgroundOled = ColorPrimitives.oledBlack;
  static const Color surfaceCard = ColorPrimitives.deepSlate;
  static const Color surfaceElevated = ColorPrimitives.elevatedDark;
  static const Color surfaceGlass = ColorPrimitives.glassDeepSlate75;
  static const Color surfaceGlassDense = ColorPrimitives.glassDeepSlate85;
  static const Color surfaceGlassSubtle = ColorPrimitives.glassDeepSlate65;

  static const Color borderGlass = ColorPrimitives.glassWhite10;
  static const Color borderGlassStrong = ColorPrimitives.glassWhite20;
  static const Color borderGlow = ColorPrimitives.neonCyan;
  static const Color borderGlowSubtle = ColorPrimitives.glassCyan25;

  static const Color textPrimary = ColorPrimitives.coolWhite;
  static const Color textSecondary = ColorPrimitives.slateGray;
  static const Color textMuted = ColorPrimitives.mutedZinc;

  static const Color accentCyan = ColorPrimitives.neonCyan;
  static const Color accentPurple = ColorPrimitives.electricPurple;

  static const Color alertWarning = ColorPrimitives.amberWarning;
  static const Color alertDanger = ColorPrimitives.crimsonRed;
  static const Color alertSuccess = ColorPrimitives.emeraldGreen;

  // Game Turbo
  static const Color turboBlue = ColorPrimitives.turboBlue;
  static const Color turboBlueLight = ColorPrimitives.turboBlueLight;
  static const Color turboRed = ColorPrimitives.turboRed;
  static const Color turboCrimson = ColorPrimitives.turboCrimson;
  static const Color turboOrange = ColorPrimitives.turboOrange;
}

/// ============================================================================
/// LAYER 3: COMPONENT TOKENS (Targeted widget roles - Dark default)
/// ============================================================================
abstract final class ColorComponentTokens {
  static const Color buttonPrimaryBg = ColorSemantics.accentCyan;
  static const Color buttonPrimaryFg = ColorPrimitives.oledBlack;
  static const Color buttonPrimaryHover = Color(0xFF33F7DC);

  static const Color buttonSecondaryBg = ColorSemantics.surfaceElevated;
  static const Color buttonSecondaryFg = ColorSemantics.textPrimary;
  static const Color buttonSecondaryBorder = ColorSemantics.borderGlass;

  static const Color hudPillBg = ColorSemantics.surfaceGlass;
  static const Color hudPillBorder = ColorSemantics.borderGlass;
  static const Color hudPillActiveBorder = ColorSemantics.accentCyan;
  static const Color hudPillActiveGlow = ColorPrimitives.glassCyan25;

  static const Color timerNormal = ColorSemantics.textPrimary;
  static const Color timerWarning = ColorSemantics.alertWarning;
  static const Color timerUrgent = ColorSemantics.alertDanger;

  static const Color glassCardBg = ColorSemantics.surfaceGlass;
  static const Color glassCardBorder = ColorSemantics.borderGlass;
  static const Color glassCardBorderGlow = ColorSemantics.borderGlow;

  static const Color cooldownRingActive = ColorSemantics.accentCyan;
  static const Color cooldownRingCharging = ColorSemantics.accentPurple;
  static const Color cooldownRingDepleted = ColorSemantics.textMuted;
  static const Color cooldownRingTrack = ColorPrimitives.glassWhite05;

  static const Color timerBadgeBg = ColorPrimitives.glassDeepSlate85;
  static const Color timerBadgeBorder = ColorSemantics.borderGlass;
  static const Color timerBadgeNormalFg = ColorSemantics.textPrimary;
  static const Color timerBadgeWarningFg = ColorSemantics.alertWarning;
  static const Color timerBadgeUrgentFg = ColorSemantics.alertDanger;
}

/// ============================================================================
/// DYNAMIC THEME EXTENSION: OwlColors
/// Enables seamless runtime reactive switching between Light & Dark themes.
/// ============================================================================
@immutable
class OwlColors extends ThemeExtension<OwlColors> {
  const OwlColors({
    required this.brightness,
    required this.background,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.surfaceGlassDense,
    required this.surfaceGlassSubtle,
    required this.borderGlass,
    required this.borderGlassStrong,
    required this.borderGlow,
    required this.borderGlowSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentCyan,
    required this.accentPurple,
    required this.alertWarning,
    required this.alertDanger,
    required this.alertSuccess,
    required this.buttonPrimaryBg,
    required this.buttonPrimaryFg,
    required this.buttonPrimaryHover,
    required this.buttonSecondaryBg,
    required this.buttonSecondaryFg,
    required this.buttonSecondaryBorder,
    required this.hudPillBg,
    required this.hudPillBorder,
    required this.hudPillActiveBorder,
    required this.hudPillActiveGlow,
    required this.timerNormal,
    required this.timerWarning,
    required this.timerUrgent,
    required this.glassCardBg,
    required this.glassCardBorder,
    required this.glassCardBorderGlow,
    required this.cooldownRingActive,
    required this.cooldownRingCharging,
    required this.cooldownRingDepleted,
    required this.cooldownRingTrack,
    required this.timerBadgeBg,
    required this.timerBadgeBorder,
    required this.timerBadgeNormalFg,
    required this.timerBadgeWarningFg,
    required this.timerBadgeUrgentFg,
    required this.inputBg,
    required this.inputBorder,
    required this.inputFocusBorder,
  });

  final Brightness brightness;
  final Color background;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color surfaceGlassDense;
  final Color surfaceGlassSubtle;
  final Color borderGlass;
  final Color borderGlassStrong;
  final Color borderGlow;
  final Color borderGlowSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentCyan;
  final Color accentPurple;
  final Color alertWarning;
  final Color alertDanger;
  final Color alertSuccess;
  final Color buttonPrimaryBg;
  final Color buttonPrimaryFg;
  final Color buttonPrimaryHover;
  final Color buttonSecondaryBg;
  final Color buttonSecondaryFg;
  final Color buttonSecondaryBorder;
  final Color hudPillBg;
  final Color hudPillBorder;
  final Color hudPillActiveBorder;
  final Color hudPillActiveGlow;
  final Color timerNormal;
  final Color timerWarning;
  final Color timerUrgent;
  final Color glassCardBg;
  final Color glassCardBorder;
  final Color glassCardBorderGlow;
  final Color cooldownRingActive;
  final Color cooldownRingCharging;
  final Color cooldownRingDepleted;
  final Color cooldownRingTrack;
  final Color timerBadgeBg;
  final Color timerBadgeBorder;
  final Color timerBadgeNormalFg;
  final Color timerBadgeWarningFg;
  final Color timerBadgeUrgentFg;
  final Color inputBg;
  final Color inputBorder;
  final Color inputFocusBorder;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  /// Tactical OLED Dark Theme Palette
  static const OwlColors dark = OwlColors(
    brightness: Brightness.dark,
    background: ColorPrimitives.oledBlack,
    surfaceCard: ColorPrimitives.deepSlate,
    surfaceElevated: ColorPrimitives.elevatedDark,
    surfaceGlass: ColorPrimitives.glassDeepSlate75,
    surfaceGlassDense: ColorPrimitives.glassDeepSlate85,
    surfaceGlassSubtle: ColorPrimitives.glassDeepSlate65,
    borderGlass: ColorPrimitives.glassWhite10,
    borderGlassStrong: ColorPrimitives.glassWhite20,
    borderGlow: ColorPrimitives.neonCyan,
    borderGlowSubtle: ColorPrimitives.glassCyan25,
    textPrimary: ColorPrimitives.coolWhite,
    textSecondary: ColorPrimitives.slateGray,
    textMuted: ColorPrimitives.mutedZinc,
    accentCyan: ColorPrimitives.neonCyan,
    accentPurple: ColorPrimitives.electricPurple,
    alertWarning: ColorPrimitives.amberWarning,
    alertDanger: ColorPrimitives.crimsonRed,
    alertSuccess: ColorPrimitives.emeraldGreen,
    buttonPrimaryBg: ColorPrimitives.neonCyan,
    buttonPrimaryFg: ColorPrimitives.oledBlack,
    buttonPrimaryHover: Color(0xFF33F7DC),
    buttonSecondaryBg: ColorPrimitives.elevatedDark,
    buttonSecondaryFg: ColorPrimitives.coolWhite,
    buttonSecondaryBorder: ColorPrimitives.glassWhite10,
    hudPillBg: ColorPrimitives.glassDeepSlate75,
    hudPillBorder: ColorPrimitives.glassWhite10,
    hudPillActiveBorder: ColorPrimitives.neonCyan,
    hudPillActiveGlow: ColorPrimitives.glassCyan25,
    timerNormal: ColorPrimitives.coolWhite,
    timerWarning: ColorPrimitives.amberWarning,
    timerUrgent: ColorPrimitives.crimsonRed,
    glassCardBg: ColorPrimitives.glassDeepSlate75,
    glassCardBorder: ColorPrimitives.glassWhite10,
    glassCardBorderGlow: ColorPrimitives.neonCyan,
    cooldownRingActive: ColorPrimitives.neonCyan,
    cooldownRingCharging: ColorPrimitives.electricPurple,
    cooldownRingDepleted: ColorPrimitives.mutedZinc,
    cooldownRingTrack: ColorPrimitives.glassWhite05,
    timerBadgeBg: ColorPrimitives.glassDeepSlate85,
    timerBadgeBorder: ColorPrimitives.glassWhite10,
    timerBadgeNormalFg: ColorPrimitives.coolWhite,
    timerBadgeWarningFg: ColorPrimitives.amberWarning,
    timerBadgeUrgentFg: ColorPrimitives.crimsonRed,
    inputBg: ColorPrimitives.glassDeepSlate85,
    inputBorder: ColorPrimitives.glassWhite10,
    inputFocusBorder: ColorPrimitives.neonCyan,
  );

  /// Modern Minimalist Light Theme Palette
  static const OwlColors light = OwlColors(
    brightness: Brightness.light,
    background: ColorPrimitives.canvasLight,
    surfaceCard: ColorPrimitives.surfaceCardLight,
    surfaceElevated: ColorPrimitives.surfaceElevatedLight,
    surfaceGlass: ColorPrimitives.glassWhite90,
    surfaceGlassDense: ColorPrimitives.glassWhite95,
    surfaceGlassSubtle: ColorPrimitives.glassWhite70,
    borderGlass: ColorPrimitives.glassDarkBorder10,
    borderGlassStrong: ColorPrimitives.glassDarkBorder20,
    borderGlow: ColorPrimitives.accentCyanLightBg,
    borderGlowSubtle: Color(0x330EA5E9),
    textPrimary: ColorPrimitives.textPrimaryLight,
    textSecondary: ColorPrimitives.textSecondaryLight,
    textMuted: ColorPrimitives.textMutedLight,
    accentCyan: ColorPrimitives.accentCyanLight,
    accentPurple: ColorPrimitives.accentPurpleLight,
    alertWarning: ColorPrimitives.alertWarningLight,
    alertDanger: ColorPrimitives.alertDangerLight,
    alertSuccess: ColorPrimitives.alertSuccessLight,
    buttonPrimaryBg: ColorPrimitives.accentCyanLightBg,
    buttonPrimaryFg: Color(0xFFFFFFFF),
    buttonPrimaryHover: Color(0xFF0284C7),
    buttonSecondaryBg: ColorPrimitives.surfaceElevatedLight,
    buttonSecondaryFg: ColorPrimitives.textPrimaryLight,
    buttonSecondaryBorder: ColorPrimitives.borderLight,
    hudPillBg: ColorPrimitives.glassWhite90,
    hudPillBorder: ColorPrimitives.borderLight,
    hudPillActiveBorder: ColorPrimitives.accentCyanLightBg,
    hudPillActiveGlow: Color(0x260EA5E9),
    timerNormal: ColorPrimitives.textPrimaryLight,
    timerWarning: ColorPrimitives.alertWarningLight,
    timerUrgent: ColorPrimitives.alertDangerLight,
    glassCardBg: ColorPrimitives.glassWhite90,
    glassCardBorder: ColorPrimitives.borderLight,
    glassCardBorderGlow: ColorPrimitives.accentCyanLightBg,
    cooldownRingActive: ColorPrimitives.accentCyanLightBg,
    cooldownRingCharging: ColorPrimitives.accentPurpleLight,
    cooldownRingDepleted: ColorPrimitives.borderLightStrong,
    cooldownRingTrack: ColorPrimitives.borderLight,
    timerBadgeBg: ColorPrimitives.surfaceElevatedLight,
    timerBadgeBorder: ColorPrimitives.borderLight,
    timerBadgeNormalFg: ColorPrimitives.textPrimaryLight,
    timerBadgeWarningFg: ColorPrimitives.alertWarningLight,
    timerBadgeUrgentFg: ColorPrimitives.alertDangerLight,
    inputBg: ColorPrimitives.surfaceCardLight,
    inputBorder: ColorPrimitives.borderLightStrong,
    inputFocusBorder: ColorPrimitives.accentCyanLightBg,
  );

  @override
  OwlColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? surfaceGlass,
    Color? surfaceGlassDense,
    Color? surfaceGlassSubtle,
    Color? borderGlass,
    Color? borderGlassStrong,
    Color? borderGlow,
    Color? borderGlowSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentCyan,
    Color? accentPurple,
    Color? alertWarning,
    Color? alertDanger,
    Color? alertSuccess,
    Color? buttonPrimaryBg,
    Color? buttonPrimaryFg,
    Color? buttonPrimaryHover,
    Color? buttonSecondaryBg,
    Color? buttonSecondaryFg,
    Color? buttonSecondaryBorder,
    Color? hudPillBg,
    Color? hudPillBorder,
    Color? hudPillActiveBorder,
    Color? hudPillActiveGlow,
    Color? timerNormal,
    Color? timerWarning,
    Color? timerUrgent,
    Color? glassCardBg,
    Color? glassCardBorder,
    Color? glassCardBorderGlow,
    Color? cooldownRingActive,
    Color? cooldownRingCharging,
    Color? cooldownRingDepleted,
    Color? cooldownRingTrack,
    Color? timerBadgeBg,
    Color? timerBadgeBorder,
    Color? timerBadgeNormalFg,
    Color? timerBadgeWarningFg,
    Color? timerBadgeUrgentFg,
    Color? inputBg,
    Color? inputBorder,
    Color? inputFocusBorder,
  }) {
    return OwlColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      surfaceGlassDense: surfaceGlassDense ?? this.surfaceGlassDense,
      surfaceGlassSubtle: surfaceGlassSubtle ?? this.surfaceGlassSubtle,
      borderGlass: borderGlass ?? this.borderGlass,
      borderGlassStrong: borderGlassStrong ?? this.borderGlassStrong,
      borderGlow: borderGlow ?? this.borderGlow,
      borderGlowSubtle: borderGlowSubtle ?? this.borderGlowSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accentCyan: accentCyan ?? this.accentCyan,
      accentPurple: accentPurple ?? this.accentPurple,
      alertWarning: alertWarning ?? this.alertWarning,
      alertDanger: alertDanger ?? this.alertDanger,
      alertSuccess: alertSuccess ?? this.alertSuccess,
      buttonPrimaryBg: buttonPrimaryBg ?? this.buttonPrimaryBg,
      buttonPrimaryFg: buttonPrimaryFg ?? this.buttonPrimaryFg,
      buttonPrimaryHover: buttonPrimaryHover ?? this.buttonPrimaryHover,
      buttonSecondaryBg: buttonSecondaryBg ?? this.buttonSecondaryBg,
      buttonSecondaryFg: buttonSecondaryFg ?? this.buttonSecondaryFg,
      buttonSecondaryBorder: buttonSecondaryBorder ?? this.buttonSecondaryBorder,
      hudPillBg: hudPillBg ?? this.hudPillBg,
      hudPillBorder: hudPillBorder ?? this.hudPillBorder,
      hudPillActiveBorder: hudPillActiveBorder ?? this.hudPillActiveBorder,
      hudPillActiveGlow: hudPillActiveGlow ?? this.hudPillActiveGlow,
      timerNormal: timerNormal ?? this.timerNormal,
      timerWarning: timerWarning ?? this.timerWarning,
      timerUrgent: timerUrgent ?? this.timerUrgent,
      glassCardBg: glassCardBg ?? this.glassCardBg,
      glassCardBorder: glassCardBorder ?? this.glassCardBorder,
      glassCardBorderGlow: glassCardBorderGlow ?? this.glassCardBorderGlow,
      cooldownRingActive: cooldownRingActive ?? this.cooldownRingActive,
      cooldownRingCharging: cooldownRingCharging ?? this.cooldownRingCharging,
      cooldownRingDepleted: cooldownRingDepleted ?? this.cooldownRingDepleted,
      cooldownRingTrack: cooldownRingTrack ?? this.cooldownRingTrack,
      timerBadgeBg: timerBadgeBg ?? this.timerBadgeBg,
      timerBadgeBorder: timerBadgeBorder ?? this.timerBadgeBorder,
      timerBadgeNormalFg: timerBadgeNormalFg ?? this.timerBadgeNormalFg,
      timerBadgeWarningFg: timerBadgeWarningFg ?? this.timerBadgeWarningFg,
      timerBadgeUrgentFg: timerBadgeUrgentFg ?? this.timerBadgeUrgentFg,
      inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusBorder: inputFocusBorder ?? this.inputFocusBorder,
    );
  }

  @override
  OwlColors lerp(ThemeExtension<OwlColors>? other, double t) {
    if (other is! OwlColors) return this;

    return OwlColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      surfaceGlassDense: Color.lerp(surfaceGlassDense, other.surfaceGlassDense, t)!,
      surfaceGlassSubtle: Color.lerp(surfaceGlassSubtle, other.surfaceGlassSubtle, t)!,
      borderGlass: Color.lerp(borderGlass, other.borderGlass, t)!,
      borderGlassStrong: Color.lerp(borderGlassStrong, other.borderGlassStrong, t)!,
      borderGlow: Color.lerp(borderGlow, other.borderGlow, t)!,
      borderGlowSubtle: Color.lerp(borderGlowSubtle, other.borderGlowSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      alertWarning: Color.lerp(alertWarning, other.alertWarning, t)!,
      alertDanger: Color.lerp(alertDanger, other.alertDanger, t)!,
      alertSuccess: Color.lerp(alertSuccess, other.alertSuccess, t)!,
      buttonPrimaryBg: Color.lerp(buttonPrimaryBg, other.buttonPrimaryBg, t)!,
      buttonPrimaryFg: Color.lerp(buttonPrimaryFg, other.buttonPrimaryFg, t)!,
      buttonPrimaryHover: Color.lerp(buttonPrimaryHover, other.buttonPrimaryHover, t)!,
      buttonSecondaryBg: Color.lerp(buttonSecondaryBg, other.buttonSecondaryBg, t)!,
      buttonSecondaryFg: Color.lerp(buttonSecondaryFg, other.buttonSecondaryFg, t)!,
      buttonSecondaryBorder: Color.lerp(buttonSecondaryBorder, other.buttonSecondaryBorder, t)!,
      hudPillBg: Color.lerp(hudPillBg, other.hudPillBg, t)!,
      hudPillBorder: Color.lerp(hudPillBorder, other.hudPillBorder, t)!,
      hudPillActiveBorder: Color.lerp(hudPillActiveBorder, other.hudPillActiveBorder, t)!,
      hudPillActiveGlow: Color.lerp(hudPillActiveGlow, other.hudPillActiveGlow, t)!,
      timerNormal: Color.lerp(timerNormal, other.timerNormal, t)!,
      timerWarning: Color.lerp(timerWarning, other.timerWarning, t)!,
      timerUrgent: Color.lerp(timerUrgent, other.timerUrgent, t)!,
      glassCardBg: Color.lerp(glassCardBg, other.glassCardBg, t)!,
      glassCardBorder: Color.lerp(glassCardBorder, other.glassCardBorder, t)!,
      glassCardBorderGlow: Color.lerp(glassCardBorderGlow, other.glassCardBorderGlow, t)!,
      cooldownRingActive: Color.lerp(cooldownRingActive, other.cooldownRingActive, t)!,
      cooldownRingCharging: Color.lerp(cooldownRingCharging, other.cooldownRingCharging, t)!,
      cooldownRingDepleted: Color.lerp(cooldownRingDepleted, other.cooldownRingDepleted, t)!,
      cooldownRingTrack: Color.lerp(cooldownRingTrack, other.cooldownRingTrack, t)!,
      timerBadgeBg: Color.lerp(timerBadgeBg, other.timerBadgeBg, t)!,
      timerBadgeBorder: Color.lerp(timerBadgeBorder, other.timerBadgeBorder, t)!,
      timerBadgeNormalFg: Color.lerp(timerBadgeNormalFg, other.timerBadgeNormalFg, t)!,
      timerBadgeWarningFg: Color.lerp(timerBadgeWarningFg, other.timerBadgeWarningFg, t)!,
      timerBadgeUrgentFg: Color.lerp(timerBadgeUrgentFg, other.timerBadgeUrgentFg, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusBorder: Color.lerp(inputFocusBorder, other.inputFocusBorder, t)!,
    );
  }
}

/// Unified facade for ergonomic token resolution across the design system.
abstract final class ColorTokens {
  static const primitives = ColorPrimitives;

  /// Dynamic context-aware accessor.
  /// Resolves the active [OwlColors] palette (Light or Dark) from the widget tree.
  static OwlColors of(BuildContext context) {
    return Theme.of(context).extension<OwlColors>() ??
        (Theme.of(context).brightness == Brightness.light
            ? OwlColors.light
            : OwlColors.dark);
  }

  // Static constants (Dark default for backward compatibility)
  static const Color backgroundOled = ColorSemantics.backgroundOled;
  static const Color surfaceCard = ColorSemantics.surfaceCard;
  static const Color surfaceElevated = ColorSemantics.surfaceElevated;
  static const Color surfaceGlass = ColorSemantics.surfaceGlass;
  static const Color surfaceGlassDense = ColorSemantics.surfaceGlassDense;
  static const Color surfaceGlassSubtle = ColorSemantics.surfaceGlassSubtle;

  static const Color borderGlass = ColorSemantics.borderGlass;
  static const Color borderGlassStrong = ColorSemantics.borderGlassStrong;
  static const Color borderGlow = ColorSemantics.borderGlow;
  static const Color borderGlowSubtle = ColorSemantics.borderGlowSubtle;

  static const Color textPrimary = ColorSemantics.textPrimary;
  static const Color textSecondary = ColorSemantics.textSecondary;
  static const Color textMuted = ColorSemantics.textMuted;

  static const Color accentCyan = ColorSemantics.accentCyan;
  static const Color accentPurple = ColorSemantics.accentPurple;

  static const Color alertWarning = ColorSemantics.alertWarning;
  static const Color alertDanger = ColorSemantics.alertDanger;
  static const Color alertSuccess = ColorSemantics.alertSuccess;

  static const Color buttonPrimaryBg = ColorComponentTokens.buttonPrimaryBg;
  static const Color buttonPrimaryFg = ColorComponentTokens.buttonPrimaryFg;
  static const Color buttonPrimaryHover = ColorComponentTokens.buttonPrimaryHover;

  static const Color buttonSecondaryBg = ColorComponentTokens.buttonSecondaryBg;
  static const Color buttonSecondaryFg = ColorComponentTokens.buttonSecondaryFg;
  static const Color buttonSecondaryBorder = ColorComponentTokens.buttonSecondaryBorder;

  static const Color hudPillBg = ColorComponentTokens.hudPillBg;
  static const Color hudPillBorder = ColorComponentTokens.hudPillBorder;
  static const Color hudPillActiveBorder = ColorComponentTokens.hudPillActiveBorder;
  static const Color hudPillActiveGlow = ColorComponentTokens.hudPillActiveGlow;

  static const Color timerNormal = ColorComponentTokens.timerNormal;
  static const Color timerWarning = ColorComponentTokens.timerWarning;
  static const Color timerUrgent = ColorComponentTokens.timerUrgent;

  static const Color glassCardBg = ColorComponentTokens.glassCardBg;
  static const Color glassCardBorder = ColorComponentTokens.glassCardBorder;
  static const Color glassCardBorderGlow = ColorComponentTokens.glassCardBorderGlow;

  static const Color cooldownRingActive = ColorComponentTokens.cooldownRingActive;
  static const Color cooldownRingCharging = ColorComponentTokens.cooldownRingCharging;
  static const Color cooldownRingDepleted = ColorComponentTokens.cooldownRingDepleted;
  static const Color cooldownRingTrack = ColorComponentTokens.cooldownRingTrack;

  static const Color timerBadgeBg = ColorComponentTokens.timerBadgeBg;
  static const Color timerBadgeBorder = ColorComponentTokens.timerBadgeBorder;
  static const Color timerBadgeNormalFg = ColorComponentTokens.timerBadgeNormalFg;
  static const Color timerBadgeWarningFg = ColorComponentTokens.timerBadgeWarningFg;
  static const Color timerBadgeUrgentFg = ColorComponentTokens.timerBadgeUrgentFg;
}
