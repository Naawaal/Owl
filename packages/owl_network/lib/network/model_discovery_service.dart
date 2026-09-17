// language: Dart, file: packages/owl_network/lib/network/model_discovery_service.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/discovered_model.dart';

/// Service responsible for querying models.dev and live provider gateways
/// to dynamically discover active LLM models and detect zero-cost free tiers.
class ModelDiscoveryService {
  final ApiClient? _apiClient;
  final Map<String, List<DiscoveredModel>> _cache = {};
  DateTime? _lastRefreshedAt;

  ModelDiscoveryService([this._apiClient]);

  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  /// Retrieves models for a given provider. Returns cached models if available,
  /// or queries upstream endpoints when online, falling back to static defaults.
  Future<List<DiscoveredModel>> getModelsForProvider(
    String providerId, {
    bool forceRefresh = false,
  }) async {
    final normalizedProvider = providerId.toLowerCase().trim();
    if (!forceRefresh && _cache.containsKey(normalizedProvider)) {
      return _cache[normalizedProvider]!;
    }

    try {
      final fetched = await _fetchFromUpstream(normalizedProvider);
      if (fetched.isNotEmpty) {
        _cache[normalizedProvider] = fetched;
        _lastRefreshedAt = DateTime.now();
        return fetched;
      }
    } catch (_) {
      // Graceful offline fallback
    }

    final fallback = getFallbackModels(normalizedProvider);
    _cache[normalizedProvider] = fallback;
    return fallback;
  }

  /// Forces an update across all supported providers.
  Future<Map<String, List<DiscoveredModel>>> refreshAllCatalogs() async {
    final providers = [
      'gemini',
      'openai',
      'claude',
      'openrouter',
      'sambanova',
      'xkiro',
      'groq',
    ];

    for (final p in providers) {
      try {
        final models = await getModelsForProvider(p, forceRefresh: true);
        _cache[p] = models;
      } catch (_) {}
    }
    _lastRefreshedAt = DateTime.now();
    return Map.unmodifiable(_cache);
  }

  /// Filters a list of models to only those flagged as free tier.
  List<DiscoveredModel> filterFreeOnly(List<DiscoveredModel> models) {
    return models.where((m) => m.isFree).toList();
  }

  Future<List<DiscoveredModel>> _fetchFromUpstream(String providerId) async {
    final api = _apiClient;
    if (api == null) return const [];

    // Special Gateway 1: xKiro public models catalog
    if (providerId == 'xkiro') {
      return await _fetchXKiroCatalog(api);
    }

    // Special Gateway 2: OpenRouter public models catalog
    if (providerId == 'openrouter' || providerId == 'deepseek') {
      return await _fetchOpenRouterCatalog(api);
    }

    // General: models.dev API
    return await _fetchFromModelsDev(api, providerId);
  }

