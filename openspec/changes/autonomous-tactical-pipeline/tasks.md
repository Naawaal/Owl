## 1. Autonomous Vision & Frame Sampling Engine

- [x] 1.1 Implement `FrameDiffer` utility for 32x32 grayscale thumbnail generation and perceptual difference calculation.
- [x] 1.2 Implement `AutonomousTacticalLoop` service supporting performance modes (1 FPS saver, 5 FPS balanced, 12 FPS high), diff suppression, and frame sampling.
- [x] 1.3 Create unit tests for `FrameDiffer` and `AutonomousTacticalLoop` lifecycle, cadence switching, and static screen suppression.

## 2. MOBA Minimap & Objective State Extractor

- [x] 2.1 Implement `MobaMinimapExtractor` with normalized landscape coordinates (top-left 0..0.34 x 0..0.20) and missing laner duration tracking.
- [x] 2.2 Implement neutral objective state extractor for Lord and Turtle timers and contest states.
- [x] 2.3 Wire `MobaMinimapExtractor` into `CoachService` and enrich `CoachPrompt.tacticalContext` with minimap telemetry.
- [x] 2.4 Create unit tests for `MobaMinimapExtractor` covering coordinate normalization, missing enemy tracking, and objective alerts.

## 3. Latency Compensation & Tactical Game Clock

- [x] 3.1 Implement latency compensation calculator in `CoachService` projecting game timestamps forward by measured provider RTT.
- [x] 3.2 Implement degradation fallback to localized heuristic audio alerts when provider RTT exceeds 1500ms.
- [x] 3.3 Create unit tests for latency compensation calculations and high-latency degradation paths.

## 4. Native Android Screen Capture & Floating Overlay Bridge

- [x] 4.1 Implement `ScreenCaptureChannel` in Dart to coordinate `MediaProjection` capture authorization, frame retrieval, and lifecycle.
- [x] 4.2 Extend `MainActivity.kt` with `com.example.owl/screen_capture` platform channel handler for `MediaProjection` screen frames.
- [x] 4.3 Extend `GameTurboOverlayService.kt` and Flutter `OverlayChannel` to relay live tactical advice and minimap radar alerts to the native floating HUD.
- [x] 4.4 Create unit tests for platform channel wrappers with mocked platform message handlers.
