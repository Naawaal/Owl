## 1. Native Screen Capture Infrastructure

- [x] 1.1 Declare `FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION` in `AndroidManifest.xml` and configure capture permissions
- [x] 1.2 Implement `MediaProjection` token receiver and `ImageReader` virtual display setup in `GameTurboOverlayService.kt`
- [x] 1.3 Implement frame capture utility with 640x360 downscaling, 75% quality JPEG compression, and immediate bitmap recycling

## 2. Multimodal Gemini Vision Pipeline

- [x] 2.1 Update `AICoachService.dart` and native HTTP client to support multipart multimodal payload structure with `inlineData`
- [x] 2.2 Construct the visual tactical prompt enforcing extraction of active hero, battle spell, lane equilibrium, and minimap threats
- [x] 2.3 Configure `responseMimeType: "application/json"` with fallback to `gemini-3-flash-preview` and `gemini-2.5-flash`

## 3. HUD Overlay Integration & Real-Time Directives

- [x] 3.1 Wire Guardian AI card tap gesture in `GameTurboOverlayService.kt` to trigger on-demand screen frame capture and analysis
- [x] 3.2 Implement the 35-second periodic tactical visual refresh loop when a game is active in foreground
- [x] 3.3 Render structured directive results (`action`, `rationale`, `radar`) with `GUARDIAN AI • LIVE` visual badge

## 4. Privacy Consent & Settings Management

- [x] 4.1 Add `guardianVisionEnabled` preference to Flutter `SettingsService` and `HardwareSystemController`
- [x] 4.2 Add system screen capture intent launcher in `MainActivity.kt` and bridge result token to overlay service
- [x] 4.3 Add Guardian Vision toggle and permission status indicator in `AppSettingsTwoPaneScreen` under AI Assistant settings
- [x] 4.4 Implement graceful fallback to text heuristics when vision is disabled, denied, or network fails

## 5. Testing & Validation

- [x] 5.1 Add unit tests for multimodal JSON serialization and directive parsing in `test/features/guardian_ai_vision_test.dart`
- [x] 5.2 Validate offline fallback heuristics and timeout handling in Flutter test suite
- [x] 5.3 Verify all existing Flutter unit and widget tests pass via `flutter test`
