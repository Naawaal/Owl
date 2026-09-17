// language: Dart, file: gameturbo_floating_toolbox.dart, target: Flutter / Owl Game Turbo
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:owl_core/owl_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/overlay/data/dnd_service.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/overlay/data/voice_changer_service.dart';
import 'package:owl/features/overlay/data/wifi_optimizer_service.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Iconic Xiaomi Game Turbo 2026 In-Game Floating Toolbox.
///
/// Features:
/// - Sleek compact header bar (Gaming tools, target FPS badge, close button)
/// - Signature Circular Reactor Tachometer FPS Gauge with laser beam flares and fine tick ring
/// - Integrated Horizontal Live Telemetry Strip with CPU & GPU segmented progress meters, clock & battery
/// - Segmented Mode Switcher ([Balanced] vs [Performance])
/// - 4 Essential Quick Actions: Free RAM (Boost), DND, Wi-Fi Speed Boost, Mistouch Rejection
/// - Direct link to GPU settings
class GameturboFloatingToolbox extends ConsumerStatefulWidget {
  const GameturboFloatingToolbox({
    super.key,
    required this.onClose,
    this.onOpenGpuSettings,
    this.gameTitle = 'Mobile Legends: Bang Bang',
    this.targetFps = 120,
  });

  final VoidCallback onClose;
  final VoidCallback? onOpenGpuSettings;
  final String gameTitle;
  final int targetFps;

  @override
  ConsumerState<GameturboFloatingToolbox> createState() =>
      _GameturboFloatingToolboxState();
}

