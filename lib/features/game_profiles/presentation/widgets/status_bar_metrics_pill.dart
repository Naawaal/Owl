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
