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
  static const Color sectorSkyLight = Color(0xFFE0F2FE); // Sky 100 for Sector Shimmer
  static const Color sectorLavenderLight = Color(0xFFEDE9FE); // Violet 100 for Sector Shimmer

  // Translucent Light Glass Fills
  static const Color glassWhite95 = Color(0xF2FFFFFF);
  static const Color glassWhite90 = Color(0xE6FFFFFF);
  static const Color glassWhite70 = Color(0xB3FFFFFF);
  static const Color glassDarkBorder10 = Color(0x1A0F172A);
  static const Color glassDarkBorder20 = Color(0x330F172A);

  // Console Horizon & Ambient Glows (Game Space Console provenance)
  static const Color horizonTop = Color(0xFF090B12);
  static const Color horizonBottom = Color(0xFF06070B);
  static const Color ambientPurple = Color(0xFF8B2BE2);
  static const Color glassPurpleAmbient18 = Color(0x2E8B2BE2);
  static const Color ambientBlue = Color(0xFF006EFF);
  static const Color glassBlueGlow10 = Color(0x1A006EFF);

  // Play Wing Gradient Stops (with baked prototype alpha)
  static const Color playWingStart = Color(0xCC0062EB);
  static const Color playWingEnd = Color(0xF50088FF);
  static const Color playWingBorder = Color(0x4DFFFFFF);
  static const Color glassWhite14 = Color(0x24FFFFFF);
  static const Color glassWhite30 = Color(0x4DFFFFFF);
  static const Color glassWhite45 = Color(0x73FFFFFF);
  static const Color glassWhite65 = Color(0xA6FFFFFF);

  // GPU Tab Fill
  static const Color gpuTabFill = Color(0xE0121620);

  // Cinematic Gold Ramp & Treatments
  static const Color goldPale = Color(0xFFFFE89E);
  static const Color goldDeep = Color(0xFFFB8500);
  static const Color goldSolid = Color(0xFFFFD700);
  static const Color goldBorder45 = Color(0x73FFD700);
  static const Color goldGlow25 = Color(0x40FFD700);
  static const Color badgeYellow = Color(0xFFEAB308);
  static const Color tripleKillScrim = Color(0xBF000000);

  // Console Purple Ramp & Treatments
  static const Color consolePurpleVivid = Color(0xFF933AEA);
  static const Color lavenderMist = Color(0xFFD8B4FE);
  static const Color subpillBorder45 = Color(0x73D8B4FE);
  static const Color subpillGlow40 = Color(0x669333EA);
  static const Color heroBloom25 = Color(0x407C3AED);

  // Gamebox Identity
  static const Color gameboxIndigoStart = Color(0xFF4338CA);
  static const Color gameboxIndigoEnd = Color(0xFF6366F1);
  static const Color gameboxGlow40 = Color(0x664F46E5);

  // Settings Surfaces (Settings Prototype provenance)
  static const Color settingsBase = Color(0xFF080B10);
  static const Color settingsPanel = Color(0xFF0E131E);
  static const Color settingsCard = Color(0xB3151C2A);
  static const Color settingsCardHover = Color(0xD91C263A);
  static const Color settingsHeader = Color(0xB30B0F17);
  static const Color settingsSidebar = Color(0xFF090D18);

  // Turbo Cyan Accent (key text, badges, active nav)
  static const Color turboCyan = Color(0xFF00E5FF);
  static const Color turboCyanGlow25 = Color(0x4000E5FF);

  // Canonical Reds & Emerald (Prototype provenance — supersede neon alerts in telemetry)
  static const Color hudCrimson = Color(0xFFFF3B30);
  static const Color hudCrimsonGlow45 = Color(0x73FF3B30);
  static const Color alertCrimson = Color(0xFFFF453A);
  static const Color alertCrimsonGlow40 = Color(0x66FF453A);
  static const Color alertCrimsonBg30 = Color(0x4DFF453A);
  static const Color alertCrimsonBg20 = Color(0x33FF453A);
  static const Color emeraldLive = Color(0xFF30D158);
  static const Color emeraldGlow35 = Color(0x5930D158);
  static const Color emeraldBg15 = Color(0x2630D158);
  static const Color tacticalAmber = Color(0xFFFF9F0A);

  // Console Neutrals
  static const Color consoleMuted = Color(0xFF8E9BAE);
  static const Color consoleDim = Color(0xFF546173);

  // Toolbox & Reactor Gauge Treatments
  static const Color toolboxBg = Color(0xF00E121B);
  static const Color toolboxHeaderDim = Color(0x800A0D14);
  static const Color gaugeDialBg = Color(0xFF070A10);
  static const Color gaugeLaser = Color(0xFFFF5A5F);
  static const Color gaugeTickWhite30 = Color(0x4DFFFFFF);
  static const Color gaugeRingCrimson70 = Color(0xB3FF3B30);
  static const Color gaugeGlowRed60 = Color(0x99E63946);
  static const Color gaugeGlowRed25 = Color(0x40E63946);
  static const Color gaugeBgRed18 = Color(0x2EE63946);
  static const Color gaugeBgBlue15 = Color(0x26007AFF);
  static const Color meterCpuEnd = Color(0xFFFF6961);
  static const Color meterGpuStart = Color(0xFF8B5CF6);
  static const Color meterGpuEnd = Color(0xFFA78BFA);
  static const Color meterGlowPurple60 = Color(0x998B5CF6);
  static const Color meterTrack12 = Color(0x1FFFFFFF);

  // Radar & Objective Treatments
  static const Color radarBorder55 = Color(0x8C007AFF);
  static const Color radarGlow30 = Color(0x4D007AFF);
  static const Color objPodBg = Color(0xE00E1118);

  // Shared Translucent Controls
  static const Color segTrackBlack40 = Color(0x66000000);
  static const Color segBgWhite05 = Color(0x0DFFFFFF);
  static const Color switchOffBorder25 = Color(0x40FFFFFF);

  // Cinematic Scrims
  static const Color scrimBlack15 = Color(0x26000000);
  static const Color scrimBlack25 = Color(0x40000000);
  static const Color scrimBlack88 = Color(0xE0000000);
  static const Color scrimBlack35 = Color(0x59000000);
  static const Color scrimBlack60 = Color(0x99000000);
  static const Color scrimWhite50 = Color(0x80FFFFFF);
  static const Color deepAmbient08 = Color(0x0D140A28);
  static const Color catActiveBlue08 = Color(0x14007AFF);
  static const Color catActiveBlue22 = Color(0x38007AFF);
  static const Color selectBlue12 = Color(0x1F007AFF);
  static const Color keyInputBg = Color(0x80000000);
  static const Color scrollTrackBlack25 = Color(0x40000000);
  static const Color scrollThumbBlue50 = Color(0x80007AFF);
  static const Color rangeTrackWhite15 = Color(0x26FFFFFF);
  static const Color toastScrim = Color(0xF2121A28);
  static const Color perfCardBg02 = Color(0x05FFFFFF);
  static const Color dialogScrim = Color(0xF2101420);
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

  static const Color alertWarning = ColorPrimitives.tacticalAmber;
  static const Color alertDanger = ColorPrimitives.alertCrimson;
  static const Color alertSuccess = ColorPrimitives.emeraldLive;

  // Game Turbo
  static const Color turboBlue = ColorPrimitives.turboBlue;
  static const Color turboBlueLight = ColorPrimitives.turboBlueLight;
  static const Color turboRed = ColorPrimitives.turboRed;
  static const Color turboCrimson = ColorPrimitives.turboCrimson;
  static const Color turboOrange = ColorPrimitives.turboOrange;
  static const Color turboCyan = ColorPrimitives.turboCyan;

  // Console Surfaces (Game Space Console provenance)
  static const Color consoleBase = ColorPrimitives.turboObsidian;
  static const Color horizonTop = ColorPrimitives.horizonTop;
  static const Color horizonBottom = ColorPrimitives.horizonBottom;
  static const Color ambientPurple = ColorPrimitives.ambientPurple;
  static const Color ambientBlue = ColorPrimitives.ambientBlue;
  static const Color consoleMuted = ColorPrimitives.consoleMuted;
  static const Color consoleDim = ColorPrimitives.consoleDim;

  // Settings Surfaces (Settings Prototype provenance)
  static const Color settingsBase = ColorPrimitives.settingsBase;
  static const Color settingsPanel = ColorPrimitives.settingsPanel;
  static const Color settingsCard = ColorPrimitives.settingsCard;
  static const Color settingsCardHover = ColorPrimitives.settingsCardHover;
  static const Color settingsHeader = ColorPrimitives.settingsHeader;
  static const Color settingsSidebar = ColorPrimitives.settingsSidebar;

  // Canonical Status (Prototype provenance)
  static const Color hudCrimson = ColorPrimitives.hudCrimson;
  static const Color alertCrimson = ColorPrimitives.alertCrimson;
  static const Color emeraldLive = ColorPrimitives.emeraldLive;
  static const Color tacticalAmber = ColorPrimitives.tacticalAmber;

  // Cinematic Accents
  static const Color goldPale = ColorPrimitives.goldPale;
  static const Color goldDeep = ColorPrimitives.goldDeep;
  static const Color goldSolid = ColorPrimitives.goldSolid;
  static const Color badgeYellow = ColorPrimitives.badgeYellow;
  static const Color consolePurple = ColorPrimitives.accentPurpleLight;
  static const Color consolePurpleVivid = ColorPrimitives.consolePurpleVivid;
  static const Color lavenderMist = ColorPrimitives.lavenderMist;
  static const Color gameboxIndigoStart = ColorPrimitives.gameboxIndigoStart;
  static const Color gameboxIndigoEnd = ColorPrimitives.gameboxIndigoEnd;

  // Toolbox & Gauge
  static const Color toolboxBg = ColorPrimitives.toolboxBg;
  static const Color gaugeDialBg = ColorPrimitives.gaugeDialBg;
  static const Color gaugeLaser = ColorPrimitives.gaugeLaser;
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

  // Telemetry States (canonical prototype values)
  static const Color telemetryCritical = ColorPrimitives.turboCrimson;
  static const Color telemetryLow = ColorPrimitives.badgeYellow;
  static const Color telemetryNormal = ColorSemantics.turboBlue;
  static const Color liveDot = ColorSemantics.emeraldLive;
  static const Color batteryShell = ColorPrimitives.glassWhite65;
  static const Color cpuBadgeFg = ColorPrimitives.borderLightStrong;
  static const Color cpuBadgeBorder = ColorPrimitives.glassWhite45;
  static const Color statusFg = ColorPrimitives.borderLight;

  // Play Wing
  static const Color playWingStart = ColorPrimitives.playWingStart;
  static const Color playWingEnd = ColorPrimitives.playWingEnd;
  static const Color playWingBorder = ColorPrimitives.playWingBorder;
  static const Color playWingFg = ColorPrimitives.coolWhite;
  static const Color playWingSubFg = Color(0xD9FFFFFF);

  // GPU Tab
  static const Color gpuTabFill = ColorPrimitives.gpuTabFill;
  static const Color gpuTabAccent = ColorSemantics.turboBlue;
  static const Color gpuTabLabel = ColorSemantics.textSecondary;

  // Hero Cinematic Card
  static const Color heroCardBorder = ColorPrimitives.glassWhite14;
  static const Color heroScrimTop = Color(0x1A000000);
  static const Color heroScrimMid = Color(0x660A0514);
  static const Color heroScrimBottom = Color(0xF207080E);
  static const Color goldBorder = ColorPrimitives.goldBorder45;
  static const Color tripleKillFg = ColorPrimitives.goldSolid;
  static const Color tripleKillBg = ColorPrimitives.tripleKillScrim;
  static const Color subpillBorder = ColorPrimitives.subpillBorder45;
  static const Color subpillFg = ColorPrimitives.coolWhite;
  static const Color paginationActive = ColorSemantics.turboBlue;
  static const Color paginationInactive = ColorSemantics.borderGlassStrong;

  // Gamebox Identity
  static const Color gameboxStart = ColorSemantics.gameboxIndigoStart;
  static const Color gameboxEnd = ColorSemantics.gameboxIndigoEnd;
  static const Color gameboxFg = ColorPrimitives.coolWhite;
  static const Color gameboxBadgeBg = ColorSemantics.badgeYellow;
  static const Color gameboxBadgeFg = ColorPrimitives.oledBlack;

  // Toolbox & Reactor Gauge
  static const Color toolboxHeaderBg = ColorPrimitives.toolboxHeaderDim;
  static const Color toolboxBorder = ColorSemantics.borderGlassStrong;
  static const Color gaugeTrack = ColorPrimitives.meterTrack12;
  static const Color meterCpuStart = ColorSemantics.hudCrimson;
  static const Color meterCpuEnd = ColorPrimitives.meterCpuEnd;
  static const Color meterGpuStart = ColorPrimitives.meterGpuStart;
  static const Color meterGpuEnd = ColorPrimitives.meterGpuEnd;
  static const Color modePerfBg = ColorSemantics.turboRed;

  // Radar & Objectives
  static const Color radarBorder = ColorPrimitives.radarBorder55;
  static const Color radarMissingBg = ColorPrimitives.alertCrimsonBg30;
  static const Color radarMissingFg = ColorSemantics.alertCrimson;
  static const Color objPodBg = ColorPrimitives.objPodBg;
  static const Color objUrgentBg = ColorPrimitives.alertCrimsonBg20;
  static const Color objUrgentFg = ColorSemantics.alertCrimson;

  // Settings Components
  static const Color settingsActiveCatIndicator = ColorSemantics.turboBlue;
  static const Color settingsNavFg = ColorSemantics.consoleMuted;
  static const Color settingsRowTitle = ColorSemantics.textPrimary;
  static const Color settingsRowDesc = ColorSemantics.consoleMuted;
  static const Color keyInputText = ColorSemantics.turboCyan;
  static const Color keyInputBg = ColorPrimitives.keyInputBg;
  static const Color providerSelectedBg = ColorPrimitives.selectBlue12;
  static const Color segSelectedBg = ColorSemantics.turboBlue;
  static const Color segTrackBg = ColorPrimitives.segTrackBlack40;
  static const Color switchOffBg = ColorPrimitives.glassWhite14;
  static const Color switchOffBorder = ColorPrimitives.switchOffBorder25;
  static const Color switchOnBg = ColorSemantics.turboBlue;
  static const Color switchOnBorder = ColorSemantics.turboBlueLight;
  static const Color telemetryGood = ColorSemantics.emeraldLive;
  static const Color telemetryCyan = ColorSemantics.turboCyan;
  static const Color telemetryAmber = ColorSemantics.tacticalAmber;
  static const Color dialogBg = ColorPrimitives.dialogScrim;
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
    required this.consoleBase,
    required this.horizonTop,
    required this.horizonBottom,
    required this.settingsBase,
    required this.settingsPanel,
    required this.settingsCard,
    required this.consoleMuted,
    required this.consoleDim,
    required this.turboCyan,
    required this.hudCrimson,
    required this.alertCrimson,
    required this.emeraldLive,
    required this.tacticalAmber,
    required this.telemetryCritical,
    required this.telemetryLow,
    required this.playWingStart,
    required this.playWingEnd,
    required this.gpuTabFill,
    required this.goldDeep,
    required this.goldSolid,
    required this.badgeYellow,
    required this.consolePurple,
    required this.consolePurpleVivid,
    required this.gameboxStart,
    required this.gameboxEnd,
    required this.toolboxBg,
    required this.gaugeLaser,
    required this.radarBorder,
    required this.dialogBg,
    required this.keyInputText,
    required this.telemetryNormal,
    required this.gaugeDialBg,
    required this.sectorSky,
    required this.sectorLavender,
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
  final Color consoleBase;
  final Color horizonTop;
  final Color horizonBottom;
  final Color settingsBase;
  final Color settingsPanel;
  final Color settingsCard;
  final Color consoleMuted;
  final Color consoleDim;
  final Color turboCyan;
  final Color hudCrimson;
  final Color alertCrimson;
  final Color emeraldLive;
  final Color tacticalAmber;
  final Color telemetryCritical;
  final Color telemetryLow;
  final Color playWingStart;
  final Color playWingEnd;
  final Color gpuTabFill;
  final Color goldDeep;
  final Color goldSolid;
  final Color badgeYellow;
  final Color consolePurple;
  final Color consolePurpleVivid;
  final Color gameboxStart;
  final Color gameboxEnd;
  final Color toolboxBg;
  final Color gaugeLaser;
  final Color radarBorder;
  final Color dialogBg;
  final Color keyInputText;
  final Color telemetryNormal;
  final Color gaugeDialBg;
  final Color sectorSky;
  final Color sectorLavender;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
  Color get turboBlue => ColorPrimitives.turboBlue;
  Color get turboBlueLight => ColorPrimitives.turboBlueLight;

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
    alertWarning: ColorPrimitives.tacticalAmber,
    alertDanger: ColorPrimitives.alertCrimson,
    alertSuccess: ColorPrimitives.emeraldLive,
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
    consoleBase: ColorPrimitives.turboObsidian,
    horizonTop: ColorPrimitives.horizonTop,
    horizonBottom: ColorPrimitives.horizonBottom,
    settingsBase: ColorPrimitives.settingsBase,
    settingsPanel: ColorPrimitives.settingsPanel,
    settingsCard: ColorPrimitives.settingsCard,
    consoleMuted: ColorPrimitives.consoleMuted,
    consoleDim: ColorPrimitives.consoleDim,
    turboCyan: ColorPrimitives.turboCyan,
    hudCrimson: ColorPrimitives.hudCrimson,
    alertCrimson: ColorPrimitives.alertCrimson,
    emeraldLive: ColorPrimitives.emeraldLive,
    tacticalAmber: ColorPrimitives.tacticalAmber,
    telemetryCritical: ColorPrimitives.turboCrimson,
    telemetryLow: ColorPrimitives.badgeYellow,
    playWingStart: ColorPrimitives.playWingStart,
    playWingEnd: ColorPrimitives.playWingEnd,
    gpuTabFill: ColorPrimitives.gpuTabFill,
    goldDeep: ColorPrimitives.goldDeep,
    goldSolid: ColorPrimitives.goldSolid,
    badgeYellow: ColorPrimitives.badgeYellow,
    consolePurple: ColorPrimitives.accentPurpleLight,
    consolePurpleVivid: ColorPrimitives.consolePurpleVivid,
    gameboxStart: ColorPrimitives.gameboxIndigoStart,
    gameboxEnd: ColorPrimitives.gameboxIndigoEnd,
    toolboxBg: ColorPrimitives.toolboxBg,
    gaugeLaser: ColorPrimitives.gaugeLaser,
    radarBorder: ColorPrimitives.radarBorder55,
    dialogBg: ColorPrimitives.dialogScrim,
    keyInputText: ColorPrimitives.turboCyan,
    telemetryNormal: ColorPrimitives.turboBlue,
    gaugeDialBg: ColorPrimitives.gaugeDialBg,
    sectorSky: ColorPrimitives.turboCyan,
    sectorLavender: ColorPrimitives.electricPurple,
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
    consoleBase: ColorPrimitives.surfaceCardLight,
    horizonTop: ColorPrimitives.canvasLight,
    horizonBottom: ColorPrimitives.surfaceElevatedLight,
    settingsBase: ColorPrimitives.surfaceCardLight,
    settingsPanel: ColorPrimitives.canvasLight,
    settingsCard: ColorPrimitives.surfaceCardLight,
    consoleMuted: ColorPrimitives.textMutedLight,
    consoleDim: ColorPrimitives.borderLightStrong,
    turboCyan: Color(0xFF0E7490),
    hudCrimson: Color(0xFFDC2626),
    alertCrimson: ColorPrimitives.alertDangerLight,
    emeraldLive: ColorPrimitives.alertSuccessLight,
    tacticalAmber: ColorPrimitives.alertWarningLight,
    telemetryCritical: ColorPrimitives.alertDangerLight,
    telemetryLow: ColorPrimitives.alertWarningLight,
    playWingStart: ColorPrimitives.playWingStart,
    playWingEnd: ColorPrimitives.playWingEnd,
    gpuTabFill: Color(0xE0FFFFFF),
    goldDeep: Color(0xFFB45309),
    goldSolid: ColorPrimitives.alertWarningLight,
    badgeYellow: Color(0xFFA16207),
    consolePurple: ColorPrimitives.accentPurpleLight,
    consolePurpleVivid: Color(0xFF6D28D9),
    gameboxStart: ColorPrimitives.gameboxIndigoStart,
    gameboxEnd: ColorPrimitives.gameboxIndigoEnd,
    toolboxBg: Color(0xF0FFFFFF),
    gaugeLaser: ColorPrimitives.alertDangerLight,
    radarBorder: ColorPrimitives.radarBorder55,
    dialogBg: Color(0xF2FFFFFF),
    keyInputText: Color(0xFF0E7490),
    telemetryNormal: ColorPrimitives.turboBlue,
    gaugeDialBg: ColorPrimitives.surfaceCardLight,
    sectorSky: ColorPrimitives.sectorSkyLight,
    sectorLavender: ColorPrimitives.sectorLavenderLight,
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
    Color? consoleBase,
    Color? horizonTop,
    Color? horizonBottom,
    Color? settingsBase,
    Color? settingsPanel,
    Color? settingsCard,
    Color? consoleMuted,
    Color? consoleDim,
    Color? turboCyan,
    Color? hudCrimson,
    Color? alertCrimson,
    Color? emeraldLive,
    Color? tacticalAmber,
    Color? telemetryCritical,
    Color? telemetryLow,
    Color? playWingStart,
    Color? playWingEnd,
    Color? gpuTabFill,
    Color? goldDeep,
    Color? goldSolid,
    Color? badgeYellow,
    Color? consolePurple,
    Color? consolePurpleVivid,
    Color? gameboxStart,
    Color? gameboxEnd,
    Color? toolboxBg,
    Color? gaugeLaser,
    Color? radarBorder,
    Color? dialogBg,
    Color? keyInputText,
    Color? telemetryNormal,
    Color? gaugeDialBg,
    Color? sectorSky,
    Color? sectorLavender,
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
      consoleBase: consoleBase ?? this.consoleBase,
      horizonTop: horizonTop ?? this.horizonTop,
      horizonBottom: horizonBottom ?? this.horizonBottom,
      settingsBase: settingsBase ?? this.settingsBase,
      settingsPanel: settingsPanel ?? this.settingsPanel,
      settingsCard: settingsCard ?? this.settingsCard,
      consoleMuted: consoleMuted ?? this.consoleMuted,
      consoleDim: consoleDim ?? this.consoleDim,
      turboCyan: turboCyan ?? this.turboCyan,
      hudCrimson: hudCrimson ?? this.hudCrimson,
      alertCrimson: alertCrimson ?? this.alertCrimson,
      emeraldLive: emeraldLive ?? this.emeraldLive,
      tacticalAmber: tacticalAmber ?? this.tacticalAmber,
      telemetryCritical: telemetryCritical ?? this.telemetryCritical,
      telemetryLow: telemetryLow ?? this.telemetryLow,
      playWingStart: playWingStart ?? this.playWingStart,
      playWingEnd: playWingEnd ?? this.playWingEnd,
      gpuTabFill: gpuTabFill ?? this.gpuTabFill,
      goldDeep: goldDeep ?? this.goldDeep,
      goldSolid: goldSolid ?? this.goldSolid,
      badgeYellow: badgeYellow ?? this.badgeYellow,
      consolePurple: consolePurple ?? this.consolePurple,
      consolePurpleVivid: consolePurpleVivid ?? this.consolePurpleVivid,
      gameboxStart: gameboxStart ?? this.gameboxStart,
      gameboxEnd: gameboxEnd ?? this.gameboxEnd,
      toolboxBg: toolboxBg ?? this.toolboxBg,
      gaugeLaser: gaugeLaser ?? this.gaugeLaser,
      radarBorder: radarBorder ?? this.radarBorder,
      dialogBg: dialogBg ?? this.dialogBg,
      keyInputText: keyInputText ?? this.keyInputText,
      telemetryNormal: telemetryNormal ?? this.telemetryNormal,
      gaugeDialBg: gaugeDialBg ?? this.gaugeDialBg,
      sectorSky: sectorSky ?? this.sectorSky,
      sectorLavender: sectorLavender ?? this.sectorLavender,
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
      consoleBase: Color.lerp(consoleBase, other.consoleBase, t)!,
      horizonTop: Color.lerp(horizonTop, other.horizonTop, t)!,
      horizonBottom: Color.lerp(horizonBottom, other.horizonBottom, t)!,
      settingsBase: Color.lerp(settingsBase, other.settingsBase, t)!,
      settingsPanel: Color.lerp(settingsPanel, other.settingsPanel, t)!,
      settingsCard: Color.lerp(settingsCard, other.settingsCard, t)!,
      consoleMuted: Color.lerp(consoleMuted, other.consoleMuted, t)!,
      consoleDim: Color.lerp(consoleDim, other.consoleDim, t)!,
      turboCyan: Color.lerp(turboCyan, other.turboCyan, t)!,
      hudCrimson: Color.lerp(hudCrimson, other.hudCrimson, t)!,
      alertCrimson: Color.lerp(alertCrimson, other.alertCrimson, t)!,
      emeraldLive: Color.lerp(emeraldLive, other.emeraldLive, t)!,
      tacticalAmber: Color.lerp(tacticalAmber, other.tacticalAmber, t)!,
      telemetryCritical:
          Color.lerp(telemetryCritical, other.telemetryCritical, t)!,
      telemetryLow: Color.lerp(telemetryLow, other.telemetryLow, t)!,
      playWingStart: Color.lerp(playWingStart, other.playWingStart, t)!,
      playWingEnd: Color.lerp(playWingEnd, other.playWingEnd, t)!,
      gpuTabFill: Color.lerp(gpuTabFill, other.gpuTabFill, t)!,
      goldDeep: Color.lerp(goldDeep, other.goldDeep, t)!,
      goldSolid: Color.lerp(goldSolid, other.goldSolid, t)!,
      badgeYellow: Color.lerp(badgeYellow, other.badgeYellow, t)!,
      consolePurple: Color.lerp(consolePurple, other.consolePurple, t)!,
      consolePurpleVivid:
          Color.lerp(consolePurpleVivid, other.consolePurpleVivid, t)!,
      gameboxStart: Color.lerp(gameboxStart, other.gameboxStart, t)!,
      gameboxEnd: Color.lerp(gameboxEnd, other.gameboxEnd, t)!,
      toolboxBg: Color.lerp(toolboxBg, other.toolboxBg, t)!,
      gaugeLaser: Color.lerp(gaugeLaser, other.gaugeLaser, t)!,
      radarBorder: Color.lerp(radarBorder, other.radarBorder, t)!,
      dialogBg: Color.lerp(dialogBg, other.dialogBg, t)!,
      keyInputText: Color.lerp(keyInputText, other.keyInputText, t)!,
      telemetryNormal:
          Color.lerp(telemetryNormal, other.telemetryNormal, t)!,
      gaugeDialBg: Color.lerp(gaugeDialBg, other.gaugeDialBg, t)!,
      sectorSky: Color.lerp(sectorSky, other.sectorSky, t)!,
      sectorLavender: Color.lerp(sectorLavender, other.sectorLavender, t)!,
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

  static const Color consoleBase = ColorSemantics.consoleBase;
  static const Color horizonTop = ColorSemantics.horizonTop;
  static const Color horizonBottom = ColorSemantics.horizonBottom;
  static const Color settingsBase = ColorSemantics.settingsBase;
  static const Color settingsPanel = ColorSemantics.settingsPanel;
  static const Color settingsCard = ColorSemantics.settingsCard;
  static const Color settingsSidebar = ColorSemantics.settingsSidebar;
  static const Color consoleMuted = ColorSemantics.consoleMuted;
  static const Color consoleDim = ColorSemantics.consoleDim;
  static const Color turboCyan = ColorSemantics.turboCyan;
  static const Color turboBlue = ColorSemantics.turboBlue;
  static const Color turboBlueLight = ColorSemantics.turboBlueLight;
  static const Color turboRed = ColorSemantics.turboRed;
  static const Color turboCrimson = ColorSemantics.turboCrimson;
  static const Color turboOrange = ColorSemantics.turboOrange;
  static const Color hudCrimson = ColorSemantics.hudCrimson;
  static const Color alertCrimson = ColorSemantics.alertCrimson;
  static const Color emeraldLive = ColorSemantics.emeraldLive;
  static const Color tacticalAmber = ColorSemantics.tacticalAmber;
  static const Color goldDeep = ColorSemantics.goldDeep;
  static const Color goldSolid = ColorSemantics.goldSolid;
  static const Color badgeYellow = ColorSemantics.badgeYellow;
  static const Color consolePurple = ColorSemantics.consolePurple;
  static const Color consolePurpleVivid = ColorSemantics.consolePurpleVivid;
  static const Color gameboxStart = ColorSemantics.gameboxIndigoStart;
  static const Color gameboxEnd = ColorSemantics.gameboxIndigoEnd;
  static const Color toolboxBg = ColorSemantics.toolboxBg;
  static const Color gaugeDialBg = ColorSemantics.gaugeDialBg;
  static const Color gaugeLaser = ColorSemantics.gaugeLaser;

  static const Color telemetryCritical = ColorComponentTokens.telemetryCritical;
  static const Color telemetryLow = ColorComponentTokens.telemetryLow;
  static const Color telemetryNormal = ColorComponentTokens.telemetryNormal;
  static const Color liveDot = ColorComponentTokens.liveDot;
  static const Color playWingStart = ColorComponentTokens.playWingStart;
  static const Color playWingEnd = ColorComponentTokens.playWingEnd;
  static const Color gpuTabFill = ColorComponentTokens.gpuTabFill;
  static const Color dialogBg = ColorComponentTokens.dialogBg;
  static const Color keyInputText = ColorComponentTokens.keyInputText;
}