class _GameturboFloatingToolboxState
    extends ConsumerState<GameturboFloatingToolbox> {
  bool _isAiActive = true;
  Timer? _topicRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Request live advice once the toolbox opens; budgets inside the
    // service suppress repeats. Never throws — failures stay silent here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestAdvice();
    });
    // Periodic topic auto-refresh; the service enforces gates and budgets.
    _topicRefreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) {
        if (!mounted) return;
        ref.read(coachServiceProvider.notifier).requestTopicRefresh();
      },
    );
  }

  @override
  void dispose() {
    _topicRefreshTimer?.cancel();
    super.dispose();
  }

  void _requestAdvice() {
    ref.read(coachServiceProvider.notifier).requestAdvice(
          situation:
              'Live coaching for ${widget.gameTitle} at ${widget.targetFps} FPS target.',
          manual: true,
        );
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
          // 0. Solid Opaque Foundation (prevents background console/game cards from bleeding through)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.isLight ? colors.surfaceCard : colors.consoleBase,
              ),
            ),
          ),

          // 1. Unified Console Atmospheric Background (same as Console 1:1)
          const Positioned.fill(child: OwlAtmosphericBackground()),

          // 2. Translucent Glass Tint Layer for high-contrast legibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.isLight
                    ? colors.surfaceCard.withValues(alpha: 0.50)
                    : colors.horizonTop.withValues(alpha: 0.55),
              ),
            ),
          ),

          // 3. Main Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Compact Header Bar
              _buildHeader(settings),

              // 2. Signature Circular Reactor FPS Gauge + Horizontal Live Telemetry Strip
              _buildReactorGauge(settings),

              // 3. Segmented Mode Capsule (Balanced vs Performance)
              _buildModePills(settings, notifier),

              // 4. Essential 4 Tools (DND, Wi-Fi, AI, Voice Changer)
              _buildEssentialTools(settings, notifier),
              AppSpacing.gapV8,

              // 5. Guardian AI Coach Callout (live advice, cached, else silent)
              _buildGuardianCallout(),
              AppSpacing.gapV8,
            ],
          ),
        ],
      ),
    );
  }

  /// Live tactical advice feed. Shows fresh advice, falls back to
  /// last-known advice, and stays silent when inference is unavailable —
  /// never an error state, never blocking.
  Widget _buildGuardianCallout() {
    final colors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final adviceAsync = ref.watch(coachServiceProvider);
    final service = ref.read(coachServiceProvider.notifier);
    final shown = adviceAsync.valueOrNull ?? service.lastKnown;

    if (shown == null) {
      if (!adviceAsync.isLoading) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.turboBlueLight,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'Consulting coach…',
              style: TypographyTokens.bodySmallOf(context).copyWith(
                fontSize: 10.5,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    final isLive = identical(shown, adviceAsync.valueOrNull);
    final topic = isLive ? service.lastPromptType : service.lastKnownTopic;
    // Topic filter: disabled topics neither trigger queries (service-side)
    // nor display here.
    if (!CoachService.isTopicEnabled(settings, topic)) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _requestAdvice,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceGlass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.borderGlass),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLive
                        ? 'GUARDIAN AI COACH • LIVE'
                        : 'GUARDIAN AI COACH • LAST KNOWN',
                    style: TypographyTokens.tacticalBadgeOf(context).copyWith(
                      fontSize: 8.5,
                      color: colors.turboBlueLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shown.action,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.titleSmallOf(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (settings.explainRecommendations)
                    Text(
                      shown.warning ?? shown.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.bodySmallOf(context).copyWith(
                        fontSize: 10.5,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.refresh_rounded,
              size: 14,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameTurboSettings settings) {
    final colors = ColorTokens.of(context);
    final isPerf = settings.performanceOptimization;
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
                      : (colors.isLight ? colors.badgeYellow : colors.turboBlue),
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

  /// Latency readout for the gauge strip. Subscribes to advice state so
  /// the readout refreshes the moment a query completes.
  String _latencyLabel() {
    ref.watch(coachServiceProvider);
    final ms =
        ref.read(coachServiceProvider.notifier).lastLatencyMs;
    return ms == null ? '--ms' : '${ms}ms';
  }

  Widget _buildReactorGauge(GameTurboSettings settings) {
    final colors = ColorTokens.of(context);
    final isPerf = settings.performanceOptimization;
    final accentColor =
        isPerf ? colors.telemetryCritical : colors.turboBlue;

    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;

    // Real-time values
    final battery = stats?.battery ?? 78;
    final cpu = stats?.cpu ?? (isPerf ? 32 : 18);
    final gpu = stats?.gpu ?? (isPerf ? 58 : 34);
    final liveFps = isPerf
        ? (stats != null && stats.fps > 60 ? stats.fps : widget.targetFps)
        : (stats?.fps != null ? math.min(stats!.fps, 60) : 60);
    final dialMaxFps = math.max(widget.targetFps.toDouble(), 120.0);
    final targetGaugeProgress = (liveFps / dialMaxFps).clamp(0.05, 1.0);
    final fpsText = '$liveFps';
    final cpuText = '$cpu%';
    final cpuProgress = (cpu / 100.0).clamp(0.05, 1.0);
    final gpuText = '$gpu%';
    final gpuProgress = (gpu / 100.0).clamp(0.05, 1.0);

    // Live clock formatted HH:mm
    final now = stats?.timestamp ?? DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
          // Top Meta (Clock, Inference Latency & Battery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeStr,
                style: TypographyTokens.bodySmallOf(context).copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary.withValues(alpha: 0.65),
                ),
              ),
              if (settings.showInGameLatencyHud)
                Text(
                  _latencyLabel(),
                  style: TypographyTokens.bodySmallOf(context).copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
              Row(
                children: [
                  Icon(
                    stats?.isCharging == true
                        ? LucideIcons.batteryCharging
                        : LucideIcons.battery,
                    size: 11,
                    color: battery <= 20
                        ? colors.telemetryCritical
                        : battery <= 40
                            ? colors.telemetryLow
                            : colors.emeraldLive,
                  ),
                  AppSpacing.gapH4,
                  Text(
                    '$battery%',
                    style: TypographyTokens.bodySmallOf(context).copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapV4,

          // Center Circular Tachometer Dial with Laser Flares
          SizedBox(
            height: 66,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Horizontal Laser Beam (only in dark mode to preserve clean light mode dial)
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

                // Tachometer Circle
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.isLight
                        ? colors.surfaceCard.withValues(alpha: 0.85)
                        : colors.gaugeDialBg,
                    border: Border.all(
                      color: accentColor.withValues(alpha: colors.isLight ? 0.35 : 0.5),
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
                    tween: Tween<double>(end: targetGaugeProgress),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, animProgress, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Live animated tachometer sweep gauge
                          CustomPaint(
                            size: const Size(66, 66),
                            painter: _ReactorTachometerPainter(
                              progress: animProgress,
                              accentColor: accentColor,
                              trackColor: colors.isLight
                                  ? colors.textPrimary.withValues(alpha: 0.10)
                                  : ColorPrimitives.gaugeTickWhite30.withValues(alpha: 0.25),
                              inactiveTickColor: colors.isLight
                                  ? colors.textPrimary.withValues(alpha: 0.18)
                                  : ColorPrimitives.gaugeTickWhite30.withValues(alpha: 0.40),
                              isLight: colors.isLight,
                            ),
                          ),

                          // Central FPS Live Counter & Unit
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                fpsText,
                                style: TypographyTokens.gaugeNumerals.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'FPS',
                                style: TypographyTokens.gaugeCaption.copyWith(
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

          // Horizontal Live Telemetry Progress Meters (CPU & GPU)
          Row(
            children: [
              // CPU Meter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CPU',
                          style: TypographyTokens.gaugeCaption.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            color: colors.textPrimary.withValues(alpha: 0.55),
                          ),
                        ),
                        Text(
                          cpuText,
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
                          widthFactor: cpuProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH12,

              // GPU Meter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GPU',
                          style: TypographyTokens.gaugeCaption.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            color: colors.textPrimary.withValues(alpha: 0.55),
                          ),
                        ),
                        Text(
                          gpuText,
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
                          widthFactor: gpuProgress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorPrimitives.meterGpuStart,
                                  ColorPrimitives.meterGpuEnd,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModePills(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    final colors = ColorTokens.of(context);
    final isPerf = settings.performanceOptimization;

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
                notifier.togglePerformanceOptimization(false);
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
                        : colors.textPrimary.withValues(alpha: colors.isLight ? 0.70 : 0.50),
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
                notifier.togglePerformanceOptimization(true);
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
                        : colors.textPrimary.withValues(alpha: colors.isLight ? 0.70 : 0.50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEssentialTools(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    final colors = ColorTokens.of(context);
    final dndState = ref.watch(dndServiceProvider);
    final dndNotifier = ref.read(dndServiceProvider.notifier);
    final wifiState = ref.watch(wifiOptimizerProvider);
    final wifiNotifier = ref.read(wifiOptimizerProvider.notifier);
    final voiceState = ref.watch(voiceChangerProvider);
    final voiceNotifier = ref.read(voiceChangerProvider.notifier);
    final adviceAsync = ref.watch(coachServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.xxs - 1,
      ),
      child: Row(
        children: [
          // 1. DND (Block notifications with real Android ZenMode)
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.bellOff,
              label: 'DND',
              isActive: dndState.isEnabled,
              activeColor: colors.telemetryCritical,
              onTap: () {
                dndNotifier.toggleDnd().then((success) {
                  if (!success &&
                      mounted &&
                      !ref.read(dndServiceProvider).hasPermission) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification Access required for DND.',
                          style: TypographyTokens.bodySmallOf(context).copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        backgroundColor: colors.surfaceCard,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                });
              },
            ),
          ),
          AppSpacing.gapH4,

          // 2. Wi-Fi Speed Boost (Real Android WifiLock + Ping Telemetry)
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.wifi,
              label: 'Wi-Fi',
              badge: wifiState.isBoostActive ? '${wifiState.latencyMs}ms' : null,
              isActive: wifiState.isBoostActive,
              activeColor: colors.turboBlueLight,
              onTap: () => wifiNotifier.toggleWifiBoost(),
            ),
          ),
          AppSpacing.gapH4,

          // 3. AI Assistant / Guide (Instant Trigger & Dual Heuristic/Cloud Inference)
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.bot,
              label: 'AI',
              isActive: _isAiActive || adviceAsync.valueOrNull != null,
              activeColor: colors.turboBlueLight,
              onTap: () {
                setState(() => _isAiActive = !_isAiActive);
                _requestAdvice();
              },
            ),
          ),
          AppSpacing.gapH4,

          // 4. Voice Changer (Real-Time DSP Mic Modulation & Preset Selector)
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.mic,
              label: 'Voice',
              badge: voiceState.isActive ? voiceState.currentPreset.name : null,
              isActive: voiceState.isActive,
              activeColor: colors.isLight
                  ? colors.turboBlue
                  : ColorTokens.consolePurpleVivid,
              onTap: () => voiceNotifier.toggleVoice(),
              onLongPress: _showVoicePresetSelector,
            ),
          ),
        ],
      ),
    );
  }

  void _showVoicePresetSelector() {
    final colors = ColorTokens.of(context);
    final voiceNotifier = ref.read(voiceChangerProvider.notifier);
    final voiceState = ref.read(voiceChangerProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TACTICAL VOICE PRESETS',
                      style: TypographyTokens.tacticalBadgeOf(ctx).copyWith(
                        fontSize: 11,
                        color: colors.turboBlueLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...kTacticalVoicePresets.map((preset) {
                  final isSelected = preset.id == voiceState.activePresetId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? colors.turboBlueLight : colors.textMuted,
                    ),
                    title: Text(
                      preset.name,
                      style: TypographyTokens.bodySmallOf(ctx).copyWith(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      preset.description,
                      style: TypographyTokens.bodySmallOf(ctx).copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    onTap: () {
                      voiceNotifier.setPreset(preset.id);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? badge,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final colors = ColorTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticHelper.selectionClick();
        onTap();
      },
      onLongPress: onLongPress != null
          ? () {
              HapticHelper.heavyImpact();
              onLongPress();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.pillPaddingVertical - 1,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: colors.isLight ? 0.12 : 0.18)
              : (colors.isLight
                  ? colors.surfaceCard.withValues(alpha: 0.75)
                  : colors.textPrimary.withValues(alpha: 0.08)),
          borderRadius: RadiusTokens.button,
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: colors.isLight ? 0.40 : 0.70)
                : colors.borderGlass,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.p16 - 2,
              color: isActive
                  ? activeColor
                  : colors.textPrimary.withValues(alpha: 0.6),
            ),
            AppSpacing.gapV4,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.telemetryBadge.copyWith(
                fontSize: 8.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? (colors.isLight ? activeColor : colors.textPrimary)
                    : colors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
            if (badge != null)
              Text(
                badge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.telemetryBadge.copyWith(
                  fontSize: 7.0,
                  fontWeight: FontWeight.w700,
                  color: colors.isLight ? activeColor : colors.turboBlueLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering the dynamic tachometer sweep arc, glowing needle pip,
/// and responsive ticks of the central reactor dial.
class _ReactorTachometerPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;
  final Color inactiveTickColor;
  final bool isLight;

  const _ReactorTachometerPainter({
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
  bool shouldRepaint(covariant _ReactorTachometerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.inactiveTickColor != inactiveTickColor ||
      oldDelegate.isLight != isLight;
}
