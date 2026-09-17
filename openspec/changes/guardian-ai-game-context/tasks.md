## 1. CoachPrompt Model — Live Context Fields

- [x] 1.1 Add optional fields to `CoachPrompt`: `gameCategory: String?`, `cpuPercent: int?`, `batteryPercent: int?`, `liveFps: int?`
- [x] 1.2 Extend `CoachPrompt.toFormattedPrompt()` to include a device-state block when any of the new fields are non-null (e.g., `Device: CPU 65% | Battery 48% | FPS 114 | Category: 5v5 MOBA`)
- [x] 1.3 Update `CoachPrompt.copyWith()`, `toMap()`, `fromMap()`, `operator==`, and `hashCode` for all four new fields
- [x] 1.4 Verify existing `CoachPrompt` tests pass without modification (new fields are optional, defaults null)

## 2. CoachService — Wire Live Stats Into Prompt

- [x] 2.1 In `CoachService.requestAdvice()`, read `systemStatsProvider` (cpu, battery, fps) and `activeGameProvider` (category) at call time; pass them into `CoachPrompt` constructor
- [x] 2.2 Replace the bare `'Scheduled $topic check-in…'` string in `requestTopicRefresh()` with a rich situation string that includes `settings.preferredRole`, live FPS, and CPU%
- [x] 2.3 Run `flutter test` and confirm all coach-service tests pass

## 3. Match Session Clock — TacticalBattlefieldHud

- [x] 3.1 Add `DateTime? _sessionStart` to `_TacticalBattlefieldHudState`; set it to `DateTime.now()` in `initState()`
- [x] 3.2 Add `int get _matchElapsedSeconds => _sessionStart == null ? 0 : DateTime.now().difference(_sessionStart!).inSeconds`
- [x] 3.3 Pass `matchElapsedSeconds: _matchElapsedSeconds` as a constructor parameter to `GameturboFloatingToolbox`; add the param to the widget

## 4. Toolbox — Enriched requestAdvice() Call

- [x] 4.1 In `_GameturboFloatingToolboxState._requestAdvice()`, replace the static situation string with a rich string incorporating `widget.gameTitle`, `widget.targetFps`, `settings.preferredRole`, live FPS from `systemStatsProvider`, and performance mode
- [x] 4.2 Pass `matchTimeSeconds: widget.matchElapsedSeconds` to `requestAdvice()`
- [x] 4.3 Pass `tacticalContext` from `_latestMinimapSnapshot` if available (already done in `CoachService`; ensure toolbox does not override with null)

## 5. Overlay Channel — setGameContext Method

- [x] 5.1 In `overlay_channel.dart`, add `Future<void> setGameContext({required String gameCategory, required String preferredRole, required String coachingLevel, required int matchElapsedSeconds})` that invokes `'setGameContext'` on the overlay MethodChannel
- [x] 5.2 Wrap the channel call in try/catch with `unawaited` so a missing service does not crash the Flutter layer

## 6. Android — setGameContext MethodChannel Handler

- [x] 6.1 In `MainActivity.kt`, add a `"setGameContext"` case in the overlay MethodChannel handler; extract `gameCategory`, `preferredRole`, `coachingLevel`, `matchElapsedSeconds` from call arguments and forward to `GameTurboOverlayService` via its public method
- [x] 6.2 In `GameTurboOverlayService.kt`, add instance vars: `var gameCategory: String = "5v5 MOBA"`, `var preferredRole: String = "auto"`, `var coachingLevel: String = "intermediate"`, `var matchElapsedSeconds: Int = 0`
- [x] 6.3 Add `fun setGameContext(gameCategory: String, preferredRole: String, coachingLevel: String, matchElapsedSeconds: Int)` method that updates those vars; also persist them to `owl_overlay_prefs` SharedPreferences for recovery after service restart
- [x] 6.4 In the companion `ServiceConnection` helper (if present), add `setGameContext` delegation

