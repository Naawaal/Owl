import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService', () {
    late SharedPreferences prefs;
    late LocalStorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = LocalStorageService(prefs);
    });

    test('defaults match specifications including system theme mode', () {
      expect(service.getThemeMode(), equals(ThemeMode.system));
      expect(service.getActiveGameProfile(), equals('Wild Rift'));
      expect(service.isSoundEnabled(), isTrue);
      expect(service.isHapticEnabled(), isTrue);
      expect(service.getOverlayOpacity(), equals(0.92));
      expect(service.getOverlayScale(), equals(1.00));
    });

    test('persists and retrieves updated values including theme mode', () async {
      await service.setThemeMode(ThemeMode.light);
      expect(service.getThemeMode(), equals(ThemeMode.light));

      await service.setThemeMode(ThemeMode.dark);
      expect(service.getThemeMode(), equals(ThemeMode.dark));

      await service.setThemeMode(ThemeMode.system);
      expect(service.getThemeMode(), equals(ThemeMode.system));
      await service.setActiveGameProfile('Mobile Legends');
      expect(service.getActiveGameProfile(), equals('Mobile Legends'));

      await service.setSoundEnabled(false);
      expect(service.isSoundEnabled(), isFalse);

      await service.setHapticEnabled(false);
      expect(service.isHapticEnabled(), isFalse);

      await service.setOverlayOpacity(0.75);
      expect(service.getOverlayOpacity(), equals(0.75));

      await service.setOverlayScale(1.25);
      expect(service.getOverlayScale(), equals(1.25));
    });

    test('clamps opacity and scale within bounds', () async {
      await service.setOverlayOpacity(1.5);
      expect(service.getOverlayOpacity(), equals(1.0));

      await service.setOverlayOpacity(0.05);
      expect(service.getOverlayOpacity(), equals(0.20));

      await service.setOverlayScale(2.0);
      expect(service.getOverlayScale(), equals(1.50));

      await service.setOverlayScale(0.5);
      expect(service.getOverlayScale(), equals(0.75));
    });

    test('Riverpod notifiers update reactively', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(activeGameProfileProvider), equals('Wild Rift'));
      await container.read(activeGameProfileProvider.notifier).setGame('Pokémon UNITE');
      expect(container.read(activeGameProfileProvider), equals('Pokémon UNITE'));

      expect(container.read(soundEnabledProvider), isTrue);
      await container.read(soundEnabledProvider.notifier).toggle();
      expect(container.read(soundEnabledProvider), isFalse);

      expect(container.read(themeModeProvider), equals(ThemeMode.system));
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      expect(container.read(hapticEnabledProvider), isTrue);
      await container.read(hapticEnabledProvider.notifier).toggle();
      expect(container.read(hapticEnabledProvider), isFalse);
    });
  });

  group('SecureStorageService', () {
    late FlutterSecureStorage rawStorage;
    late SecureStorageService secureService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      rawStorage = const FlutterSecureStorage();
      secureService = SecureStorageService(rawStorage);
    });

    test('saves, retrieves, and deletes BYOK API keys', () async {
      expect(await secureService.getApiKey(AIProvider.gemini), isNull);
      expect(await secureService.hasApiKey(AIProvider.gemini), isFalse);

      await secureService.saveApiKey(AIProvider.gemini, 'gemini-key-12345');
      expect(await secureService.getApiKey(AIProvider.gemini), equals('gemini-key-12345'));
      expect(await secureService.hasApiKey(AIProvider.gemini), isTrue);

      await secureService.deleteApiKey(AIProvider.gemini);
      expect(await secureService.getApiKey(AIProvider.gemini), isNull);
      expect(await secureService.hasApiKey(AIProvider.gemini), isFalse);
    });

    test('clears all provider keys cleanly', () async {
      await secureService.saveApiKey(AIProvider.openAI, 'sk-test-openai');
      await secureService.saveApiKey(AIProvider.anthropic, 'sk-ant-test');

      final statusBefore = await secureService.getProviderStatus();
      expect(statusBefore[AIProvider.openAI], isTrue);
      expect(statusBefore[AIProvider.anthropic], isTrue);

      await secureService.clearAllApiKeys();

      final statusAfter = await secureService.getProviderStatus();
      expect(statusAfter[AIProvider.openAI], isFalse);
      expect(statusAfter[AIProvider.anthropic], isFalse);
    });
  });
}
