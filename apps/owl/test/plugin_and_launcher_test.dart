import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_mod_studio/owl_mod_studio.dart';
import 'package:owl_skins/owl_skins.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late CatalogRepository catalogRepository;
  late PluginRepository pluginRepository;
  late SkinRepository skinRepository;
  late LauncherService launcherService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    catalogRepository = CatalogRepository();
    // loadCatalog with default mocks
    await catalogRepository.loadCatalog();

    pluginRepository = PluginRepository(
      catalogRepository: catalogRepository,
      storageService: storageService,
    );

    skinRepository = SkinRepository(
      catalogRepository: catalogRepository,
      storageService: storageService,
    );

    launcherService = LauncherService(storageService);
  });

  group('LauncherService', () {
    test('reports not installed when game is uninstalled', () async {
      await storageService.setMockGameInstalled('uninstalled-game', false);
      final result = await launcherService.launchGame(
        'com.fake.uninstalled',
        gameId: 'uninstalled-game',
      );
      expect(result.isSuccess, isFalse);
      expect(result.status, LaunchStatus.notInstalled);
    });

    test('launches successfully when game is installed', () async {
      await storageService.setMockGameInstalled('installed-game', true);
      final result = await launcherService.launchGame(
        'com.fake.installed',
        gameId: 'installed-game',
        simulateSuccessOnNonAndroid: true,
      );
      expect(result.isSuccess, isTrue);
    });
  });

  group('PluginProvider', () {
    test('blocks incompatible plugin version', () async {
      final pluginProvider = PluginProvider(pluginRepository: pluginRepository);
      const game = Game(
        id: 'pubg-mobile',
        name: 'PUBG',
        packageName: 'com.tencent.ig',
        minVersion: '2.8.0',
        category: 'Battle Royale',
        icon: 'shield',
        description: 'Action',
        isInstalled: true,
        installedVersion: '2.8.0',
      );

      const incompatiblePlugin = GamePlugin(
        id: 'legacy-patch',
        name: 'Legacy Patch',
        description: 'Old version only',
        version: '0.9.0',
        gameIds: ['pubg-mobile'],
        compatibleVersions: ['2.5.0'],
        category: 'Legacy',
      );

      final result = await pluginProvider.togglePlugin(game, incompatiblePlugin, true);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Version mismatch'));
    });

    test('enables compatible plugin and saves toggle', () async {
      final pluginProvider = PluginProvider(pluginRepository: pluginRepository);
      const game = Game(
        id: 'subway-surfers',
        name: 'Subway Surfers',
        packageName: 'com.kiloo.subwaysurf',
        minVersion: '3.15.0',
        category: 'Runner',
        icon: 'train',
        description: 'Runner',
        isInstalled: true,
        installedVersion: '3.15.0',
      );

      await pluginProvider.loadPluginsForGame('subway-surfers');
      final plugins = pluginProvider.getPluginsForGame('subway-surfers');
      expect(plugins.isNotEmpty, isTrue);

      final targetPlugin = plugins.first;
      final result = await pluginProvider.togglePlugin(game, targetPlugin, true);
      expect(result.success, isTrue);

      // Verify persistence in storage
      expect(storageService.isPluginEnabled('subway-surfers', targetPlugin.id), isTrue);
    });
  });

  group('SkinProvider', () {
    test('applies skin and clears defaults', () async {
      final skinProvider = SkinProvider(skinRepository: skinRepository);
      await skinProvider.loadSkinPacksForGame('subway-surfers');

      final packs = skinProvider.getSkinPacksForGame('subway-surfers');
      expect(packs.isNotEmpty, isTrue);

      final targetPack = packs.first;
      await skinProvider.applySkinPack('subway-surfers', targetPack);

      expect(skinProvider.getAppliedSkinPack('subway-surfers')?.id, targetPack.id);
      expect(storageService.getAppliedSkinPackId('subway-surfers'), targetPack.id);

      // Clear skin
      await skinProvider.clearAppliedSkin('subway-surfers');
      expect(skinProvider.getAppliedSkinPack('subway-surfers'), isNull);
      expect(storageService.getAppliedSkinPackId('subway-surfers'), isNull);
    });
  });
}
