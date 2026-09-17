## Context

See proposal.md — Why. Today `togglePerformanceOptimization` persists prefs and calls `applyPersistedHardwareState`, but that path hardcodes `targetFps: 120|60` instead of the active game target, and the overlay Flutter isolate may not see main-engine channel side effects reliably. Native `GameTurboOverlayService` keeps its own `isPerformanceMode` / `currentTargetFps`. Gauge UX (Wi‑Fi ms meta) was partially applied in code and must be locked by this change.

## Goals / Non-Goals

**Goals:**
- Single source of truth: `GameTurboSettings.performanceOptimization` (+ related fields) in SharedPreferences
- Every mode toggle applies: prefs → FPS tracker → MainActivity/overlay `setPerformanceMode` → service refresh/FPS ceilings → UI accents
- Use active game `targetFps` for Performance; 60 for Balanced
- Overlay engine receives mode via existing games channel + prefs reload on `shown`
- Lock gauge meta UX (Wi‑Fi ms only) and Console-without-preview-HUD

**Non-Goals:**
- Rebuilding Console cinematic stage
- New AI/coach budgets (assistant performance profiles stay separate)
- Archiving `hud-console-ui-parity` in this change
- Translucent Activity fallback for FlutterView

## Decisions

1. **Persist via existing settings notifier**  
   Keep `togglePerformanceOptimization` as the primary API. Fix `applyPersistedHardwareState` to pass `activeGame?.targetFps ?? state.gpuFpsTarget ?? 120` when Performance.  
   *Alternative:* separate overlay-only mode store — rejected (drift).

2. **Overlay isolate sync**  
   On toolbox mode tap: notifier persists + games channel `setPerformanceMode`. On `shown` / expand: prefs.reload + re-read settings; native already has mode from service. Optionally push `configure` with `isPerformance` for instant UI before prefs round-trip.  
   *Alternative:* MethodChannel-only ephemeral mode — rejected (not persistent).

3. **Native apply**  
   `GameTurboOverlayService.setPerformanceMode(isPerf, targetFps)` remains the sink for refresh rate + live FPS clamps; OverlayFlutterEngineHost games bridge already calls it — ensure MainActivity path uses the same targetFps resolution.

4. **UX chrome**  
   Gauge meta = Wi‑Fi latency only; Wi‑Fi action has no badge. Already started; tasks verify and finish any leftovers.

5. **Console TURBO pill**  
   Continues to call the same `setPerformanceMode` / toggle path as toolbox pills (no separate preview HUD).

## Risks / Trade-offs

- [Overlay prefs lag] → Call `prefs.reload()` on `shown` and include `isPerformance` in `configure` for immediate paint  
- [Wrong target FPS when no active game] → Fall back to `gpuFpsTarget` then 120  
- [Two engines write prefs concurrently] → SharedPreferences last-write-wins; acceptable for boolean mode  

## Migration Plan

1. Ship Dart + Kotlin sync fixes together (hot restart / reinstall)  
2. Existing persisted `performanceOptimization` continues to work; no schema bump required unless envelope fields change  
3. Rollback: revert change; prefs remain valid booleans  

## Open Questions

- None blocking: game target FPS source is `InstalledGame.targetFps` with `gpuFpsTarget` fallback.
