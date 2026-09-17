import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/data/game_discovery_service.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_storage/owl_storage.dart';

/// Provider exposing the native/platform game discovery service.
final gameDiscoveryServiceProvider = Provider<GameDiscoveryService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GameDiscoveryService(prefs);
});

/// State of discovered games and user selection.
class InstalledGamesState {
  final List<InstalledGame> games;
  final InstalledGame? activeGame;
  final bool isLoading;
  final String? error;

  const InstalledGamesState({
    required this.games,
    this.activeGame,
    this.isLoading = false,
    this.error,
  });

  InstalledGamesState copyWith({
    List<InstalledGame>? games,
    InstalledGame? activeGame,
    bool? isLoading,
    String? error,
  }) {
    return InstalledGamesState(
      games: games ?? this.games,
      activeGame: activeGame ?? this.activeGame,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier controlling the dynamic games list and active deck.
class InstalledGamesNotifier extends StateNotifier<InstalledGamesState> {
  final GameDiscoveryService _service;
  final Ref? _ref;

  InstalledGamesNotifier(this._service, [this._ref])
      : super(const InstalledGamesState(games: [], isLoading: true)) {
    loadGames();
  }

  /// Initial scan and load of games.
  Future<void> loadGames() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final games = await _service.getInstalledGames();
      final savedPkg = _service.getActiveGamePackage();

      InstalledGame? active;
      if (savedPkg != null) {
        active = games.where((g) => g.packageName == savedPkg).firstOrNull;
      }
      active ??= games.firstOrNull;

      if (!mounted) return;
      state = InstalledGamesState(
        games: games,
        activeGame: active,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Switch the active game in Game Space Console.
  void selectGame(InstalledGame game) {
    state = state.copyWith(activeGame: game);
    _service.saveActiveGamePackage(game.packageName);
  }

  /// Select game by index.
  void selectGameByIndex(int index) {
    if (index >= 0 && index < state.games.length) {
      selectGame(state.games[index]);
    }
  }

  /// Toggle whether an installed app is included in Game Space.
  Future<void> toggleGameInSpace(InstalledGame game, bool inSpace) async {
    final updatedGames = state.games.map((g) {
      if (g.packageName == game.packageName) {
        return g.copyWith(isInGameSpace: inSpace);
      }
      return g;
    }).toList();

    // If game was not in list yet, add it
    if (!updatedGames.any((g) => g.packageName == game.packageName)) {
      updatedGames.add(game.copyWith(isInGameSpace: inSpace));
    }

    final enabledPackages = updatedGames
        .where((g) => g.isInGameSpace)
        .map((g) => g.packageName)
        .toList();

    await _service.updateGameSpaceDeck(enabledPackages);

    InstalledGame? active = state.activeGame;
    if (active != null && !inSpace && active.packageName == game.packageName) {
      active = updatedGames.where((g) => g.isInGameSpace).firstOrNull;
    } else if (inSpace && active == null) {
      active = game;
    }

    state = state.copyWith(games: updatedGames, activeGame: active);
  }

  /// Launch the currently active game.
  Future<bool> launchActiveGame() async {
    final game = state.activeGame;
    if (game == null) return false;
    String? apiKey;
    String provider = 'gemini';
    String model = 'gemini-3-flash-preview';
    if (_ref != null) {
      try {
        final settings = _ref.read(gameTurboSettingsProvider);
        provider = settings.activeAiProvider;
        model = settings.activeModel;
        apiKey = await _ref.read(apiKeyManagerProvider).getApiKey(provider);
      } catch (_) {}
    }
    return await _service.launchGame(
      game.packageName,
      gameName: game.name,
      targetFps: game.targetFps,
      aiApiKey: apiKey,
      aiProvider: provider,
      aiModel: model,
    );
  }
}

/// Riverpod provider delivering the reactive installed games controller.
final installedGamesProvider =
    StateNotifierProvider<InstalledGamesNotifier, InstalledGamesState>((ref) {
  final service = ref.watch(gameDiscoveryServiceProvider);
  return InstalledGamesNotifier(service, ref);
});

/// Riverpod selector provider for the active selected game.
final activeGameProvider = Provider<InstalledGame?>((ref) {
  return ref.watch(installedGamesProvider).activeGame;
});
