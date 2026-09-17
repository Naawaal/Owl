// language: Dart, file: game_space_top_status_bar.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/game_profiles/presentation/widgets/status_bar_metrics_pill.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Shared Game Space top status bar used by Console and In-Game HUD.
///
/// Left: battery shell, CPU badge, FPS badge ([StatusBarMetricsCluster]).
/// Center: interactive TURBO/BALANCED pill ([TurboModeStatusBarPill]).
/// Right: plain leading + settings icons (Console uses add; HUD uses back).
class GameSpaceTopStatusBar extends ConsumerWidget {
  const GameSpaceTopStatusBar({
    super.key,
    required this.isToolboxOpen,
    required this.onTurboPillTap,
    required this.onLeadingAction,
    required this.onSettingsTap,
    this.leadingIcon = Icons.add,
    this.leadingIconSize = 19,
  });

  final bool isToolboxOpen;
  final VoidCallback onTurboPillTap;
  final VoidCallback onLeadingAction;
  final VoidCallback onSettingsTap;
  final IconData leadingIcon;
  final double leadingIconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owlColors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final isPerf = settings.performanceOptimization;
    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;
    final gameState = ref.watch(installedGamesProvider);
    final activeGame = gameState.activeGame;
    final maxAllowed = isPerf ? (activeGame?.targetFps ?? 120) : 60;
    final hasLiveFps = stats != null && stats.fps > 0;
    final liveFps = hasLiveFps ? stats.fps.clamp(15, maxAllowed) : 0;
    final liveFpsLabel = hasLiveFps ? '$liveFps' : '--';
    final modePrefix = isPerf ? 'TURBO' : 'BALANCED';
    final battery = (stats != null && stats.battery > 0) ? stats.battery : 78;
    final cpu = (stats != null && stats.cpu > 0) ? stats.cpu : 32;

    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatusBarMetricsCluster(
            battery: battery,
            cpu: cpu,
            liveFpsLabel: liveFpsLabel,
          ),
          TurboModeStatusBarPill(
            isToolboxOpen: isToolboxOpen,
            modePrefix: modePrefix,
            liveFpsLabel: liveFpsLabel,
            onTap: onTurboPillTap,
          ),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLeadingAction,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    leadingIcon,
                    size: leadingIconSize,
                    color: owlColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSettingsTap,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: owlColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
