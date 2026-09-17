## 1. Tactical AI & Heuristics Engine Wiring

- [x] 1.1 Update `OfflineTacticalHeuristicsEngine` to accept `GameTurboSettings` and filter advice by tactical toggles (`missingEnemyAlerts`, `overextensionRadar`, `objectiveTimers`, `laneWaveAdvice`, `explainRecommendations`) and `coachingLevel`.
- [x] 1.2 Wire `CoachPrompt` formatting to account for `explainRecommendations` and preferred role overrides.
- [x] 1.3 Update `CoachService` to pass settings into offline fallback generation and enforce `assistantMode` (`off`, `postMatch`, `live`).

## 2. Tactical Voice & Alerts Engine Wiring

- [x] 2.1 Update `TtsAnnouncer` to support audio focus control matching `avoidInterruptingGameAudio`.
- [x] 2.2 Wire `CoachService._maybeAnnounce` to enforce priority filtering (`criticalOnly`, `important`, `allAlerts`), `speechCooldownSeconds`, and tactical haptic feedback via `HapticHelper`.
- [x] 2.3 Wire `_triggerTestCallout()` in `AppSettingsTwoPaneScreen` to speak through `ttsAnnouncerProvider`, honor `hapticsEnabled`, and respect `avoidInterruptingGameAudio`.

## 3. Assistant Performance & Hardware Throttling

- [x] 3.1 Verify and update `CoachService` sampling rates, query cooldowns, and match caps based on `performanceMode` (`saver`, `balanced`, `high`).
- [x] 3.2 Wire thermal protection and adaptive workload to live CPU, RAM, and battery stats from `systemStatsProvider`.
- [x] 3.3 Connect live telemetry diagnostics in `AppSettingsTwoPaneScreen` to display actual `lastLatencyMs`, active CPU, RAM, and battery temperature.
- [x] 3.4 Ensure `TacticalBattlefieldHud` and `GameturboFloatingToolbox` cleanly honor `assistantMode == 'off'` and `showInGameLatencyHud`.

## 4. Verification & Unit Tests

- [x] 4.1 Add and update unit tests for `OfflineTacticalHeuristicsEngine` tactical toggle filtering.
- [x] 4.2 Add and update unit tests for `TtsAnnouncer` and `CoachService` alert priority, cooldown gating, and haptic alerts.
- [x] 4.3 Run `flutter test` across the test suite to verify all unit tests pass without regressions.
