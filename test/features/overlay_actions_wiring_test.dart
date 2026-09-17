// language: Dart, file: overlay_actions_wiring_test.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/ai_coach/domain/offline_tactical_heuristics_engine.dart';
import 'package:owl/features/overlay/data/dnd_service.dart';
import 'package:owl/features/overlay/data/voice_changer_service.dart';
import 'package:owl/features/overlay/data/wifi_optimizer_service.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Overlay HUD Actions Domain Services Test Suite', () {
    test('DndService toggles state and updates settings', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final dndNotifier = container.read(dndServiceProvider.notifier);
      expect(container.read(dndServiceProvider).isEnabled, isTrue);

      final success = await dndNotifier.toggleDnd(false);
      expect(success, isTrue);
      expect(container.read(dndServiceProvider).isEnabled, isFalse);
      expect(
        container.read(gameTurboSettingsProvider).restrictFloatingNotifications,
        isFalse,
      );

      await dndNotifier.toggleDnd(true);
      expect(container.read(dndServiceProvider).isEnabled, isTrue);
      expect(
        container.read(gameTurboSettingsProvider).restrictFloatingNotifications,
        isTrue,
      );
    });

    test('WifiOptimizerService toggles boost and tracks latency', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final wifiNotifier = container.read(wifiOptimizerProvider.notifier);
      expect(container.read(wifiOptimizerProvider).isBoostActive, isTrue);

      final success = await wifiNotifier.toggleWifiBoost(false);
      expect(success, isTrue);
      expect(container.read(wifiOptimizerProvider).isBoostActive, isFalse);
      expect(
        container.read(gameTurboSettingsProvider).wifiSpeedBoost,
        isFalse,
      );

      await wifiNotifier.toggleWifiBoost(true);
      expect(container.read(wifiOptimizerProvider).isBoostActive, isTrue);
      expect(container.read(wifiOptimizerProvider).latencyMs, greaterThan(0));
    });

    test('VoiceChangerService toggles active state and switches presets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final voiceNotifier = container.read(voiceChangerProvider.notifier);
      expect(container.read(voiceChangerProvider).isActive, isFalse);

      final success = await voiceNotifier.toggleVoice(true);
      expect(success, isTrue);
      expect(container.read(voiceChangerProvider).isActive, isTrue);

      await voiceNotifier.setPreset('cybernetic');
      expect(container.read(voiceChangerProvider).activePresetId, 'cybernetic');
      expect(container.read(voiceChangerProvider).currentPreset.name, 'Cybernetic');

      await voiceNotifier.toggleVoice(false);
      expect(container.read(voiceChangerProvider).isActive, isFalse);
    });

    test('OfflineTacticalHeuristicsEngine produces game-specific meta advice', () {
      const engine = OfflineTacticalHeuristicsEngine();

      final mobaAdvice = engine.generateAdvice(
        gameName: 'Mobile Legends: Bang Bang',
        role: 'jungler',
        matchTimeSeconds: 120,
      );
      expect(mobaAdvice.action, contains('Turtle'));
      expect(mobaAdvice.warning, isNotEmpty);
      expect(mobaAdvice.reason, isNotEmpty);

      final brAdvice = engine.generateAdvice(
        gameName: 'Free Fire MAX',
        role: 'assault',
        matchTimeSeconds: 400,
      );
      expect(brAdvice.action, contains('zone'));
      expect(brAdvice.reason, isNotEmpty);
    });

    test('CoachService falls back to offline heuristics when no API key exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiKeyManagerProvider.overrideWith((ref) => ApiKeyManager(null)),
        ],
      );
      addTearDown(container.dispose);

      final coachNotifier = container.read(coachServiceProvider.notifier);
      await coachNotifier.requestAdvice(
        situation: 'Contesting river objective',
        manual: true,
      );

      final state = container.read(coachServiceProvider);
      expect(state.valueOrNull, isNotNull);
      expect(state.valueOrNull?.action, isNotEmpty);
      expect(coachNotifier.lastKnown, isNotNull);
    });
  });

  group('GameturboFloatingToolbox Widget Integration', () {
    testWidgets('Renders all 4 wired buttons and responds to taps', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            apiKeyManagerProvider.overrideWith((ref) => ApiKeyManager(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GameturboFloatingToolbox(
                  gameTitle: 'Mobile Legends: Bang Bang',
                  targetFps: 120,
                  onClose: () {},
                  onOpenGpuSettings: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DND'), findsOneWidget);
      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);

      // Tap DND
      await tester.tap(find.text('DND'));
      await tester.pumpAndSettle();

      // Tap Wi-Fi
      await tester.tap(find.text('Wi-Fi'));
      await tester.pumpAndSettle();

      // Tap AI
      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();

      // Tap Voice
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();

      // Verify the AI Coach advice card is rendered and not blank
      expect(find.textContaining('GUARDIAN AI COACH'), findsOneWidget);
    });
  });
}
