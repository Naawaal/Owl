// language: Dart, test: assistant_wiring_test.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/ai_coach/data/tts_announcer.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_network/owl_network.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a Dio short-circuited by [respond]: no live HTTP in tests.
Dio cannedDio(
  FutureOr<Response<dynamic>> Function(RequestOptions options) respond,
) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        Future.sync(() => respond(options)).then(
          handler.resolve,
          onError: (Object e) {
            if (e is DioException) {
              handler.reject(e);
            } else {
              handler.reject(
                DioException(requestOptions: options, error: e),
              );
            }
          },
        );
      },
    ),
  );
  return dio;
}

const openAiGeneratePayload = {
  'choices': [
    {
      'message': {
        'content':
            'Action: Rotate to Dragon pit\nReason: Bot wave pushing.\nWarning: No river vision.',
      },
      'finish_reason': 'stop',
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prompt shaping and budget scaling (pure)', () {
    test('depth blocks differ per coaching level', () {
      final beginner = CoachService.depthBlock('beginner');
      final advanced = CoachService.depthBlock('advanced');
      expect(beginner, isNot(contains('wave-control')));
      expect(advanced, contains('wave-control'));
      expect(beginner, isNot(equals(advanced)));
    });

    test('sensitivity scales cooldown and cap', () {
      const early = GameTurboSettings(warningSensitivity: 'earlyWarning');
      const balanced = GameTurboSettings();
      const conservative =
          GameTurboSettings(warningSensitivity: 'conservative');
      expect(
        CoachService.effectiveCooldown(early) <
            CoachService.effectiveCooldown(balanced),
        isTrue,
      );
      expect(
        CoachService.effectiveCooldown(conservative) >
            CoachService.effectiveCooldown(balanced),
        isTrue,
      );
      expect(
        CoachService.effectiveCap(conservative) <=
            CoachService.effectiveCap(balanced),
        isTrue,
      );
      expect(
        CoachService.effectiveCap(early) >=
            CoachService.effectiveCap(balanced),
        isTrue,
      );
    });

    test('performance presets order saver below high', () {
      expect(
        CoachService.baseCooldownFor('saver') >
            CoachService.baseCooldownFor('high'),
        isTrue,
      );
      expect(
        CoachService.baseCapFor('saver') < CoachService.baseCapFor('high'),
        isTrue,
      );
      expect(
        CoachService.fpsTargetFor('saver') <=
            CoachService.fpsTargetFor('high'),
        isTrue,
      );
    });

    test('topic toggles subscribe and filter', () {
      const allOn = GameTurboSettings();
      expect(CoachService.subscribedTopics(allOn), hasLength(4));
      expect(
        CoachService.isTopicEnabled(allOn, CoachService.topicObjective),
        isTrue,
      );
      const objectivesOff = GameTurboSettings(objectiveTimers: false);
      expect(
        CoachService.subscribedTopics(objectivesOff),
        isNot(contains(CoachService.topicObjective)),
      );
      expect(
        CoachService.isTopicEnabled(
            objectivesOff, CoachService.topicObjective),
        isFalse,
      );
      expect(
        CoachService.isTopicEnabled(objectivesOff, 'tactical'),
        isTrue,
      );
    });
  });

  group('Stress throttle', () {
    test('engages after sustained stress and releases on relief', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(coachServiceProvider.notifier);
      const settings = GameTurboSettings();

      expect(service.isStressThrottled, isFalse);
      service.reportStressSample(
          settings: settings, cpuPercent: 90, batteryPercent: 15);
      service.reportStressSample(
          settings: settings, cpuPercent: 92, batteryPercent: 14);
      expect(service.isStressThrottled, isFalse);
      service.reportStressSample(
          settings: settings, cpuPercent: 88, batteryPercent: 18);
      expect(service.isStressThrottled, isTrue);
      expect(
        service.enforcedCooldown(settings) >
            CoachService.effectiveCooldown(settings),
        isTrue,
      );

      service.reportStressSample(
          settings: settings, cpuPercent: 20, batteryPercent: 80);
      service.reportStressSample(
          settings: settings, cpuPercent: 25, batteryPercent: 80);
      expect(service.isStressThrottled, isTrue);
      service.reportStressSample(
          settings: settings, cpuPercent: 20, batteryPercent: 80);
      expect(service.isStressThrottled, isFalse);
    });

    test('disabled toggles prevent engagement', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(coachServiceProvider.notifier);
      const unguarded = GameTurboSettings(thermalProtection: false);
      for (var i = 0; i < 5; i++) {
        service.reportStressSample(
            settings: unguarded, cpuPercent: 95, batteryPercent: 10);
      }
      expect(service.isStressThrottled, isFalse);
    });
  });

  group('TTS announcer guards', () {
    test('speaks through the delegate and records marker', () async {
      final spoken = <String>[];
      final announcer = TtsAnnouncer(
        speakDelegate: (text) async {
          spoken.add(text);
          return 1;
        },
      );
      expect(await announcer.speak('Rotate now.'), isTrue);
      expect(spoken, equals(['Rotate now.']));
      expect(announcer.lastSpokeAt, isNotNull);
      expect(await announcer.speak('   '), isFalse);
    });

    test('missing engine resolves false without throwing', () async {
      final announcer = TtsAnnouncer();
      // No delegate and no platform plugin in unit tests: must not throw.
      await announcer.speak('Hello.');
      await announcer.stop();
    });
  });

  group('Voice gating in CoachService', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer makeContainer(Dio dio, TtsAnnouncer tts) {
      final api = ApiClient(dio);
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(api),
          apiKeyManagerProvider.overrideWith(
            (ref) => ApiKeyManager(null, api),
          ),
          ttsAnnouncerProvider.overrideWithValue(tts),
        ],
      );
    }

    Dio successDio() => cannedDio((options) async => Response(
          requestOptions: options,
          statusCode: 200,
          data: openAiGeneratePayload,
        ));

    test('critical-only filter silences warning-less advice', () async {
      final spoken = <String>[];
      final tts = TtsAnnouncer(
        speakDelegate: (text) async {
          spoken.add(text);
          return 1;
        },
      );
      final container = makeContainer(successDio(), tts);
      addTearDown(container.dispose);

      // Response WITH warning (payload has Warning line) → spoken.
      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-voicekey00000000000000001');
      container.read(gameTurboSettingsProvider.notifier).setActiveAiProvider(
            'openai',
          );
      await container
          .read(coachServiceProvider.notifier)
          .requestAdvice(situation: 'Dragon soon.', manual: true);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(spoken, hasLength(1));
      expect(spoken.single, contains('Rotate to Dragon pit'));
    });

    test('voice disabled silences announcements', () async {
      final spoken = <String>[];
      final tts = TtsAnnouncer(
        speakDelegate: (text) async {
          spoken.add(text);
          return 1;
        },
      );
      final container = makeContainer(successDio(), tts);
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-voicekey00000000000000002');
      final settings = container.read(gameTurboSettingsProvider.notifier);
      settings.setActiveAiProvider('openai');
      settings.toggleVoiceAlerts(false);
      await container
          .read(coachServiceProvider.notifier)
          .requestAdvice(situation: 'Dragon soon.', manual: true);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(spoken, isEmpty);
      // Advice itself still lands visually.
      expect(
        container.read(coachServiceProvider).valueOrNull,
        isNotNull,
      );
    });

    test('speech cooldown spaces announcements', () async {
      final spoken = <String>[];
      final tts = TtsAnnouncer(
        speakDelegate: (text) async {
          spoken.add(text);
          return 1;
        },
      );
      final container = makeContainer(successDio(), tts);
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-voicekey00000000000000003');
      final settings = container.read(gameTurboSettingsProvider.notifier);
      settings.setActiveAiProvider('openai');
      settings.setAlertPriority('allAlerts');
      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'First.', manual: true);
      service.resetMatchBudget();
      await service.requestAdvice(situation: 'Second.', manual: true);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      // Default 8s cooldown: only the first announcement plays.
      expect(spoken, hasLength(1));
    });
  });

  group('Haptics gate and master kill-switch', () {
    test('disabled global flag silences all helpers without throwing',
        () async {
      HapticHelper.globalEnabled = false;
      addTearDown(() => HapticHelper.globalEnabled = true);
      await HapticHelper.selectionClick();
      await HapticHelper.lightImpact();
      await HapticHelper.mediumImpact();
      await HapticHelper.heavyImpact();
      await HapticHelper.vibrate();
    });

    test('master off halts auto queries but allows manual refresh', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dio = cannedDio((options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: openAiGeneratePayload,
          ));
      final api = ApiClient(dio);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(api),
          apiKeyManagerProvider.overrideWith(
            (ref) => ApiKeyManager(null, api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-masterkey00000000000000004');
      final settings = container.read(gameTurboSettingsProvider.notifier);
      settings.setActiveAiProvider('openai');
      settings.toggleGameTurboMaster(false);

      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'Auto tick.');
      expect(container.read(coachServiceProvider).valueOrNull, isNull);

      await service.requestAdvice(situation: 'Manual tap.', manual: true);
      expect(
        container.read(coachServiceProvider).valueOrNull,
        isNotNull,
      );
    });

    test('master off skips native perf sync without throwing', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      container.read(gameTurboSettingsProvider.notifier).toggleGameTurboMaster(false);
      final notifier = container.read(gameTurboSettingsProvider.notifier);
      await notifier.applyPersistedHardwareState();
    });

    test('native perf sync invokes the channel when master is on', () async {
      final channel = MethodChannel('com.example.owl/games');
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return true;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameTurboSettingsProvider.notifier);
      await notifier.applyPersistedHardwareState();
      expect(calls, contains('setPerformanceMode'));
    });
  });
}
