## Purpose

Provides native Do Not Disturb and in-game notification banner suppression to shield competitive mobile gamers from distracting alerts.

## ADDED Requirements

### Requirement: In-Game Notification Suppression
The system SHALL toggle system Do Not Disturb and suppress floating heads-up notifications during active gameplay sessions.

#### Scenario: Toggle DND on
- **WHEN** the player taps the DND action button in the overlay toolbox
- **THEN** the system requests notification policy access if not granted, enables ZenMode/interruption filter on Android, and updates the DND button state to active

#### Scenario: Toggle DND off
- **WHEN** the player taps the active DND action button in the overlay toolbox
- **THEN** the system restores normal notification policy interruptions and updates the button state to inactive

#### Scenario: Missing notification policy permission
- **WHEN** the player taps DND without system Notification Policy access
- **THEN** the system opens the Android Notification Access settings screen and prompts the user to grant permission without crashing
