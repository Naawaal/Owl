## Purpose

Enables users to manage game plugins and launch installed Android games with selected plugins from a single hub.

## ADDED Requirements

### Requirement: Game library detection
The system SHALL display a library of supported games showing install status and compatible plugin count.

#### Scenario: Installed game shows as launchable
- **WHEN** a supported game package is installed on the device
- **THEN** the system shows it as Installed with its compatible plugins listed

#### Scenario: Missing game prompts install
- **WHEN** a supported game is not installed
- **THEN** the system shows it as Not Installed and offers an install guidance action

### Requirement: Plugin enablement per game
The system SHALL allow users to enable or disable individual plugins per game, persisting selection across restarts.

#### Scenario: Toggle plugin persists
- **WHEN** user toggles a plugin ON for a game and restarts the app
- **THEN** the system shows that plugin still ON for that game

#### Scenario: Incompatible plugin blocked
- **WHEN** user tries to enable a plugin marked incompatible with the installed game version
- **THEN** the system blocks enablement and explains the version mismatch

### Requirement: Launch game with plugins
The system SHALL launch the selected game with its enabled plugins and report launch failures.

#### Scenario: Successful launch
- **WHEN** user taps Play on an installed game with at least one plugin enabled
- **THEN** the system attempts to launch the game package and shows a launching state

#### Scenario: Failed launch surfaces error
- **WHEN** the game package cannot be launched (uninstalled or blocked)
- **THEN** the system shows a clear error and keeps the user on the game detail screen
