// language: Dart, file: gameturbo_floating_toolbox.dart, target: Flutter / Owl Game Turbo
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
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
  bool _isVoiceChangerActive = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: const Color(0xF50D111A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.88),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: ColorSemantics.turboBlue.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Compact Header Bar (FPS badge removed)
          _buildHeader(settings),

          // 2. Signature Circular Reactor FPS Gauge + Horizontal Live Telemetry Strip
          _buildReactorGauge(settings),

          // 3. Segmented Mode Capsule (Balanced vs Performance)
          _buildModePills(settings, notifier),

          // 4. Essential 4 Tools (DND, Wi-Fi, AI, Voice Changer)
          _buildEssentialTools(settings, notifier),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildHeader(GameTurboSettings settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0x66080B12),
        border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⚡',
                  style: TextStyle(fontSize: 12, color: ColorSemantics.turboCrimson),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Gaming tools',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
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
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0x1AFFFFFF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(LucideIcons.x, size: 11, color: const Color(0xCCFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactorGauge(GameTurboSettings settings) {
    final isPerf = settings.performanceOptimization;
    final accentColor =
        isPerf ? ColorSemantics.turboCrimson : ColorSemantics.turboBlueLight;

    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;

    // Real-time values
    final battery = stats?.battery ?? 78;
    final cpu = stats?.cpu ?? (isPerf ? 32 : 18);
    final gpu = stats?.gpu ?? (isPerf ? 58 : 34);
    final liveFps = stats?.fps ?? (isPerf ? widget.targetFps : 60);
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
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.75,
          colors: [
            accentColor.withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Top Meta (Clock & Battery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xA6FFFFFF),
                  fontFamily: TypographyTokens.monoFontFamily,
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
                        ? const Color(0xFFE63946)
                        : battery <= 40
                            ? const Color(0xFFEAB308)
                            : const Color(0xFF30D158),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$battery%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xA6FFFFFF),
                      fontFamily: TypographyTokens.monoFontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Center Circular Tachometer Dial with Laser Flares
          SizedBox(
            height: 66,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Horizontal Laser Beam
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
                              ? const Color(0xFFFF5A5F)
                              : const Color(0xFF64B5F6),
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
                    color: const Color(0xF2070A10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dotted tick ring
                      CustomPaint(
                        size: const Size(66, 66),
                        painter: _ReactorTickRingPainter(),
                      ),

                      // Central FPS Live Counter & Unit (Chinese label removed)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fpsText,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: TypographyTokens.monoFontFamily,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'FPS',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              fontFamily: TypographyTokens.monoFontFamily,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

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
                        const Text(
                          'CPU',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0x80FFFFFF),
                          ),
                        ),
                        Text(
                          cpuText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: TypographyTokens.monoFontFamily,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3.5,
                        color: const Color(0x24FFFFFF),
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
              const SizedBox(width: 14),

              // GPU Meter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GPU',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0x80FFFFFF),
                          ),
                        ),
                        Text(
                          gpuText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: TypographyTokens.monoFontFamily,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3.5,
                        color: const Color(0x24FFFFFF),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: gpuProgress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFFA78BFA),
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
    final isPerf = settings.performanceOptimization;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          // 1. Balanced Mode Pill
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.togglePerformanceOptimization(false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7.5),
                decoration: BoxDecoration(
                  gradient: !isPerf
                      ? const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF0055B8)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: !isPerf
                      ? [
                          BoxShadow(
                            color: ColorSemantics.turboBlue.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Balanced',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: !isPerf ? Colors.white : const Color(0x80FFFFFF),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 2. Performance Mode Pill
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.heavyImpact();
                notifier.togglePerformanceOptimization(true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7.5),
                decoration: BoxDecoration(
                  gradient: isPerf
                      ? const LinearGradient(
                          colors: [Color(0xFFFF3B30), Color(0xFFE63946)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isPerf
                      ? [
                          BoxShadow(
                            color: ColorSemantics.turboCrimson.withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPerf ? Colors.white : const Color(0x80FFFFFF),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
      child: Row(
        children: [
          // 1. DND (Block notifications)
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.bellOff,
              label: 'DND',
              isActive: settings.restrictFloatingNotifications,
              activeColor: ColorSemantics.turboCrimson,
              onTap: () => notifier.toggleRestrictFloatingNotifications(
                  !settings.restrictFloatingNotifications),
            ),
          ),
          const SizedBox(width: 5),

          // 2. Wi-Fi Speed Boost
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.wifi,
              label: 'Wi-Fi',
              isActive: settings.wifiSpeedBoost,
              activeColor: ColorSemantics.turboBlueLight,
              onTap: () =>
                  notifier.toggleWifiSpeedBoost(!settings.wifiSpeedBoost),
            ),
          ),
          const SizedBox(width: 5),

          // 3. AI Assistant / Guide
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.bot,
              label: 'AI',
              isActive: _isAiActive,
              activeColor: ColorSemantics.turboBlueLight,
              onTap: () => setState(() => _isAiActive = !_isAiActive),
            ),
          ),
          const SizedBox(width: 5),

          // 4. Voice Changer
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.mic,
              label: 'Voice',
              isActive: _isVoiceChangerActive,
              activeColor: const Color(0xFFA855F7),
              onTap: () => setState(
                  () => _isVoiceChangerActive = !_isVoiceChangerActive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.18)
              : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.7)
                : const Color(0x1FFFFFFF),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : const Color(0x99FFFFFF),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0x99FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering the fine dashed tick ring of the central tachometer dial.
class _ReactorTickRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const tickCount = 40;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i * 2 * math.pi) / tickCount;
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      final x2 = center.dx + (radius - 2.5) * math.cos(angle);
      final y2 = center.dy + (radius - 2.5) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
