// language: Dart, file: overlay_edge_rail.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl_design/owl_design.dart';

/// Vertical edge rail indicator that detects drags and taps to reveal the Game Turbo toolbox.
class OverlayEdgeRail extends StatelessWidget {
  const OverlayEdgeRail({
    super.key,
    required this.isRight,
    required this.dragDistance,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
  });

  final bool isRight;
  final double dragDistance;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final pull = dragDistance.clamp(0.0, 72.0);
    final glow = (pull / 72.0).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 72,
        child: Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 3.5 + (pull * 0.04),
            height: 52,
            margin: EdgeInsets.only(
              left: isRight ? 0 : pull * 0.15,
              right: isRight ? pull * 0.15 : 0,
            ),
            decoration: BoxDecoration(
              color: colors.turboBlue.withValues(alpha: 0.55 + glow * 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colors.turboBlueLight.withValues(
                  alpha: 0.45 + glow * 0.4,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.turboBlue.withValues(
                    alpha: 0.25 + glow * 0.35,
                  ),
                  blurRadius: 8 + glow * 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
