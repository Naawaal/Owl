## Purpose

Ensures the Flutter In-Game HUD companion matches the Game Space Console UI/UX 1:1 and opens Game Turbo tools via a Xiaomi-style vertical edge rail with an inward slide gesture.

## ADDED Requirements

### Requirement: Console and In-Game HUD visual parity
The In-Game HUD SHALL present the same top status bar chrome and main stage layout as the Game Space Console: battery shell with percentage, CPU badge with percentage, FPS badge with live value, central interactive mode pill, left game sidebar, cinematic center stage, right Play wing, and bottom GPU settings tab.

#### Scenario: In-Game HUD top status bar
- **WHEN** the user views the In-Game HUD companion screen
- **THEN** the top status bar displays battery, CPU, and FPS telemetry on the left, a central interactive `TURBO` or `BALANCED` pill with live FPS, and plain icon actions on the right matching Console spacing and styling

#### Scenario: In-Game HUD main stage layout
- **WHEN** the user views the In-Game HUD companion screen with games in Game Space
- **THEN** the body shows the left game list sidebar, cinematic center hero stage, right Play wing, and bottom GPU trapezoid tab in the same composition as Console

#### Scenario: HUD-specific leading action
- **WHEN** the user taps the leading right-side icon on the In-Game HUD top bar
- **THEN** the system navigates back to the Game Space Console instead of opening Add Games

### Requirement: Xiaomi-style edge rail open gesture
When in-game shortcuts are enabled, the In-Game HUD SHALL show a thin vertical edge rail on the configured shortcut edge and SHALL open the Game Turbo floating toolbox when the user slides inward from that rail.

#### Scenario: Slide opens toolbox from left rail
- **WHEN** shortcuts are enabled, the edge is configured on the left, and the user slides inward past the open threshold from the vertical rail
- **THEN** the Game Turbo floating toolbox opens anchored near that edge

#### Scenario: Slide opens toolbox from right rail
- **WHEN** shortcuts are enabled, the edge is configured on the right, and the user slides inward past the open threshold from the vertical rail
- **THEN** the Game Turbo floating toolbox opens anchored near the right edge

#### Scenario: Shortcuts disabled hides rail
- **WHEN** in-game shortcuts are disabled
- **THEN** the vertical edge rail is not shown and the center top-bar pill remains available to toggle the toolbox

#### Scenario: Rail hidden while toolbox open
- **WHEN** the Game Turbo floating toolbox is open
- **THEN** the vertical edge rail is hidden or non-interactive until the toolbox is dismissed

### Requirement: Shared Console and HUD top bar behavior
Console and In-Game HUD SHALL share the same top status bar presentation and interactive pill behavior so telemetry badges and the mode pill do not diverge between the two screens.

#### Scenario: Center pill toggles toolbox on HUD
- **WHEN** the user taps the central mode pill on the In-Game HUD
- **THEN** the Game Turbo floating toolbox toggles open or closed using the same pill interaction pattern as Console
