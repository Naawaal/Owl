import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:owl_core/owl_core.dart';
import 'package:owl_library/owl_library.dart';
import 'package:owl_mod_studio/owl_mod_studio.dart';
import 'package:owl_skins/owl_skins.dart';
import 'presentation/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final catalogRepository = CatalogRepository();
  await catalogRepository.loadCatalog();

  final launcherService = LauncherService(storageService);

  final gameRepository = GameRepository(
    catalogRepository: catalogRepository,
    storageService: storageService,
    launcherService: launcherService,
  );

  final pluginRepository = PluginRepository(
    catalogRepository: catalogRepository,
    storageService: storageService,
  );

  final skinRepository = SkinRepository(
    catalogRepository: catalogRepository,
    storageService: storageService,
  );

  runApp(
    OwlApp(
      storageService: storageService,
      catalogRepository: catalogRepository,
      launcherService: launcherService,
      gameRepository: gameRepository,
      pluginRepository: pluginRepository,
      skinRepository: skinRepository,
    ),
  );
}

class OwlApp extends StatelessWidget {
  final StorageService storageService;
  final CatalogRepository catalogRepository;
  final LauncherService launcherService;
  final GameRepository gameRepository;
  final PluginRepository pluginRepository;
  final SkinRepository skinRepository;

  const OwlApp({
    super.key,
    required this.storageService,
    required this.catalogRepository,
    required this.launcherService,
    required this.gameRepository,
    required this.pluginRepository,
    required this.skinRepository,
  });

  @override
  Widget build(BuildContext context) {
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
        title: 'Owl Game Companion',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AppShell(),
      ),
    );
  }
}
