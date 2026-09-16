## Purpose

Connects the app's AI surface to real provider inference so tactical advice is genuinely generated, keys are genuinely verified, and the Guardian toolbox speaks from live game state instead of static text.

## ADDED Requirements

### Requirement: Real key verification

The system SHALL verify an API key with a real lightweight provider call and report genuine latency, distinguishing auth failures from network failures.

#### Scenario: Valid key verifies with measured latency

- **WHEN** the user tests a valid key with connectivity
- **THEN** the UI SHALL report success with the measured round-trip latency in milliseconds

#### Scenario: Invalid key reports auth failure

- **WHEN** the user tests an invalid or revoked key
- **THEN** the UI SHALL report an authentication failure, SHALL NOT save the key as verified, and SHALL NOT show a fabricated latency

#### Scenario: Offline test reports network failure

- **WHEN** the user tests any key without connectivity
- **THEN** the UI SHALL report a network failure distinct from an auth failure

### Requirement: Live tactical advice from game state

The system SHALL generate tactical advice from live game state (active game, player role, match clock, objective timers, current situation) through the configured provider and model, and SHALL expose the latest advice reactively.

#### Scenario: Advice reflects the live match

- **WHEN** a coaching query fires with a known game, role, and match clock
- **THEN** the returned advice SHALL reference the current game context and SHALL arrive parsed into action, reason, and optional warning fields

#### Scenario: Advice follows provider and model selection

- **WHEN** the user switches the active provider or model in settings
- **THEN** subsequent queries SHALL route to the newly selected provider and model with the stored key for that provider

### Requirement: Toolbox callout fed by live advice

The system SHALL display the latest live advice in the Guardian toolbox callout, falling back to last-known advice and then silence when inference is unavailable.

#### Scenario: Fresh advice displayed

- **WHEN** a new advice response arrives while the toolbox is open
- **THEN** the callout SHALL update to the new advice without user interaction

#### Scenario: Graceful degradation without key or connectivity

- **WHEN** no API key is stored or the device is offline
- **THEN** the callout SHALL show last-known advice if present, otherwise SHALL stay silent, and SHALL never block gameplay or show an error state in the overlay

### Requirement: Request budgets enforced

The system SHALL bound inference usage with a request timeout, a minimum cooldown between calls, and a per-match call cap.

#### Scenario: Cooldown suppresses rapid refires

- **WHEN** two queries trigger within the cooldown window
- **THEN** only the first SHALL reach the network and the second SHALL resolve from cache or be dropped

#### Scenario: Timeout fails fast

- **WHEN** a provider call exceeds the timeout
- **THEN** the query SHALL resolve as unavailable within a bounded time and SHALL NOT hang the coaching pipeline

### Requirement: Keys never leak

The system SHALL never log, display in full, or persist API keys outside secure storage, and SHALL mask keys everywhere in UI and diagnostics.

#### Scenario: Key material stays masked

- **WHEN** any log, error message, toast, or diagnostic output references authentication
- **THEN** it SHALL contain no more than the last 4 characters of any key
