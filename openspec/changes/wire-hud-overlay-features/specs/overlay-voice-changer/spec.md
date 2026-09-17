## Purpose

Modulates microphone audio in real time with tactical DSP audio presets to provide immersive voice communication in multiplayer games.

## ADDED Requirements

### Requirement: Microphone Audio Modulation
The system SHALL capture microphone audio and apply digital signal processing effects in real time when voice changer is active.

#### Scenario: Activate voice changer
- **WHEN** the player taps the Voice button in the overlay toolbox
- **THEN** the system requests microphone permissions if needed, starts the DSP audio processing loop, and activates the Voice tool indicator

#### Scenario: Deactivate voice changer
- **WHEN** the player taps the active Voice button
- **THEN** the system stops audio capture and processing, releasing microphone hardware resources

### Requirement: Tactical Voice Preset Selection
The system SHALL offer tactical DSP effect presets tailored for multiplayer squad communications.

#### Scenario: Long-press voice tool for preset menu
- **WHEN** the player long-presses or taps the Voice button
- **THEN** the system displays a tactical preset selector with Commander, Cybernetic, Tactical Radio, and Studio presets
