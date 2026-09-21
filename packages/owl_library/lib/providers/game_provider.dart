import 'package:flutter/foundation.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_mod_studio/owl_mod_studio.dart';
import '../repositories/game_repository.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _gameRepository;
  final PluginRepository _pluginRepository;

  List<Game> _games = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, int> _pluginCounts = {};

  GameProvider({
    required GameRepository gameRepository,
    required PluginRepository pluginRepository,
  })  : _gameRepository = gameRepository,
        _pluginRepository = pluginRepository;

  List<Game> get games => _games;
  List<Game> get installedGames => _games.where((g) => g.isInstalled).toList();
  List<Game> get notInstalledGames => _games.where((g) => !g.isInstalled).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int getPluginCount(String gameId) {
    return _pluginCounts[gameId] ?? 0;
  }

  int getPluginCountForGame(String gameId) => getPluginCount(gameId);

  Future<void> loadGames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _games = await _gameRepository.getGames();
      for (final game in _games) {
        final plugins = await _pluginRepository.getPluginsForGame(game.id);
        _pluginCounts[game.id] = plugins.length;
      }
    } catch (e) {
      _error = 'Failed to load games: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMockInstalled(String gameId) async {
    final game = _games.firstWhere((g) => g.id == gameId);
    await _gameRepository.setMockInstalled(gameId, !game.isInstalled);
    await loadGames();
  }

  Future<void> toggleGameInstalled(String gameId) async {
    await toggleMockInstalled(gameId);
  }
}
