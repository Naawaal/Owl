import 'package:owl_core/owl_core.dart';

class SkinRepository {
  final CatalogRepository _catalogRepository;
  final StorageService? _storageService;

  SkinRepository({
    required CatalogRepository catalogRepository,
    StorageService? storageService,
  })  : _catalogRepository = catalogRepository,
        _storageService = storageService;

  Future<List<SkinPack>> getSkinPacksForGame(String gameId) async {
    if (!_catalogRepository.isLoaded) {
      await _catalogRepository.loadCatalog();
    }
    final all = _catalogRepository.rawSkinPacks;
    final filtered = all.where((s) => s.gameId == gameId).toList();

    final storage = _storageService;
    if (storage == null) return filtered;

    final appliedPackId = storage.getAppliedSkinPackId(gameId);
    final appliedTimestamp = storage.getAppliedSkinTimestamp(gameId);

    final result = <SkinPack>[];
    for (final s in filtered) {
      final isApplied = s.id == appliedPackId;
      result.add(s.copyWith(
        isApplied: isApplied,
        appliedAt: isApplied ? appliedTimestamp : null,
      ));
    }
    return result;
  }

  Future<void> applySkinPack(String gameId, String packId) async {
    await _storageService?.setAppliedSkinPack(gameId, packId);
  }

  Future<void> clearAppliedSkinPack(String gameId) async {
    await _storageService?.clearAppliedSkinPack(gameId);
  }
}
