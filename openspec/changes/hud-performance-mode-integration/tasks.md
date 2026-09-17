## 1. Mode persistence + target FPS

- [x] 1.1 Fix `applyPersistedHardwareState` to use active game `targetFps` (fallback `gpuFpsTarget`, then 120) for Performance and 60 for Balanced
- [x] 1.2 Ensure `togglePerformanceOptimization` / Console TURBO pill both persist and call the same apply path
- [x] 1.3 Pass `isPerformance` (+ targetFps) in overlay `configure` / session config so the toolbox paints the correct mode before prefs reload completes

## 2. Cross-surface sync

- [x] 2.1 Confirm overlay `games` channel `setPerformanceMode` updates `GameTurboOverlayService` and that `pushStats` respects the new ceiling
- [x] 2.2 On overlay `shown`, reload SharedPreferences and refresh `gameTurboSettingsProvider` / mode-dependent UI
- [x] 2.3 On service start / expand, restore `isPerformanceMode` and `currentTargetFps` from prefs or last Flutter configure — not hardcoded demo values

## 3. Full Balanced / Performance behavior

- [x] 3.1 Balanced: clamp gauge/live FPS display and preferred refresh to 60; blue/calm accents on pills + gauge
- [x] 3.2 Performance: use game target FPS for gauge dial max, native refresh preference, and telemetry clamps; critical/red accents
- [x] 3.3 Align MainActivity `setPerformanceMode` argument handling with overlay bridge (same targetFps resolution)

## 4. In-game HUD UX polish

- [x] 4.1 Verify gauge meta strip is Wi‑Fi latency only (no clock, battery, or inference `--ms`)
- [x] 4.2 Verify Wi‑Fi quick-action has no ms badge
- [x] 4.3 Confirm Console has no `GameturboFloatingToolbox` overlay and no Play → `TacticalBattlefieldHud` preview navigation

## 5. Verification

- [ ] 5.1 Manual: toggle Balanced ↔ Performance in overlay; kill app; relaunch; expand overlay — mode persists
- [ ] 5.2 Manual: toggle from Console TURBO pill; open game overlay — mode matches; FPS ceiling 60 vs game target
- [x] 5.3 Run `flutter analyze --no-fatal-warnings` on touched Dart files and fix new issues
