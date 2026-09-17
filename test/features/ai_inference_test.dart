// language: Dart, test: ai_inference_test.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/ai_coach.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
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

DioException dioError(
  RequestOptions options, {
  int? statusCode,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response(
            requestOptions: options,
            statusCode: statusCode,
            data: {'error': 'mocked failure'},
          ),
  );
}

const geminiGeneratePayload = {
  'candidates': [
    {
      'content': {
        'parts': [
          {
            'text':
                'Action: Rotate to Dragon pit\nReason: Bot wave pushing.\nWarning: No river vision.'
          },
        ],
      },
      'finishReason': 'STOP',
    },
  ],
};

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
  // Plain unit tests below drive notifiers that emit haptics; the binding
  // must exist before any of them run (independent of test order/filtering).
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Key masking', () {
    test('masks to last four characters', () {
      expect(maskApiKey('AIzaSyValidKey1234567890'), equals('***7890'));
    });

    test('short keys fully masked', () {
      expect(maskApiKey('abc'), equals('****'));
    });
  });

  group('Error mapping', () {
    test('maps 401/403 to auth without key material', () {
      final client = _ProbeClient();
      final error = NetworkException.serverError(
        statusCode: 401,
        message: 'API key not valid: sk-secret-full-key-material',
      );
      final mapped = client.probeMap(error);
      expect(mapped.failure, equals(InferenceFailure.auth));
      expect(mapped.message, isNot(contains('sk-secret-full-key-material')));
    });

    test('maps 429 to rateLimited and timeouts to timeout', () {
      final client = _ProbeClient();
      expect(
        client
            .probeMap(const NetworkException(
                message: 'x', code: 'SERVER_ERROR'))
            .failure,
        equals(InferenceFailure.unknown),
      );
      expect(
        client
            .probeMap(
                NetworkException.serverError(statusCode: 429, message: 'slow'))
            .failure,
        equals(InferenceFailure.rateLimited),
      );
      expect(
        client.probeMap(NetworkException.timeout()).failure,
        equals(InferenceFailure.timeout),
      );
      expect(
        client.probeMap(NetworkException.noInternet()).failure,
        equals(InferenceFailure.network),
      );
    });
  });

  group('Response parsing', () {
    test('Gemini extracts joined text and rejects empty payloads', () {
      expect(
        GeminiInferenceClient.extractText(
          geminiGeneratePayload,
          maskedKeyTail: '***7890',
        ),
        contains('Rotate to Dragon pit'),
      );
      expect(
        () => GeminiInferenceClient.extractText(
          {'nonsense': true},
          maskedKeyTail: '***7890',
        ),
        throwsA(isA<InferenceException>()),
      );
    });

    test('Gemini delta extraction tolerates malformed chunks', () {
      expect(
        GeminiInferenceClient.extractDelta(
          '{"candidates":[{"content":{"parts":[{"text":"hi"}]}}]}',
          maskedKeyTail: '***7890',
        ),
        equals('hi'),
      );
      expect(
        GeminiInferenceClient.extractDelta(
          'not-json{{{',
          maskedKeyTail: '***7890',
        ),
        equals(''),
      );
    });

    test('OpenAI extracts message content and stream deltas', () {
      const payload = {
        'choices': [
          {
            'message': {'content': 'Freeze the wave.'},
            'finish_reason': 'stop',
          },
        ],
      };
      expect(
        OpenAiInferenceClient.extractText(
          payload,
          maskedKeyTail: '***7890',
        ),
        equals('Freeze the wave.'),
      );
      expect(
        OpenAiInferenceClient.extractDelta(
          '{"choices":[{"delta":{"content":"Freeze"}}]}',
        ),
        equals('Freeze'),
      );
      expect(
        OpenAiInferenceClient.extractDelta('garbage'),
        equals(''),
      );
    });

    test('Claude extracts blocks and content_block_delta events', () {
      const payload = {
        'content': [
          {'type': 'text', 'text': 'Contest the objective.'},
        ],
      };
      expect(
        ClaudeInferenceClient.extractText(
          payload,
          maskedKeyTail: '***7890',
        ),
        equals('Contest the objective.'),
      );
      expect(
        ClaudeInferenceClient.extractDelta(
          '{"type":"content_block_delta","delta":{"text":"Contest"}}',
        ),
        equals('Contest'),
      );
      expect(
        ClaudeInferenceClient.extractDelta(
          '{"type":"message_start","message":{}}',
        ),
        equals(''),
      );
    });
  });

  group('Client factory', () {
    ApiClient stubApi() => ApiClient(Dio());

    test('resolves every settings provider id', () {
      expect(
        inferenceClientFor(providerId: 'gemini', api: stubApi()),
        isA<GeminiInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'openai', api: stubApi()),
        isA<OpenAiInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'claude', api: stubApi()),
        isA<ClaudeInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'openrouter', api: stubApi()),
        isA<OpenRouterInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'deepseek', api: stubApi()),
        isA<OpenRouterInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'sambanova', api: stubApi()),
        isA<SambaNovaInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'xkiro', api: stubApi()),
        isA<XKiroInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'groq', api: stubApi()),
        isA<GroqInferenceClient>(),
      );
      expect(
        inferenceClientFor(providerId: 'unknown-id', api: stubApi()),
        isA<GeminiInferenceClient>(),
      );
    });
  });

  group('Key verification over mocked transport', () {
    test('valid key verifies with measured latency', () async {
      final dio = cannedDio((options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: {'models': []},
          ));
      final client = GeminiInferenceClient(ApiClient(dio));
      final result = await client.verifyKey(
        apiKey: 'AIzaSyValidKey0123456789abcdef',
        model: 'gemini-2.0-flash',
      );
      expect(result.ok, isTrue);
      expect(result.latencyMs, greaterThanOrEqualTo(0));
    });

    test('revoked key reports auth failure', () async {
      final dio = cannedDio((options) async {
        throw dioError(options, statusCode: 401);
      });
      final client = GeminiInferenceClient(ApiClient(dio));
      final result = await client.verifyKey(
        apiKey: 'AIzaSyRevokedKey00000000000000',
        model: 'gemini-2.0-flash',
      );
      expect(result.ok, isFalse);
      expect(result.failure, equals(InferenceFailure.auth));
    });

    test('offline transport reports network failure', () async {
      final dio = cannedDio((options) async {
        throw dioError(
          options,
          type: DioExceptionType.connectionError,
        );
      });
      final client = OpenAiInferenceClient(ApiClient(dio));
      final result = await client.verifyKey(
        apiKey: 'sk-proj-validformatkey00000000000001',
        model: 'gpt-4o-mini',
      );
      expect(result.ok, isFalse);
      expect(result.failure, equals(InferenceFailure.network));
    });

    test('hung request fails fast on timeout', () async {
      final dio = cannedDio((options) async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: geminiGeneratePayload,
        );
      });
      final client = GeminiInferenceClient(ApiClient(dio));
      expect(
        () => client.generate(
          apiKey: 'AIzaSyValidKey0123456789abcdef',
          model: 'gemini-2.0-flash',
          prompt: 'tactical check',
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.failure,
            'failure',
            InferenceFailure.timeout,
          ),
        ),
      );
    });
  });

  group('CoachService budgets and fallback', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer makeContainer(Dio dio) {
      final api = ApiClient(dio);
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(api),
          apiKeyManagerProvider.overrideWith(
            (ref) => ApiKeyManager(null, api),
          ),
        ],
      );
    }

    test('serves offline advice without a stored key and never throws',
        () async {
      final dio = cannedDio((options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: geminiGeneratePayload,
          ));
      final container = makeContainer(dio);
      addTearDown(container.dispose);

      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'Dragon spawning soon.');

      final state = container.read(coachServiceProvider);
      final response = state.valueOrNull;
      expect(state.hasError, isFalse);
      expect(response, isNotNull);
      expect(response!.action, isNotEmpty);
      expect(service.lastKnown, isNotNull);
      expect(service.callsThisMatch, equals(0));
    });

    test('live advice parses into action/reason and caches', () async {
      var hits = 0;
      final dio = cannedDio((options) async {
        hits++;
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: openAiGeneratePayload,
        );
      });
      final container = makeContainer(dio);
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-livekey000000000000000001');
      container.read(gameTurboSettingsProvider.notifier).setActiveAiProvider(
            'openai',
          );

      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'Dragon spawning in 40s.');

      final state = container.read(coachServiceProvider);
      final response = state.valueOrNull;
      expect(response, isNotNull);
      expect(response!.action, contains('Rotate to Dragon pit'));
      expect(service.lastKnown, isNotNull);
      expect(service.callsThisMatch, equals(1));

      // Cooldown suppresses the immediate refire: still exactly one hit.
      await service.requestAdvice(situation: 'Dragon spawning in 35s.');
      expect(hits, equals(1));
    });

    test('auth failure falls back to offline advice without error state',
        () async {
      final dio = cannedDio((options) async {
        throw dioError(options, statusCode: 401);
      });
      final container = makeContainer(dio);
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-revokedkey00000000000002');
      container.read(gameTurboSettingsProvider.notifier).setActiveAiProvider(
            'openai',
          );

      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'Baron spawning soon.');

      final state = container.read(coachServiceProvider);
      final response = state.valueOrNull;
      expect(state.hasError, isFalse);
      expect(response, isNotNull);
      expect(response!.action, isNotEmpty);
      expect(response.reason, isNotEmpty);
      expect(service.lastKnown, isNotNull);
      expect(service.callsThisMatch, equals(0));
    });

    test('parsed responses keep raw text for audit', () async {
      final dio = cannedDio((options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: openAiGeneratePayload,
          ));
      final container = makeContainer(dio);
      addTearDown(container.dispose);

      await container
          .read(apiKeyManagerProvider)
          .saveApiKey('openai', 'sk-proj-auditkey000000000000000003');
      container.read(gameTurboSettingsProvider.notifier).setActiveAiProvider(
            'openai',
          );

      final service = container.read(coachServiceProvider.notifier);
      await service.requestAdvice(situation: 'Audit check.');
      final response = service.lastKnown;
      expect(response, isNotNull);
      expect(response!.rawText, isNotEmpty);
      expect(response.timestamp, isA<DateTime>());
      expect(CoachResponse.fromRawText('Just push mid.').action,
          isNotEmpty);
    });
  });
}

/// Test probe exposing protected mapping for unit tests.
final class _ProbeClient extends BaseInferenceClient {
  _ProbeClient() : super(_NoApi());

  @override
  String get providerId => 'probe';

  @override
  Future<KeyVerification> verifyKey({
    required String apiKey,
    required String model,
  }) =>
      throw UnimplementedError();

  @override
  Future<String> generate({
    required String apiKey,
    required String model,
    required String prompt,
    Duration? timeout,
  }) =>
      throw UnimplementedError();

  @override
  Stream<String> generateStream({
    required String apiKey,
    required String model,
    required String prompt,
    Duration? timeout,
  }) =>
      throw UnimplementedError();

  InferenceException probeMap(NetworkException e) =>
      mapError(e, maskedKeyTail: '***0000');
}

/// Placeholder ApiClient for mapping-only probes (never called).
class _NoApi extends ApiClient {
  _NoApi() : super(Dio());
}
