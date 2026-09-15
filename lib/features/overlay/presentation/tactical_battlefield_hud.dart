// language: Dart, file: tactical_battlefield_hud.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl_design/owl_design.dart';

/// Interactive Live Match In-Game HUD with Xiaomi Game Turbo 2026 Overlay.
///
/// Features:
/// - Slim edge handle docked at upper-left bezel
/// - Expandable [GameturboFloatingToolbox]
/// - Minimap Threat Radar with enemy missing indicator
/// - Objective spawn timers (Turtle / Dragon & Lord / Baron)
class TacticalBattlefieldHud extends StatefulWidget {
  const TacticalBattlefieldHud({
    super.key,
    this.activeGame,
  });

  final InstalledGame? activeGame;

  @override
  State<TacticalBattlefieldHud> createState() => _TacticalBattlefieldHudState();
}

class _TacticalBattlefieldHudState extends State<TacticalBattlefieldHud> {
  bool _isToolboxOpen = false;

  void _toggleToolbox(bool open) {
    HapticFeedback.mediumImpact();
    setState(() => _isToolboxOpen = open);
  }

  void _openGpuSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GpuSettingsTwoPaneScreen(
          gameTitle: widget.activeGame?.name ?? 'Mobile Legends: Bang Bang',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Simulated MOBA Battlefield Environment
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [Color(0xFF16252C), Color(0xFF090E13)],
                ),
              ),
              child: CustomPaint(
                painter: _SimulatedBattlefieldGridPainter(),
              ),
            ),
          ),

          // 2. Top Bar Navigation (Exit back to console)
          Positioned(
            top: 14,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Exit Match',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Top-Left Minimap Threat Radar Overlay
          Positioned(
            top: 14,
            left: 14,
            child: _buildMinimapRadar(),
          ),

          // 4. Top-Right Objective Timers Dock
          Positioned(
            top: 50,
            right: 16,
            child: _buildObjectiveTimers(),
          ),

          // 5. Slim Edge Handle (Non-intrusive Game Turbo trigger)
          if (!_isToolboxOpen)
            Positioned(
              top: 14,
              left: 180,
              child: _buildEdgeHandle(),
            ),

          // 6. Floating Xiaomi Game Turbo 2026 Toolbox
          if (_isToolboxOpen)
            Positioned(
              top: 14,
              left: 180,
              child: GameturboFloatingToolbox(
                gameTitle: widget.activeGame?.name ?? 'Mobile Legends: Bang Bang',
                targetFps: widget.activeGame?.targetFps ?? 120,
                onClose: () => _toggleToolbox(false),
                onOpenGpuSettings: _openGpuSettings,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEdgeHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleToolbox(true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xE00E121A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x2EFFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF30D158),
                boxShadow: [
                  BoxShadow(color: Color(0xFF30D158), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '⚡',
              style: TextStyle(fontSize: 10, color: ColorSemantics.turboBlueLight),
            ),
            const SizedBox(width: 4),
            const Text(
              'TURBO 120 FPS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimapRadar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0x5907090E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorSemantics.turboBlue.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorSemantics.turboBlue.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Minimap grid & river
          CustomPaint(
            size: const Size(150, 150),
            painter: _MinimapRiverPainter(),
          ),

          // Danger alert pill at bottom
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x4DFF453A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF453A)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'ENEMY MID MISSING: 18s',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF453A),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveTimers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Turtle / Dragon Pod (Urgent)
        _buildCountdownPod(
          name: 'TURTLE / DRAGON',
          time: '00:38',
          isUrgent: true,
          ringProgress: 0.78,
          ringColor: const Color(0xFFFF453A),
        ),
        const SizedBox(height: 8),

        // Lord / Baron Pod
        _buildCountdownPod(
          name: 'LORD / BARON',
          time: '04:12',
          isUrgent: false,
          ringProgress: 0.32,
          ringColor: ColorSemantics.turboBlue,
        ),
      ],
    );
  }

  Widget _buildCountdownPod({
    required String name,
    required String time,
    required bool isUrgent,
    required double ringProgress,
    required Color ringColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0x33FF453A) : const Color(0xE00E1118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFF453A) : const Color(0x22FFFFFF),
        ),
        boxShadow: isUrgent
            ? [
                BoxShadow(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Progress Gauge Ring
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: ringProgress,
              strokeWidth: 2.8,
              backgroundColor: const Color(0x1AFFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0x8AFFFFFF),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isUrgent ? const Color(0xFFFF453A) : Colors.white,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinimapRiverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = const Color(0x55007AFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // River diagonal line
    canvas.drawLine(const Offset(20, 130), const Offset(130, 20), riverPaint);

    // Ambush danger circle
    final alertCirclePaint = Paint()
      ..color = const Color(0x40FF453A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(75, 75), 18, alertCirclePaint);

    final alertStrokePaint = Paint()
      ..color = const Color(0xFFFF453A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(75, 75), 18, alertStrokePaint);
    canvas.drawCircle(const Offset(75, 75), 5, Paint()..color = const Color(0xFFFF453A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimulatedBattlefieldGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
