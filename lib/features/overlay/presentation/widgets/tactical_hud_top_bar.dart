// language: Dart, file: tactical_hud_top_bar.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/overlay/data/wifi_optimizer_service.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// In-Game Tactical Battlefield HUD top status bar.
class TacticalHudTopBar extends ConsumerWidget {
  const TacticalHudTopBar({
    super.key,
    this.game,
    required this.onBack,
  });

  final InstalledGame? game;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final statsAsync = ref.watch(systemStatsProvider);
    ref.watch(coachServiceProvider);
    final latencyMs = ref.read(coachServiceProvider.notifier).lastLatencyMs;
    final stats = statsAsync.valueOrNull;
    final battery = (stats != null && stats.battery > 0) ? stats.battery : 78;
    final cpu = (stats != null && stats.cpu > 0) ? stats.cpu : 32;
    final battFraction = (battery / 100.0).clamp(0.0, 1.0);
    final battColor = battery <= 20
        ? colors.telemetryCritical
        : battery <= 40
            ? colors.telemetryLow
            : colors.telemetryNormal;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Return to Game Space button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.isLight
                    ? colors.surfaceElevated.withValues(alpha: 0.8)
                    : colors.textPrimary.withValues(alpha: 0.1),
                borderRadius: RadiusTokens.borderPill,
                border: Border.all(color: colors.borderGlass),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.chevronLeft,
                    size: AppSizes.p12,
                    color: colors.textPrimary,
                  ),
                  AppSpacing.gapH4,
                  Text(
                    'Game Space',
                    style: TypographyTokens.titleSmallOf(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center: Game Title & Max FPS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game?.name ?? 'Game In-Session',
                style: TypographyTokens.titleSmallOf(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              AppSpacing.gapH8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs - 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.turboBlue.withValues(alpha: 0.18),
                  borderRadius: RadiusTokens.borderXs,
                  border: Border.all(color: colors.turboBlue),
                ),
                child: Text(
                  '${game?.targetFps ?? 120} FPS Max',
                  style: TypographyTokens.telemetryBadge.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: colors.turboBlueLight,
                  ),
                ),
              ),
            ],
          ),

          // Right: Wi-Fi, Latency, Battery & CPU
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ref.watch(wifiOptimizerProvider).isBoostActive) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.turboBlue.withValues(alpha: 0.18),
                    borderRadius: RadiusTokens.borderXs,
                    border: Border.all(
                      color: colors.turboBlueLight.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.wifi,
                        size: 9,
                        color: colors.turboBlueLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${ref.watch(wifiOptimizerProvider).latencyMs}ms',
                        style: TypographyTokens.telemetryBadge.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: colors.turboBlueLight,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH8,
              ],
              if (settings.showInGameLatencyHud && latencyMs != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.turboCyan.withValues(alpha: 0.18),
                    borderRadius: RadiusTokens.borderXs,
                    border: Border.all(
                      color: colors.turboCyan.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.bot,
                        size: 9,
                        color: colors.turboCyan,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${latencyMs}ms',
                        style: TypographyTokens.telemetryBadge.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: colors.turboCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH8,
              ],

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
                                color: colors.textPrimary.withValues(
                                  alpha: 0.65,
                                ),
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
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
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
                                color: colors.textPrimary.withValues(
                                  alpha: 0.65,
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
                  AppSpacing.gapH4,
                  Text(
                    '$battery%',
                    style: TypographyTokens.statusMicroOf(
                      context,
                    ).copyWith(fontSize: 11, color: colors.textPrimary),
                  ),
                ],
              ),
              AppSpacing.gapH12,

              // CPU badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs - 1,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: colors.textPrimary.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'CPU',
                      style: TypographyTokens.telemetryBadge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    '$cpu%',
                    style: TypographyTokens.statusMicroOf(
                      context,
                    ).copyWith(fontSize: 11, color: colors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
