import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game.dart';
import '../models/plugin.dart';
import '../models/skin_pack.dart';

class CatalogRepository {
  List<Game> _games = [];
  List<GamePlugin> _plugins = [];
  List<SkinPack> _skinPacks = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<Game> get rawGames => List.unmodifiable(_games);
  List<GamePlugin> get rawPlugins => List.unmodifiable(_plugins);
  List<SkinPack> get rawSkinPacks => List.unmodifiable(_skinPacks);

  Future<void> loadCatalog({String assetPath = 'assets/catalog.json'}) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('games')) {
        final gamesList = data['games'] as List<dynamic>;
        _games = gamesList
            .map((e) => Game.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('plugins')) {
        final pluginsList = data['plugins'] as List<dynamic>;
        _plugins = pluginsList
            .map((e) => GamePlugin.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('skinPacks')) {
        final skinPacksList = data['skinPacks'] as List<dynamic>;
        _skinPacks = skinPacksList
            .map((e) => SkinPack.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _isLoaded = true;
    } catch (e) {
      _games = _fallbackGames();
      _plugins = _fallbackPlugins();
      _skinPacks = _fallbackSkinPacks();
      _isLoaded = true;
    }
  }

  List<Game> _fallbackGames() {
    return const [
      Game(
        id: 'subway_surfers',
        name: 'Subway Surfers',
        packageName: 'com.kiloo.subwaysurf',
        minVersion: '1.0.0',
        category: 'Arcade',
        icon: 'subway_icon',
        description: 'Dash as fast as you can!',
        isInstalled: true,
      ),
      Game(
        id: 'free_fire',
        name: 'Free Fire MAX',
        packageName: 'com.dts.freefiremax',
        minVersion: '2.0.0',
        category: 'Action',
        icon: 'freefire_icon',
        description: 'Battle Royale on mobile.',
        isInstalled: true,
      ),
      Game(
        id: 'pubg_mobile',
        name: 'PUBG MOBILE',
        packageName: 'com.tencent.ig',
        minVersion: '3.0.0',
        category: 'Action',
        icon: 'pubg_icon',
        description: 'The original battle royale.',
        isInstalled: false,
      ),
      Game(
        id: 'candy_crush',
        name: 'Candy Crush Saga',
        packageName: 'com.king.candycrushsaga',
        minVersion: '1.0.0',
        category: 'Puzzle',
        icon: 'candy_icon',
        description: 'Sweet match-3 puzzle game.',
        isInstalled: false,
      ),
    ];
  }

  List<GamePlugin> _fallbackPlugins() {
    return const [
      GamePlugin(
        id: '60fps_unlock',
        name: '60 FPS Unlocker',
        description: 'Unlocks high framerate mode on supported displays.',
        version: '1.2.0',
        gameIds: ['subway_surfers', 'free_fire'],
        compatibleVersions: ['1.0.0', '2.0.0'],
        category: 'Graphics',
        isEnabled: false,
      ),
      GamePlugin(
        id: 'fov_changer',
        name: 'FOV Expander',
        description: 'Increases field of view for wider perspective.',
        version: '1.0.5',
        gameIds: ['free_fire', 'pubg_mobile'],
        compatibleVersions: ['2.0.0', '3.0.0'],
        category: 'Graphics',
        isEnabled: false,
      ),
      GamePlugin(
        id: 'ultra_hd',
        name: 'Ultra HD Textures',
        description: 'Forces high quality textures regardless of thermal state.',
        version: '2.0.1',
        gameIds: ['subway_surfers'],
        compatibleVersions: ['1.0.0'],
        category: 'Graphics',
        isEnabled: false,
      ),
    ];
  }

  List<SkinPack> _fallbackSkinPacks() {
    return [
      SkinPack(
        id: 'neon_rider',
        gameId: 'subway_surfers',
        name: 'Neon Cyber Rider',
        description: 'High-contrast glowing outfit and hoverboard preset.',
        version: '1.0.0',
        author: 'Lulubox Studio',
        accentColor: '#00E5FF',
        previewTags: const ['Cyber', 'Neon', 'HD'],
        isApplied: false,
      ),
      SkinPack(
        id: 'crimson_samurai',
        gameId: 'free_fire',
        name: 'Crimson Samurai',
        description: 'Ancient warrior red armor set with gold trim.',
        version: '2.1.0',
        author: 'ShadowCraft',
        accentColor: '#FF1744',
        previewTags: const ['Warrior', 'Armor'],
        isApplied: false,
      ),
    ];
  }
}
