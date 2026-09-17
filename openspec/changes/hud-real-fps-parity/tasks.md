## 1. Native Telemetry & Refresh Rate Engine

- [x] 1.1 Implement circular sliding-window frame rate arrival sampler in `GameTurboOverlayService.kt` off `ImageReader` with <0.1ms overhead
- [x] 1.2 Decouple `captureScreenFrame` and `captureScreenFrameRaw` so JPEG/PNG encoding only executes on explicit demand
- [x] 1.3 Add `Choreographer.FrameCallback` on the overlay window to measure display composition rate during idle/fallback periods
- [x] 1.4 Update `updateWindowPreferredRefreshRate` in `GameTurboOverlayService.kt` to resolve matching `Display.Mode` (60Hz vs 120Hz) and set `preferredDisplayModeId`, `preferredMinDisplayRefreshRate`, and `preferredMaxDisplayRefreshRate`
- [x] 1.5 Synchronize `MainActivity.kt`'s `applyPerformanceMode` and `getLiveFps()` with `GameTurboOverlayService`

## 2. Flutter HUD & Telemetry Parity

- [x] 2.1 Update `RealTimeFpsTracker` in `system_stats_service.dart` to sync mode targets (60 ceiling in Balanced, 120 ceiling in Performance) without artificial inflation
- [x] 2.2 Remove hardcoded `isPerf ? ... : 60` logic in `gameturbo_floating_toolbox.dart` to display genuine live FPS
- [x] 2.3 Remove redundant inline Guardian AI callout from `GameturboFloatingToolbox` to keep Guardian AI isolated to its separate floating tactical bubble
- [x] 2.4 Update `TacticalBattlefieldHud` top status bar to replicate `GameSpaceConsoleScreen`'s top status bar 1:1 (Battery, CPU, FPS badges, central interactive pill, and navigation)

## 3. Native Floating Handle & Gauge 1:1 Styling

- [x] 3.1 Update collapsed handle in `GameTurboOverlayService.kt` to match the console pill geometry, emerald dot, dynamic mode prefix (`TURBO` vs `BALANCED`), and tune icon
- [x] 3.2 Update `ReactorGaugeView` tachometer dial in `GameTurboOverlayService.kt` to scale dynamically (`fps / 60` in Balanced mode, `fps / 120` in Performance mode)

## 4. Verification & Validation

- [x] 4.1 Run `flutter analyze --no-fatal-warnings` and verify 0 issues
- [ ] 4.2 Build debug APK and deploy to device `24090RA29G`
- [ ] 4.3 Verify physical display refresh rate switches (60Hz vs 120Hz) via `dumpsys display` across Balanced and Performance modes
- [ ] 4.4 Verify live FPS telemetry in Pokémon UNITE and Console Screen reflects true rendering speed (~58–60 FPS) with separate floating Guardian AI bubble
