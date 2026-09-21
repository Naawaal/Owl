import 'package:flutter/foundation.dart';
import 'package:owl_core/owl_core.dart';
import '../repositories/skin_repository.dart';

class SkinProvider extends ChangeNotifier {
  final SkinRepository _skinRepository;

  final Map<String, List<SkinPack>> _gameSkins = {};
  bool _isLoading = false;
  String? _statusMessage;

  SkinProvider({required SkinRepository skinRepository})
      : _skinRepository = skinRepository;

  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;

  List<SkinPack> getSkinPacksForGame(String gameId) {
    return _gameSkins[gameId] ?? [];
  }

  SkinPack? getAppliedSkinPack(String gameId) {
    final list = _gameSkins[gameId] ?? [];
    final matches = list.where((p) => p.isApplied);
    return matches.isNotEmpty ? matches.first : null;
  }

  Future<void> loadSkinPacksForGame(String gameId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final packs = await _skinRepository.getSkinPacksForGame(gameId);
      _gameSkins[gameId] = packs;
    } catch (e) {
      _statusMessage = 'Failed to load skins: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySkinPack(String gameId, SkinPack pack) async {
    try {
      await _skinRepository.applySkinPack(gameId, pack.id);
      await loadSkinPacksForGame(gameId);
      _statusMessage = 'Applied ${pack.name} successfully.';
    } catch (e) {
      _statusMessage = 'Failed to apply skin: $e';
    }
    notifyListeners();
  }

  Future<void> clearAppliedSkin(String gameId) async {
    try {
      await _skinRepository.clearAppliedSkinPack(gameId);
      await loadSkinPacksForGame(gameId);
      _statusMessage = 'Cleared applied custom skin pack.';
    } catch (e) {
      _statusMessage = 'Failed to clear skin: $e';
    }
    notifyListeners();
  }
}
