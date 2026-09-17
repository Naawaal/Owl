// language: Dart, file: game_card_carousel.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Center hero carousel displaying cover art, triple-kill preview, and title shaders.
class GameCardCarousel extends ConsumerWidget {
  const GameCardCarousel({
    super.key,
    required this.activeGame,
    required this.deckGames,
  });

  final InstalledGame? activeGame;
  final List<InstalledGame> deckGames;

  void _switchGameDelta(WidgetRef ref, int delta, int activeIndex) {
    if (deckGames.isEmpty) return;
    HapticHelper.selectionClick();
    final newIndex = (activeIndex + delta).clamp(0, deckGames.length - 1);
    final target = deckGames[newIndex];
    ref.read(installedGamesProvider.notifier).selectGame(target);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owlColors = ColorTokens.of(context);
    final activeHeroIndex =
        (activeGame != null && deckGames.contains(activeGame))
            ? deckGames.indexOf(activeGame!)
            : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final vel = details.primaryVelocity;
            if (vel != null) {
              if (vel < -200) {
                _switchGameDelta(ref, 1, activeHeroIndex);
              } else if (vel > 200) {
                _switchGameDelta(ref, -1, activeHeroIndex);
              }
            }
          },
          child: Container(
            width: 500,
            height: 295,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: owlColors.isLight
                    ? owlColors.borderGlassStrong
                    : ColorComponentTokens.heroCardBorder,
              ),
              boxShadow: ElevationTokens.heroShadows(owlColors.isLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/wild_rift_splash.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
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
                      stops: [0.0, 0.4, 0.9],
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 22,
                  child: Container(
                    width: 290,
                    height: 165,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorComponentTokens.goldBorder,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        ElevationTokens.toolboxDeep,
                        BoxShadow(
                          color: ColorPrimitives.goldGlow25,
                          blurRadius: 20,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/moba_gameplay_bg.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.7,
                              colors: [
                                Colors.transparent,
                                ColorPrimitives.scrimBlack60,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorComponentTokens.tripleKillBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: ColorTokens.goldSolid,
                                ),
                                boxShadow: const [ElevationTokens.goldBadge],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 10,
                                    color: ColorTokens.goldSolid,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'TRIPLE KILL',
                                    style: TypographyTokens.tripleKillLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorTokens.textPrimary,
                            ColorPrimitives.goldPale,
                            ColorPrimitives.amberWarning,
                            ColorPrimitives.goldDeep,
                          ],
                          stops: [0.0, 0.4, 0.8, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          activeGame?.name.toUpperCase() ??
                              '5V5 ACTION GAMEPLAY',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.heroHeadline,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          gradient: LinearGradient(
                            colors: [
                              owlColors.consolePurple.withValues(alpha: 0.5),
                              owlColors.consolePurpleVivid.withValues(
                                alpha: 0.85,
                              ),
                              owlColors.consolePurple.withValues(alpha: 0.5),
                            ],
                          ),
                          border: Border.all(
                            color: ColorComponentTokens.subpillBorder,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: ColorPrimitives.subpillGlow40,
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: owlColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SKILL LEADS TO VICTORY',
                              style: TypographyTokens.subpillLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapV12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isActive = index == activeHeroIndex;
            return GestureDetector(
              onTap: () {
                HapticHelper.selectionClick();
                if (deckGames.isNotEmpty) {
                  final target = deckGames[index % deckGames.length];
                  ref.read(installedGamesProvider.notifier).selectGame(target);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 14,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? owlColors.turboBlue
                      : owlColors.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: owlColors.turboBlue.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
