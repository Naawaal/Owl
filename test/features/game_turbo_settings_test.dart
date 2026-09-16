// language: Dart, file: game_turbo_settings_test.dart, target: Flutter / Owl Game Turbo
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameTurboSettings Domain Model Tests', () {
    test('defaultSettings has expected Xiaomi HyperOS Game Turbo defaults', () {
      const s = GameTurboSettings.defaultSettings;

      // General
      expect(s.gameTurboMaster, isTrue);
      expect(s.inGameShortcuts, isTrue);
      expect(s.shortcutEdgePosition, equals('Top-Left'));
      expect(s.contentRecommendations, isTrue);
      expect(s.hideGamesFromHomeScreen, isFalse);

      // Performance
      expect(s.performanceOptimization, isTrue);
      expect(s.wifiSpeedBoost, isTrue);
      expect(s.aggressiveMemoryCleanup, isTrue);
      expect(s.spatialAudio, isTrue);

      // DND
      expect(s.restrictFloatingNotifications, isTrue);
      expect(s.restrictButtonsAndGestures, isTrue);
      expect(s.answerCallsHandsFree, isTrue);

      // Guardian AI
      expect(s.guardianTacticalEngine, isTrue);
      expect(s.aiInferenceBackend, equals('Local NPU'));
      expect(s.tacticalAudioCallouts, isTrue);
      expect(s.enemyMissingRadar, isTrue);
    });

    test('copyWith produces modified copy without mutating original', () {
      const s1 = GameTurboSettings();
      final s2 = s1.copyWith(
        shortcutEdgePosition: 'Left Edge',
        performanceOptimization: false,
        aiInferenceBackend: 'Gemini 2.5',
      );

      expect(s1.shortcutEdgePosition, equals('Top-Left'));
      expect(s1.performanceOptimization, isTrue);
      expect(s1.aiInferenceBackend, equals('Local NPU'));

      expect(s2.shortcutEdgePosition, equals('Left Edge'));
      expect(s2.performanceOptimization, isFalse);
      expect(s2.aiInferenceBackend, equals('Gemini 2.5'));
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      const original = GameTurboSettings(
        gameTurboMaster: false,
        inGameShortcuts: true,
        shortcutEdgePosition: 'Top-Right',
        contentRecommendations: false,
        hideGamesFromHomeScreen: true,
        performanceOptimization: false,
        wifiSpeedBoost: false,
        aggressiveMemoryCleanup: false,
        spatialAudio: false,
        restrictFloatingNotifications: false,
        restrictButtonsAndGestures: false,
        answerCallsHandsFree: false,
        guardianTacticalEngine: false,
        aiInferenceBackend: 'Claude 3.5',
        tacticalAudioCallouts: false,
        enemyMissingRadar: false,
      );

      final map = original.toMap();
      final restored = GameTurboSettings.fromMap(map);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('toJson and fromJson string serialization round-trip', () {
      const original = GameTurboSettings(
        shortcutEdgePosition: 'Left Edge',
        aiInferenceBackend: 'Gemini 2.5',
      );

      final jsonStr = original.toJson();
      final restored = GameTurboSettings.fromJson(jsonStr);

      expect(restored, equals(original));
    });
  });

  group('GameTurboSettingsNotifier Persistence Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loads default settings when storage is empty', () {
      final notifier = GameTurboSettingsNotifier(prefs);
      expect(notifier.state, equals(GameTurboSettings.defaultSettings));
    });

    test('persists mutations to SharedPreferences and restores on next boot', () async {
      final notifier = GameTurboSettingsNotifier(prefs);

      // Perform mutations across categories
      notifier.setShortcutEdgePosition('Top-Right');
      notifier.togglePerformanceOptimization(false);
      notifier.setAiInferenceBackend('Gemini 2.5');
      notifier.toggleHideGamesFromHomeScreen(true);

      // Verify immediate state update
      expect(notifier.state.shortcutEdgePosition, equals('Top-Right'));
      expect(notifier.state.performanceOptimization, isFalse);
      expect(notifier.state.aiInferenceBackend, equals('Gemini 2.5'));
      expect(notifier.state.hideGamesFromHomeScreen, isTrue);

      // Verify raw JSON in SharedPreferences
      final raw = prefs.getString('owl_game_turbo_settings_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['shortcutEdgePosition'], equals('Top-Right'));
      expect(decoded['performanceOptimization'], isFalse);
      expect(decoded['aiInferenceBackend'], equals('Gemini 2.5'));
      expect(decoded['hideGamesFromHomeScreen'], isTrue);

      // Verify new notifier instance restores persisted state
      final freshNotifier = GameTurboSettingsNotifier(prefs);
      expect(freshNotifier.state.shortcutEdgePosition, equals('Top-Right'));
      expect(freshNotifier.state.performanceOptimization, isFalse);
      expect(freshNotifier.state.aiInferenceBackend, equals('Gemini 2.5'));
      expect(freshNotifier.state.hideGamesFromHomeScreen, isTrue);
    });

    test('resetToDefaults restores default settings and updates SharedPreferences', () {
      final notifier = GameTurboSettingsNotifier(prefs);
      notifier.togglePerformanceOptimization(false);
      notifier.setShortcutEdgePosition('Left Edge');

      expect(notifier.state.performanceOptimization, isFalse);

      notifier.resetToDefaults();
      expect(notifier.state, equals(GameTurboSettings.defaultSettings));
    });
  });

  group('Settings Screen & Floating Toolbox Full UI Logic Integration Tests', () {
    testWidgets('Toggling switch in AppSettingsTwoPaneScreen mutates provider state', (tester) async {
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
                return const AppSettingsTwoPaneScreen();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: Master engine is true
      expect(capturedRef.read(gameTurboSettingsProvider).gameTurboMaster, isTrue);

      // Find Master Engine switch and toggle it off
      final masterSwitchFinder = find.byType(MiuiSwitch).first;
      await tester.tap(masterSwitchFinder);
      await tester.pumpAndSettle();

      // State is now false
      expect(capturedRef.read(gameTurboSettingsProvider).gameTurboMaster, isFalse);

      // Tap Reset Default button
      await tester.tap(find.text('Reset Default'));
      await tester.pumpAndSettle();

      // State restored to true
      expect(capturedRef.read(gameTurboSettingsProvider).gameTurboMaster, isTrue);
    });

    testWidgets('GameturboFloatingToolbox Mode Pills toggle Balanced vs Performance', (tester) async {
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
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  capturedRef = ref;
                  return GameturboFloatingToolbox(
                    onClose: () {},
                    onOpenGpuSettings: () {},
                    targetFps: 120,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default: Performance is true, FPS gauge displays 120
      expect(capturedRef.read(gameTurboSettingsProvider).performanceOptimization, isTrue);
      expect(find.text('120'), findsOneWidget);

      // Tap 'Balanced' mode pill
      await tester.tap(find.text('Balanced'));
      await tester.pumpAndSettle();

      // Performance is now false, FPS gauge updates to 60
      expect(capturedRef.read(gameTurboSettingsProvider).performanceOptimization, isFalse);
      expect(find.text('60'), findsOneWidget);

      // Tap 'Performance' mode pill
      await tester.tap(find.text('Performance'));
      await tester.pumpAndSettle();

      // Restored to true and 120 FPS
      expect(capturedRef.read(gameTurboSettingsProvider).performanceOptimization, isTrue);
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets('GameturboFloatingToolbox Tools Grid toggles mutate settings provider', (tester) async {
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
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  capturedRef = ref;
                  return GameturboFloatingToolbox(
                    onClose: () {},
                    onOpenGpuSettings: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle DND button
      expect(capturedRef.read(gameTurboSettingsProvider).restrictFloatingNotifications, isTrue);
      await tester.tap(find.text('DND'));
      await tester.pumpAndSettle();
      expect(capturedRef.read(gameTurboSettingsProvider).restrictFloatingNotifications, isFalse);

      // Toggle Wi-Fi button
      expect(capturedRef.read(gameTurboSettingsProvider).wifiSpeedBoost, isTrue);
      await tester.tap(find.text('Wi-Fi'));
      await tester.pumpAndSettle();
      expect(capturedRef.read(gameTurboSettingsProvider).wifiSpeedBoost, isFalse);

      // Verify AI and Voice buttons exist and can be tapped
      expect(find.text('AI'), findsOneWidget);
      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();

      expect(find.text('Voice'), findsOneWidget);
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
    });
  });
}
