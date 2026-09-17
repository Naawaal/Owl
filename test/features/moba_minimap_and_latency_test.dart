// language: Dart, file: moba_minimap_and_latency_test.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/ai_coach/domain/vision/moba_minimap_extractor.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_network/owl_network.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

const openAiPayload = {
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

  group('MobaMinimapExtractor Unit Tests', () {
    late MobaMinimapExtractor extractor;

    setUp(() {
      extractor = MobaMinimapExtractor(missingThresholdSeconds: 5);
    });

    test('cropMinimap extracts top-left 34% width by 20% height', () {
      const srcW = 1000;
      const srcH = 500;
      final screenBytes = Uint8List(srcW * srcH * 4)..fillRange(0, srcW * srcH * 4, 200);

      final cropped = extractor.cropMinimap(screenBytes, srcW, srcH);
      expect(cropped.width, equals(340));
      expect(cropped.height, equals(100));
      expect(cropped.bytes.length, equals(340 * 100 * 4));
    });

    test('cropMinimap handles empty or zero dimension frames', () {
      final emptyResult = extractor.cropMinimap(Uint8List(0), 0, 0);
      expect(emptyResult.width, equals(0));
      expect(emptyResult.height, equals(0));
      expect(emptyResult.bytes.isEmpty, isTrue);
    });

    test('tracks missing enemies after vision loss exceeds threshold', () {
      // t=10s: Enemy Mid laner visible
      final snap1 = extractor.processTokens(
        detectedTokens: [
          const MinimapHeroToken(
            id: 'enemy_mid',
            team: 'enemy',
            lane: 'mid',
            normalizedX: 0.5,
            normalizedY: 0.5,
            lastSeenMatchTimeSeconds: 10,
          ),
        ],
        matchTimeSeconds: 10,
      );

      expect(snap1.visibleEnemies.length, equals(1));
      expect(snap1.missingEnemies.isEmpty, isTrue);

      // t=12s: Enemy Mid not in frame (2s elapsed < 5s threshold)
      final snap2 = extractor.processTokens(
        detectedTokens: [],
        matchTimeSeconds: 12,
      );
      expect(snap2.missingEnemies.isEmpty, isTrue);

      // t=16s: 6s elapsed >= 5s threshold -> Enemy is marked MISSING
      final snap3 = extractor.processTokens(
        detectedTokens: [],
        matchTimeSeconds: 16,
      );
      expect(snap3.missingEnemies.length, equals(1));
      expect(snap3.missingEnemies.first.isMissing, isTrue);
      expect(snap3.missingEnemies.first.missingDurationSeconds, equals(6));
      expect(
        snap3.tacticalAlerts.any((a) => a.contains('Enemy mid missing for 6s')),
        isTrue,
      );

      // t=20s: Enemy reappears in bot lane -> no longer missing
      final snap4 = extractor.processTokens(
        detectedTokens: [
          const MinimapHeroToken(
            id: 'enemy_mid',
            team: 'enemy',
            lane: 'mid',
            normalizedX: 0.8,
            normalizedY: 0.8,
            lastSeenMatchTimeSeconds: 20,
          ),
        ],
        matchTimeSeconds: 20,
      );
      expect(snap4.missingEnemies.isEmpty, isTrue);
      expect(snap4.visibleEnemies.length, equals(1));
    });

    test('detects upcoming and contested neutral objectives', () {
      // t=110s: Turtle spawning in 10s
      final snap1 = extractor.processTokens(
        detectedTokens: [],
        matchTimeSeconds: 110,
      );
      expect(
        snap1.objectives.any((o) => o.name == 'Turtle' && o.status == 'upcoming'),
        isTrue,
      );
      expect(
        snap1.tacticalAlerts.any((a) => a.contains('Turtle spawning in 10s')),
        isTrue,
      );

      // t=200s: Turtle is alive; both teams near pit (0.20, 0.12) -> contested
      final snap2 = extractor.processTokens(
        detectedTokens: [
          const MinimapHeroToken(
            id: 'ally_jg',
            team: 'ally',
            normalizedX: 0.21,
            normalizedY: 0.13,
            lastSeenMatchTimeSeconds: 200,
          ),
          const MinimapHeroToken(
            id: 'enemy_jg',
            team: 'enemy',
            normalizedX: 0.22,
            normalizedY: 0.11,
            lastSeenMatchTimeSeconds: 200,
          ),
        ],
        matchTimeSeconds: 200,
      );

      final turtle = snap2.objectives.firstWhere((o) => o.name == 'Turtle');
      expect(turtle.status, equals('contested'));
      expect(turtle.isContested, isTrue);
      expect(
        snap2.tacticalAlerts.any((a) => a.contains('Turtle is actively contested')),
        isTrue,
      );
    });

    test('toTacticalContext serializes correctly into CoachPrompt format', () {
      final snap = extractor.processTokens(
        detectedTokens: [
          const MinimapHeroToken(
            id: 'ally_mid',
            team: 'ally',
            normalizedX: 0.4,
            normalizedY: 0.4,
            lastSeenMatchTimeSeconds: 30,
          ),
        ],
        matchTimeSeconds: 30,
      );

      final contextMap = snap.toTacticalContext();
      expect(contextMap['matchTime'], equals(30));
      expect(contextMap['visibleAlliesCount'], equals(1));
      expect(contextMap['visibleEnemiesCount'], equals(0));
      expect(contextMap['objectives'], isNotEmpty);
    });
  });

  group('CoachService Latency Compensation & Degradation Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('computeCompensatedMatchTime adjusts timestamp forward by RTT', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final coach = container.read(coachServiceProvider.notifier);

      // Without measured latency, returns raw time
      expect(coach.computeCompensatedMatchTime(120), equals(120));

      // Ingest minimap tokens
      coach.ingestMinimapTokens(
        detectedTokens: [
          const MinimapHeroToken(
            id: 'enemy_top',
            team: 'enemy',
            normalizedX: 0.1,
            normalizedY: 0.1,
            lastSeenMatchTimeSeconds: 50,
          ),
        ],
        matchTimeSeconds: 50,
      );

      expect(coach.latestMinimapSnapshot, isNotNull);
      expect(coach.latestMinimapSnapshot!.visibleEnemies.length, equals(1));
    });

    test('high latency beyond 1500ms degrades to local heuristic with warning', () async {
      final dio = cannedDio((options) async {
        // Delay 1600ms to trip latency degradation threshold
        await Future<void>.delayed(const Duration(milliseconds: 1600));
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: openAiPayload,
        );
      });

      final api = ApiClient(dio);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(api),
          apiKeyManagerProvider.overrideWith((ref) => ApiKeyManager(null, api)),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-test-latency-key-1234567890');
      container.read(gameTurboSettingsProvider.notifier).setActiveAiProvider('openai');

      final coach = container.read(coachServiceProvider.notifier);
      await coach.requestAdvice(
        situation: 'Contesting Lord pit in river',
        matchTimeSeconds: 600,
        manual: true,
      );

      final advice = coach.lastKnown;
      expect(advice, isNotNull);
      expect(coach.lastLatencyMs, greaterThanOrEqualTo(1500));
      // Degraded to heuristic advice with high latency warning
      expect(advice!.warning, contains('High latency'));
    });
  });
}
