// language: Dart, file: tactical_hud_game_stage.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl_design/owl_design.dart';

/// Center game stage card in the Tactical Battlefield HUD.
class TacticalHudGameStage extends StatelessWidget {
  const TacticalHudGameStage({
    super.key,
    this.game,
    required this.onOpenToolbox,
  });

  final InstalledGame? game;
  final VoidCallback onOpenToolbox;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Container(
      width: 520,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.borderXl,
        border: Border.all(color: colors.borderGlass),
        boxShadow: const [ElevationTokens.heroDeep, ElevationTokens.heroBloom],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (game?.iconBytes != null)
            Image.memory(game!.iconBytes!, fit: BoxFit.cover)
          else
            Image.asset(
              'assets/images/wild_rift_splash.jpg',
              fit: BoxFit.cover,
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorComponentTokens.heroScrimTop,
                  ColorComponentTokens.heroScrimMid,
                  ColorComponentTokens.heroScrimBottom,
                ],
                stops: [0.0, 0.45, 0.95],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.md + 2,
            left: AppSpacing.lg - 4,
            right: AppSpacing.lg - 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.zap,
                            size: 14,
                            color: colors.badgeYellow,
                          ),
                          AppSpacing.gapH8,
                          Expanded(
                            child: Text(
                              game?.name ?? 'Game Space Live Match',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TypographyTokens.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: ColorComponentTokens.playWingFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${game?.category ?? 'Gaming Engine'} · Game Turbo Active',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.bodySmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ColorComponentTokens.playWingSubFg,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH12,
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onOpenToolbox,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.pillPaddingVertical,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.turboBlue, colors.turboBlueLight],
                      ),
                      borderRadius: RadiusTokens.button,
                      boxShadow: [
                        BoxShadow(
                          color: colors.turboBlue.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.sliders,
                          size: AppSizes.p12,
                          color: ColorComponentTokens.playWingFg,
                        ),
                        AppSpacing.gapH4,
                        Text(
                          'Open Turbo HUD',
                          style: TypographyTokens.buttonText.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: ColorComponentTokens.playWingFg,
                          ),
                        ),
                      ],
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
}
