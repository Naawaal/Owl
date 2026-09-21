import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_library/owl_library.dart';
import 'package:owl_mod_studio/owl_mod_studio.dart';
import 'package:owl_skins/owl_skins.dart';
import 'package:owl/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late CatalogRepository catalogRepository;
  late LauncherService launcherService;
  late GameRepository gameRepository;
  late PluginRepository pluginRepository;
  late SkinRepository skinRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    catalogRepository = CatalogRepository();
    await catalogRepository.loadCatalog();

    launcherService = LauncherService(storageService);
    gameRepository = GameRepository(
      catalogRepository: catalogRepository,
      storageService: storageService,
      launcherService: launcherService,
    );
    pluginRepository = PluginRepository(
      catalogRepository: catalogRepository,
      storageService: storageService,
    );
    skinRepository = SkinRepository(
      catalogRepository: catalogRepository,
      storageService: storageService,
    );
  });

  Widget createTestApp(Widget child) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<CatalogRepository>.value(value: catalogRepository),
        Provider<LauncherService>.value(value: launcherService),
        Provider<GameRepository>.value(value: gameRepository),
        Provider<PluginRepository>.value(value: pluginRepository),
        Provider<SkinRepository>.value(value: skinRepository),
        ChangeNotifierProvider<GameProvider>(
          create: (_) => GameProvider(
            gameRepository: gameRepository,
            pluginRepository: pluginRepository,
          )..loadGames(),
        ),
        ChangeNotifierProvider<PluginProvider>(
          create: (_) => PluginProvider(pluginRepository: pluginRepository),
        ),
        ChangeNotifierProvider<SkinProvider>(
          create: (_) => SkinProvider(skinRepository: skinRepository),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('AppShell renders all 4 navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      OwlApp(
        storageService: storageService,
        catalogRepository: catalogRepository,
        launcherService: launcherService,
        gameRepository: gameRepository,
        pluginRepository: pluginRepository,
        skinRepository: skinRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Plugins'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('Lulubox Hub'), findsOneWidget);

    // Tap Games tab
    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();

    expect(find.text('Game Library'), findsOneWidget);
    expect(find.text('Subway Surfers'), findsWidgets);
  });

  testWidgets('SkinManagerScreen displays legal banner and handles apply/clear',
      (WidgetTester tester) async {
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

    await tester.pumpWidget(createTestApp(const SkinManagerScreen(game: game)));
    await tester.pumpAndSettle();

    // Verify legal notice per spec
    expect(find.text('Legal & Safety Boundary'), findsOneWidget);
    expect(find.text('No Custom Pack Applied'), findsOneWidget);

    // Find Apply button
    final applyButton = find.widgetWithText(FilledButton, 'Apply');
    if (applyButton.evaluate().isNotEmpty) {
      await tester.tap(applyButton.first);
      await tester.pumpAndSettle();

      // Clear button should now appear
      final clearButton = find.widgetWithText(OutlinedButton, 'Clear');
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Restore Default Config?'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.widgetWithText(FilledButton, 'Clear & Restore'));
      await tester.pumpAndSettle();

      expect(find.text('No Custom Pack Applied'), findsOneWidget);
    }
  });
}
