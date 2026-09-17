// language: Dart, file: game_deck_sidebar.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Left sidebar listing installed games in the Game Space deck.
class GameDeckSidebar extends ConsumerWidget {
  const GameDeckSidebar({
    super.key,
    required this.deckGames,
    required this.activeGame,
    required this.onOpenAddGames,
  });

  final List<InstalledGame> deckGames;
  final InstalledGame? activeGame;
  final VoidCallback onOpenAddGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owlColors = ColorTokens.of(context);
    return SizedBox(
      width: 188,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deckGames.isEmpty)
            GestureDetector(
              onTap: onOpenAddGames,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: owlColors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: owlColors.borderGlassStrong),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: owlColors.turboBlueLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add First Game',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.statusMicro.copyWith(
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: deckGames.length,
                itemBuilder: (context, index) {
                  final game = deckGames[index];
                  final isActive = game.packageName == activeGame?.packageName;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticHelper.selectionClick();
                      ref
                          .read(installedGamesProvider.notifier)
                          .selectGame(game);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (owlColors.isLight
                                ? owlColors.turboBlue.withValues(alpha: 0.08)
                                : owlColors.textPrimary
                                    .withValues(alpha: 0.08))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? (owlColors.isLight
                                  ? owlColors.turboBlue.withValues(alpha: 0.25)
                                  : owlColors.textPrimary.withValues(
                                      alpha: 0.08,
                                    ))
                              : Colors.transparent,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: owlColors.isLight
                                      ? owlColors.turboBlue.withValues(
                                          alpha: 0.08,
                                        )
                                      : ColorPrimitives.segTrackBlack40,
                                  blurRadius: owlColors.isLight ? 12 : 20,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ColorComponentTokens.gameboxStart,
                                      ColorComponentTokens.gameboxEnd,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: ColorPrimitives.glassWhite15,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: game.iconBytes != null
                                    ? Image.memory(
                                        game.iconBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.sports_esports_outlined,
                                        color: owlColors.textPrimary
                                            .withValues(alpha: 0.54),
                                        size: 22,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 1,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: ColorComponentTokens.gameboxBadgeBg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    game.category.contains('MOBA')
                                        ? '5v5'
                                        : '${game.targetFps}F',
                                    style: TypographyTokens.telemetryBadge
                                        .copyWith(
                                      fontWeight: FontWeight.w900,
                                      color:
                                          ColorComponentTokens.gameboxBadgeFg,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              game.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TypographyTokens.titleSmall.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? owlColors.textPrimary
                                    : owlColors.textSecondary,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
