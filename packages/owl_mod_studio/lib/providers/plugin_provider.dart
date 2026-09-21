import 'package:flutter/foundation.dart';
import 'package:owl_core/owl_core.dart';
import '../repositories/plugin_repository.dart';

class ToggleResult {
  final bool success;
  final String? errorMessage;

  const ToggleResult.success()
      : success = true,
        errorMessage = null;

  const ToggleResult.blocked(this.errorMessage) : success = false;
}

class PluginProvider extends ChangeNotifier {
  final PluginRepository _pluginRepository;

  final Map<String, List<GamePlugin>> _gamePlugins = {};
  bool _isLoading = false;
  String? _error;

  // ignore: prefer_initializing_formals
  PluginProvider({required PluginRepository pluginRepository})
      : _pluginRepository = pluginRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<GamePlugin> getPluginsForGame(String gameId) {
    return _gamePlugins[gameId] ?? [];
  }

  List<GamePlugin> getEnabledPlugins(String gameId) {
    final list = _gamePlugins[gameId] ?? [];
    return list.where((p) => p.isEnabled).toList();
  }

  Future<void> loadPluginsForGame(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plugins = await _pluginRepository.getPluginsForGame(gameId);
      _gamePlugins[gameId] = plugins;
    } catch (e) {
      _error = 'Failed to load plugins: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ToggleResult> togglePlugin(Game game, GamePlugin plugin, bool enable) async {
    // Version compatibility check
    if (enable && !plugin.isCompatibleWith(game.installedVersion)) {
      return ToggleResult.blocked(
        'Version mismatch: Plugin requires version ${plugin.compatibleVersions.join(", ")}, '
        'but installed version is ${game.installedVersion ?? "unknown"}.',
      );
    }

    try {
      await _pluginRepository.togglePlugin(game.id, plugin.id, enable);

      // Update in-memory state
      final currentList = _gamePlugins[game.id] ?? [];
      final updatedList = currentList.map((p) {
        if (p.id == plugin.id) {
          return p.copyWith(isEnabled: enable);
        }
        return p;
      }).toList();
      _gamePlugins[game.id] = updatedList;
      notifyListeners();

      return const ToggleResult.success();
    } catch (e) {
      return ToggleResult.blocked('Failed to toggle plugin: $e');
    }
  }
}
