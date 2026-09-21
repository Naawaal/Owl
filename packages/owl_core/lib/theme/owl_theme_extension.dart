import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeExtension providing compile-time type-safe access to titanium tokens,
/// glassmorphism backgrounds, and glowing accent borders.
@immutable
class OwlThemeExtension extends ThemeExtension<OwlThemeExtension> {
  final Color borderSubtle;
  final Color borderStrong;
  final Color borderHighlight;
  final Color glassNavBg;
  final Color surfaceElevated;
  final Color surfaceHover;
  final Color accentGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final LinearGradient cardGradient;
  final LinearGradient accentGradient;

  const OwlThemeExtension({
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderHighlight,
    required this.glassNavBg,
    required this.surfaceElevated,
    required this.surfaceHover,
    required this.accentGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.cardGradient,
    required this.accentGradient,
  });

  /// Default Minimal Titanium & Slate dark mode tokens.
  static const OwlThemeExtension dark = OwlThemeExtension(
    borderSubtle: AppColors.darkBorderSubtle,
    borderStrong: AppColors.darkBorderStrong,
    borderHighlight: AppColors.borderHighlight,
    glassNavBg: AppColors.darkGlassNavBg,
    surfaceElevated: AppColors.darkSurfaceElevated,
    surfaceHover: AppColors.darkSurfaceHover,
    accentGlow: AppColors.accentGlow,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    cardGradient: AppColors.darkCardGradient,
    accentGradient: AppColors.primaryGradient,
  );

  /// Minimal Titanium & Slate light mode tokens.
  static const OwlThemeExtension light = OwlThemeExtension(
    borderSubtle: AppColors.lightBorderSubtle,
    borderStrong: AppColors.lightBorderStrong,
    borderHighlight: AppColors.borderHighlight,
    glassNavBg: AppColors.lightGlassNavBg,
    surfaceElevated: AppColors.lightSurfaceElevated,
    surfaceHover: AppColors.lightSurfaceHover,
    accentGlow: AppColors.accentGlow,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    cardGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: AppColors.primaryGradient,
  );

  /// Fast helper to access `OwlThemeExtension` from the ambient context.
  static OwlThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<OwlThemeExtension>() ?? dark;
  }

  @override
  OwlThemeExtension copyWith({
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderHighlight,
    Color? glassNavBg,
    Color? surfaceElevated,
    Color? surfaceHover,
    Color? accentGlow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    LinearGradient? cardGradient,
    LinearGradient? accentGradient,
  }) {
    return OwlThemeExtension(
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      borderHighlight: borderHighlight ?? this.borderHighlight,
      glassNavBg: glassNavBg ?? this.glassNavBg,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      accentGlow: accentGlow ?? this.accentGlow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      cardGradient: cardGradient ?? this.cardGradient,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  OwlThemeExtension lerp(ThemeExtension<OwlThemeExtension>? other, double t) {
    if (other is! OwlThemeExtension) return this;
    return OwlThemeExtension(
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderHighlight: Color.lerp(borderHighlight, other.borderHighlight, t)!,
      glassNavBg: Color.lerp(glassNavBg, other.glassNavBg, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      accentGradient: LinearGradient.lerp(accentGradient, other.accentGradient, t)!,
    );
  }
}
