## Purpose

Provides fine-grained state management discipline, rebuild containment via targeted Riverpod selectors, and zero unnecessary `setState` calls across the Owl gaming companion.

## ADDED Requirements

### Requirement: Selective State Subscription for Overlay HUD
The Battlefield HUD and floating quick action components SHALL subscribe exclusively to the discrete properties they consume rather than entire root setting state records.

#### Scenario: Tactical setting mutation does not rebuild unrelated HUD stage
- **WHEN** in-game tactical settings such as DND or Sound Alerts are toggled
- **THEN** the root `TacticalBattlefieldHud` and its underlying game stage do not rebuild unnecessarily

#### Scenario: Telemetry changes do not re-render quick action buttons
- **WHEN** system stats stream emits updated FPS and CPU metrics
- **THEN** quick action toggles and DND buttons maintain their existing widget elements without rebuild

### Requirement: Stateless Representation for Static Controllers
Console views and display carousels that do not maintain distinct internal ephemeral lifecycle state SHALL be implemented as stateless `ConsumerWidget` components.

#### Scenario: Active game changes from external sidebar
- **WHEN** the user selects a game from the deck sidebar
- **THEN** the hero carousel indicators update reactively without requiring internal `setState` synchronization

### Requirement: High-Frequency Timer Isolation
High-frequency periodic tickers (such as countdown loops or telemetry counters) SHALL be encapsulated in isolated leaf widgets to prevent parent view re-renders.

#### Scenario: Showcase timer tick
- **WHEN** a 1-second countdown ticker triggers
- **THEN** only the specific timer indicator updates its visual state while the parent showcase view remains undisturbed
