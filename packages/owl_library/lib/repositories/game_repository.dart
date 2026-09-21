import 'package:owl_core/owl_core.dart';

class GameRepository {
  final CatalogRepository _catalogRepository;
  final StorageService? _storageService;
  final LauncherService? _launcherService;

  GameRepository({
    required CatalogRepository catalogRepository,
    StorageService? storageService,
    LauncherService? launcherService,
  })  : _catalogRepository = catalogRepository,
        _storageService = storageService,
        _launcherService = launcherService;

  Future<List<Game>> getGames() async {
    if (!_catalogRepository.isLoaded) {
      await _catalogRepository.loadCatalog();
    }

    final rawGames = _catalogRepository.rawGames;
    final List<Game> resolvedGames = [];

    for (final game in rawGames) {
      bool installed = false;
      final launcher = _launcherService;
      final storage = _storageService;
      if (launcher != null) {
        installed = await launcher.isGameInstalled(
          game.packageName,
          gameId: game.id,
        );
      } else if (storage != null) {
        installed = storage.isMockGameInstalled(game.id);
      }

      resolvedGames.add(game.copyWith(
        isInstalled: installed,
        installedVersion: installed ? game.minVersion : null,
      ));
    }

    return resolvedGames;
  }

  Future<Game?> getGameById(String id) async {
    final games = await getGames();
    final matches = games.where((g) => g.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  Future<void> setMockInstalled(String gameId, bool installed) async {
    await _storageService?.setMockGameInstalled(gameId, installed);
  }
}
