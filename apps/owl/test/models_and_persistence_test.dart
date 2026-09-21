import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl_core/owl_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Models JSON serialization', () {
    test('Game model serializes and deserializes', () {
      final json = {
        'id': 'subway-surfers',
        'name': 'Subway Surfers',
        'packageName': 'com.kiloo.subwaysurf',
        'minVersion': '3.15.0',
        'category': 'Runner',
        'icon': 'train',
        'description': 'Dash through tracks',
        'isInstalled': true,
        'installedVersion': '3.15.0',
      };

      final game = Game.fromJson(json);
      expect(game.id, 'subway-surfers');
      expect(game.name, 'Subway Surfers');
      expect(game.isInstalled, true);
      expect(game.installedVersion, '3.15.0');

      final serialized = game.toJson();
      expect(serialized['id'], 'subway-surfers');
      expect(serialized['isInstalled'], true);
    });

    test('GamePlugin model handles compatibility correctly', () {
      const plugin = GamePlugin(
        id: 'fps-booster',
        name: 'FPS Booster',
        description: 'Smooth 60 fps',
        version: '1.0.0',
        gameIds: ['subway-surfers'],
        compatibleVersions: ['3.15.0', '3.16.0'],
        category: 'Performance',
      );

      expect(plugin.isCompatibleWith('3.15.0'), isTrue);
      expect(plugin.isCompatibleWith('3.16.0'), isTrue);
      expect(plugin.isCompatibleWith('2.0.0'), isFalse);
    });

    test('SkinPack model handles JSON and applied states', () {
      final json = {
        'id': 'cyber-pack',
        'gameId': 'subway-surfers',
        'name': 'Cyber Skin',
        'description': 'Neon theme',
        'version': '1.2.0',
        'author': 'Neo',
        'accentColor': '#00FFCC',
        'previewTags': ['Cyber', 'Neon'],
        'isApplied': true,
        'appliedAt': '2026-09-21T10:00:00.000Z',
      };

      final skin = SkinPack.fromJson(json);
      expect(skin.id, 'cyber-pack');
      expect(skin.isApplied, isTrue);
      expect(skin.appliedAt, isNotNull);
      expect(skin.previewTags.length, 2);
    });
  });

  group('StorageService Persistence', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
    });

    test('Persists and retrieves plugin toggle', () async {
      expect(storageService.isPluginEnabled('subway-surfers', 'fps-boost'), isFalse);

      await storageService.setPluginEnabled('subway-surfers', 'fps-boost', true);
      expect(storageService.isPluginEnabled('subway-surfers', 'fps-boost'), isTrue);

      await storageService.setPluginEnabled('subway-surfers', 'fps-boost', false);
      expect(storageService.isPluginEnabled('subway-surfers', 'fps-boost'), isFalse);
    });

    test('Persists applied skin pack and tracks previous version on replace', () async {
      expect(storageService.getAppliedSkinPackId('subway-surfers'), isNull);

      await storageService.setAppliedSkinPack('subway-surfers', 'cyber-neon');
      expect(storageService.getAppliedSkinPackId('subway-surfers'), 'cyber-neon');
      expect(storageService.getAppliedSkinTimestamp('subway-surfers'), isNotNull);

      // Re-apply another pack saves previous pack id
      await storageService.setAppliedSkinPack('subway-surfers', 'golden-era');
      expect(storageService.getAppliedSkinPackId('subway-surfers'), 'golden-era');
      expect(storageService.getPreviousAppliedSkinPackId('subway-surfers'), 'cyber-neon');

      // Clear applied skin
      await storageService.clearAppliedSkinPack('subway-surfers');
      expect(storageService.getAppliedSkinPackId('subway-surfers'), isNull);
      expect(storageService.getAppliedSkinTimestamp('subway-surfers'), isNull);
    });
  });
}
