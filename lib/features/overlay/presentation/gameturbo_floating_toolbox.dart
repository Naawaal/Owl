// language: Dart, file: gameturbo_floating_toolbox.dart, target: Flutter / Owl Game Turbo
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/overlay/data/overlay_channel.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/overlay/data/voice_changer_service.dart';
import 'package:owl/features/overlay/presentation/widgets/toolbox_performance_mode_switch.dart';
import 'package:owl/features/overlay/presentation/widgets/toolbox_quick_actions_grid.dart';
import 'package:owl/features/overlay/presentation/widgets/toolbox_telemetry_reactor.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Iconic Xiaomi Game Turbo 2026 In-Game Floating Toolbox.
///
/// Refactored orchestrator shell hosting telemetry reactor, performance mode
/// switch, and quick actions grid.
class GameturboFloatingToolbox extends ConsumerStatefulWidget {
  const GameturboFloatingToolbox({
    super.key,
    required this.onClose,
    this.onOpenGpuSettings,
    this.gameTitle = 'Game',
    this.targetFps = 120,
    this.matchElapsedSeconds = 0,
  });

  final VoidCallback onClose;
  final VoidCallback? onOpenGpuSettings;
  final String gameTitle;
  final int targetFps;
  final int matchElapsedSeconds;

  @override
  ConsumerState<GameturboFloatingToolbox> createState() =>
      _GameturboFloatingToolboxState();
}

class _GameturboFloatingToolboxState
    extends ConsumerState<GameturboFloatingToolbox> {
  Timer? _topicRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncGameContext();
      unawaited(ref.read(voiceChangerProvider.notifier).syncFromNative());
      final settings = ref.read(gameTurboSettingsProvider);
      if (settings.guardianTacticalEngine) {
        _requestAdvice();
      }
    });
    _topicRefreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) {
        if (!mounted) return;
        final settings = ref.read(gameTurboSettingsProvider);
        if (!settings.guardianTacticalEngine) return;
        if (!settings.performanceOptimization) return;
        _syncGameContext();
        ref.read(coachServiceProvider.notifier).requestTopicRefresh();
      },
    );
  }

  @override
  void dispose() {
    _topicRefreshTimer?.cancel();
    super.dispose();
  }

  void _syncGameContext() {
    if (!mounted) return;
    final settings = ref.read(gameTurboSettingsProvider);
    unawaited(
      const OverlayChannel().setGameContext(
        gameCategory: '5v5 MOBA',
        preferredRole: settings.preferredRole,
        coachingLevel: settings.coachingLevel,
        matchElapsedSeconds: widget.matchElapsedSeconds,
      ),
    );
  }

  void _requestAdvice() {
    final settings = ref.read(gameTurboSettingsProvider);
    if (!settings.guardianTacticalEngine) return;
    final stats = ref.read(systemStatsProvider).valueOrNull;
    final role = settings.preferredRole == 'auto'
        ? 'auto-detected role'
        : settings.preferredRole;
    final fpsPart =
        stats != null && stats.fps > 0 ? ' | Live FPS: ${stats.fps}' : '';
    final cpuPart =
        stats != null && stats.cpu > 0 ? ' | CPU: ${stats.cpu}%' : '';
    final modePart = ' | Mode: ${settings.performanceMode}';
    ref.read(coachServiceProvider.notifier).requestAdvice(
      situation:
          'Live coaching for ${widget.gameTitle} at ${widget.targetFps} FPS target'
          ' | Role: $role$fpsPart$cpuPart$modePart.',
      matchTimeSeconds: widget.matchElapsedSeconds,
      manual: true,
    );
  }

  Future<void> _toggleAi(bool next) async {
    final notifier = ref.read(gameTurboSettingsProvider.notifier);
    notifier.toggleGuardianTacticalEngine(next);
    const channel = OverlayChannel();
    if (next) {
      await channel.showGuardianOverlay();
      if (mounted) _requestAdvice();
    } else {
      await channel.hideGuardianOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);
    final colors = ColorTokens.of(context);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: colors.isLight ? colors.surfaceCard : colors.consoleBase,
        borderRadius: RadiusTokens.borderXl,
        border: Border.all(
          color: colors.borderGlassStrong,
          width: 1.2,
        ),
        boxShadow: [
          ElevationTokens.toolboxShadow(colors.isLight),
          BoxShadow(
            color: colors.turboBlue
                .withValues(alpha: colors.isLight ? 0.12 : 0.22),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.isLight ? colors.surfaceCard : colors.consoleBase,
              ),
            ),
          ),
          const Positioned.fill(child: OwlAtmosphericBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.isLight
                    ? colors.surfaceCard.withValues(alpha: 0.50)
                    : colors.horizonTop.withValues(alpha: 0.55),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, settings),
              ToolboxTelemetryReactor(
                targetFps: widget.targetFps,
                isPerformance: settings.performanceOptimization,
              ),
              ToolboxPerformanceModeSwitch(
                isPerformance: settings.performanceOptimization,
                targetFps: widget.targetFps,
                onModeChanged: (val) async {
                  await notifier.togglePerformanceOptimization(
                    val,
                    gameTargetFps: widget.targetFps,
                  );
                },
              ),
              ToolboxQuickActionsGrid(onAiToggled: _toggleAi),
              AppSpacing.gapV8,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic settings) {
    final colors = ColorTokens.of(context);
    final isPerf = settings.performanceOptimization as bool;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceElevated.withValues(alpha: 0.5)
            : colors.horizonTop.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.zap,
                  size: 13,
                  color: isPerf
                      ? colors.telemetryCritical
                      : (colors.isLight
                          ? colors.badgeYellow
                          : colors.turboBlue),
                ),
                AppSpacing.gapH4,
                Flexible(
                  child: Text(
                    'Gaming tools',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.titleSmallOf(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
            child: Container(
              width: AppSizes.p24 - 4,
              height: AppSizes.p24 - 4,
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  LucideIcons.x,
                  size: 11,
                  color: colors.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
