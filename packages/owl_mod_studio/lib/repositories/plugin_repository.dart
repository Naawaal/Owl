import 'package:owl_core/owl_core.dart';

class PluginRepository {
  final CatalogRepository _catalogRepository;
  final StorageService? _storageService;

  // ignore: prefer_initializing_formals
  PluginRepository({
    required CatalogRepository catalogRepository,
    StorageService? storageService,
  })  : _catalogRepository = catalogRepository,
        _storageService = storageService;

  Future<List<GamePlugin>> getPluginsForGame(String gameId) async {
    if (!_catalogRepository.isLoaded) {
      await _catalogRepository.loadCatalog();
    }
    final all = _catalogRepository.rawPlugins;
    final filtered = all.where((p) => p.gameIds.contains(gameId)).toList();

    final storage = _storageService;
    if (storage == null) return filtered;

    final result = <GamePlugin>[];
    for (final p in filtered) {
      final isEnabled = storage.isPluginEnabled(gameId, p.id);
      result.add(p.copyWith(isEnabled: isEnabled));
    }
    return result;
  }

  Future<List<GamePlugin>> getAllPlugins() async {
    if (!_catalogRepository.isLoaded) {
      await _catalogRepository.loadCatalog();
    }
    final all = _catalogRepository.rawPlugins;
    return all;
  }

  Future<void> togglePlugin(String gameId, String pluginId, bool enable) async {
    await _storageService?.setPluginEnabled(gameId, pluginId, enable);
  }

  Future<void> setPluginEnabled(String gameId, String pluginId, bool enabled) async {
    await togglePlugin(gameId, pluginId, enabled);
  }
}
