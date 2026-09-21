## Purpose

Lets users browse, preview, and apply user-provided skin and config packs per game with safe backup and restore tracking.

## ADDED Requirements

### Requirement: Browse skin packs per game
The system SHALL list available skin/config packs filtered by selected game, showing name, version, and preview.

#### Scenario: Filter by game
- **WHEN** user selects a game in the skin manager
- **THEN** the system shows only packs marked compatible with that game

#### Scenario: Empty catalog state
- **WHEN** no packs exist for the selected game
- **THEN** the system shows an empty state with an import guidance action

### Requirement: Preview and apply pack
The system SHALL allow users to preview a pack and apply it to the selected game, recording applied version.

#### Scenario: Apply pack records state
- **WHEN** user applies a compatible pack to a game
- **THEN** the system marks that pack as Applied and stores its version and timestamp

#### Scenario: Re-apply replaces safely
- **WHEN** user applies a different pack while one is already applied
- **THEN** the system replaces the applied state and keeps prior pack metadata for restore

### Requirement: Clear and restore defaults
The system SHALL allow users to clear the applied pack and restore default state with confirmation.

#### Scenario: Clear applied pack
- **WHEN** user confirms Clear on a game with an applied pack
- **THEN** the system removes the applied state and shows No Custom Pack Applied

### Requirement: Legal-safe content boundary
The system SHALL NOT bundle or download copyrighted game assets; packs MUST be user-provided metadata/configs only, with a visible notice.

#### Scenario: Notice visible
- **WHEN** user opens the skin manager
- **THEN** the system displays a notice that only user-provided configs are supported and copyrighted assets are not distributed