## 7. Android — Upgrade Native AI Prompts

- [x] 7.1 In the text-only prompt branch (`queryGeminiTacticalDirectives`, else branch at ~line 1649), replace the 2-line prompt with a full structured prompt that includes: game name, category, role, coaching level directive (beginner/intermediate/advanced mapped same as `CoachService.depthBlock()`), match time (formatted MM:SS), and performance mode
- [x] 7.2 In the vision prompt branch (~line 1638), add role and match time alongside the existing hero/minimap analysis instruction
- [x] 7.3 In the OpenAI-compat system message (~line 1664), update to include role and coaching level

## 8. Toolbox — Fire setGameContext on Open and Refresh

- [x] 8.1 In `_GameturboFloatingToolboxState.initState()` post-frame callback, add a call to `OverlayChannel().setGameContext(gameCategory: ..., preferredRole: settings.preferredRole, coachingLevel: settings.coachingLevel, matchElapsedSeconds: widget.matchElapsedSeconds)` alongside the existing `_requestAdvice()` call
- [x] 8.2 In the 90-second `_topicRefreshTimer` callback, add a `OverlayChannel().setGameContext(...)` call with updated `matchElapsedSeconds` before calling `requestTopicRefresh()`

## 9. Guardian Callout UX — Warning Pill

- [x] 9.1 In `_buildGuardianCallout()`, add a warning pill `Container` above the action text when `shown.warning` is non-null and non-empty; use `colors.telemetryCritical` tint with pill shape matching `RadiusTokens.pillBadge`
- [x] 9.2 Ensure the pill text uses `TypographyTokens.telemetryBadge` at ~9px, max 1 line, ellipsized

## 10. Guardian Callout UX — Topic Chip + Provider/Latency Badge

- [x] 10.1 Add a 6×6 `Container` dot with `BoxShape.circle` before the GUARDIAN AI COACH badge text; map `topic` → color: `missing-enemy` → `colors.telemetryCritical`, `overextension` → `colors.badgeYellow`, `objective` → `colors.emeraldLive`, `wave` → `colors.turboBlue`, default → `colors.textMuted`
- [x] 10.2 Right-align `<provider> • <latency>ms` text on the same Row as the LIVE badge; read `settings.activeAiProvider` and `service.lastLatencyMs`; omit latency portion when null

## 11. Guardian Callout UX — Loading Shimmer

- [x] 11.1 Add a shimmer `AnimationController` (`_shimmerController`) in `_GameturboFloatingToolboxState`; initialize in `initState()`, dispose in `dispose()`
- [x] 11.2 When `adviceAsync.isLoading && shown == null`, render an `AnimatedBuilder` driven by `_shimmerController` that pulses a rounded `Container` row (matching the approximate height of the action+reason layout) between opacity 0.25 and 0.65 using `colors.surfaceGlass`

## 12. Guardian Callout UX — Refresh Tap Animation + 2-Line Action

- [x] 12.1 Add a `bool _refreshAnimating` state flag; on tap of the callout, set `_refreshAnimating = true`, then reset to `false` after 200ms using `Future.delayed`
- [x] 12.2 Wrap the refresh `Icon` in a `TweenAnimationBuilder<double>` that scales 1.0 → 1.4 → 1.0 over 200ms when `_refreshAnimating` changes to true
- [x] 12.3 Change the action `Text` widget from `maxLines: 1` to `maxLines: 2`

## 13. Verification

- [x] 13.1 `flutter analyze --no-fatal-warnings` — zero new errors
- [x] 13.2 `flutter test` — all tests pass (142/142)
- [ ] 13.3 Manual: open toolbox in-app → verify advice callout shows role and device stats in the AI response reasoning
- [ ] 13.4 Manual: trigger a response with a warning field → verify red warning pill appears above the action text
- [ ] 13.5 Manual: switch provider to Groq → logcat confirms the enriched prompt is sent to Groq's endpoint with role, category, and device stats
