## Why

The in-game Flutter overlay toolbox can switch Balanced / Performance, but the mode is not reliably persistent or fully wired: Console, overlay isolate, and native `GameTurboOverlayService` can disagree; Balanced does not consistently enforce 60 FPS / refresh; Performance does not always apply the game’s target FPS and gauge/telemetry accents. Recent UI tweaks (Wi‑Fi ms meta strip, Console HUD preview removed) also need a coherent UX pass so the in-game HUD feels finished and trustworthy.

## What Changes

- **Persistent mode**: Balanced / Performance chosen in the overlay (or Console TURBO pill) persists to SharedPreferences and is restored on cold start, overlay expand, and service restart.
- **Cross-surface sync**: Mode changes sync among Console Riverpod state, overlay Flutter engine, and native `GameTurboOverlayService` (FPS ceiling, preferred refresh rate, gauge accents).
- **Full Balanced integration**: Caps live FPS display and preferred refresh to 60; blue/calm telemetry accents; mode pill + Console TURBO pill stay consistent.
- **Full Performance integration**: Uses game `targetFps` (e.g. 90/120); red/critical accents; native turbo path and `setPerformanceMode` stay aligned.
- **In-game HUD UX polish**: Keep Wi‑Fi latency in the gauge meta strip (no clock / battery / inference `--ms`); Wi‑Fi tool button has no ms badge; mode pills and telemetry remain readable in light/dark.
- **No Console preview HUD**: Confirm Console does not host `GameturboFloatingToolbox` or navigate to `TacticalBattlefieldHud` for testing (already removed; lock via requirements).

## Capabilities

### New Capabilities
- `hud-performance-mode`: Persistent Balanced / Performance mode with full behavioral integration across Flutter overlay, Console, and native overlay service, plus in-game HUD UX polish for the mode/telemetry chrome.

### Modified Capabilities
<!-- None — no existing main-spec capability covers overlay mode persistence -->

## Impact

- `lib/features/overlay/presentation/gameturbo_floating_toolbox.dart` — mode pills + gauge UX
- `lib/features/settings/presentation/settings_provider.dart` — persist + native `setPerformanceMode`
- `lib/overlay_entry.dart` — overlay isolate mode sync / prefs reload
- `android/.../OverlayFlutterEngineHost.kt` — games channel mode bridge
- `android/.../GameTurboOverlayService.kt` — apply/persist `isPerformanceMode`, FPS ceilings
- `android/.../MainActivity.kt` — `setPerformanceMode` parity with overlay path
- Console top bar TURBO pill already toggles mode; ensure it uses the same persistence path
