import 'package:flutter/material.dart';

/// Design tokens for the Minimal Titanium & Slate design system.
/// Values directly mirror the finalized prototype style definitions.
abstract final class AppColors {
  // --- Shared Accent Tokens ---
  static const Color primaryAccent = Color(0xFF3B82F6);
  static const Color secondaryAccent = Color(0xFF00D2FF);
  static const Color accentGlow = Color(0x473B82F6); // rgba(59, 130, 246, 0.28)
  static const Color accentHover = Color(0xFF2563EB);
  static const Color borderHighlight = Color(0x733B82F6); // rgba(59, 130, 246, 0.45)

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0x4010B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // --- Dark Mode Tokens (Default) ---
  static const Color darkBackground = Color(0xFF090B10);
  static const Color darkSurface = Color(0xFF10141E);
  static const Color darkSurfaceElevated = Color(0xFF171E2D);
  static const Color darkSurfaceHover = Color(0xFF212A3E);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  static const Color darkBorderSubtle = Color(0x12FFFFFF); // rgba(255, 255, 255, 0.07)
  static const Color darkBorderStrong = Color(0x24FFFFFF); // rgba(255, 255, 255, 0.14)
  static const Color darkGlassNavBg = Color(0xD910141E); // rgba(16, 20, 30, 0.85)

  // --- Light Mode Tokens ---
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE2E8F0);
  static const Color lightSurfaceHover = Color(0xFFCBD5E1);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  static const Color lightBorderSubtle = Color(0x140F172A); // rgba(15, 23, 42, 0.08)
  static const Color lightBorderStrong = Color(0x260F172A); // rgba(15, 23, 42, 0.15)
  static const Color lightGlassNavBg = Color(0xE0FFFFFF); // rgba(255, 255, 255, 0.88)

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleAccentGradient = LinearGradient(
    colors: [Color(0x263B82F6), Color(0x1400D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF141A26), Color(0xFF0F131C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
