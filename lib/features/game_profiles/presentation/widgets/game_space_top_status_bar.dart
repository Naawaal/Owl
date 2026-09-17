// language: Dart, file: game_space_top_status_bar.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/game_profiles/presentation/widgets/status_bar_metrics_pill.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Console top status bar.
///
/// Left: battery / CPU / FPS metrics.
/// Right: add-game + settings actions.
/// Balanced/Performance mode lives only in the in-game toolbox HUD.
class GameSpaceTopStatusBar extends ConsumerWidget {
  const GameSpaceTopStatusBar({
    super.key,
    required this.onLeadingAction,
    required this.onSettingsTap,
    this.leadingIcon = Icons.add,
    this.leadingIconSize = 19,
  });

  final VoidCallback onLeadingAction;
  final VoidCallback onSettingsTap;
  final IconData leadingIcon;
  final double leadingIconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owlColors = ColorTokens.of(context);
    final isPerf = ref.watch(
      gameTurboSettingsProvider.select((s) => s.performanceOptimization),
    );
    final targetFps = ref.watch(
      installedGamesProvider.select((s) => s.activeGame?.targetFps ?? 120),
    );
    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;
    final maxAllowed = isPerf ? targetFps : 60;
    final hasLiveFps = stats != null && stats.fps > 0;
    final liveFps = hasLiveFps ? stats.fps.clamp(15, maxAllowed) : 0;
    final liveFpsLabel = hasLiveFps ? '$liveFps' : '--';
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
