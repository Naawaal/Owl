## Context

See proposal.md — Why. Mode persistence and refresh/FPS ceilings already exist (`togglePerformanceOptimization` → native `setPerformanceMode`). DND and Wi‑Fi channels are wired on main and overlay engines. Anti-jank rules already stop Choreographer/stats while the rail is collapsed. This design adds an atomic ritual + Owl budget on top of that path, and an OEM deep-link for true clocks.

## Goals / Non-Goals

**Goals:**
- One coordinator invoked from Console and HUD mode toggles
- Best-effort focus package + restoreable priors
- Balanced cuts Owl AI/vision heat; Performance keeps lean rail
- Optional OEM booster open intent
- Truthful user feedback

**Non-Goals:**
- OEM CPU/GPU governor control or `GameManager.setGameMode` for other packages
- Killing other apps’ processes
- GFX Tool–style graphics hacks
- Replacing Xiaomi/Samsung Game Turbo

## Decisions

1. **Coordinator in Dart, effects via existing channels**  
   `ModeRitualCoordinator.apply(isPerf, targetFps)` owns prior snapshot + ordered best-effort calls to DND/Wi‑Fi/settings immersion toggles, then signals toast. Native already handles refresh via `applyPersistedHardwareState`.  
   *Alternative:* all-native ritual — rejected (duplicates Flutter settings SoT).

2. **Priors stored in-memory + prefs envelope**  
   Snapshot `{dnd, wifi, mistouch, brightnessLock}` when entering Performance; restore on Balanced. Persist snapshot so process death mid-Performance still restores sensibly.  
   *Alternative:* never restore (leave DND on) — rejected (surprises users).

3. **Owl budget as volatile + prefs-driven flag**  
   Native `owlBalancedBudget` (or reuse `!isPerformanceMode`) gates guardian refresh and MediaProjection keep-warm. Dart coach loop reads `performanceOptimization` and skips/slows ticks when false.  
   *Alternative:* separate user setting — rejected (mode *is* the budget).

4. **OEM bridge is discovery + Intent, not integration**  
   Package/intent table for known boosters; UI chip only when `resolveActivity` succeeds.  
   *Alternative:* private Xiaomi APIs — rejected (not every Android).

5. **Toast from Flutter when HUD open; native Toast when only rail**  
   Ensures feedback mid-match without expanding toolbox.

## Risks / Trade-offs

- [DND permission denied] → Skip step; toast still mentions what applied  
- [Brightness WRITE_SETTINGS denied] → Skip brightness lock  
- [User manually toggles DND during Performance] → Next Balanced restores ritual prior, not live manual state — document as intentional  
- [OEM package rename] → Bridge silently unavailable; no crash  
- [Ritual hitches game] → All channel calls async/best-effort; never force display mode from collapsed rail (keep anti-jank)

## Migration Plan

1. Ship with existing `performanceOptimization` prefs — no schema bump required beyond optional `ritualPriors` map in settings envelope  
2. Default: first Performance captures priors from current tool state  
3. Rollback: revert coordinator; modes still persist/refresh as today

## Open Questions

- None blocking: immersion lock set is the existing settings toggles already exposed in Owl.
