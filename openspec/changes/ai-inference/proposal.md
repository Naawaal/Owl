## Why

The app collects per-provider API keys and ships prompt/response models plus a dio client, yet performs zero HTTP calls: the "Test Key" button simulates latency instead of verifying, and the Guardian toolbox has no live advice path. The AI settings page is a dead end. Wiring real inference turns the console's AI surface into a working feature.

## What Changes

- Add a provider inference layer: Gemini-first request client (`generateContent` + streaming `streamGenerateContent`) built on the existing `ApiClient`/`postStream` plumbing, with OpenAI (`chat/completions`) second; Claude and OpenRouter follow the same interface.
- Replace the simulated key test with a real verification call (lightweight `models/list` or minimal generation) that reports genuine latency and auth failures.
- Add a coach service that builds `CoachPrompt`s from live game state (active game, role, timers, situation), sends them to the active provider/model, parses results via `CoachResponse.fromRawText`, and exposes a reactive latest-advice state.
- Feed the Guardian toolbox callout from live advice with graceful fallback (cached/last-known advice, then silent) when offline, keyless, or rate-limited; never block gameplay on inference.
- Enforce request budgets: timeout, cooldown between calls, and a per-match call cap so the feature cannot spam APIs or drain battery.

## Capabilities

### New Capabilities
- `ai-inference`: live provider inference — Gemini-first client with streaming, real key verification, game-state-driven coach service with reactive advice state, toolbox callout feed with offline fallback, and request budgets.

### Modified Capabilities
- None — `openspec/specs/` is empty, so there are no existing capabilities to modify.

## Impact

- Affected code: new `packages/owl_network/lib/network/inference/` clients, new `lib/features/ai_coach/data/coach_service.dart`, `lib/features/settings/presentation/settings_provider.dart` (`ApiKeyManager.testConnection`), `lib/features/overlay/presentation/gameturbo_floating_toolbox.dart` (callout feed), `test/` (client parsing, service, key-verification tests with mocked dio).
- No new dependencies (`dio` already present); no storage-backend changes (keys stay in secure storage, never logged).
- Verification: `flutter analyze`, `flutter test` with mocked HTTP, manual live-key pass on Android.