  Future<List<DiscoveredModel>> _fetchXKiroCatalog(ApiClient api) async {
    try {
      final response = await api.get('https://api.xkiro.com/v1/models');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((item) {
          final id = item['id']?.toString() ?? '';
          final displayName = item['display_name']?.toString() ?? id;
          final tier = item['access_tier']?.toString().toLowerCase() ?? '';
          final pricing = item['pricing'] as Map?;
          final inputCost = (pricing?['input'] as num?)?.toDouble() ?? 0.0;
          final outputCost = (pricing?['output'] as num?)?.toDouble() ?? 0.0;
          final contextLen = (item['context_length'] as num?)?.toInt();

          final isFree = tier == 'free' ||
              id.contains(':free') ||
              (inputCost == 0.0 && outputCost == 0.0);

          return DiscoveredModel(
            id: id,
            name: displayName,
            providerId: 'xkiro',
            isFree: isFree,
            contextLength: contextLen,
            inputPrice: inputCost,
            outputPrice: outputCost,
          );
        }).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<DiscoveredModel>> _fetchOpenRouterCatalog(ApiClient api) async {
    try {
      final response = await api.get('https://openrouter.ai/api/v1/models');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((item) {
          final id = item['id']?.toString() ?? '';
          final name = item['name']?.toString() ?? id;
          final pricing = item['pricing'] as Map?;
          final promptPrice = double.tryParse(pricing?['prompt']?.toString() ?? '') ?? 0.0;
          final completionPrice = double.tryParse(pricing?['completion']?.toString() ?? '') ?? 0.0;
          final contextLen = (item['context_length'] as num?)?.toInt();

          final isFree = id.contains(':free') ||
              (promptPrice == 0.0 && completionPrice == 0.0);

          return DiscoveredModel(
            id: id,
            name: name,
            providerId: 'openrouter',
            isFree: isFree,
            contextLength: contextLen,
            inputPrice: promptPrice,
            outputPrice: completionPrice,
          );
        }).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<DiscoveredModel>> _fetchFromModelsDev(
    ApiClient api,
    String providerId,
  ) async {
    try {
      final response = await api.get('https://models.dev/api.json');
      final data = response.data;
      if (data is Map) {
        final slug = switch (providerId) {
          'gemini' => 'google',
          'claude' => 'anthropic',
          _ => providerId,
        };

        if (data.containsKey(slug) && data[slug] is Map) {
          final providerData = data[slug] as Map;
          final modelsMap = providerData['models'];
          if (modelsMap is Map) {
            final result = <DiscoveredModel>[];
            modelsMap.forEach((key, val) {
              if (val is Map) {
                final id = val['id']?.toString() ?? key.toString();
                final name = val['name']?.toString() ?? id;
                final dynamic rawContext = val['context'] ??
                    val['context_length'] ??
                    (val['limit'] is Map ? (val['limit'] as Map)['context'] : null);
                final contextLen = (rawContext as num?)?.toInt();
                final pricing = val['pricing'] as Map?;
                final inputCost = (pricing?['input'] as num?)?.toDouble();
                final outputCost = (pricing?['output'] as num?)?.toDouble();
                final isFree = id.contains(':free') ||
                    (inputCost == 0.0 && outputCost == 0.0);

                result.add(DiscoveredModel(
                  id: id,
                  name: name,
                  providerId: providerId,
                  isFree: isFree,
                  contextLength: contextLen,
                  inputPrice: inputCost,
                  outputPrice: outputCost,
                ));
              }
            });
            if (result.isNotEmpty) return result;
          }
        }
      }
    } catch (_) {}
    return const [];
  }

  /// Curated fallback models when offline or on first boot.
  List<DiscoveredModel> getFallbackModels(String providerId) {
    switch (providerId) {
      case 'xkiro':
        return const [
          DiscoveredModel(
            id: 'deepseek/deepseek-v4.1-flash',
            name: 'DeepSeek V4.1 Flash',
            providerId: 'xkiro',
            isFree: true,
            contextLength: 1048576,
          ),
          DiscoveredModel(
            id: 'qwen/qwen3.7-flash:free',
            name: 'Qwen 3.7 Flash (Free)',
            providerId: 'xkiro',
            isFree: true,
            contextLength: 1000000,
          ),
          DiscoveredModel(
            id: 'minimax/minimax-m3:free',
            name: 'MiniMax M3 (Free)',
            providerId: 'xkiro',
            isFree: true,
            contextLength: 1000000,
          ),
          DiscoveredModel(
            id: 'qwen/qwen3.8-max',
            name: 'Qwen 3.8 Max',
            providerId: 'xkiro',
            isFree: false,
            contextLength: 1000000,
          ),
          DiscoveredModel(
            id: 'openai/gpt-5.6-luna',
            name: 'GPT-5.6 Luna',
            providerId: 'xkiro',
            isFree: false,
            contextLength: 1000000,
          ),
          DiscoveredModel(
            id: 'google/gemini-2.5-flash',
            name: 'Gemini 2.5 Flash',
            providerId: 'xkiro',
            isFree: false,
            contextLength: 1000000,
          ),
        ];

      case 'openrouter':
      case 'deepseek':
        return const [
          DiscoveredModel(
            id: 'meta-llama/llama-3.3-70b-instruct:free',
            name: 'Llama 3.3 70B Instruct (Free)',
            providerId: 'openrouter',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'deepseek/deepseek-r1:free',
            name: 'DeepSeek R1 (Free)',
            providerId: 'openrouter',
            isFree: true,
            contextLength: 163840,
          ),
          DiscoveredModel(
            id: 'qwen/qwen-2.5-coder-32b-instruct:free',
            name: 'Qwen 2.5 Coder 32B (Free)',
            providerId: 'openrouter',
            isFree: true,
            contextLength: 32768,
          ),
          DiscoveredModel(
            id: 'deepseek/deepseek-chat',
            name: 'DeepSeek V3',
            providerId: 'openrouter',
            isFree: false,
            contextLength: 65536,
          ),
          DiscoveredModel(
            id: 'google/gemini-2.0-flash-001',
            name: 'Gemini 2.0 Flash',
            providerId: 'openrouter',
            isFree: false,
            contextLength: 1048576,
          ),
        ];

      case 'sambanova':
        return const [
          DiscoveredModel(
            id: 'Meta-Llama-3.3-70B-Instruct',
            name: 'Meta Llama 3.3 70B Instruct',
            providerId: 'sambanova',
            isFree: true, // Free daily developer tier
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'DeepSeek-R1-0528',
            name: 'DeepSeek R1 0528 (Fast Reasoning)',
            providerId: 'sambanova',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'DeepSeek-V3.1',
            name: 'DeepSeek V3.1',
            providerId: 'sambanova',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'openai/gpt-oss-120b',
            name: 'OpenAI GPT-OSS 120B',
            providerId: 'sambanova',
            isFree: false,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'MiniMax-M2.7',
            name: 'MiniMax M2.7',
            providerId: 'sambanova',
            isFree: false,
            contextLength: 196608,
          ),
        ];

      case 'groq':
        return const [
          DiscoveredModel(
            id: 'llama-3.3-70b-versatile',
            name: 'Llama 3.3 70B Versatile',
            providerId: 'groq',
            isFree: true, // Free rate-limited developer tier
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'llama-3.1-8b-instant',
            name: 'Llama 3.1 8B Instant',
            providerId: 'groq',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'openai/gpt-oss-120b',
            name: 'OpenAI GPT-OSS 120B',
            providerId: 'groq',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'openai/gpt-oss-20b',
            name: 'OpenAI GPT-OSS 20B (Ultra Fast)',
            providerId: 'groq',
            isFree: true,
            contextLength: 131072,
          ),
          DiscoveredModel(
            id: 'qwen/qwen3.6-27b',
            name: 'Qwen 3.6 27B',
            providerId: 'groq',
            isFree: true,
            contextLength: 131072,
          ),
        ];

      case 'gemini':
        return const [
          DiscoveredModel(
            id: 'gemini-3-flash-preview',
            name: 'Gemini 3 Flash Preview',
            providerId: 'gemini',
            isFree: true,
            contextLength: 1048576,
          ),
          DiscoveredModel(
            id: 'gemini-2.5-flash',
            name: 'Gemini 2.5 Flash',
            providerId: 'gemini',
            isFree: true,
            contextLength: 1048576,
          ),
          DiscoveredModel(
            id: 'gemini-3.5-flash',
            name: 'Gemini 3.5 Flash',
            providerId: 'gemini',
            isFree: false,
            contextLength: 1048576,
          ),
        ];

      case 'openai':
        return const [
          DiscoveredModel(
            id: 'gpt-4o-mini',
            name: 'GPT-4o Mini',
            providerId: 'openai',
            isFree: false,
            contextLength: 128000,
          ),
          DiscoveredModel(
            id: 'gpt-4o',
            name: 'GPT-4o',
            providerId: 'openai',
            isFree: false,
            contextLength: 128000,
          ),
        ];

      case 'claude':
        return const [
          DiscoveredModel(
            id: 'claude-3-5-haiku',
            name: 'Claude 3.5 Haiku',
            providerId: 'claude',
            isFree: false,
            contextLength: 200000,
          ),
          DiscoveredModel(
            id: 'claude-3-5-sonnet',
            name: 'Claude 3.5 Sonnet',
            providerId: 'claude',
            isFree: false,
            contextLength: 200000,
          ),
        ];

      default:
        return const [];
    }
  }
}
