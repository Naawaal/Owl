# Tasks: Live AI Overlay Coach

## 1. Credential Bridging (Flutter to Android Service)

- [x] 1.1 Update `MainActivity.kt` to extract `aiApiKey`, `aiProvider`, and `aiModel` arguments in `launchGame` and forward them to `GameTurboOverlayService.start()`.
- [x] 1.2 Add `setAiCredentials` MethodChannel handler in `MainActivity.kt` to forward live credential updates directly to `GameTurboOverlayService.setAiCredentials()`.
- [x] 1.3 Update Flutter game launch invocation in `game_discovery_provider.dart` to read the active AI key and model from `apiKeyManagerProvider` and pass them into the launch call.

## 2. Native Gemini REST Client & Inference Engine

- [x] 2.1 Implement `queryGeminiTacticalDirectives()` in `GameTurboOverlayService.kt` using background `ExecutorService`, HTTPS `HttpURLConnection`, and 8-second timeout.
- [x] 2.2 Construct a high-performance gaming prompt requesting structured JSON output: `{"action": "...", "reason": "...", "warning": "..."}`.
- [x] 2.3 Safely parse the response with fallback to `HardwareSystemController.getTacticalDirectives()` upon network error, timeout, or invalid key.

## 3. Overlay HUD Interactive State & UI Wiring

- [x] 3.1 Implement visual loading state ("ANALYZING BATTLEFIELD...") in `guardianOverlayView` during in-flight inference queries.
- [x] 3.2 Wire tap-to-cycle and the refresh button to trigger live AI generation when an API key is set, falling back to local heuristics when unconfigured.
- [x] 3.3 Ensure both Light Mode and Dark Mode styling dynamically adapt to live incoming AI directives without UI clipping.

## 4. Verification & Testing

- [x] 4.1 Compile native Android code via `./gradlew compileDebugKotlin` to verify zero compilation errors.
- [x] 4.2 Run the complete Flutter test suite (`flutter test`) to ensure no regressions.
