## Purpose

Applies an atomic Balanced/Performance conditions package on every Android device so mode toggles reduce interruptions, improve net feel, and engage immersion locks with restoreable priors—without claiming OEM CPU/GPU locks.

## ADDED Requirements

### Requirement: Single toggle entry applies the full ritual
The system MUST apply the mode ritual whenever the user toggles Balanced or Performance from Console or the in-game HUD, using one shared entry path with persisted mode state.

#### Scenario: HUD Performance pill
- **WHEN** the user selects Performance in the floating toolbox
- **THEN** the system persists Performance mode and runs the Performance ritual package before or with the existing refresh/FPS apply path

#### Scenario: Console TURBO pill
- **WHEN** the user taps the Console TURBO control to switch modes
- **THEN** the system uses the same ritual entry path as the HUD pills

### Requirement: Performance ritual engages focus package
When entering Performance, the system MUST best-effort enable DND (if notification policy is granted), enable Wi‑Fi low-latency boost, apply a high preferred refresh hint for the active game target FPS, and engage configured immersion locks (mistouch / gesture restrict / brightness lock when permitted).

#### Scenario: Performance with permissions granted
- **WHEN** the user switches to Performance and required permissions are available
- **THEN** DND is on, Wi‑Fi boost is on, refresh preference targets the game FPS ceiling, and immersion locks are engaged

#### Scenario: Performance with missing DND permission
- **WHEN** the user switches to Performance without notification-policy access
- **THEN** the ritual still completes other steps and MUST NOT fail the mode toggle

### Requirement: Balanced ritual restores priors
When entering Balanced, the system MUST restore DND, Wi‑Fi boost, and immersion lock states captured before the last Performance ritual (or safe defaults if none were stored), and apply a 60 FPS refresh preference.

#### Scenario: Balanced after Performance
- **WHEN** the user had DND off before Performance, then switches to Balanced
- **THEN** DND returns to off (prior), Wi‑Fi boost and immersion locks restore to their pre-Performance values, and refresh preference targets 60

### Requirement: User-visible confirmation without false GPU claims
The system MUST give immediate haptic feedback and a short toast or overlay message that describes real effects (quiet notifications, net boost, cooler/sustained play). Messages MUST NOT claim CPU/GPU unlock or OEM Game Turbo equivalence.

#### Scenario: Performance toast
- **WHEN** Performance ritual completes
- **THEN** the user sees a short confirmation mentioning quieter play and/or faster net and the FPS target, with no GPU-unlock wording

#### Scenario: Balanced toast
- **WHEN** Balanced ritual completes
- **THEN** the user sees a short confirmation emphasizing cooler or sustained play
