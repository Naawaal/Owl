## Purpose

Provides genuine real-time hardware telemetry and physical display refresh rate controls across Balanced and Performance gaming modes, while enforcing a unified 1:1 visual design system between the Console Screen, the In-Game HUD, and the floating overlay pill.

## ADDED Requirements

### Requirement: Real-Time FPS Measurement
The system SHALL continuously measure the genuine frame rate of the running application or display composition using sliding-window frame interval sampling without artificial fallbacks or static overrides.

#### Scenario: Active in-game frame rate sampling
- **WHEN** a game is rendering frames while the overlay or HUD is active
- **THEN** the system calculates and displays the true measured frame presentation rate matching the game's actual frame output.

#### Scenario: Display idle or vsync settling
- **WHEN** no new image frames are actively submitted by the game for more than 500 milliseconds
- **THEN** the system falls back to the measured hardware display composition rate rather than a hardcoded maximum.

### Requirement: Physical Display Refresh Rate Mode Enforcement
The system SHALL set the physical display mode and refresh rate constraints on the window manager to enforce 60Hz in Balanced Mode and unlock up to 120Hz in Performance Mode.

#### Scenario: User selects Balanced Mode
- **WHEN** the user switches the active profile to Balanced Mode
- **THEN** the system applies a 60Hz display mode ID with minimum and maximum refresh rates locked to 60Hz, capping rendering ceiling to 60 FPS.

#### Scenario: User selects Performance Mode
- **WHEN** the user switches the active profile to Performance Mode
- **THEN** the system applies the maximum supported high-refresh display mode ID (up to 120Hz) with minimum and maximum refresh rates set to the target rate, allowing unlocked high-frame-rate rendering.

### Requirement: Console and In-Game HUD 1:1 UI/UX Parity
The In-Game HUD top bar and native floating overlay handle SHALL mirror the visual layout, typography, telemetry badges, and interactive pill styling of the Console Screen.

#### Scenario: In-Game HUD top bar display
- **WHEN** the user views the In-Game HUD companion screen
- **THEN** the top status bar displays the battery shell with percentage, the CPU badge with percentage, the FPS badge with live value, and the central interactive `● TURBO / BALANCED <fps> FPS 🎛️` pill matching the Console Screen 1:1.

#### Scenario: Native floating handle pill display
- **WHEN** the native Game Turbo overlay handle is rendered over a running game
- **THEN** the handle displays an emerald status dot, dynamic mode label (`TURBO` or `BALANCED`), live measured FPS, and a trailing tune icon with rounded capsule geometry matching the Console pill.

### Requirement: Independent Floating Guardian AI
The system SHALL present Guardian AI tactical coaching as a distinct, dedicated floating battlefield bubble rather than embedding duplicate advice inside the floating toolbox card.

#### Scenario: Floating toolbox expansion during active match
- **WHEN** the user opens the Game Turbo floating toolbox while Guardian AI is enabled
- **THEN** the toolbox displays the Reactor Tachometer Gauge, telemetry meters, mode switcher, and quick tools, while Guardian AI advice remains displayed in its separate floating tactical overlay.
