// language: Dart, file: game_stage_launch_bar.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl_design/owl_design.dart';

/// Play wing button pinned to the right edge of the main stage.
class GamePlayWing extends StatelessWidget {
  const GamePlayWing({
    super.key,
    required this.activeGame,
    required this.onPlay,
  });

  final InstalledGame? activeGame;
  final void Function(InstalledGame? activeGame) onPlay;

  @override
  Widget build(BuildContext context) {
    final owlColors = ColorTokens.of(context);
    return SizedBox(
      width: 175,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onPlay(activeGame),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 175,
            height: 114,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [owlColors.playWingStart, owlColors.playWingEnd],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              border: Border.all(
                color: owlColors.isLight
                    ? owlColors.turboBlue.withValues(alpha: 0.25)
                    : owlColors.textPrimary.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [ElevationTokens.playWingShadow(owlColors.isLight)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -14,
                    top: -10,
                    bottom: -10,
                    child: Container(
                      width: 1.5,
                      color: ColorComponentTokens.playWingBorder,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: ColorPrimitives.scrimWhite50,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 17,
                            color: ColorComponentTokens.playWingFg,
                          ),
                          const SizedBox(width: 6),
                          Text('Play', style: TypographyTokens.playWingTitle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Game Turbo can turn on automatically',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.playWingSubtitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom GPU settings tab pinned to the center bottom of the stage.
class GameGpuTab extends StatelessWidget {
  const GameGpuTab({
    super.key,
    required this.activeGame,
    required this.onOpenGpuSettings,
  });

  final InstalledGame? activeGame;
  final void Function(InstalledGame? activeGame) onOpenGpuSettings;

  @override
  Widget build(BuildContext context) {
    final owlColors = ColorTokens.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onOpenGpuSettings(activeGame),
        child: CustomPaint(
          painter: GpuTabBorderPainter(
            borderColor: owlColors.isLight
                ? owlColors.borderGlassStrong
                : ColorPrimitives.glassWhite15,
            fillColor: owlColors.gpuTabFill,
            shadowColor: owlColors.isLight
                ? owlColors.textPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Container(
            width: 240,
            height: 40,
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: owlColors.turboBlue,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: owlColors.turboBlue.withValues(
                          alpha: owlColors.isLight ? 0.35 : 0.45,
                        ),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GPU settings',
                  style: TypographyTokens.gpuTabLabel.copyWith(
                    color: owlColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Beveled GPU tab trapezoid painter shared by Console and HUD.
class GpuTabBorderPainter extends CustomPainter {
  const GpuTabBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
  });

  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.10, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width, size.height)
      ..close();

    if (shadowColor.a > 0) {
      canvas.drawShadow(path, shadowColor, 8.0, false);
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.10, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant GpuTabBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
