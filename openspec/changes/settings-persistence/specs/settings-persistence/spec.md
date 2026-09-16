## Purpose

Makes every app setting — theme, AI provider and model, toggles, performance profile, game deck, and API keys — survive an app restart exactly as the user left it, with failures surfaced instead of swallowed.

## ADDED Requirements

### Requirement: Theme selection survives restart

The system SHALL persist the user's theme choice in exactly one store, and the app SHALL boot with the persisted theme applied on every cold start.

#### Scenario: Theme round-trip across restart

- **WHEN** the user selects Light theme in App Settings, kills the app, and relaunches
- **THEN** the app SHALL render in Light theme without any further interaction

#### Scenario: Single theme default

- **WHEN** no theme was ever selected (fresh install)
- **THEN** the app SHALL boot with one documented default theme, and both the settings screen and any theme switcher SHALL display that same default

### Requirement: Settings categories survive restart

The system SHALL restore every persisted settings category to its last-saved value on boot: AI provider and model, assistant and tactical-AI options, voice and alert options, performance profile and workload toggles, and overlay and shortcut options.

#### Scenario: Full settings round-trip

- **WHEN** the user changes one option in each settings category, restarts the app, and reopens settings
- **THEN** every changed option SHALL show the value set before the restart

#### Scenario: Reset restores documented defaults

- **WHEN** the user triggers Reset to Factory Defaults and restarts
- **THEN** every setting SHALL show its documented default value after the restart

### Requirement: Hardware state matches persisted settings after boot

The system SHALL re-apply persisted hardware-affecting state (performance mode target, FPS-tracker mode) to the native layer on every cold start without requiring the user to re-toggle anything.

#### Scenario: Performance mode re-applied on boot

- **WHEN** the app cold-starts with performance optimization persisted as enabled
- **THEN** the native performance mode and FPS target SHALL be set to the performance values before or as the first frame renders, with no user action

### Requirement: Persistence failures are visible

The system SHALL surface settings write failures to the user (toast or snackbar) instead of failing silently, while keeping the in-memory value applied for the running session.

#### Scenario: Failed write notifies the user

- **WHEN** a settings write cannot be persisted
- **THEN** the user SHALL see a failure notice and the running session SHALL continue with the selected value

### Requirement: Unknown or corrupt settings migrate safely

The system SHALL version the persisted settings payload; on encountering an unknown version or corrupt payload it SHALL fall back to documented defaults, record the fallback, and rewrite a clean versioned payload.

#### Scenario: Corrupt payload recovers

- **WHEN** the app boots with an unreadable settings payload
- **THEN** the app SHALL boot with default settings, SHALL NOT crash, and SHALL persist a clean payload on the next successful write

#### Scenario: Future version migrates forward

- **WHEN** the app boots with a settings payload from a newer schema version
- **THEN** the app SHALL boot with default settings rather than crash or apply partial unknown fields

### Requirement: API keys survive restart per provider

The system SHALL retain each provider's API key in secure hardware storage across restarts, and SHALL NOT delete keys when settings are reset to defaults.

#### Scenario: Key round-trip across restart

- **WHEN** the user saves an API key, restarts the app, and opens the provider settings
- **THEN** the key SHALL be present (masked) without re-entry

#### Scenario: Reset preserves keys

- **WHEN** the user triggers Reset to Factory Defaults
- **THEN** all saved API keys SHALL remain intact

### Requirement: Game deck survives restart

The system SHALL restore the game-space deck membership and the active game selection on boot.

#### Scenario: Deck round-trip across restart

- **WHEN** the user curates the game deck and selects an active game, then restarts
- **THEN** the same deck membership and active game SHALL be restored, or a documented fallback SHALL apply when a previously installed game is gone

### Requirement: Settings construction has no side effects

The system SHALL construct settings state without invoking native channels, haptics, or hardware trackers, so settings logic is fully testable without platform mocks.

#### Scenario: Persistence tests run platform-free

- **WHEN** the settings persistence test suite runs on a host without native plugins
- **THEN** all tests SHALL pass with zero native-channel invocations escaping the test zone
