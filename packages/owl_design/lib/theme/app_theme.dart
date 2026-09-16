// language: Dart, file: app_theme.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens/tokens.dart';

/// ============================================================================
/// OWL APP THEME
/// Dual-mode modern minimalist Light Theme & cyber-tactical OLED Dark Theme.
/// Zero generic Material elevation, zero ripple junk, maximum contrast.
/// ============================================================================
abstract final class AppTheme {
  /// Default scroll physics for fluid tactical telemetry scrolling.
  static const ScrollPhysics scrollPhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  /// Dark tactical system UI overlay style matching OLED black HUD.
  static const SystemUiOverlayStyle darkSystemUiOverlayStyle =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: ColorPrimitives.oledBlack,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      );

  /// Modern minimalist light system UI overlay style.
  static const SystemUiOverlayStyle lightSystemUiOverlayStyle =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      );

  /// Backward-compatible alias for default dark overlay.
  static const SystemUiOverlayStyle systemUiOverlayStyle =
      darkSystemUiOverlayStyle;

  /// Returns the corresponding system UI overlay style for the specified [brightness].
  static SystemUiOverlayStyle systemUiOverlayStyleFor(Brightness brightness) {
    return brightness == Brightness.light
        ? lightSystemUiOverlayStyle
        : darkSystemUiOverlayStyle;
  }

  /// Builds the modern minimalist Light ThemeData (Linear / Scandinavian aesthetic).
  static ThemeData get lightTheme {
    const owl = OwlColors.light;
    final textTheme = TextTheme(
      displayLarge: TypographyTokens.displayTimerLarge.copyWith(
        color: owl.textPrimary,
      ),
      displayMedium: TypographyTokens.displayTimer.copyWith(
        color: owl.textPrimary,
      ),
      displaySmall: TypographyTokens.displayTimerSmall.copyWith(
        color: owl.textPrimary,
      ),
      headlineMedium: TypographyTokens.headline.copyWith(
        color: owl.textPrimary,
      ),
      titleMedium: TypographyTokens.titleMedium.copyWith(
        color: owl.textPrimary,
      ),
      titleSmall: TypographyTokens.titleSmall.copyWith(
        color: owl.textSecondary,
      ),
      bodyLarge: TypographyTokens.bodyMedium.copyWith(
        color: owl.textPrimary,
      ),
      bodyMedium: TypographyTokens.bodyMedium.copyWith(
        color: owl.textPrimary,
      ),
      bodySmall: TypographyTokens.bodySmall.copyWith(
        color: owl.textSecondary,
      ),
      labelLarge: TypographyTokens.buttonText.copyWith(
        color: owl.buttonPrimaryFg,
      ),
      labelMedium: TypographyTokens.tacticalLabel.copyWith(
        color: owl.textSecondary,
      ),
      labelSmall: TypographyTokens.tacticalBadge.copyWith(
        color: owl.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Clean Slate 50 Minimalist Canvas
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      canvasColor: const Color(0xFFF8FAFC),

      // Zero-out default ripple feedback
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,

      // Light ColorScheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF0EA5E9),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0F2FE),
        onPrimaryContainer: Color(0xFF0284C7),
        secondary: Color(0xFF7C3AED),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFEDE9FE),
        onSecondaryContainer: Color(0xFF5B21B6),
        tertiary: Color(0xFFD97706),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFFE11D48),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A),
        surfaceContainer: Color(0xFFFFFFFF),
        surfaceContainerHigh: Color(0xFFF1F5F9),
        outline: Color(0xFFE2E8F0),
        outlineVariant: Color(0xFFCBD5E1),
      ),

      textTheme: textTheme,
      fontFamily: TypographyTokens.uiFontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TypographyTokens.headline.copyWith(
          color: owl.textPrimary,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 20),
      ),

      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.card,
          side: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFFCBD5E1);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return const Color(0xFF0284C7);
            }
            return const Color(0xFF0EA5E9);
          }),
          foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
          textStyle: WidgetStatePropertyAll(TypographyTokens.buttonText),
          padding: const WidgetStatePropertyAll(SpacingTokens.buttonInsets),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RadiusTokens.button),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          backgroundColor: const WidgetStatePropertyAll(Color(0xFFF1F5F9)),
          foregroundColor: const WidgetStatePropertyAll(Color(0xFF0F172A)),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
          textStyle: WidgetStatePropertyAll(TypographyTokens.buttonText),
          padding: const WidgetStatePropertyAll(SpacingTokens.buttonInsets),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RadiusTokens.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: const WidgetStatePropertyAll(Color(0xFF0284C7)),
          padding: const WidgetStatePropertyAll(SpacingTokens.pillInsets),
          textStyle: WidgetStatePropertyAll(TypographyTokens.titleSmall),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFF1F5F9),
        disabledColor: Color(0xFFE2E8F0),
        selectedColor: Color(0xFFE0F2FE),
        secondarySelectedColor: Color(0xFFEDE9FE),
        padding: SpacingTokens.pillCompactInsets,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.hudChip,
          side: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        labelStyle: TypographyTokens.tacticalBadge,
        secondaryLabelStyle: TypographyTokens.tacticalBadge,
        elevation: 0,
        pressElevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1.0,
        space: 1.0,
      ),

      iconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 20),

      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0xFFCBD5E1)),
        radius: Radius.circular(2.0),
        thickness: WidgetStatePropertyAll(4.0),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: RadiusTokens.borderSm,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        textStyle: TypographyTokens.bodySmall.copyWith(
          color: const Color(0xFFFFFFFF),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),

      extensions: const [
        OwlColors.light,
        OwlThemeExtension(
          glowCyan: BoxShadow(
            color: Color(0x330EA5E9),
            blurRadius: 16.0,
            spreadRadius: 0.0,
          ),
          glowPurple: BoxShadow(
            color: Color(0x337C3AED),
            blurRadius: 16.0,
            spreadRadius: 0.0,
          ),
          glowDanger: BoxShadow(
            color: Color(0x33E11D48),
            blurRadius: 16.0,
            spreadRadius: 0.0,
          ),
          glowWarning: BoxShadow(
            color: Color(0x33D97706),
            blurRadius: 16.0,
            spreadRadius: 0.0,
          ),
          glowSuccess: BoxShadow(
            color: Color(0x33059669),
            blurRadius: 16.0,
            spreadRadius: 0.0,
          ),
        ),
      ],
    );
  }

  /// Builds the complete OLED Dark ThemeData configured with the 3-tier token architecture.
  static ThemeData get darkTheme {
    const owl = OwlColors.dark;
    final textTheme = TextTheme(
      displayLarge: TypographyTokens.displayTimerLarge.copyWith(
        color: owl.textPrimary,
      ),
      displayMedium: TypographyTokens.displayTimer.copyWith(
        color: owl.textPrimary,
      ),
      displaySmall: TypographyTokens.displayTimerSmall.copyWith(
        color: owl.textPrimary,
      ),
      headlineMedium: TypographyTokens.headline.copyWith(
        color: owl.textPrimary,
      ),
      titleMedium: TypographyTokens.titleMedium.copyWith(
        color: owl.textPrimary,
      ),
      titleSmall: TypographyTokens.titleSmall.copyWith(
        color: owl.textPrimary,
      ),
      bodyLarge: TypographyTokens.bodyMedium.copyWith(
        color: owl.textSecondary,
      ),
      bodyMedium: TypographyTokens.bodyMedium.copyWith(
        color: owl.textSecondary,
      ),
      bodySmall: TypographyTokens.bodySmall.copyWith(
        color: owl.textMuted,
      ),
      labelLarge: TypographyTokens.buttonText.copyWith(
        color: owl.buttonPrimaryFg,
      ),
      labelMedium: TypographyTokens.tacticalLabel.copyWith(
        color: owl.textSecondary,
      ),
      labelSmall: TypographyTokens.tacticalBadge.copyWith(
        color: owl.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // OLED Deep Canvas
      scaffoldBackgroundColor: ColorTokens.backgroundOled,
      canvasColor: ColorTokens.backgroundOled,

      // Zero-out default Material feedback & ripples
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,

      // Tactical ColorScheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: ColorTokens.accentCyan,
        onPrimary: ColorTokens.buttonPrimaryFg,
        primaryContainer: ColorPrimitives.glassCyan15,
        onPrimaryContainer: ColorTokens.accentCyan,
        secondary: ColorTokens.accentPurple,
        onSecondary: ColorPrimitives.coolWhite,
        secondaryContainer: ColorPrimitives.glassPurple15,
        onSecondaryContainer: ColorPrimitives.coolWhite,
        tertiary: ColorTokens.alertWarning,
        onTertiary: ColorPrimitives.oledBlack,
        error: ColorTokens.alertDanger,
        onError: ColorPrimitives.coolWhite,
        surface: ColorTokens.surfaceCard,
        onSurface: ColorTokens.textPrimary,
        surfaceContainer: ColorTokens.surfaceCard,
        surfaceContainerHigh: ColorTokens.surfaceElevated,
        outline: ColorTokens.borderGlass,
        outlineVariant: ColorTokens.borderGlassStrong,
      ),

      // Crisp HUD Typography
      textTheme: textTheme,
      fontFamily: TypographyTokens.uiFontFamily,

      // Transparent Tactical App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ColorTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TypographyTokens.headline.copyWith(
          color: owl.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: ColorTokens.textPrimary,
          size: 20,
        ),
      ),

      // Glass / OLED Cards
      cardTheme: const CardThemeData(
        color: ColorTokens.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.card,
          side: BorderSide(color: ColorTokens.borderGlass, width: 1.0),
        ),
      ),

      // Tactical Buttons: Primary Neon Cyan Action
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return ColorTokens.textMuted;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return ColorTokens.buttonPrimaryHover;
            }
            return ColorTokens.buttonPrimaryBg;
          }),
          foregroundColor: const WidgetStatePropertyAll(
            ColorTokens.buttonPrimaryFg,
          ),
          textStyle: WidgetStatePropertyAll(TypographyTokens.buttonText),
          padding: const WidgetStatePropertyAll(SpacingTokens.buttonInsets),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RadiusTokens.button),
          ),
        ),
      ),

      // Tactical Buttons: Secondary Glass / Outline Action
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          backgroundColor: const WidgetStatePropertyAll(
            ColorTokens.buttonSecondaryBg,
          ),
          foregroundColor: const WidgetStatePropertyAll(
            ColorTokens.buttonSecondaryFg,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: ColorTokens.buttonSecondaryBorder, width: 1.0),
          ),
          textStyle: WidgetStatePropertyAll(TypographyTokens.buttonText),
          padding: const WidgetStatePropertyAll(SpacingTokens.buttonInsets),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RadiusTokens.button),
          ),
        ),
      ),

      // Tactical Buttons: Text Ghost Button
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: const WidgetStatePropertyAll(ColorTokens.accentCyan),
          padding: const WidgetStatePropertyAll(SpacingTokens.pillInsets),
          textStyle: WidgetStatePropertyAll(TypographyTokens.titleSmall),
        ),
      ),

      // HUD Telemetry Pills & Chips
      chipTheme: ChipThemeData(
        backgroundColor: ColorTokens.hudPillBg,
        disabledColor: ColorTokens.surfaceCard,
        selectedColor: ColorPrimitives.glassCyan25,
        secondarySelectedColor: ColorPrimitives.glassPurple25,
        padding: SpacingTokens.pillCompactInsets,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.hudChip,
          side: BorderSide(color: ColorTokens.hudPillBorder, width: 1.0),
        ),
        labelStyle: TypographyTokens.tacticalBadge,
        secondaryLabelStyle: TypographyTokens.tacticalBadge,
        elevation: 0,
        pressElevation: 0,
      ),

      // Hairline Dividers
      dividerTheme: const DividerThemeData(
        color: ColorTokens.borderGlass,
        thickness: 1.0,
        space: 1.0,
      ),

      // Crisp Iconography
      iconTheme: const IconThemeData(color: ColorTokens.textPrimary, size: 20),

      // Minimal Tactical Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: const WidgetStatePropertyAll(ColorTokens.borderGlassStrong),
        radius: const Radius.circular(2.0),
        thickness: const WidgetStatePropertyAll(4.0),
      ),

      // Tooltip HUD Styling
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ColorTokens.surfaceElevated,
          borderRadius: RadiusTokens.borderSm,
          border: Border.all(color: ColorTokens.borderGlass),
          boxShadow: const [ElevationTokens.cardAmbient],
        ),
        textStyle: TypographyTokens.bodySmall.copyWith(
          color: ColorTokens.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),

      // Custom Owl Design System Extensions
      extensions: const [
        OwlColors.dark,
        OwlThemeExtension(
          glowCyan: ElevationTokens.glowCyan,
          glowPurple: ElevationTokens.glowPurple,
          glowDanger: ElevationTokens.glowDanger,
          glowWarning: ElevationTokens.glowWarning,
          glowSuccess: ElevationTokens.glowSuccess,
        ),
      ],
    );
  }
}

