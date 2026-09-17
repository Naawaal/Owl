## 1. AI Provider Domain Models

- [x] 1.1 Add `sambanova`, `xkiro`, and `groq` to `AIProvider` enum in `lib/features/ai_coach/domain/models/ai_provider.dart`
- [x] 1.2 Implement `displayName`, `defaultModel`, `availableModels`, and `apiKeyStorageKey` for SambaNova, xKiro, and Groq with non-deprecated verified models
- [x] 1.3 Add domain model unit tests in `test/features/features_domain_test.dart` for new providers and model catalogs

## 2. Network Inference Clients

- [x] 2.1 Implement `SambaNovaInferenceClient` in `packages/owl_network/lib/network/inference/sambanova_inference_client.dart` targeting `https://api.sambanova.ai/v1`
- [x] 2.2 Implement `XKiroInferenceClient` in `packages/owl_network/lib/network/inference/xkiro_inference_client.dart` targeting `https://api.xkiro.com/v1`
- [x] 2.3 Implement `GroqInferenceClient` in `packages/owl_network/lib/network/inference/groq_inference_client.dart` targeting `https://api.groq.com/openai/v1`
- [x] 2.4 Update `inferenceClientFor` factory in `packages/owl_network/lib/network/inference/inference_client_factory.dart` and export clients in `owl_network.dart`
- [x] 2.5 Add unit tests in `packages/owl_network/test/` for new inference clients, key verification, and response parsing

## 3. Settings Provider & Secure Credential Management

- [x] 3.1 Update `SettingsNotifier` in `lib/features/settings/presentation/settings_provider.dart` to support default models and API key validation for SambaNova, xKiro, and Groq
- [x] 3.2 Update `GameTurboSettings` and `AppSettings` models to handle serialization and persistence for the new providers
- [x] 3.3 Ensure secure storage reads and writes for `owl_api_key_sambanova`, `owl_api_key_xkiro`, and `owl_api_key_groq`

## 4. Game Turbo Settings UI Integration

- [x] 4.1 Update `AppSettingsTwoPaneScreen` to add provider selection cards for SambaNova, xKiro, and Groq with distinctive badges and estimated latency metrics
- [x] 4.2 Wire dynamic model dropdowns to display verified model options when SambaNova, xKiro, or Groq is selected
- [x] 4.3 Add credential input fields with provider-specific validation hints (e.g. `gsk_` for Groq) adhering strictly to Owl design tokens and `GEMINI.md` constraints

## 5. Verification & Regression Testing

- [x] 5.1 Run all unit and feature tests across `owl` and `owl_network` (`flutter test`)
- [x] 5.2 Validate OpenSpec artifacts with `openspec validate add-sambanova-xkiro-groq-providers`
