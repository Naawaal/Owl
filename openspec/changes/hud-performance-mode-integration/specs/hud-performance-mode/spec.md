## Purpose

Defines persistent Balanced / Performance gaming mode for the in-game overlay HUD, with full FPS, refresh, and telemetry behavior, plus polished mode/telemetry chrome.

## ADDED Requirements

### Requirement: Mode persists across sessions
The system SHALL persist the user's Balanced or Performance selection and restore it when the app starts, when the overlay service starts, and when the in-game toolbox expands.

#### Scenario: Restore after cold start
- **WHEN** the user previously selected Performance and relaunches Owl
- **THEN** Console TURBO pill, overlay toolbox mode pills, and native overlay service all start in Performance

#### Scenario: Restore on overlay expand
- **WHEN** the user expands the in-game toolbox after switching apps
- **THEN** the mode pills and gauge accents match the last persisted selection

### Requirement: Mode sync across Console, overlay isolate, and native service
The system SHALL keep Balanced / Performance synchronized among the main Flutter app, the overlay Flutter engine, and the native overlay service whenever the user changes mode on any of those surfaces.

#### Scenario: Toggle from overlay toolbox
- **WHEN** the user taps Balanced or Performance in the in-game toolbox
- **THEN** SharedPreferences updates, native overlay applies the mode, and a later Console session shows the same mode

#### Scenario: Toggle from Console TURBO pill
- **WHEN** the user taps the Console TURBO / BALANCED pill
- **THEN** the selection persists and the next in-game overlay expand reflects that mode

### Requirement: Balanced mode full behavior
When Balanced is active, the system SHALL cap displayed live FPS and preferred display refresh at 60, use calm/blue gauge accents, and instruct native overlay to use the balanced path.

#### Scenario: Balanced FPS ceiling
- **WHEN** Balanced is active and raw measured FPS exceeds 60
- **THEN** the toolbox gauge and telemetry treat the effective FPS as at most 60

### Requirement: Performance mode full behavior
When Performance is active, the system SHALL use the active game's target FPS (not a hardcoded 120 when the game target differs), use critical/red gauge accents, and instruct native overlay to use the performance path with that target.

#### Scenario: Performance uses game target FPS
- **WHEN** Performance is active and the active game target FPS is 90
- **THEN** native `setPerformanceMode` and FPS tracker targets use 90, not a fixed 120

#### Scenario: Performance gauge accents
- **WHEN** Performance is active in the toolbox
- **THEN** the mode Performance pill and gauge accents use the critical/turbo-red visual treatment

### Requirement: In-game gauge meta strip UX
The in-game toolbox gauge meta strip SHALL show Wi‑Fi latency (icon + ms) and SHALL NOT show clock time, battery percentage, or inference latency `--ms`.

#### Scenario: Meta strip contents
- **WHEN** the toolbox is open
- **THEN** the gauge top meta row shows Wi‑Fi latency only (e.g. icon + `24ms` or `--ms` when unknown)

### Requirement: Wi‑Fi tool button without latency badge
The Wi‑Fi quick-action button in the toolbox SHALL NOT display a latency ms badge; latency belongs only in the gauge meta strip.

#### Scenario: Wi‑Fi button chrome
- **WHEN** Wi‑Fi boost is active
- **THEN** the Wi‑Fi button shows active styling without an `NNms` badge overlay

### Requirement: Console has no preview HUD
The Game Space Console SHALL NOT present an in-app Gaming tools overlay preview and SHALL NOT navigate to an in-app battlefield HUD solely to preview overlay UI.

#### Scenario: Play launches game only
- **WHEN** the user taps Play with overlay permission granted
- **THEN** Owl launches the selected game and the system overlay; it does not push an in-app HUD route for preview
