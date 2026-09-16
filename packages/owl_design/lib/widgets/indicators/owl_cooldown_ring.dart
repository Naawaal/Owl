import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// A cyber-tactical radial cooldown gauge engineered for MOBA skill timers and objective respawns.
/// Renders:
/// - A subtle anti-aliased circular track.
/// - A smooth arc showing normalized progress (0.0 = depleted/empty, 1.0 = full/ready).
/// - A luminous glowing leading-edge dot positioned at the arc's tip.
/// - Centered monospaced tabular digits or custom widget content (e.g., champion ability icon).
class OwlCooldownRing extends StatelessWidget {
  const OwlCooldownRing({
    super.key,
    required this.progress,
    this.size = 48.0,
    this.strokeWidth = 3.5,
    this.centerText,
    this.child,
    this.activeColor,
    this.trackColor,
    this.showLeadingDot = true,
    this.startAngle = -math.pi / 2, // 12 o'clock default
    this.clockwise = true,
  });

  /// Progress fraction between `0.0` (empty) and `1.0` (full).
  final double progress;

  /// Diameter of the cooldown ring in pixels. Defaults to 48.0.
  final double size;

  /// Thickness of the stroke in pixels. Defaults to 3.5.
  final double strokeWidth;

  /// Optional center countdown string (e.g. "12", "04", "1.4").
  /// Rendered in monospaced tabular figures.
  final String? centerText;

  /// Optional centered custom widget (such as a skill icon or buff emblem).
  final Widget? child;

  /// Override color for the active progress arc. Defaults to [ColorTokens.accentCyan].
  final Color? activeColor;

  /// Override color for the inactive circular track.
  final Color? trackColor;

  /// Whether to render a bright glowing dot at the leading tip of the countdown arc.
  final bool showLeadingDot;

  /// Starting angle in radians. Defaults to -pi / 2 (top/12 o'clock).
  final double startAngle;

  /// Whether the arc sweeps clockwise. Defaults to true.
  final bool clockwise;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveActiveColor = activeColor ?? colors.accentCyan;
    final effectiveTrackColor = trackColor ??
        (isDark
            ? ColorComponentTokens.cooldownRingTrack
            : const Color(0xFFE2E8F0));

    final clampedProgress = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: clampedProgress, end: clampedProgress),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutQuad,
      builder: (context, animatedProgress, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _CooldownRingPainter(
                  progress: animatedProgress,
                  strokeWidth: strokeWidth,
                  activeColor: effectiveActiveColor,
                  trackColor: effectiveTrackColor,
                  showLeadingDot: showLeadingDot,
                  startAngle: startAngle,
                  clockwise: clockwise,
                ),
              ),
              if (child != null)
                Padding(
                  padding: EdgeInsets.all(strokeWidth * 1.6),
                  child: child,
                )
              else if (centerText != null)
                Text(
                  centerText!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: (size * 0.28).clamp(10.0, 20.0),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    height: 1.0,
                    color: effectiveActiveColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CooldownRingPainter extends CustomPainter {
  const _CooldownRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
    required this.showLeadingDot,
    required this.startAngle,
    required this.clockwise,
  });

  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;
  final bool showLeadingDot;
  final double startAngle;
  final bool clockwise;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (radius <= 0) return;

    // 1. Draw subtle background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.001) return;

    // 2. Draw active progress sweep arc
    final sweepAngle = (clockwise ? 1 : -1) * (2 * math.pi * progress);

    final arcPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // 3. Draw glowing luminous leading-edge dot
    if (showLeadingDot && progress > 0.02 && progress < 0.99) {
      final currentAngle = startAngle + sweepAngle;
      final dotCenter = Offset(
        center.dx + (radius * math.cos(currentAngle)),
        center.dy + (radius * math.sin(currentAngle)),
      );

      // Outer glow bloom
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

      canvas.drawCircle(dotCenter, strokeWidth * 1.3, glowPaint);

      // Core solid bright pip
      final pipPaint = Paint()
        ..color = ColorPrimitives.coolWhite
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawCircle(dotCenter, strokeWidth * 0.55, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CooldownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showLeadingDot != showLeadingDot;
  }
}
