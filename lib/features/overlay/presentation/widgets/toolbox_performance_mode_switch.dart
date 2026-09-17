// language: Dart, file: toolbox_performance_mode_switch.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Segmented mode switch between Balanced and Performance profiles.
class ToolboxPerformanceModeSwitch extends StatelessWidget {
  const ToolboxPerformanceModeSwitch({
    super.key,
    required this.isPerformance,
    required this.targetFps,
    required this.onModeChanged,
  });

  final bool isPerformance;
  final int targetFps;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isPerf = isPerformance;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.pillPaddingVertical,
      ),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceCard.withValues(alpha: 0.8)
            : colors.textPrimary.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderPill,
        border: Border.all(
          color: colors.borderGlass,
        ),
      ),
      child: Row(
        children: [
          // 1. Balanced Mode Pill
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticHelper.selectionClick();
                onModeChanged(false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: !isPerf
                      ? LinearGradient(
                          colors: [
                            colors.turboBlue,
                            colors.turboBlueLight,
                          ],
                        )
                      : null,
                  borderRadius: RadiusTokens.borderPill,
                  boxShadow: !isPerf
                      ? [
                          BoxShadow(
                            color: colors.turboBlue.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Balanced',
                  style: TypographyTokens.buttonText.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: !isPerf
                        ? ColorComponentTokens.playWingFg
                        : colors.textPrimary.withValues(
                            alpha: colors.isLight ? 0.70 : 0.50,
                          ),
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapH4,

          // 2. Performance Mode Pill
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticHelper.heavyImpact();
                onModeChanged(true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: isPerf
                      ? LinearGradient(
                          colors: [
                            colors.hudCrimson,
                            colors.telemetryCritical,
                          ],
                        )
                      : null,
                  borderRadius: RadiusTokens.borderPill,
                  boxShadow: isPerf
                      ? [
                          BoxShadow(
                            color: colors.telemetryCritical
                                .withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Performance',
                  style: TypographyTokens.buttonText.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPerf
                        ? ColorComponentTokens.playWingFg
                        : colors.textPrimary.withValues(
                            alpha: colors.isLight ? 0.70 : 0.50,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
