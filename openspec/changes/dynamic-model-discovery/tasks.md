## 1. Domain Models & Discovery Service

- [x] 1.1 Create `DiscoveredModel` class with serialization and free-tier detection in `packages/owl_network/lib/network/models/discovered_model.dart`
- [x] 1.2 Implement `ModelDiscoveryService` in `packages/owl_network/lib/network/model_discovery_service.dart` supporting `models.dev`, `xKiro`, `OpenRouter`, and caching
- [x] 1.3 Add unit tests in `packages/owl_network/test/model_discovery_service_test.dart` for parser, free-model detection, and offline fallback

## 2. Settings State Management

- [x] 2.1 Add `modelDiscoveryServiceProvider` and integrate dynamic model resolution into `SettingsNotifier` in `lib/features/settings/presentation/settings_provider.dart`
- [x] 2.2 Add `showOnlyFreeModels` toggle to `GameTurboSettings` and `SettingsNotifier`
- [x] 2.3 Wire manual refresh action `refreshModelCatalog()` in `SettingsNotifier`

## 3. Game Turbo Settings UI Polish

- [x] 3.1 Update model dropdown to render `DiscoveredModel` entries with `🟢 FREE` and `⚡ PRO` badges in `lib/features/settings/presentation/app_settings_two_pane_screen.dart`
- [x] 3.2 Add `Show Free Models Only` filter switch in the AI Provider & Model Configuration pane
- [x] 3.3 Add `↻ Refresh Catalog` action button with status indicator
- [x] 3.4 Update provider selection cards with explicit free-tier highlights for xKiro, OpenRouter, SambaNova, and Groq

## 4. Verification & Validation

- [x] 4.1 Run all unit and integration tests (`flutter test`)
- [x] 4.2 Validate change with `openspec validate dynamic-model-discovery`
