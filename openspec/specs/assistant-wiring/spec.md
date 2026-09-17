# assistant-wiring Specification

## Purpose
Makes every Assistant, Performance, Voice, and Overlay setting observably alter app behavior, so no settings control is decorative: coaching depth, topics, budgets, voice, haptics, and the master switch all do what their screens promise.
## Requirements
### Requirement: Assistant mode gates automation

The system SHALL query for live advice only when the assistant mode enables it; in off mode no automatic queries SHALL fire, while manual refresh SHALL still work.

#### Scenario: Off mode stays silent

- **WHEN** assistant mode is off and the toolbox opens
- **THEN** no automatic inference query SHALL fire and the callout SHALL remain silent unless the user refreshes manually

### Requirement: Coaching level shapes briefing depth

The system SHALL shape generated briefings by coaching level: beginner briefings SHALL use plain fundamentals language, advanced briefings SHALL include wave-control and cooldown specifics, intermediate SHALL sit between them.

#### Scenario: Level changes the briefing

- **WHEN** the same game situation is queried under beginner and advanced levels
- **THEN** the two prompts sent to the provider SHALL differ in their depth instruction and the callouts SHALL reflect the selected depth

### Requirement: Sensitivity scales budgets

The system SHALL scale inference budgets by warning sensitivity: early-warning SHALL allow more frequent queries than balanced, and conservative SHALL allow fewer.

#### Scenario: Conservative queries less often

- **WHEN** two identical sessions run under early-warning and conservative sensitivity
- **THEN** the conservative session SHALL issue no more networked queries than the early-warning session over the same period

### Requirement: Topic toggles subscribe and filter advice

The system SHALL only auto-query and display topics whose toggles are enabled; a disabled topic SHALL neither trigger queries nor appear in the callout.

#### Scenario: Disabled topic stays quiet

- **WHEN** objective timers are disabled and an objective event would otherwise trigger advice
- **THEN** no objective-topic query SHALL fire and no objective advice SHALL display

### Requirement: Performance profile drives budgets

The system SHALL map the performance profile to concrete inference budgets and FPS targets: saver SHALL query least often with the lowest FPS target, high SHALL query most often with the highest target, balanced in between.

#### Scenario: Saver profile conserves calls

- **WHEN** identical sessions run under saver and high profiles
- **THEN** the saver session SHALL issue no more networked queries and SHALL target no higher FPS than the high session

### Requirement: Stress throttling protects the device

The system SHALL tighten inference budgets when sustained device stress is detected (high CPU load with low battery) provided thermal protection is enabled, and SHALL relax them when stress clears.

#### Scenario: Stress throttles queries

- **WHEN** thermal protection is enabled and sustained stress is detected mid-match
- **THEN** the service SHALL reduce query frequency until stress clears, without user action

### Requirement: Latency readout reflects last inference

The system SHALL display the last measured inference latency in the toolbox and edge handle whenever the latency HUD is enabled, and SHALL hide it when disabled.

#### Scenario: Latency visible after a query

- **WHEN** a query completes with latency display enabled
- **THEN** the toolbox and edge handle SHALL show the measured milliseconds until the next query completes

### Requirement: Voice callouts follow voice settings

The system SHALL speak fresh advice through on-device TTS only when voice alerts are enabled, only for priorities passing the alert filter, spaced at least by the speech cooldown, and mixed so game audio is never ducked.

#### Scenario: Critical-only filter silences routine advice

- **WHEN** the alert priority is critical-only and routine advice arrives
- **THEN** no voice SHALL play while the visual callout SHALL still update

#### Scenario: Cooldown spaces announcements

- **WHEN** two speakable advisories arrive within the speech cooldown
- **THEN** the second SHALL be skipped or queued without overlapping the first

### Requirement: Haptics follow the haptics setting

The system SHALL emit haptic feedback only when haptics are enabled; with haptics disabled no vibration SHALL occur anywhere in the app.

#### Scenario: Disabled haptics stay still

- **WHEN** haptics are disabled and the user performs haptic-triggering actions
- **THEN** the device SHALL NOT vibrate for any of them

### Requirement: Master switch kills automation

The system SHALL halt all automation (advice queries, voice announcements, native performance sync) when the master switch is off, while manual controls SHALL keep working.

#### Scenario: Master off freezes automation

- **WHEN** the master switch is turned off mid-match
- **THEN** no further automatic queries, announcements, or native syncs SHALL fire until it is re-enabled

