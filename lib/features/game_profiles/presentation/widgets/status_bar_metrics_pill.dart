// language: Dart, file: status_bar_metrics_pill.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl_design/owl_design.dart';

/// Telemetry metrics cluster on the top status bar (battery meter, CPU badge, live FPS badge).
class StatusBarMetricsCluster extends StatelessWidget {
  const StatusBarMetricsCluster({
    super.key,
    required this.battery,
    required this.cpu,
    required this.liveFpsLabel,
  });

  final int battery;
  final int cpu;
  final String liveFpsLabel;

  @override
  Widget build(BuildContext context) {
    final owlColors = ColorTokens.of(context);
    final battFraction = (battery / 100.0).clamp(0.0, 1.0);
    final battColor = battery <= 20
        ? owlColors.telemetryCritical
        : battery <= 40
            ? owlColors.telemetryLow
            : owlColors.telemetryNormal;
    final battLabel = battery > 0 ? '$battery%' : '--%';
    final cpuLabel = cpu > 0 ? '$cpu%' : '--%';

    return Row(
      children: [
        // Battery Shell
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 10,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned.fill(
                    right: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: owlColors.textPrimary.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.all(1),
                      child: LayoutBuilder(
                        builder: (ctx, cst) {
                          return Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                width: cst.maxWidth * battFraction,
                                decoration: BoxDecoration(
                                  color: battColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      width: 2,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: owlColors.textPrimary.withValues(
                            alpha: owlColors.isLight ? 0.75 : 0.65,
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(1),
                            bottomRight: Radius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              battLabel,
              style: TypographyTokens.statusMicro.copyWith(
                color: owlColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // CPU Badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: owlColors.textPrimary.withValues(
                    alpha: owlColors.isLight ? 0.4 : 0.45,
                  ),
                  width: 1.2,
                ),
              ),
              child: Text(
                'CPU',
                style: TypographyTokens.telemetryBadge.copyWith(
                  color: owlColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              cpuLabel,
              style: TypographyTokens.statusMicro.copyWith(
                color: owlColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        // FPS Badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: owlColors.emeraldLive.withValues(
                    alpha: owlColors.isLight ? 0.6 : 0.45,
                  ),
                  width: 1.2,
                ),
              ),
              child: Text(
                'FPS',
                style: TypographyTokens.telemetryBadge.copyWith(
                  color: owlColors.emeraldLive,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              liveFpsLabel,
              style: TypographyTokens.statusMicro.copyWith(
                color: owlColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Central interactive TURBO / BALANCED capsule pill on the top status bar.
class TurboModeStatusBarPill extends StatelessWidget {
  const TurboModeStatusBarPill({
    super.key,
    required this.isToolboxOpen,
    required this.modePrefix,
    required this.liveFpsLabel,
    required this.onTap,
  });

  final bool isToolboxOpen;
  final String modePrefix;
  final String liveFpsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final owlColors = ColorTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isToolboxOpen
              ? owlColors.turboBlue.withValues(alpha: 0.2)
              : (owlColors.isLight
                  ? owlColors.turboBlue.withValues(alpha: 0.08)
                  : owlColors.textPrimary.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isToolboxOpen
                ? owlColors.turboBlueLight
                : (owlColors.isLight
                    ? owlColors.turboBlue.withValues(alpha: 0.25)
                    : owlColors.turboBlue.withValues(alpha: 0.18)),
            width: 1.2,
          ),
          boxShadow: isToolboxOpen
              ? [
                  BoxShadow(
                    color: owlColors.turboBlue.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: owlColors.emeraldLive,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$modePrefix $liveFpsLabel FPS',
              style: TypographyTokens.tacticalBadge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: owlColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isToolboxOpen ? Icons.close : Icons.tune,
              size: 11,
              color: owlColors.isLight
                  ? owlColors.turboBlue
                  : owlColors.turboBlueLight,
            ),
          ],
        ),
      ),
    );
  }
}
