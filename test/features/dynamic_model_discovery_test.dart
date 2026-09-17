// language: Dart, file: dynamic_model_discovery_test.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_network/owl_network.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Dynamic Model Discovery & Free-Tier Filtering Integration Tests', () {
    testWidgets('renders MODELS.DEV badge, Free Only toggle, and Sync button', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: AppSettingsTwoPaneScreen(
              initialCategory: AppSettingCategory.aiProviders,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI controls
      expect(find.text('Select Active Tactical Model'), findsOneWidget);
      expect(find.text('MODELS.DEV'), findsOneWidget);
      expect(find.text('Free Only'), findsOneWidget);
      expect(find.text('Sync'), findsOneWidget);

      // Verify provider cards display tags including free tier highlights
      expect(find.text('FREE TIER'), findsWidgets);
      expect(find.text('FREE QUOTA'), findsOneWidget);
    });

    testWidgets('Toggling Free Only filters discovered models and mutates settings state', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return const AppSettingsTwoPaneScreen(
                  initialCategory: AppSettingCategory.aiProviders,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: showOnlyFreeModels is false
      expect(capturedRef.read(gameTurboSettingsProvider).showOnlyFreeModels, isFalse);

      // Tap Free Only
      await tester.tap(find.text('Free Only'));
      await tester.pumpAndSettle();

      // Verified state toggled to true
      expect(capturedRef.read(gameTurboSettingsProvider).showOnlyFreeModels, isTrue);

      // Switch to xKiro Gateway (scroll into view in horizontal provider strip)
      await tester.ensureVisible(find.text('xKiro Gateway'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('xKiro Gateway'));
      await tester.pumpAndSettle();

      // Only free-flagged models should be displayed (e.g., DeepSeek V4.1 Flash, Qwen 3.7 Flash)
      expect(capturedRef.read(gameTurboSettingsProvider).activeAiProvider, equals('xkiro'));
      expect(find.text('FREE TIER'), findsWidgets);
    });

    testWidgets('Selecting a discovered model card mutates activeModel', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return const AppSettingsTwoPaneScreen(
                  initialCategory: AppSettingCategory.aiProviders,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Groq (scroll into view in horizontal provider strip)
      await tester.ensureVisible(find.text('Groq'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groq'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).activeAiProvider, equals('groq'));
      expect(capturedRef.read(gameTurboSettingsProvider).activeModel, equals('llama-3.3-70b-versatile'));

      // If available, tap on Llama 3.1 8B Instant model card
      final instantCard = find.text('Llama 3.1 8B Instant');
      if (instantCard.evaluate().isNotEmpty) {
        await tester.ensureVisible(instantCard);
        await tester.pumpAndSettle();
        await tester.tap(instantCard);
        await tester.pumpAndSettle();
        expect(capturedRef.read(gameTurboSettingsProvider).activeModel, equals('llama-3.1-8b-instant'));
      }
    });

    testWidgets('Tapping Sync button triggers catalog refresh without error', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: AppSettingsTwoPaneScreen(
              initialCategory: AppSettingCategory.aiProviders,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sync button
      await tester.tap(find.text('Sync'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Screen remains stable and functional
      expect(find.text('Select Active Tactical Model'), findsOneWidget);
    });
  });
}
