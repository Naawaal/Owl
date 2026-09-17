## Why

While the HyperOS Game Turbo settings UI exposes granular controls across Assistant & Tactical AI, Voice & Alerts, and Assistant Performance, several runtime services (`CoachService`, `TtsAnnouncer`, `SystemStatsService`, and `TacticalBattlefieldHud`) are only partially connected to these configuration values. Tactical feature toggles (missing enemy radar, overextension alerts, objective timers, wave advice), TTS alert priority filtering, speech cooldown gating, haptic feedback triggers, test voice callouts, and live performance telemetry diagnostics need complete end-to-end wiring so user preferences immediately drive runtime gameplay behavior without restart.

## What Changes

- **Assistant & Tactical AI Wiring**:
  - Wire `assistantMode` (`live`, `postMatch`, `off`) across `CoachService` and `TacticalBattlefieldHud` so `off` completely suspends background inference and hides advice overlays, and `postMatch` delays tactical advice until post-game review.
  - Wire `preferredRole` override, `warningSensitivity` cooldown scaling, and `coachingLevel` depth flags into `CoachPrompt` and `OfflineTacticalHeuristicsEngine`.
  - Wire granular tactical toggles (`missingEnemyAlerts`, `overextensionRadar`, `objectiveTimers`, `laneWaveAdvice`, `explainRecommendations`, `guardianVisionEnabled`) into prompt generation and heuristics filter pipelines.
- **Voice & Alerts Engine Wiring**:
  - Connect `TtsAnnouncer` with `alertPriority` (`criticalOnly`, `important`, `allAlerts`), `speechCooldownSeconds`, and `voiceAlertsEnabled` gating.
  - Implement tactical haptic feedback in `CoachService` / `HapticHelper` triggered on incoming alerts according to `hapticsEnabled`.
  - Connect the "Test Tactical Callout" button in `AppSettingsTwoPaneScreen` to trigger speech through `TtsAnnouncer` with accompanying haptic feedback.
  - Wire `avoidInterruptingGameAudio` flag to the audio session ducking configuration.
- **Assistant Performance & Hardware Adaptation**:
  - Connect `assistantPerformanceProfile` (`saver`, `balanced`, `high`) to `CoachService` capture FPS, advice cooldowns, and token caps.
  - Feed real-time thermal/CPU metrics from `systemStatsProvider` into `adaptiveWorkload` and `thermalProtection` safeguards.
  - Connect real-time hardware metrics and latest inference latency into the settings screen telemetry diagnostic panel.

## Capabilities

### New Capabilities
- `tactical-assistant-wiring`: End-to-end wiring of Assistant & Tactical AI configurations, Voice & Alert callout rules with priority gating, and dynamic performance/thermal throttling across the Owl coaching runtime.

### Modified Capabilities

## Impact

- `lib/features/settings/presentation/screens/app_settings_two_pane_screen.dart`: Wire test voice callout, telemetry readings, and reactive listeners.
- `lib/features/coach/application/coach_service.dart`: Wire settings-driven mode enforcement, priority classification, haptic alerts, and performance profile intervals.
- `lib/features/coach/domain/coach_prompt.dart` & heuristics: Filter advice based on tactical toggles and coaching level.
- `lib/features/hud/tactical_battlefield_hud.dart`: Honor assistant mode standby and latency HUD toggle.
- `lib/core/sound/tts_announcer.dart`: Implement priority filtering, speech cooldown timer, and audio focus ducking.
