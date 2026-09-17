// language: Dart, file: overlay_edge_handle.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Floating edge pill button displaying live TURBO status and FPS, tapping opens the toolbox.
class OverlayEdgeHandle extends ConsumerWidget {
  const OverlayEdgeHandle({
    super.key,
    this.game,
    required this.onTap,
  });

  final InstalledGame? game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final stats = ref.watch(systemStatsProvider).valueOrNull;
    final liveFps = stats?.fps ?? (game?.targetFps ?? 120);
    ref.watch(coachServiceProvider);
    final settings = ref.watch(gameTurboSettingsProvider);
    final latencyMs = ref.read(coachServiceProvider.notifier).lastLatencyMs;
    final label = settings.showInGameLatencyHud && latencyMs != null
        ? 'TURBO $liveFps FPS • ${latencyMs}ms'
        : 'TURBO $liveFps FPS';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.pillPaddingVertical - 1,
        ),
        decoration: BoxDecoration(
          color: colors.isLight
              ? colors.surfaceCard.withValues(alpha: 0.88)
              : colors.horizonTop.withValues(alpha: 0.90),
          borderRadius: RadiusTokens.borderPill,
          border: Border.all(
            color: colors.turboBlueLight.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.turboBlue.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.zap,
              size: AppSizes.p12,
              color: colors.badgeYellow,
            ),
            AppSpacing.gapH4,
            Text(
              label,
              style: TypographyTokens.buttonText.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
