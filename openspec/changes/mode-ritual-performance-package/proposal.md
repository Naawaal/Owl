## Why

Balanced and Performance mode currently persist and hint refresh/FPS ceilings, but the toggle does not apply a portable “game conditions” package users expect from Game Turbo–class tools. On every Android device a third-party app cannot lock CPU/GPU clocks; it *can* reduce interruptions, improve net feel, engage immersion locks, and free thermal headroom by throttling Owl’s own AI/vision load. We need that atomic ritual so mode switches actually improve the match and feel competitive without fake OEM claims.

## What Changes

- Add a single **mode ritual** on Balanced ↔ Performance toggle: DND, Wi‑Fi low-latency, soft refresh preference, immersion locks (mistouch/gestures/brightness), with prior-state restore
- Add **Owl performance budgets** keyed by mode: Balanced throttles coach ticks / MediaProjection warmth / guardian refresh; Performance keeps rail lean but allows coaching when AI is on
- Surface haptic + short toast naming real effects (not “GPU unlocked”)
- Optional **OEM Game Booster bridge**: detect Xiaomi/Samsung/Oppo game tools and one-tap open system settings to complement Owl
- Wire Console TURBO pill and HUD mode pills through the same ritual entry point (extends existing `togglePerformanceOptimization` path)

## Capabilities

### New Capabilities
- `mode-ritual`: Atomic Balanced/Performance package (DND, Wi‑Fi, refresh hint, immersion, toast/haptic) with restore-on-Balanced; Console and HUD toggles share one entry point
- `owl-performance-budget`: Mode-gated Owl self-throttling so Balanced frees thermal headroom for the game
- `oem-game-booster-bridge`: Best-effort detect and open OEM Game Turbo / Game Booster / Game Space

### Modified Capabilities
- (none — `hud-performance-mode` is not yet in main `openspec/specs/`; toggle wiring is covered under `mode-ritual`)

## Impact

- Dart: new coordinators under overlay/settings; `settings_provider` apply path; DND/Wi‑Fi services; coach/autonomous loop gates; HUD/Console feedback
- Android: `GameTurboOverlayService` budget flag; toast when Flutter HUD not focused; optional OEM package intent helpers
- Permissions: notification policy, Wi‑Fi, WRITE_SETTINGS (brightness) — all best-effort
- Depends on / complements existing `hud-performance-mode-integration` persistence work; does not claim OEM CPU/GPU locks
