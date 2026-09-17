## Why

The Game Turbo overlay and in-game HUD currently exhibit hardcoded, inaccurate FPS telemetry (e.g. displaying a static `120 FPS` or `60 FPS` regardless of actual game rendering speed) and display refresh rate switches that do not physically enforce display mode rates on modern Android versions. Furthermore, the UI/UX between the Console Screen, the In-Game HUD (`TacticalBattlefieldHud`), and the native floating overlay handle lacks visual and behavioral parity, while Guardian AI advice is redundantly duplicated inside toolbox cards rather than remaining cleanly separated as an in-game floating tactical bubble.

## What Changes

- **Real Frame Rate Telemetry**: Eliminate hardcoded FPS overrides in both native Kotlin and Flutter. Measure real game frame presentation frequency via sliding-window arrival timestamps from `ImageReader` (MediaProjection) and hardware display composition frequency from `Choreographer`.
- **Hardware Display Mode Enforcement**: Update native window layout parameters (`preferredDisplayModeId`, `preferredMinDisplayRefreshRate`, `preferredMaxDisplayRefreshRate`, `preferredRefreshRate`) to physically lock 60Hz in Balanced Mode and unlock up to 120Hz in Performance Mode.
- **Console & HUD UI/UX 1:1 Parity**: Align the In-Game HUD top bar with the Console Screen status bar: Battery shell + %, CPU badge + %, FPS badge + live value on the left; interactive `● TURBO / BALANCED <fps> FPS 🎛️` pill in the center; navigation/settings on the right.
- **Native Handle Parity**: Style the native floating overlay handle to match the Console central pill 1:1 with emerald live dot, dynamic mode prefix, live measured FPS, and tune icon.
- **Guardian AI Separation**: Keep Guardian AI cleanly detached as an autonomous floating tactical bubble in-game without cluttering the floating toolbox cards with redundant inline advice.
- **Lightweight Screen Capture**: Optimize `ImageReader.setOnImageAvailableListener` to only decode and compress frames when explicit screen capture is requested, preventing heavy per-frame JPEG/PNG compression overhead.

## Capabilities

### New Capabilities
- `game-turbo-telemetry-hud`: Real-time hardware and game frame rate measurement, physical display refresh rate switching between Balanced and Performance modes, and unified 1:1 UI/UX parity between Console Screen, In-Game HUD, and native overlay handles.

### Modified Capabilities
<!-- None -->

## Impact

- `android/app/src/main/kotlin/com/example/owl/GameTurboOverlayService.kt`: Frame arrival timestamp sampler, physical display mode switching, pill styling, and lightweight image reader listener.
- `android/app/src/main/kotlin/com/example/owl/MainActivity.kt`: Synchronized display mode switching and live FPS query fallback.
- `lib/features/overlay/data/system_stats_service.dart`: Synchronized ceiling in `RealTimeFpsTracker` without synthetic inflation.
- `lib/features/overlay/presentation/gameturbo_floating_toolbox.dart`: Removal of fake 60/120 overrides and redundant inline guardian callout.
- `lib/features/overlay/presentation/tactical_battlefield_hud.dart`: Adoption of Console Screen top bar and central interactive pill.
