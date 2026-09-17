## Why

Nineteen settings controls across Assistant, Performance, Voice, and Overlay screens persist and display correctly but change nothing at runtime: coaching depth, alert topics, voice callouts, haptics gating, performance budgets, and the master switch are all dead. With live inference now working (`ai-inference` change), wiring these controls to real behavior completes the features the settings pages promise.

## What Changes

- **Assistant & Tactical AI:** `assistantMode` gates live auto-querying (off = silent); `coachingLevel` shapes prompt depth (beginner/intermediate/advanced briefings); `warningSensitivity` scales service budgets; `explainRecommendations` toggles reason display in the callout; the four topic toggles (missing-enemy, overextension, objectives, wave advice) subscribe topics for periodic auto-refresh and filter callout display.
- **Assistant Performance:** `performanceMode` selects budget presets (saver/balanced/high map to cooldown, call cap, and FPS target); `adaptiveWorkload` lets the service tighten budgets under device stress; `thermalProtection` enables stress throttling driven by sustained CPU load and battery state; `showInGameLatencyHud` surfaces the last inference latency in the toolbox and edge handle.
- **Voice & Alerts:** new TTS engine speaks fresh advice gated by `voiceAlertsEnabled`, filtered by `alertPriority`, spaced by `speechCooldownSeconds`, mixed per `avoidInterruptingGameAudio` (never ducks game audio); `hapticsEnabled` gates every haptic firing site through one central check. Adds the `flutter_tts` dependency.
- **Overlay:** `gameTurboMaster` kills all automation (advice queries, TTS, native perf sync) while leaving manual controls live; `restrictButtonsAndGestures` enforces immersive mode on boot as well as on toggle.

## Capabilities

### New Capabilities
- `assistant-wiring`: live behavior behind all Assistant, Performance, Voice, and Overlay settings — prompt shaping and topic-gated auto-refresh, budget presets with stress throttling, latency HUD readout, TTS callouts with priority/cooldown/mix control, central haptics gate, and master kill-switch.

### Modified Capabilities
- None — `openspec/specs/` is empty, so there are no existing capabilities to modify.

## Impact

- Affected code: `CoachService` (budgets, prompt shaping, latency tracking), new TTS engine wrapper + provider, `gameturbo_floating_toolbox.dart` (callout + latency readout), `tactical_battlefield_hud.dart` (latency readout), `main.dart` (immersive enforcement, TTS init), haptic call sites, `test/` (budget mapping, gating, TTS-mocked tests).
- New dependency: `flutter_tts` (Android TTS engine; iOS AVSpeech passthrough).
- Verification: `flutter analyze`, `flutter test` (mocked TTS + budgets), manual device pass: toggles alter behavior observably per category.
