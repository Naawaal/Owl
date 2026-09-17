import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_network/owl_network.dart';

/// Provider for ModelDiscoveryService instance.
final modelDiscoveryServiceProvider = Provider<ModelDiscoveryService>((ref) {
  ApiClient? api;
  try {
    api = ref.watch(apiClientProvider);
  } catch (_) {}
  return ModelDiscoveryService(api);
});

/// Timestamp of last successful catalog refresh from upstream.
final catalogRefreshTimestampProvider = StateProvider<DateTime?>((ref) => null);

/// True while an upstream model discovery fetch is in progress.
final isCatalogRefreshingProvider = StateProvider<bool>((ref) => false);

/// Dynamic list of discovered models for currently active AI provider,
/// respecting the showOnlyFreeModels filter.
final discoveredModelsForCurrentProvider =
    FutureProvider<List<DiscoveredModel>>((ref) async {
  final settings = ref.watch(gameTurboSettingsProvider);
  final discoveryService = ref.watch(modelDiscoveryServiceProvider);
  ref.watch(catalogRefreshTimestampProvider);

  final models = await discoveryService.getModelsForProvider(settings.activeAiProvider);
  if (settings.showOnlyFreeModels) {
    return discoveryService.filterFreeOnly(models);
  }
  return models;
});

/// Global action to trigger an upstream refresh of all model catalogs.
Future<void> refreshModelCatalog(WidgetRef ref) async {
  final refreshingNotifier = ref.read(isCatalogRefreshingProvider.notifier);
  refreshingNotifier.state = true;
  try {
    final discovery = ref.read(modelDiscoveryServiceProvider);
    await discovery.refreshAllCatalogs();
    ref.read(catalogRefreshTimestampProvider.notifier).state = DateTime.now();
  } finally {
    refreshingNotifier.state = false;
  }
}
