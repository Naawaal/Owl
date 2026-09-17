// language: Dart, file: game_space_main_stage.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/game_profiles/presentation/widgets/game_card_carousel.dart';
import 'package:owl/features/game_profiles/presentation/widgets/game_deck_sidebar.dart';
import 'package:owl/features/game_profiles/presentation/widgets/game_stage_launch_bar.dart';

export 'game_stage_launch_bar.dart' show GpuTabBorderPainter;

/// Shared Console / HUD main stage: sidebar, cinematic hero, Play wing, GPU tab.
///
/// Refactored orchestrator shell delegating to [GameDeckSidebar], [GameCardCarousel],
/// [GamePlayWing], and [GameGpuTab].
class GameSpaceMainStage extends ConsumerWidget {
  const GameSpaceMainStage({
    super.key,
    required this.onOpenAddGames,
    required this.onPlay,
    required this.onOpenGpuSettings,
  });

  final VoidCallback onOpenAddGames;
  final void Function(InstalledGame? activeGame) onPlay;
  final void Function(InstalledGame? activeGame) onOpenGpuSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(installedGamesProvider);
    final deckGames = gameState.games.where((g) => g.isInGameSpace).toList();
    final activeGame = gameState.activeGame ?? deckGames.firstOrNull;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: GameDeckSidebar(
                    deckGames: deckGames,
                    activeGame: activeGame,
                    onOpenAddGames: onOpenAddGames,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GameCardCarousel(
                          activeGame: activeGame,
                          deckGames: deckGames,
                        ),
                      ),
                    ),
                  ),
                ),
                GamePlayWing(
                  activeGame: activeGame,
                  onPlay: onPlay,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GameGpuTab(
              activeGame: activeGame,
              onOpenGpuSettings: onOpenGpuSettings,
            ),
          ),
        ],
      ),
    );
  }
}
