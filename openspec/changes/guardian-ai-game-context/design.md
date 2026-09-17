## Context

The app uses a dual-layer architecture: the Flutter `CoachService` handles AI advice for the in-app UI, and the Android-native `GameTurboOverlayService` runs an autonomous inference loop for the system-level overlay over games. Both currently send minimal prompts — Flutter sends a static `"Live coaching for <game> at <fps> FPS target."` string; the native overlay sends a 2-line prompt with only game name and FPS. All device stats, player role, game genre, and match time are available in the app at inference time but never forwarded to the LLM.

The `CoachPrompt` domain model already accepts `tacticalContext: Map<String, dynamic>?` and `heroChampion: String?` as optional fields; the `systemStatsProvider` already yields CPU/battery/FPS on a 2-second poll; `activeGameProvider` already holds `category` and `targetFps`. The missing piece is wiring these together at the call sites and extending `CoachPrompt` with the typed stat fields.

On the Android side, `GameTurboOverlayService` receives API credentials via `setAiCredentials` over MethodChannel but has no equivalent channel for game context. Its `currentGameName` and `currentTargetFps` are set via Intent extras on start, which means mid-match context (role, coaching level, match time) never reaches the overlay.

## Goals / Non-Goals

**Goals:**
- Every AI call (Flutter and Android) carries: game name, game category, player role, coaching level, CPU%, battery%, live FPS, and match elapsed time
- The Android overlay prompt quality matches the Flutter prompt quality
- All new fields are optional/nullable so no existing call site breaks
- Guardian callout UX is upgraded to surface warning severity, topic, provider+latency, shimmer loading, tap feedback, and wider action text

**Non-Goals:**
- Real-time game API integration (no reading game memory, no network calls to game servers)
- Hero auto-detection (hero field remains manually set or vision-extracted; this change does not add hero auto-fill)
- Persistent match state across app restarts
- Changes to the AI provider routing logic (handled in previous session)

## Decisions

### D1: Extend `CoachPrompt` with typed stat fields vs. stuffing into `tacticalContext`

**Decision**: Add `gameCategory: String?`, `cpuPercent: int?`, `batteryPercent: int?`, `liveFps: int?` as first-class fields on `CoachPrompt`.

**Rationale**: `tacticalContext` is a free-form map for minimap/objective data. Mixing device telemetry into it pollutes the semantic boundary and makes the prompt formatter harder to test. Typed fields allow `toFormattedPrompt()` to produce a consistent, readable block and allow individual tests to assert specific field inclusion.

**Alternative**: Stuffing everything into `tacticalContext` — rejected because it conflates two distinct concerns (game state vs. device state) and makes the formatter depend on string keys.

---

### D2: Match timer owned by `TacticalBattlefieldHud`, not `GameturboFloatingToolbox`

**Decision**: The session clock (`_matchStartTime`) lives in `_TacticalBattlefieldHudState`. The HUD passes `matchElapsedSeconds` down to `GameturboFloatingToolbox` as a constructor parameter.

**Rationale**: The toolbox is toggled open/closed many times per match. If it owned the clock, elapsed time would reset on every open. The HUD widget is created once per match session and is the correct owner. The clock starts in `initState` and is never reset until the HUD is disposed.

**Alternative**: Timer in the `CoachService` / Riverpod — rejected because `CoachService` is a state notifier shared across sessions and resetting it cleanly on new-match detection is already done via `resetMatchBudget()`; adding timer logic there conflates two concerns.

---

### D3: `setGameContext` as a separate MethodChannel method, not extended `setAiCredentials`

**Decision**: Add a new `setGameContext` handler alongside the existing `setAiCredentials` handler in `MainActivity.kt`.

**Rationale**: Credentials and game context have different update cadences. Credentials are set once on settings change; game context updates every 90 seconds with the topic refresh. Merging them forces a full credential re-send on every topic refresh, which is wasteful and risks clearing the key in edge cases. Separate channels keep concerns isolated.

**Alternative**: Extend `setAiCredentials` payload — rejected because it couples two orthogonal concerns and would require re-sending the API key on every match-time update.

---

### D4: Guardian callout shimmer implemented as `AnimatedContainer` with opacity animation, not a third-party package

**Decision**: Shimmer effect built from a cycling `AnimatedContainer` opacity (0.3 → 0.8 → 0.3) using an `AnimationController` already available in the stateful toolbox widget. No new package dependency.

**Rationale**: The app already has `AnimationController` infrastructure in the toolbox. Adding `shimmer` or `skeletonizer` package for a single loading row in a compact overlay widget is not worth the dependency weight.

---

### D5: Topic chip as colored `Container` dot, not icon

**Decision**: A 6×6 `Container` with `BoxShape.circle` and topic-mapped color, positioned inline before the badge text.

**Rationale**: Keeps the callout header compact (the row is already constrained to ~270dp wide). An icon (even at 8px) would push the provider+latency text off the edge on smaller overlays. A dot at 6px adds clear color signal with zero overflow risk.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| `systemStatsProvider` returns null at the moment `requestAdvice` fires | All stat fields on `CoachPrompt` are nullable; `toFormattedPrompt()` omits fields that are null — advice still fires |
| Match timer desync if HUD is backgrounded | `DateTime.now()` subtraction is always wall-clock relative; background time counts. This is acceptable — MOBA match time is real time |
| `setGameContext` channel call silently fails if overlay not yet started | Flutter side wraps in try/catch with `unawaited`; no user-visible failure |
| Android prompt size increases → slightly higher token usage | Increase is minimal (~50 tokens); all providers have 300 `max_tokens` cap already set, well within free-tier limits |
| Guardian callout shimmer `AnimationController` leaks if widget disposed during animation | `dispose()` already cancels `_topicRefreshTimer`; shimmer controller added to same `dispose()` block |

## Migration Plan

All changes are additive (new optional fields, new MethodChannel handler, UI widget changes). No migrations, no database schema changes, no API version bumps. Rollback = revert the commits for each track independently.
