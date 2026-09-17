## Context

The HyperOS Game Turbo settings UI exposes deep customization for Assistant & Tactical AI (Category 3), Voice & Alerts (Category 4), and Assistant Performance (Category 5). However, several settings properties are disconnected from the active runtime engine:
- Voice test callouts in `AppSettingsTwoPaneScreen` only triggered visual toasts and hardcoded haptics without calling `TtsAnnouncer`.
- Tactical feature toggles (`missingEnemyAlerts`, `overextensionRadar`, `objectiveTimers`, `laneWaveAdvice`, `explainRecommendations`) were partially filtered in topic refresh, but not wired into `OfflineTacticalHeuristicsEngine` advice generation or `CoachPrompt` formatted output.
- `TtsAnnouncer` lacked dynamic priority evaluation (`criticalOnly`, `important`, `allAlerts`) and audio ducking toggles.
- Telemetry diagnostics in the performance settings pane showed hardcoded dummy strings (`38 ms`, `34.2°C`, `86 MB`) instead of reading live data from `systemStatsProvider` and `coachServiceProvider`.

## Goals / Non-Goals

**Goals:**
- Fully wire all Category 3 (Assistant & Tactical AI) settings into both `CoachService` and `OfflineTacticalHeuristicsEngine`.
- Wire Category 4 (Voice & Alerts) so TTS callouts respect `voiceAlertsEnabled`, `alertPriority`, `speechCooldownSeconds`, `avoidInterruptingGameAudio`, and `hapticsEnabled`.
- Fully wire Category 5 (Assistant Performance) so performance profiles dynamically scale intervals, thermal protection downscales when stressed, and the telemetry dashboard displays genuine live system metrics.
- Keep the design compliant with `GEMINI.md` and Flutter UI tokens.

**Non-Goals:**
- Building or compiling an Android APK (strict project constraint: do not run Gradle assemble).
- Modifying underlying OS kernel drivers or hardware thermal governors.

## Decisions

### 1. Centralized Priority and Gating in `TtsAnnouncer` and `CoachService`
- **Choice**: Evaluate voice and haptic eligibility in `CoachService._maybeAnnounce` with priority classification:
  - `criticalOnly`: Only triggers if `response.warning` is non-empty.
  - `important`: Triggers if either `response.warning` is non-empty or `response.action` contains high-priority keywords (Lord, Turtle, Steal, Base, Gank).
  - `allAlerts`: Triggers for all valid tactical responses.
- **Speech Cooldown**: Check `announcer.lastSpokeAt` against `settings.speechCooldownSeconds`.
- **Audio Ducking**: Pass `focus: !settings.avoidInterruptingGameAudio` to `TtsAnnouncer.speak()`.
- **Haptics**: Trigger `HapticHelper.heavyImpact()` or `tacticalAlert()` only when `settings.hapticsEnabled` is true.

### 2. Heuristics & Prompt Generator Setting Awareness
- **Choice**: Pass `GameTurboSettings` into `OfflineTacticalHeuristicsEngine.generateAdvice`.
- When `explainRecommendations` is false, shorten `reason` or omit verbose explanations.
- Filter heuristics output based on `missingEnemyAlerts`, `overextensionRadar`, `objectiveTimers`, and `laneWaveAdvice`.
- Incorporate `settings.coachingLevel` to adjust technical vocabulary across heuristic advice.

### 3. Reactive Telemetry Dashboard
- **Choice**: In `AppSettingsTwoPaneScreen._buildPerformanceSettings`, watch `systemStatsProvider` and `coachServiceProvider`.
- Display genuine `coachService.lastLatencyMs` (formatted as `${ms} ms` or `Ready` / `Idle`), active CPU/RAM readings from `SystemStats`, and effective profile sampling rates.

### 4. Interactive Test Tactical Callout
- **Choice**: Connect `_triggerTestCallout()` to read `ttsAnnouncerProvider` and invoke `speak()` with sample tactical copy, honoring `voiceAlertsEnabled`, `hapticsEnabled`, and `avoidInterruptingGameAudio`.

## Risks / Trade-offs

- **[Risk]** TTS engine might fail or not be installed on test runners or headless environments.
  - **Mitigation**: `TtsAnnouncer` guards all calls with try/catch and delegates to `speakDelegate` in test environments.
- **[Risk]** Overactive tactical callouts during intense teamfights may clutter game audio.
  - **Mitigation**: `speechCooldownSeconds` and `alertPriority` strictly gate speech refires.
