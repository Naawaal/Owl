// language: Dart, file: spacing_tokens.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/widgets.dart';

/// ============================================================================
/// SPACING TOKENS
/// 4dp base grid system for rigid tactical layout and HUD component alignment.
/// ============================================================================
abstract final class SpacingTokens {
  // 4dp Grid Base Units
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Layout Inset Values
  static const double screenPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double pillPaddingHorizontal = 12.0;
  static const double pillPaddingVertical = 6.0;

  // Pre-baked Edge Insets
  static const EdgeInsets insetsNone = EdgeInsets.zero;
  static const EdgeInsets insetsXxs = EdgeInsets.all(xxs);
  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);
  static const EdgeInsets insetsXxl = EdgeInsets.all(xxl);

  // Component Layout Insets
  static const EdgeInsets screenInsets = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenHorizontalInsets = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardCompactInsets = EdgeInsets.all(sm);
  static const EdgeInsets pillInsets = EdgeInsets.symmetric(
    horizontal: pillPaddingHorizontal,
    vertical: pillPaddingVertical,
  );
  static const EdgeInsets pillCompactInsets = EdgeInsets.symmetric(
    horizontal: xs,
    vertical: xxs,
  );
  static const EdgeInsets buttonInsets = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Ergonomic Gap / Spacer Widgets
  static const SizedBox gapXxs = SizedBox(width: xxs, height: xxs);
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  // Horizontal Gaps
  static const SizedBox gapH4 = SizedBox(width: xxs);
  static const SizedBox gapH8 = SizedBox(width: xs);
  static const SizedBox gapH12 = SizedBox(width: sm);
  static const SizedBox gapH16 = SizedBox(width: md);
  static const SizedBox gapH24 = SizedBox(width: lg);
  static const SizedBox gapH32 = SizedBox(width: xl);

  // Vertical Gaps
  static const SizedBox gapV4 = SizedBox(height: xxs);
  static const SizedBox gapV8 = SizedBox(height: xs);
  static const SizedBox gapV12 = SizedBox(height: sm);
  static const SizedBox gapV16 = SizedBox(height: md);
  static const SizedBox gapV24 = SizedBox(height: lg);
  static const SizedBox gapV32 = SizedBox(height: xl);
}

/// Ergonomic alias for [SpacingTokens] matching standard project conventions.
typedef AppSpacing = SpacingTokens;

/// Predefined spacing and sizing scalars mapped to the 4dp grid.
abstract final class AppSizes {
  static const double p4 = SpacingTokens.xxs;
  static const double p8 = SpacingTokens.xs;
  static const double p12 = SpacingTokens.sm;
  static const double p16 = SpacingTokens.md;
  static const double p24 = SpacingTokens.lg;
  static const double p32 = SpacingTokens.xl;
  static const double p48 = SpacingTokens.xxl;
}
