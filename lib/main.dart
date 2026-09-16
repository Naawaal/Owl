import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl/app/app.dart';
import 'package:owl/app/app_observer.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:owl/app/router/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Outfit is bundled in assets/fonts — never fetch at runtime so the
  // design system renders identically online and offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Enforce true landscape orientation across all devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive edge-to-edge gaming mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();

  // Re-apply persisted hardware state (performance mode, FPS target) before
  // the first frame so native matches storage on every cold start.
  try {
    final bootContainer = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await bootContainer
        .read(gameTurboSettingsProvider.notifier)
        .applyPersistedHardwareState();
    await bootContainer
        .read(gameTurboSettingsProvider.notifier)
        .migrateLegacyPayloadIfNeeded();
    bootContainer.dispose();
  } catch (_) {}

  runApp(
    ProviderScope(
      observers: const [AppObserver()],
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const OwlApp(initialRoute: AppRoutes.console),
    ),
  );
}
