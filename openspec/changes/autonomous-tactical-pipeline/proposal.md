## Why

While Owl has established tactical coaching logic, multi-model providers, and audio alert pipelines, coaching currently relies on manual triggers or passive screen queries. To function as an authentic esports game companion, Owl must autonomously observe live gameplay in the background, extract critical MOBA tactical states (minimap hero positions, missing enemy laners, and neutral objective countdowns) with minimal battery/thermal overhead, and surface real-time guidance directly on top of active games via Android's `SYSTEM_ALERT_WINDOW` overlay.

## What Changes

- **Autonomous Background Game-Tick Engine**: Implement `AutonomousTacticalLoop` driven by user performance profiles (1 FPS saver, 5 FPS balanced, 12 FPS high), featuring frame diffing / perceptual hashing to suppress redundant inference during loading or paused screens.
- **MOBA Minimap & Objective State Extractor**: Implement `MobaMinimapExtractor` to isolate landscape minimap regions (top-left 20% x 34%), track missing enemy laners, extract Lord/Turtle timers, and inject structured context into `CoachPrompt`.
- **Latency-Compensated Game Clock**: Synthesize network round-trip latency offsets with match duration timestamps so tactical alerts land before plays develop rather than in the past.
- **Native Android Overlay Linkage**: Connect the Flutter app to `GameTurboOverlayService` via `MethodChannel` for permission acquisition (`SYSTEM_ALERT_WINDOW`), launch synchronization, and HUD metric passing.

## Capabilities

### New Capabilities
- `autonomous-tactical-pipeline`: Continuous background frame sampling, MOBA minimap vision extraction, latency-compensated tactical coaching triggers, and native floating overlay control.

### Modified Capabilities
<!-- None: existing tactical-assistant-wiring contracts remain backwards-compatible -->

## Impact

- **Flutter / Dart Core**: New services `AutonomousTacticalLoop` and `MobaMinimapExtractor` under `packages/owl_common/lib/src/services/` or `lib/services/`. Updates to `CoachService` to accept autonomous ticks.
- **Native Android**: Integration in `MainActivity.kt` for `MediaProjection` screen capture intent handling and bridging to `GameTurboOverlayService`.
- **Dependencies**: Uses existing Flutter image/vision utilities, `flutter_isolate` or background isolate if compute-heavy, and Android standard platform channels.
