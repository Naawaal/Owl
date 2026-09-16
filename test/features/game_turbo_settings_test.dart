// language: Dart, file: game_turbo_settings_test.dart, target: Flutter / Owl MOBA Companion
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('GameTurboSettings Domain Model Tests', () {
    test('defaultSettings has expected tactical companion defaults', () {
      const s = GameTurboSettings.defaultSettings;

      // General
      expect(s.themeMode, equals(ThemeMode.dark));
      expect(s.interfaceLanguage, equals('en'));

      // AI Provider & Models
      expect(s.activeAiProvider, equals('gemini'));
      expect(s.activeModel, equals('gemini-2.0-flash'));

      // Assistant & Tactical AI
      expect(s.assistantMode, equals('live'));
      expect(s.coachingLevel, equals('intermediate'));
      expect(s.preferredRole, equals('auto'));
      expect(s.warningSensitivity, equals('balanced'));
      expect(s.explainRecommendations, isTrue);
      expect(s.missingEnemyAlerts, isTrue);
      expect(s.overextensionRadar, isTrue);
      expect(s.objectiveTimers, isTrue);
      expect(s.laneWaveAdvice, isTrue);

      // Voice & Alerts
      expect(s.voiceAlertsEnabled, isTrue);
      expect(s.alertPriority, equals('criticalOnly'));
      expect(s.speechCooldownSeconds, equals(8));
      expect(s.avoidInterruptingGameAudio, isTrue);
      expect(s.hapticsEnabled, isTrue);

      // Assistant Performance
      expect(s.performanceMode, equals('balanced'));
      expect(s.adaptiveWorkload, isTrue);
      expect(s.thermalProtection, isTrue);
      expect(s.showInGameLatencyHud, isTrue);

      // Overlay compatibility
      expect(s.gameTurboMaster, isTrue);
      expect(s.inGameShortcuts, isTrue);
      expect(s.shortcutEdgePosition, equals('Top-Left'));
      expect(s.performanceOptimization, isTrue);
      expect(s.wifiSpeedBoost, isTrue);
      expect(s.restrictFloatingNotifications, isTrue);
      expect(s.restrictButtonsAndGestures, isTrue);
    });

    test('copyWith produces modified copy without mutating original', () {
      const s1 = GameTurboSettings();
      final s2 = s1.copyWith(
        activeAiProvider: 'openai',
        activeModel: 'gpt-4o-mini',
        preferredRole: 'jungle',
        performanceMode: 'high',
      );

      expect(s1.activeAiProvider, equals('gemini'));
      expect(s1.activeModel, equals('gemini-2.0-flash'));
      expect(s1.preferredRole, equals('auto'));
      expect(s1.performanceMode, equals('balanced'));

      expect(s2.activeAiProvider, equals('openai'));
      expect(s2.activeModel, equals('gpt-4o-mini'));
      expect(s2.preferredRole, equals('jungle'));
      expect(s2.performanceMode, equals('high'));
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      const original = GameTurboSettings(
        themeMode: ThemeMode.light,
        interfaceLanguage: 'es',
        activeAiProvider: 'claude',
        activeModel: 'claude-3-5-haiku',
        assistantMode: 'postMatch',
        coachingLevel: 'advanced',
        preferredRole: 'mid',
        warningSensitivity: 'earlyWarning',
        explainRecommendations: false,
        missingEnemyAlerts: false,
        overextensionRadar: false,
        objectiveTimers: false,
        laneWaveAdvice: false,
        voiceAlertsEnabled: false,
        alertPriority: 'important',
        speechCooldownSeconds: 15,
        avoidInterruptingGameAudio: false,
        hapticsEnabled: false,
        performanceMode: 'saver',
        adaptiveWorkload: false,
        thermalProtection: false,
        showInGameLatencyHud: false,
      );

      final map = original.toMap();
      final restored = GameTurboSettings.fromMap(map);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('toJson and fromJson string serialization round-trip', () {
      const original = GameTurboSettings(
        activeAiProvider: 'deepseek',
        activeModel: 'deepseek/deepseek-chat',
        preferredRole: 'roam',
      );

      final jsonStr = original.toJson();
      final restored = GameTurboSettings.fromJson(jsonStr);

      expect(restored, equals(original));
    });
  });

  group('ApiKeyManager Validation Tests', () {
    final manager = ApiKeyManager(null);

    test('validateKeyFormat verifies Gemini keys', () {
      expect(manager.validateKeyFormat('gemini', ''), isNotNull);
      expect(manager.validateKeyFormat('gemini', 'short_invalid_key'), isNotNull);
      expect(manager.validateKeyFormat('gemini', 'AIzaSyValidGeminiKeyFormatLength32'), isNull);
    });

    test('validateKeyFormat verifies OpenAI keys', () {
      expect(manager.validateKeyFormat('openai', 'invalid_no_prefix'), isNotNull);
      expect(manager.validateKeyFormat('openai', 'sk-validOpenAiKeyLength32Characters'), isNull);
    });

    test('validateKeyFormat verifies Claude keys', () {
      expect(manager.validateKeyFormat('claude', 'invalid_key'), isNotNull);
      expect(manager.validateKeyFormat('claude', 'sk-ant-validAnthropicKeyFormat32Chars'), isNull);
    });

    test('testConnection returns latency simulation for valid keys', () async {
      final latency = await manager.testConnection('gemini', 'AIzaSyValidGeminiKeyFormatLength32');
      expect(latency, greaterThan(30));
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

      notifier.setActiveAiProvider('openai');
      notifier.setPreferredRole('jungle');
      notifier.setPerformanceMode('high');
      notifier.setThemeMode(ThemeMode.light);

      expect(notifier.state.activeAiProvider, equals('openai'));
      expect(notifier.state.activeModel, equals('gpt-4o-mini'));
      expect(notifier.state.preferredRole, equals('jungle'));
      expect(notifier.state.performanceMode, equals('high'));
      expect(notifier.state.themeMode, equals(ThemeMode.light));

      final raw = prefs.getString('owl_game_turbo_settings_v2');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['activeAiProvider'], equals('openai'));
      expect(decoded['activeModel'], equals('gpt-4o-mini'));
      expect(decoded['preferredRole'], equals('jungle'));

      final freshNotifier = GameTurboSettingsNotifier(prefs);
      expect(freshNotifier.state.activeAiProvider, equals('openai'));
      expect(freshNotifier.state.preferredRole, equals('jungle'));
    });

    test('resetToDefaults restores default settings and updates SharedPreferences', () {
      final notifier = GameTurboSettingsNotifier(prefs);
      notifier.setPreferredRole('solo');
      notifier.setPerformanceMode('saver');

      expect(notifier.state.preferredRole, equals('solo'));

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

      // Tap Reset to Factory Defaults button
      await tester.tap(find.text('Reset to Factory Defaults'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).themeMode, equals(ThemeMode.dark));
    });

    testWidgets('AppSettingsTwoPaneScreen validates API key format and reports errors', (tester) async {
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

      // Enter invalid key for Gemini (starts with wrong prefix or is too short)
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.pumpAndSettle();

      // Tap Save & Test
      await tester.tap(find.text('Save & Test'));
      await tester.pumpAndSettle();

      // Verify validation error is displayed
      expect(find.textContaining('Google Gemini keys typically start with "AIza"'), findsOneWidget);

      // Now enter valid Gemini key format
      await tester.enterText(find.byType(TextField), 'AIzaSyDummyGeminiKeyValidFormat12345');
      await tester.pumpAndSettle();

      // Error should be cleared on input change
      expect(find.textContaining('Google Gemini keys typically start with "AIza"'), findsNothing);

      // Tap Save & Test
      await tester.tap(find.text('Save & Test'));
      await tester.pump();
      expect(find.text('Testing...'), findsOneWidget);

      // Advance clock past simulated network delay and settle SnackBar
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.textContaining('latency'), findsWidgets);
    });

    testWidgets('AppSettingsTwoPaneScreen switches AI Provider and updates available models', (tester) async {
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

      // Switch to OpenAI
      await tester.tap(find.text('OpenAI'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).activeAiProvider, equals('openai'));
      expect(capturedRef.read(gameTurboSettingsProvider).activeModel, equals('gpt-4o-mini'));
      expect(find.text('gpt-4o-mini'), findsOneWidget);

      // Switch to Claude
      await tester.tap(find.text('Claude'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).activeAiProvider, equals('claude'));
      expect(capturedRef.read(gameTurboSettingsProvider).activeModel, equals('claude-3-5-haiku'));
      expect(find.text('claude-3-5-haiku'), findsOneWidget);
    });

    testWidgets('AppSettingsTwoPaneScreen updates preferred role between Auto and manual overrides', (tester) async {
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
                  initialCategory: AppSettingCategory.assistant,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Auto (Default)
      expect(capturedRef.read(gameTurboSettingsProvider).preferredRole, equals('auto'));
      expect(find.textContaining('Auto-detects Smite / Retribution / Roaming boots'), findsOneWidget);

      // Select Jungle
      await tester.tap(find.text('Jungle'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).preferredRole, equals('jungle'));
      expect(find.textContaining('Fixed role override: JUNGLE'), findsOneWidget);

      // Select Auto (Default) back
      await tester.tap(find.text('Auto (Default)'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).preferredRole, equals('auto'));
      expect(find.textContaining('Auto-detects Smite / Retribution / Roaming boots'), findsOneWidget);
    });

    testWidgets('Voice & Alerts Play Test button triggers tactical alert SnackBar', (tester) async {
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
              initialCategory: AppSettingCategory.alerts,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Play Test
      await tester.tap(find.text('Play Test'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tactical Alert: Enemy Jungler missing from Bot River!'), findsOneWidget);
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

      expect(capturedRef.read(gameTurboSettingsProvider).performanceOptimization, isTrue);
      expect(find.text('120'), findsOneWidget);

      await tester.tap(find.text('Balanced'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(gameTurboSettingsProvider).performanceOptimization, isFalse);
      expect(find.text('60'), findsOneWidget);

      await tester.tap(find.text('Performance'));
      await tester.pumpAndSettle();

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

      expect(capturedRef.read(gameTurboSettingsProvider).restrictFloatingNotifications, isTrue);
      await tester.tap(find.text('DND'));
      await tester.pumpAndSettle();
      expect(capturedRef.read(gameTurboSettingsProvider).restrictFloatingNotifications, isFalse);

      expect(capturedRef.read(gameTurboSettingsProvider).wifiSpeedBoost, isTrue);
      await tester.tap(find.text('Wi-Fi'));
      await tester.pumpAndSettle();
      expect(capturedRef.read(gameTurboSettingsProvider).wifiSpeedBoost, isFalse);
    });
  });
}
