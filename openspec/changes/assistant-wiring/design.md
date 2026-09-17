## Context

See `proposal.md` (Why) for motivation. Current state shaping this design:

- `CoachService` (from the `ai-inference` change) already owns budgets (30s cooldown, 20/match cap, 20s timeout), prompt assembly from `CoachPrompt`, `AsyncValue` state with last-known caching — but reads only provider, model, role, and the master engine flag. It ignores level, sensitivity, mode, topics, and performance profile.
- No TTS exists anywhere (`flutter_tts` absent); haptics fire directly at call sites with no gate; `gameTurboMaster` and `restrictButtonsAndGestures` are write-only.
- `SystemStats` exposes battery/cpu/gpu/fps but no temperature sensor; thermal response must derive from available signals.
- The toolbox owns the callout surface and already watches the coach state; the edge handle shows FPS text.

## Goals / Non-Goals

**Goals:**
- Every one of the 19 dead controls observably alters behavior, verified per category on device.
- Voice and budgets stay bounded: no API spam, no battery drain, no gameplay interruption.
- All new behavior covered by mocked tests; no live calls in CI.

**Non-Goals:**
- No post-match coaching UI (assistant `postMatch` mode parks as live-off; surface is a follow-up).
- No native temperature sensor channel (documented follow-up; proxy signals suffice).
- No settings UI redesign and no new settings options.

## Decisions

### 0. Prompt shaping carries level, sensitivity, and topics

`coachingLevel` selects a depth instruction block appended to the prompt (beginner: fundamentals-only language; advanced: wave-control plus cooldown specifics); `warningSensitivity` appends an urgency line and scales the service's cooldown/cap multipliers (early 0.5x/1.5x, balanced 1x/1x, conservative 2x/0.5x); each topic toggle maps to a prompt type the auto-refresh loop may issue. `assistantMode` off suppresses all automatic queries (manual refresh still allowed); `explainRecommendations` off hides the reason line in the callout.

Alternative considered: separate prompt templates per level. Rejected — one template with a depth block is easier to tune and test.

### 1. Performance profile selects budget presets; stress throttles dynamically

`saver`/`balanced`/`high` map to (cooldown, cap, FPS target) presets; `adaptiveWorkload` permits the service to tighten toward saver budgets under stress; `thermalProtection` enables the stress response itself, driven by sustained high CPU with low battery from the existing stats stream. `showInGameLatencyHud` toggles a latency readout fed by the service's last measured milliseconds in toolbox and edge handle.

Alternative considered: native battery-temperature channel for thermal input. Rejected for this change — new platform code for one signal; the CPU+battery proxy is available now, native temp is a follow-up.

### 2. TTS engine behind priority, cooldown, and mix guards

A small TTS provider wrapper speaks only fresh advice passing the priority filter (`criticalOnly` = warnings/urgent only), spaced by `speechCooldownSeconds`, configured to mix with (never duck) game audio. `voiceAlertsEnabled` off silences it entirely. `flutter_tts` is the engine (Android TTS / iOS AVSpeech passthrough, no new native code).

Alternative considered: custom audio synthesis. Rejected — orders of magnitude more work for zero user-visible gain.

### 3. Central gates for haptics and master switch

All haptic call sites route through one `Haptics` helper consulting `hapticsEnabled`. `gameTurboMaster` off halts coach auto-queries, TTS, and native perf sync (manual controls unaffected). `restrictButtonsAndGestures` additionally enforces immersive mode at boot, matching its toggle-time behavior.

Alternative considered: gating inside each call site ad hoc. Rejected — nineteen sites invite drift; one helper, one test.

## Risks / Trade-offs

- [Risk] TTS voice talks over critical game audio → Mitigation: mix-don't-duck session config plus cooldown spacing; priority filter defaults to critical-only.
- [Risk] Auto-refresh raises API cost and battery use → Mitigation: topic-gated, budget-capped, profile-scaled, stress-throttled; off by default per topic where sensible.
- [Risk] CPU+battery proxy misfires thermal throttle on capable devices → Mitigation: sustained-window detection (not spikes) with hysteresis; thermal protection toggle remains user-overridable.
- [Trade-off] `postMatch` mode parks without a surface → Accepted: documented; live/off cover the shipped experience, post-match UI is a follow-up.

## Migration Plan

1. Land service shaping, budgets, TTS, gates, and readouts in a single change (no persisted format changes; settings keys untouched).
2. Verify: `flutter analyze`, `flutter test` with mocked TTS/dio/budgets, manual device pass toggling each of the 19 controls observably.
3. Rollback: revert the single change; controls return to persisted-but-inert and inference keeps working as today.
