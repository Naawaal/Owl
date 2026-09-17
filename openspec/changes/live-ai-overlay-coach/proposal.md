# Proposal: Live AI Overlay Coach

## Why

While the in-app testing HUD (`TacticalBattlefieldHud`) in Owl already queries live cloud LLMs (Gemini, OpenAI, Claude, DeepSeek) through `CoachService`, the standalone in-game floating HUD overlay (`GameTurboOverlayService`) currently only cycles through offline heuristic directives from `HardwareSystemController.kt`. When players are actively in a game with the floating overlay, they cannot see live generative tactical advice from their configured BYOK AI key. Adding native live AI querying to the overlay provides real-time, context-aware coaching during actual gameplay.

## What Changes

- **API Credential & Provider Bridging**: Pass the stored BYOK API key, active provider (`gemini`, `openai`, `claude`, etc.), and selected model from Flutter's secure storage to `GameTurboOverlayService` when a game is launched or when settings change.
- **Native Live AI Inference in Overlay**: Implement a lightweight, non-blocking asynchronous REST client inside `GameTurboOverlayService.kt` that calls the provider endpoint (Google Gemini `generateContent` via HTTPS) with situational context (game name, preferred role, target FPS, elapsed time).
- **Interactive UI Refresh & Loading State**:
  - Tapping the refresh icon or directive card in the standalone overlay displays a subtle pulsing "Analyzing battlefield..." status.
  - Replaces text with parsed Action, Rationale, and Warning upon response arrival.
- **Graceful Offline & Rate-Limit Fallback**: Retain `HardwareSystemController.getTacticalDirectives()` as instant fallback if the API key is missing, network fails, or quota is exceeded.

## Capabilities

### New Capabilities
- `live-ai-overlay-inference`: Asynchronous on-device cloud LLM inference executed from the native Android system overlay HUD over third-party games with automatic heuristic fallback.

### Modified Capabilities
*(None - first time introducing overlay AI live inference)*

## Impact

- `android/app/src/main/kotlin/com/example/owl/GameTurboOverlayService.kt`: Add async Gemini inference client, loading state, and directive updater.
- `android/app/src/main/kotlin/com/example/owl/MainActivity.kt`: Extend `launchGame` and `setAiCredentials` MethodChannel calls to forward API key, provider, and model name to the overlay service.
- `lib/features/game_profiles/presentation/game_discovery_provider.dart`: Forward the stored API key and active model when invoking `launchGame`.
