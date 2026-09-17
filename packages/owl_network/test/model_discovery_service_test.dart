// language: Dart, file: packages/owl_network/test/model_discovery_service_test.dart, target: Flutter / Owl MOBA HUD
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_network/owl_network.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DiscoveredModel', () {
    test('formats context length accurately', () {
      final model1M = DiscoveredModel(
        id: 'test-1m',
        name: 'Test 1M',
        providerId: 'gemini',
        contextLength: 1048576,
      );
      expect(model1M.formattedContext, '1M');

      final model128k = DiscoveredModel(
        id: 'test-128k',
        name: 'Test 128K',
        providerId: 'groq',
        contextLength: 131072,
      );
      expect(model128k.formattedContext, '128K');

      final model32k = DiscoveredModel(
        id: 'test-32k',
        name: 'Test 32K',
        providerId: 'sambanova',
        contextLength: 32768,
      );
      expect(model32k.formattedContext, '32K');

      final modelNull = DiscoveredModel(
        id: 'test-null',
        name: 'Test Null',
        providerId: 'openai',
      );
      expect(modelNull.formattedContext, isNull);
    });

    test('isFree flag respects pricing and tier flags', () {
      final freeModel = DiscoveredModel(
        id: 'free-model',
        name: 'Free Model',
        providerId: 'xkiro',
        isFree: true,
      );
      expect(freeModel.isFree, isTrue);

      final paidModel = DiscoveredModel(
        id: 'paid-model',
        name: 'Paid Model',
        providerId: 'openai',
        inputPrice: 0.15,
        outputPrice: 0.60,
      );
      expect(paidModel.isFree, isFalse);
    });
  });

  group('ModelDiscoveryService - Fallback Mode', () {
    late ModelDiscoveryService service;

    setUp(() {
      service = ModelDiscoveryService();
    });

    test('returns curated fallback models for all supported providers', () async {
      final sambanova = await service.getModelsForProvider('sambanova');
      expect(sambanova, isNotEmpty);
      expect(sambanova.any((m) => m.id.contains('Meta-Llama-3.3-70B-Instruct')), isTrue);

      final groq = await service.getModelsForProvider('groq');
      expect(groq, isNotEmpty);
      expect(groq.any((m) => m.id.contains('llama-3.3-70b-versatile')), isTrue);

      final xkiro = await service.getModelsForProvider('xkiro');
      expect(xkiro, isNotEmpty);
      expect(xkiro.any((m) => m.isFree), isTrue);

      final openrouter = await service.getModelsForProvider('openrouter');
      expect(openrouter, isNotEmpty);
      expect(openrouter.any((m) => m.isFree), isTrue);
    });

    test('filters free only correctly', () async {
      final xkiroModels = await service.getModelsForProvider('xkiro');
      final freeModels = service.filterFreeOnly(xkiroModels);

      expect(freeModels, isNotEmpty);
      expect(freeModels.every((m) => m.isFree), isTrue);
    });
  });

  group('ModelDiscoveryService - Upstream Ingestion', () {
    test('correctly parses xKiro live models response', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        if (options.uri.toString() == 'https://api.xkiro.com/v1/models') {
          final jsonStr = jsonEncode({
            'object': 'list',
            'data': [
              {
                'id': 'deepseek/deepseek-r1:free',
                'display_name': 'DeepSeek R1 (Free)',
                'access_tier': 'free',
                'context_length': 65536,
                'pricing': {'input': 0.0, 'output': 0.0},
              },
              {
                'id': 'anthropic/claude-3-5-sonnet',
                'display_name': 'Claude 3.5 Sonnet',
                'access_tier': 'pro',
                'context_length': 200000,
                'pricing': {'input': 3.0, 'output': 15.0},
              }
            ]
          });
          return ResponseBody.fromString(
            jsonStr,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final apiClient = ApiClient(dio);
      final service = ModelDiscoveryService(apiClient);

      final models = await service.getModelsForProvider('xkiro', forceRefresh: true);
      expect(models.length, 2);

      final freeModel = models.firstWhere((m) => m.id.contains(':free'));
      expect(freeModel.isFree, isTrue);
      expect(freeModel.name, 'DeepSeek R1 (Free)');
      expect(freeModel.formattedContext, '64K');

      final proModel = models.firstWhere((m) => m.id.contains('claude-3-5-sonnet'));
      expect(proModel.isFree, isFalse);
    });

    test('correctly parses OpenRouter live models response', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        if (options.uri.toString() == 'https://openrouter.ai/api/v1/models') {
          final jsonStr = jsonEncode({
            'data': [
              {
                'id': 'meta-llama/llama-3.3-70b-instruct:free',
                'name': 'Meta: Llama 3.3 70B Instruct (free)',
                'context_length': 131072,
                'pricing': {'prompt': '0', 'completion': '0'},
              },
              {
                'id': 'openai/gpt-4o',
                'name': 'OpenAI: GPT-4o',
                'context_length': 128000,
                'pricing': {'prompt': '0.0000025', 'completion': '0.00001'},
              }
            ]
          });
          return ResponseBody.fromString(
            jsonStr,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final apiClient = ApiClient(dio);
      final service = ModelDiscoveryService(apiClient);

      final models = await service.getModelsForProvider('openrouter', forceRefresh: true);
      expect(models.length, 2);

      final freeModel = models.firstWhere((m) => m.id.contains(':free'));
      expect(freeModel.isFree, isTrue);

      final paidModel = models.firstWhere((m) => m.id == 'openai/gpt-4o');
      expect(paidModel.isFree, isFalse);
    });

    test('correctly parses models.dev API response for Groq', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        if (options.uri.toString() == 'https://models.dev/api.json') {
          final jsonStr = jsonEncode({
            'groq': {
              'id': 'groq',
              'name': 'Groq',
              'models': {
                'llama-3.3-70b-versatile': {
                  'id': 'llama-3.3-70b-versatile',
                  'name': 'Llama 3.3 70B Versatile',
                  'context_length': 131072,
                  'pricing': {'input': 0.0, 'output': 0.0},
                }
              }
            }
          });
          return ResponseBody.fromString(
            jsonStr,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final apiClient = ApiClient(dio);
      final service = ModelDiscoveryService(apiClient);

      final models = await service.getModelsForProvider('groq', forceRefresh: true);
      expect(models.length, 1);
      expect(models.first.id, 'llama-3.3-70b-versatile');
      expect(models.first.name, 'Llama 3.3 70B Versatile');
      expect(models.first.formattedContext, '128K');
    });
  });
}
