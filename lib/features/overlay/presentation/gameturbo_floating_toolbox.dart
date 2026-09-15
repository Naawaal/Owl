// language: Dart, file: gameturbo_floating_toolbox.dart, target: Flutter / Owl Game Turbo
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl_design/owl_design.dart';

/// 1:1 Replica of Xiaomi Game Turbo 2026 Floating In-Game Toolbox (ref_settings_1).
///
/// Features:
/// - Sleek top header bar with Gaming tools title and close button (NO Games tab)
/// - Circular Glowing Reactor FPS Gauge with laser beam flares and dotted ticks
/// - Flanking CPU & GPU progress meters
/// - Capsule Mode Switcher ([Balanced] vs [Performance])
/// - 4 Feature Cards (Enhanced visuals, Network, Memory, Voice changer)
/// - 8 Tools Grid (Screenshot, Record, Mistouch, AI Guide, DND, Comments, Wi-Fi, More tools)
/// - Guardian AI Tactical Co-Pilot banner
class GameturboFloatingToolbox extends StatefulWidget {
  const GameturboFloatingToolbox({
    super.key,
    required this.onClose,
    required this.onOpenGpuSettings,
    this.gameTitle = 'Mobile Legends: Bang Bang',
    this.targetFps = 120,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenGpuSettings;
  final String gameTitle;
  final int targetFps;

  @override
  State<GameturboFloatingToolbox> createState() => _GameturboFloatingToolboxState();
}

class _GameturboFloatingToolboxState extends State<GameturboFloatingToolbox> {
  bool _isPerformanceMode = true;
  bool _isMistouchActive = true;
  bool _isAiGuideActive = true;
  bool _isDndActive = true;
  bool _isWifiBoostActive = true;
  bool _isMemoryCleaned = false;

  void _purgeMemory() {
    HapticFeedback.heavyImpact();
    setState(() => _isMemoryCleaned = true);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _isMemoryCleaned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 356,
      decoration: BoxDecoration(
        color: const Color(0xF210141E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x24FFFFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Sleek Top Header Bar
          _buildHeader(),

          // 2. Central Glowing Reactor FPS Gauge
          _buildReactorGauge(),

          // 3. Segmented Mode Pills (Balanced vs Performance)
          _buildModePills(),

          // 4. Middle 4 Feature Cards (2x2)
          _buildMiddleCards(),

          // 5. Bottom 8 Tools Grid (4x2)
          _buildToolsGrid(),

          // 6. Guardian Live Tactical Banner
          _buildGuardianBanner(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0x660A0D14),
        border: Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚡',
                style: TextStyle(fontSize: 13, color: ColorSemantics.turboCrimson),
              ),
              SizedBox(width: 6),
              Text(
                'Gaming tools',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: Text(
                      '${widget.gameTitle.split(':').first.trim()} ${widget.targetFps} FPS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0x99FFFFFF),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onClose();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x14FFFFFF),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: const Center(
                      child: Icon(Icons.close, size: 12, color: Color(0x99FFFFFF)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactorGauge() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.68,
          colors: [
            ColorSemantics.turboCrimson.withValues(alpha: 0.18),
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
              const Text(
                '15:31',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xA6FFFFFF),
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.battery_charging_full, size: 12, color: Color(0xFF30D158)),
                  SizedBox(width: 3),
                  Text(
                    '88%',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xA6FFFFFF),
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Center Circle with Horizontal Laser Flares
          SizedBox(
            height: 72,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Horizontal Laser Beam
                Positioned(
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          ColorSemantics.turboCrimson.withValues(alpha: 0.4),
                          const Color(0xFFFF5A5F),
                          ColorSemantics.turboCrimson.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFFF3B30),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Color(0x80FF3B30),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Tachometer Dial
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF191E2C), Color(0xFF0D1017)],
                    ),
                    border: Border.all(
                      color: ColorSemantics.turboCrimson.withValues(alpha: 0.85),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorSemantics.turboCrimson.withValues(alpha: 0.6),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _ReactorTickRingPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '帧率',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0x80FFFFFF),
                            height: 1,
                          ),
                        ),
                        Text(
                          '120',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'JetBrains Mono',
                            height: 1,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 12),
                            ],
                          ),
                        ),
                        Text(
                          'FPS',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xB3FFFFFF),
                            letterSpacing: 0.8,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // CPU & GPU Meters
          Row(
            children: [
              Expanded(
                child: _buildMeterUnit(label: 'CPU', value: '30%', progress: 0.30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMeterUnit(label: 'GPU', value: '56%', progress: 0.56),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeterUnit({
    required String label,
    required String value,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0x8AFFFFFF),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(2),
          ),
          clipBehavior: Clip.antiAlias,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorSemantics.turboOrange, ColorSemantics.turboCrimson],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: ColorSemantics.turboCrimson.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModePills() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: const Color(0x73000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isPerformanceMode = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: !_isPerformanceMode ? const Color(0xFF262A36) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Balanced',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: !_isPerformanceMode ? Colors.white : const Color(0x99FFFFFF),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isPerformanceMode = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: _isPerformanceMode ? ColorSemantics.turboRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isPerformanceMode
                      ? [
                          BoxShadow(
                            color: ColorSemantics.turboRed.withValues(alpha: 0.55),
                            blurRadius: 14,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _isPerformanceMode ? Colors.white : const Color(0x99FFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCardTile(
                  name: 'Enhanced visuals',
                  desc: 'Vibrant HDR active',
                  icon: Icons.memory_outlined,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCardTile(
                  name: 'Network',
                  desc: 'Reduce network lag',
                  icon: Icons.language_outlined,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildCardTile(
                  name: _isMemoryCleaned ? 'Cleaned!' : 'Memory',
                  desc: _isMemoryCleaned ? 'Freed 480MB RAM' : 'Free up system RAM',
                  icon: Icons.rocket_launch_outlined,
                  iconColor: ColorSemantics.turboCrimson,
                  onTap: _purgeMemory,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCardTile(
                  name: 'Voice changer',
                  desc: 'Spice up your voice',
                  icon: Icons.mic_none_outlined,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required String name,
    required String desc,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x10FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0x8AFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: 17,
              color: iconColor ?? Colors.white.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolButton(
                label: 'Screenshot',
                icon: Icons.content_cut_outlined,
                onTap: () => HapticFeedback.mediumImpact(),
              ),
              _buildToolButton(
                label: 'Record',
                icon: Icons.videocam_outlined,
                onTap: () => HapticFeedback.mediumImpact(),
              ),
              _buildToolButton(
                label: 'Mistouch',
                icon: Icons.pan_tool_outlined,
                isActive: _isMistouchActive,
                activeColor: ColorSemantics.turboBlueLight,
                onTap: () => setState(() => _isMistouchActive = !_isMistouchActive),
              ),
              _buildToolButton(
                label: 'AI Guide',
                icon: Icons.explore_outlined,
                isActive: _isAiGuideActive,
                activeColor: ColorSemantics.turboCrimson,
                onTap: () => setState(() => _isAiGuideActive = !_isAiGuideActive),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _buildToolButton(
                label: 'DND',
                icon: Icons.notifications_off_outlined,
                isActive: _isDndActive,
                activeColor: ColorSemantics.turboBlueLight,
                onTap: () => setState(() => _isDndActive = !_isDndActive),
              ),
              _buildToolButton(
                label: 'Comments',
                icon: Icons.chat_bubble_outline,
                onTap: () => HapticFeedback.lightImpact(),
              ),
              _buildToolButton(
                label: 'Wi-Fi',
                icon: Icons.wifi,
                isActive: _isWifiBoostActive,
                activeColor: ColorSemantics.turboBlueLight,
                onTap: () => setState(() => _isWifiBoostActive = !_isWifiBoostActive),
              ),
              _buildToolButton(
                label: 'More tools',
                icon: Icons.grid_view_outlined,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onClose();
                  widget.onOpenGpuSettings();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required String label,
    required IconData icon,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final color = isActive ? (activeColor ?? Colors.white) : const Color(0xB3FFFFFF);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuardianBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xA6080B12),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.smart_toy_outlined, size: 11, color: ColorSemantics.turboBlueLight),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'GUARDIAN AI COACH (12s)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: ColorSemantics.turboBlueLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '"Vi burned ult in top river skirmish. Bot dive is safe for next 60s."',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFFE2E8F0),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorSemantics.turboBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: ColorSemantics.turboBlue),
              ),
              child: const Text(
                'COACH CHAT',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: ColorSemantics.turboBlueLight,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering the fine dashed tick ring of the central tachometer dial.
class _ReactorTickRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const tickCount = 48;
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
