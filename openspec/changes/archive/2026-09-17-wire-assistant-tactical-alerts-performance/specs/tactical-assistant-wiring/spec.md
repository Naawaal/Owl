## Purpose

Provides comprehensive runtime wiring and enforcement of Assistant & Tactical AI settings, Voice & Alert callout prioritization, and adaptive performance profiles across the Owl gaming assistant overlay and services.

## ADDED Requirements

### Requirement: Assistant Operational Mode Gating
The assistant runtime SHALL govern background analysis, AI inference, and overlay displays according to the configured assistant mode.

#### Scenario: Live mode active
- **WHEN** assistant mode is set to 'live' and a game is running
- **THEN** the coach service continuously captures game state, runs tactical heuristics, requests AI advice, and presents real-time HUD overlays

#### Scenario: Off mode active
- **WHEN** assistant mode is set to 'off'
- **THEN** the coach service suspends background image capture, halts model inference calls, and the HUD hides tactical advice callouts

#### Scenario: Post-match mode active
- **WHEN** assistant mode is set to 'postMatch' during active gameplay
- **THEN** real-time in-game tactical alerts are suppressed, and advice generation is deferred until the match concludes

### Requirement: Tactical AI Feature Filtering
The tactical heuristics engine and coaching prompt generator SHALL respect user toggles for individual tactical features.

#### Scenario: Missing enemy radar disabled
- **WHEN** missing enemy alerts toggle is disabled in settings
- **THEN** the heuristics engine and prompt builder suppress missing enemy proximity and rotation warnings

#### Scenario: Overextension radar disabled
- **WHEN** overextension radar toggle is disabled in settings
- **THEN** deep lane vulnerability and overextension warnings are excluded from emitted advice

#### Scenario: Objective timers disabled
- **WHEN** objective timers toggle is disabled in settings
- **THEN** Lord, Turtle, and jungle buff spawn alerts and countdown callouts are excluded from emitted advice

#### Scenario: Lane wave advice disabled
- **WHEN** lane wave advice toggle is disabled in settings
- **THEN** minion wave freeze, slow-push, and crash instructions are excluded from emitted advice

#### Scenario: Explain recommendations toggled
- **WHEN** explain recommendations toggle is enabled
- **THEN** emitted tactical advice includes contextual rationale explaining the tactical benefit of the action

### Requirement: Coaching Level and Role Specialization
The coaching system SHALL tailor advice complexity, tone, and strategic focus to the player's selected coaching level and preferred role.

#### Scenario: Preferred role override
- **WHEN** a player selects a specific role such as 'jungle' or 'roam' instead of 'auto'
- **THEN** tactical heuristics and prompt priorities focus on that role's objectives regardless of auto-detected lane assignment

#### Scenario: Coaching level depth
- **WHEN** coaching level is set to 'beginner'
- **THEN** advice uses concise, foundational terminology without advanced macro jargon, while 'advanced' provides technical micro and macro positioning data

### Requirement: Tactical Voice and Alert Prioritization
Voice announcements and alerts SHALL be filtered by alert priority level, master audio toggles, and speech cooldown timers.

#### Scenario: Voice alerts disabled
- **WHEN** voice alerts toggle is disabled
- **THEN** text-to-speech synthesis is suppressed for all incoming tactical advice

#### Scenario: Critical only alert priority
- **WHEN** alert priority is set to 'criticalOnly'
- **THEN** only alerts marked with critical urgency (e.g. imminent gank or base invasion) trigger voice announcements, and standard tactical hints remain silent

#### Scenario: Speech cooldown enforcement
- **WHEN** a voice alert has been announced within the configured speech cooldown interval
- **THEN** subsequent non-critical voice announcements are dropped or queued until the cooldown expires

#### Scenario: Test tactical callout triggered
- **WHEN** the user triggers the test callout action in settings
- **THEN** the system speaks a test voice announcement through the TTS engine and fires a tactical haptic pulse

### Requirement: Tactical Haptic Notification
Tactical alerts SHALL emit physical vibration pulses when haptics are enabled and suppressed when disabled.

#### Scenario: Haptic feedback on tactical alerts
- **WHEN** haptics are enabled and a high-priority tactical alert is received
- **THEN** the device triggers a distinct tactical haptic pattern

#### Scenario: Haptic feedback disabled
- **WHEN** haptics are disabled
- **THEN** no vibration pattern is triggered upon receiving tactical alerts

### Requirement: Performance Profiles and Adaptive Throttling
The assistant runtime SHALL adjust screen capture sampling rate, inference cooldowns, and thermal safeguards based on the active performance profile.

#### Scenario: Saver performance profile
- **WHEN** performance profile is set to 'saver'
- **THEN** screenshot capture runs at reduced frame rates, advice intervals are extended, and AI token limits are minimized

#### Scenario: High performance profile
- **WHEN** performance profile is set to 'high' and thermal status is normal
- **THEN** screenshot capture and heuristics sampling run at maximum cadence with reduced advice cooldowns

#### Scenario: Thermal protection safeguard
- **WHEN** thermal protection is enabled and battery or CPU temperatures exceed safe thresholds
- **THEN** the assistant automatically downscales capture frequency and extends cooldowns to prevent device overheating and frame drops

#### Scenario: In-game latency HUD toggle
- **WHEN** the show in-game latency HUD toggle is enabled or disabled
- **THEN** the tactical overlay displays or hides the live network and inference latency badge accordingly

### Requirement: Real-time Telemetry Diagnostics Display
The settings performance view SHALL display live system telemetry and inference metrics.

#### Scenario: Live telemetry inspection
- **WHEN** a user views the performance settings panel
- **THEN** the telemetry diagnostic panel displays current CPU utilization, memory pressure, battery temperature, and the latency of the most recent model inference
