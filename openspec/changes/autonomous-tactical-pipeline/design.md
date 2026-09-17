## Context

Owl's coaching stack currently possesses multi-model API streaming, tactical prompt formation, and voice alert pipelines (`tactical-assistant-wiring`), but coaching relies on explicit user button pushes or mock ticks. Additionally, while `GameTurboOverlayService.kt` contains a 2,500-line dual-state floating HUD and `MainActivity.kt` defines `REQUEST_SCREEN_CAPTURE = 8812`, there is no continuous autonomous frame-sampling loop, MOBA minimap parsing engine, or end-to-end platform linkage.

Constraints:
- Strict prohibition against building APKs or executing Gradle assemble.
- Strict compliance with `GEMINI.md` for any Flutter UI or HUD components.
- Zero battery runaway; background loops must throttle and respect device performance tiers.

## Goals / Non-Goals

**Goals:**
- Create `AutonomousTacticalLoop` service managing continuous background game-tick execution according to `PerformanceMode` (1 FPS, 5 FPS, 12 FPS).
- Implement fast perceptual frame diffing (32x32 grayscale thumbnail diff) to suppress model calls during static loading or paused states.
- Create `MobaMinimapExtractor` to crop landscape minimap coordinates (top-left 0.0, 0.0 to 0.34, 0.20), extract missing enemy laner status, and detect neutral objective states (Turtle/Lord).
- Incorporate latency compensation to offset tactical recommendations by provider round-trip time.
- Wire `MethodChannel("com.example.owl/overlay")` and `MethodChannel("com.example.owl/screen_capture")` in Dart and Kotlin to control `GameTurboOverlayService` and `MediaProjection`.

**Non-Goals:**
- Shipping bundled on-device TensorFlow/ONNX models for full semantic segmentation.
- Replacing the existing `CoachService` architecture; instead, the autonomous loop feeds directly into `CoachService.requestTacticalTick()`.
- Building or assembling native APKs.

## Decisions

### Decision 1: Downsampled Frame Diffing for Redundancy Suppression
- **Choice**: Sampled frames are scaled down to 32x32 single-channel grayscale bytes. Successive frames are compared using mean squared error (MSE) or absolute pixel difference. If diff < 3%, the engine marks the screen as static and skips AI provider inference while advancing the local match ticker.
- **Alternatives Considered**: Full 1080p byte comparison (excessive CPU/memory overhead per tick); client-side OpenCV integration (bloats binary and adds heavy native bindings).

### Decision 2: Decoupled Autonomous Loop Architecture
- **Choice**: Separate concerns into `AutonomousTacticalLoop` (timing, capture scheduling, diffing, lifecycle), `MobaMinimapExtractor` (coordinate mapping, hero token tracking, objective timings), and `CoachService` (reasoning, prompt construction, multi-model dispatch).
- **Alternatives Considered**: Bloating `CoachService` with frame sampling and pixel analysis (violates single responsibility and hinders isolated testing).

### Decision 3: Lightweight Heuristic Minimap Token Extraction
- **Choice**: Analyze the top-left 34% x 20% viewport with localized color range heuristics (red team tokens vs blue team tokens vs gold/purple neutral markers). Track missing duration via sliding timestamp windows.
- **Alternatives Considered**: Cloud vision API on every frame (unacceptable cost and latency at 5 FPS); full native NDK computer vision (unnecessary complexity for 2D icon extraction).

### Decision 4: Platform Channel Bridge for Native Overlay & MediaProjection
- **Choice**: Extend Flutter-Android method channels:
  - `com.example.owl/screen_capture`: `requestCapturePermission()`, `startCapture()`, `stopCapture()`, `getLatestFrame()`.
  - `com.example.owl/overlay`: `hasOverlayPermission()`, `requestOverlayPermission()`, `showOverlay()`, `hideOverlay()`, `updateOverlayData()`.
- **Alternatives Considered**: Third-party Flutter screen recorder plugins (often unmaintained, conflicting with Android 14 foreground service requirements).

## Risks / Trade-offs

- **[Risk] MediaProjection Consent on Android 14+**: Android 14 requires explicit per-launch screen capture consent and foreground service type `mediaProjection`.
  → **Mitigation**: Handle permission rejection gracefully with informative UI alerts and provide a simulated feed mode for development and testing.
- **[Risk] Thermal and Battery Throttling at High Cadence**: Continuous 12 FPS capture can cause thermal throttling on budget devices.
  → **Mitigation**: Default to Balanced (5 FPS) or Battery Saver (1 FPS), automatically downgrade cadence if frame diffing indicates prolonged low activity, and stop immediately on session pause.
