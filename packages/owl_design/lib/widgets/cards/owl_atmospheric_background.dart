// language: Dart, file: owl_atmospheric_background.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Signature multi-layered atmospheric background shared across Console, In-Game HUD,
/// and Two-Pane Settings screens.
///
/// Features:
/// - Light Mode: Flagship Sector Shimmer (clean sky & lavender diagonal shimmer
///   with cyan ambient aura at the top edge).
/// - Dark Mode: Deep Obsidian Horizon (rich linear gradient with central purple
///   bloom and rightward ambient blue atmosphere).
class OwlAtmosphericBackground extends StatelessWidget {
  const OwlAtmosphericBackground({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient layer
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: colors.isLight
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.sectorSky.withValues(alpha: 0.75),
                        colors.surfaceCard.withValues(alpha: 0.98),
                        colors.surfaceElevated.withValues(alpha: 0.92),
                        colors.sectorLavender.withValues(alpha: 0.60),
                      ],
                      stops: const [0.0, 0.40, 0.70, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.horizonTop,
                        colors.horizonBottom,
                      ],
                    ),
            ),
          ),
        ),

        // Ambient radial glow layer
        if (colors.isLight)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -1.1),
                  radius: 0.7,
                  colors: [
                    colors.accentCyan.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          )
        else ...[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 0.0),
                  radius: 0.85,
                  colors: [
                    ColorPrimitives.glassPurpleAmbient18,
                    ColorPrimitives.deepAmbient08,
                    colors.consoleBase.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -120,
            top: 0,
            bottom: 0,
            width: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: [
                    ColorPrimitives.ambientBlue.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],

        // Content layer
        if (child != null)
          Positioned.fill(
            child: child!,
          ),
      ],
    );
  }
}