/// Custom ScrollBehavior configuring BouncingScrollPhysics and removing glow effects.
class OwlScrollBehavior extends MaterialScrollBehavior {
  const OwlScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      AppTheme.scrollPhysics;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// ThemeExtension providing fast access to HUD glow effects and tactical telemetry styles.
@immutable
class OwlThemeExtension extends ThemeExtension<OwlThemeExtension> {
  final BoxShadow glowCyan;
  final BoxShadow glowPurple;
  final BoxShadow glowDanger;
  final BoxShadow glowWarning;
  final BoxShadow glowSuccess;

  const OwlThemeExtension({
    required this.glowCyan,
    required this.glowPurple,
    required this.glowDanger,
    required this.glowWarning,
    required this.glowSuccess,
  });

  @override
  ThemeExtension<OwlThemeExtension> copyWith({
    BoxShadow? glowCyan,
    BoxShadow? glowPurple,
    BoxShadow? glowDanger,
    BoxShadow? glowWarning,
    BoxShadow? glowSuccess,
  }) {
    return OwlThemeExtension(
      glowCyan: glowCyan ?? this.glowCyan,
      glowPurple: glowPurple ?? this.glowPurple,
      glowDanger: glowDanger ?? this.glowDanger,
      glowWarning: glowWarning ?? this.glowWarning,
      glowSuccess: glowSuccess ?? this.glowSuccess,
    );
  }

  @override
  ThemeExtension<OwlThemeExtension> lerp(
    covariant ThemeExtension<OwlThemeExtension>? other,
    double t,
  ) {
    if (other is! OwlThemeExtension) return this;
    return OwlThemeExtension(
      glowCyan: BoxShadow.lerp(glowCyan, other.glowCyan, t) ?? glowCyan,
      glowPurple: BoxShadow.lerp(glowPurple, other.glowPurple, t) ?? glowPurple,
      glowDanger: BoxShadow.lerp(glowDanger, other.glowDanger, t) ?? glowDanger,
      glowWarning:
          BoxShadow.lerp(glowWarning, other.glowWarning, t) ?? glowWarning,
      glowSuccess:
          BoxShadow.lerp(glowSuccess, other.glowSuccess, t) ?? glowSuccess,
    );
  }
}

/// Ergonomic extension on BuildContext to access Owl theme and tokens.
extension OwlThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  OwlThemeExtension get owlTheme =>
      Theme.of(this).extension<OwlThemeExtension>()!;
  OwlColors get owlColors => ColorTokens.of(this);
}
