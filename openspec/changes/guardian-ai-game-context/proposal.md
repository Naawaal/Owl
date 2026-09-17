## Why

The Guardian AI currently sends context-blind prompts — it knows only the game name and FPS target. With zero match state (role, hero, match timer, CPU load, live FPS, or enemy positions), the AI invents guesses that are wrong for the specific game being played. Fixing this closes the accuracy gap and makes advice actionable rather than generic.

## What Changes

- **Game context payload enriched** in `CoachPrompt` — adds `gameCategory`, `cpuPercent`, `batteryPercent`, `liveFps` fields; `toFormattedPrompt()` includes all of them so every AI call is grounded in live device and game state.
- **`CoachService` wires live stats** — reads `systemStatsProvider` at request time and injects cpu/battery/fps into the prompt; topic-refresh calls also carry the enriched situation string.
- **Match timer propagated** — `TacticalBattlefieldHud` owns a session clock started on first render; elapsed seconds flow down to every `requestAdvice()` call so match-time advice is accurate mid-match.
- **`setGameContext` MethodChannel** — new Flutter → Android channel call carrying `gameCategory`, `preferredRole`, `coachingLevel`, `matchElapsedSeconds` into `GameTurboOverlayService`; fired from the toolbox on open and on each topic refresh.
- **Android prompt upgraded** — the native overlay's text-only prompt (previously 2 lines) expanded to match the Flutter prompt quality: includes role, coaching level, CPU%, battery%, live FPS, and topic type; vision prompt also gains role + match time.
- **Guardian callout UI/UX** — warning severity pill (red/amber) for critical warnings; topic chip beside LIVE badge; provider + latency inline; shimmer placeholder during load; tap-refresh micro-animation; action text expanded to 2 lines.

## Capabilities

### New Capabilities

- `game-context-payload`: Structured game context (role, category, device stats, match time) assembled and injected into every AI coaching request on both Flutter and Android layers.
- `guardian-game-context-channel`: `setGameContext` MethodChannel contract allowing Flutter to push live match context into the native `GameTurboOverlayService` so the autonomous overlay prompt stays in sync with the Flutter-layer context.
- `guardian-callout-ux`: Enhanced Guardian AI callout widget with warning pill, topic chip, provider/latency badge, loading shimmer, refresh tap animation, and 2-line action text.

### Modified Capabilities

*(none — no existing spec-level behavior contracts change; this change adds new behaviors only)*

## Impact

- **`lib/features/ai_coach/domain/models/coach_prompt.dart`** — new optional fields, extended `toFormattedPrompt()`
- **`lib/features/ai_coach/data/coach_service.dart`** — reads `systemStatsProvider` at call time, enriched situation string in `requestTopicRefresh()`
- **`lib/features/overlay/presentation/tactical_battlefield_hud.dart`** — match session timer, passes elapsed seconds downstream
- **`lib/features/overlay/presentation/gameturbo_floating_toolbox.dart`** — enriched `requestAdvice()` call, Guardian callout UX overhaul, fires `setGameContext` channel
- **`lib/features/overlay/data/overlay_channel.dart`** — new `setGameContext()` method
- **`android/…/MainActivity.kt`** — new `setGameContext` MethodChannel handler
- **`android/…/GameTurboOverlayService.kt`** — new instance vars, `setGameContext()` method, upgraded text-only and vision prompts
- **No breaking API changes** — all new `CoachPrompt` fields are optional; existing call sites compile unchanged
