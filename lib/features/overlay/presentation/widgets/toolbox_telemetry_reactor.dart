// language: Dart, file: toolbox_telemetry_reactor.dart, target: Flutter / Owl Game Turbo
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/overlay/data/wifi_optimizer_service.dart';
import 'package:owl_design/owl_design.dart';

/// Tachometer gauge and real-time CPU/GPU/Wi-Fi telemetry meter strip for the toolbox.
class ToolboxTelemetryReactor extends ConsumerStatefulWidget {
  const ToolboxTelemetryReactor({
    super.key,
    required this.targetFps,
    required this.isPerformance,
  });

  final int targetFps;
  final bool isPerformance;

  @override
  ConsumerState<ToolboxTelemetryReactor> createState() =>
      _ToolboxTelemetryReactorState();
}

class _ToolboxTelemetryReactorState
    extends ConsumerState<ToolboxTelemetryReactor> {
  double _gaugeProgressAnim = 0.05;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isPerf = widget.isPerformance;
    final targetAccent =
        isPerf ? colors.telemetryCritical : colors.turboBlue;

    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;

    final cpu = stats?.cpu ?? 0;
    final gpu = stats?.gpu ?? 0;
    final liveFps = isPerf
        ? (stats != null && stats.fps > 60 ? stats.fps : widget.targetFps)
        : (stats?.fps != null ? math.min(stats!.fps, 60) : 60);
    final dialMaxFps = math.max(widget.targetFps.toDouble(), 120.0);
    final targetGaugeProgress = (liveFps / dialMaxFps).clamp(0.05, 1.0);
    final cpuText = cpu > 0 ? '$cpu%' : '--%';
    final cpuProgress = (cpu / 100.0).clamp(0.05, 1.0);
    final gpuText = gpu > 0 ? '$gpu%' : '--%';
    final gpuProgress = (gpu / 100.0).clamp(0.05, 1.0);

    final (wifiMs, isWifiBoost) = ref.watch(
      wifiOptimizerProvider.select((w) => (w.latencyMs, w.isBoostActive)),
    );
    final wifiLabel = wifiMs > 0 ? '${wifiMs}ms' : '--ms';

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, animAccent, _) {
        final accentColor = animAccent ?? targetAccent;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.pillPaddingVertical,
          ),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.75,
              colors: [
                accentColor.withValues(alpha: colors.isLight ? 0.08 : 0.14),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.wifi,
                      size: 11,
                      color: isWifiBoost
                          ? colors.turboBlueLight
                          : colors.textPrimary.withValues(alpha: 0.65),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      wifiLabel,
                      style: TypographyTokens.bodySmallOf(context).copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapV4,
              SizedBox(
                height: 66,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!colors.isLight)
                      Positioned(
                        left: 6,
                        right: 6,
                        child: Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                accentColor.withValues(alpha: 0.4),
                                isPerf
                                    ? colors.gaugeLaser
                                    : colors.turboBlueLight,
                                accentColor.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.isLight
                            ? colors.surfaceCard.withValues(alpha: 0.85)
                            : colors.gaugeDialBg,
                        border: Border.all(
                          color: accentColor.withValues(
                            alpha: colors.isLight ? 0.35 : 0.5,
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(
                              alpha: colors.isLight ? 0.10 : 0.35,
                            ),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: _gaugeProgressAnim,
                          end: targetGaugeProgress,
                        ),
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        onEnd: () => _gaugeProgressAnim = targetGaugeProgress,
                        builder: (context, animProgress, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(66, 66),
                                painter: ReactorTachometerPainter(
                                  progress: animProgress,
                                  accentColor: accentColor,
                                  trackColor: colors.isLight
                                      ? colors.textPrimary
                                          .withValues(alpha: 0.10)
                                      : ColorPrimitives.gaugeTickWhite30
                                          .withValues(alpha: 0.25),
                                  inactiveTickColor: colors.isLight
                                      ? colors.textPrimary
                                          .withValues(alpha: 0.18)
                                      : ColorPrimitives.gaugeTickWhite30
                                          .withValues(alpha: 0.40),
                                  isLight: colors.isLight,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$liveFps',
                                    style: TypographyTokens.gaugeNumerals
                                        .copyWith(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'FPS',
                                    style:
                                        TypographyTokens.gaugeCaption.copyWith(
                                      fontSize: 8,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapV4,
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryMeter(
                      context: context,
                      label: 'CPU',
                      valueText: cpuText,
                      progress: cpuProgress,
                      accent: colors.isLight
                          ? colors.turboBlue
                          : colors.turboBlueLight,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Expanded(
                    child: _buildTelemetryMeter(
                      context: context,
                      label: 'GPU',
                      valueText: gpuText,
                      progress: gpuProgress,
                      accent: colors.isLight
                          ? ColorPrimitives.meterGpuStart
                          : ColorPrimitives.meterGpuEnd,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTelemetryMeter({
    required BuildContext context,
    required String label,
    required String valueText,
    required double progress,
    required Color accent,
  }) {
    final colors = ColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TypographyTokens.gaugeCaption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                color: colors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            Text(
              valueText,
              style: TypographyTokens.objectiveTime.copyWith(
                fontSize: 9,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.gapV4,
        ClipRRect(
          borderRadius: RadiusTokens.borderXs,
          child: Container(
            height: 3.5,
            color: colors.isLight
                ? colors.textPrimary.withValues(alpha: 0.08)
                : ColorPrimitives.glassWhite14,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter rendering the dynamic tachometer sweep arc, glowing needle pip,
/// and responsive ticks of the central reactor dial.
class ReactorTachometerPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;
  final Color inactiveTickColor;
  final bool isLight;

  const ReactorTachometerPainter({
    required this.progress,
    required this.accentColor,
    required this.trackColor,
    required this.inactiveTickColor,
    required this.isLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 270 degree sweep from 135 deg (3*pi/4) to 405 deg (9*pi/4)
    const startAngle = 0.75 * math.pi;
    const totalSweep = 1.5 * math.pi;
    final clampedProgress = progress.clamp(0.0, 1.0);

    // 1. Background Track Arc
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    // 2. Active Progress Sweep Arc with Neon Glow
    if (clampedProgress > 0.01) {
      final activeSweep = totalSweep * clampedProgress;

      if (!isLight) {
        final glowPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.35)
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawArc(rect, startAngle, activeSweep, false, glowPaint);
      }

      final activePaint = Paint()
        ..color = accentColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, activeSweep, false, activePaint);

      // 3. Leading Needle Pip at active sweep tip
      final tipAngle = startAngle + activeSweep;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      final tipOffset = Offset(tipX, tipY);

      // Outer glow circle
      canvas.drawCircle(
        tipOffset,
        3.5,
        Paint()..color = accentColor.withValues(alpha: isLight ? 0.3 : 0.5),
      );
      // Bright core
      canvas.drawCircle(
        tipOffset,
        1.8,
        Paint()..color = isLight ? accentColor : ColorPrimitives.coolWhite,
      );
    }

    // 4. Tachometer Tick Marks (25 ticks across 270 deg)
    const tickCount = 25;
    for (int i = 0; i < tickCount; i++) {
      final fraction = i / (tickCount - 1);
      final angle = startAngle + fraction * totalSweep;
      final isTickActive = fraction <= clampedProgress;

      final tickPaint = Paint()
        ..color = isTickActive ? accentColor : inactiveTickColor
        ..strokeWidth = isTickActive ? 1.4 : 0.9
        ..style = PaintingStyle.stroke;

      final rOuter = radius - 1.5;
      final rInner = isTickActive ? (radius - 5.0) : (radius - 3.2);

      final x1 = center.dx + rInner * math.cos(angle);
      final y1 = center.dy + rInner * math.sin(angle);
      final x2 = center.dx + rOuter * math.cos(angle);
      final y2 = center.dy + rOuter * math.sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ReactorTachometerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.inactiveTickColor != inactiveTickColor ||
      oldDelegate.isLight != isLight;
}
