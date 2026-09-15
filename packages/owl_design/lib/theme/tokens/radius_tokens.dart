// language: Dart, file: radius_tokens.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/painting.dart';

/// ============================================================================
/// RADIUS TOKENS
/// Corner radiuses for HUD cards, telemetry chips, cooldown rings, and badges.
/// ============================================================================
abstract final class RadiusTokens {
  // Raw Scalar Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  // Radius Primitives
  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusPill = Radius.circular(pill);

  // Pre-baked BorderRadius Geometries
  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderPill = BorderRadius.all(radiusPill);

  // Component Border Radius Bindings
  static const BorderRadius card = borderMd;
  static const BorderRadius modal = borderLg;
  static const BorderRadius button = borderSm;
  static const BorderRadius pillBadge = borderPill;
  static const BorderRadius tag = borderXs;
  static const BorderRadius hudChip = borderPill;
}
