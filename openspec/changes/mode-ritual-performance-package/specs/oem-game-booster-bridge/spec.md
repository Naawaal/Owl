## Purpose

Detects OEM Game Turbo / Game Booster / Game Space tools when present and lets the user open them in one tap so Owl complements real system CPU/GPU boosts instead of faking them.

## ADDED Requirements

### Requirement: Detect known OEM game tools
The system MUST best-effort detect installed OEM gaming tools (at least Xiaomi Game Turbo / HyperOS equivalents, Samsung Game Booster / Gaming Hub entry points, and Oppo/Realme Game Space where package or intent is known).

#### Scenario: Xiaomi tool present
- **WHEN** a known Xiaomi Game Turbo package or settings intent is available
- **THEN** the OEM bridge reports that a system booster is available

#### Scenario: No OEM tool
- **WHEN** no known OEM game tool is found
- **THEN** the bridge reports unavailable and the UI MUST NOT show a broken open action

### Requirement: One-tap open system booster
When a system booster is available, Console or HUD MUST offer an action that opens the OEM game tool or its settings via a public intent. Failure to open MUST NOT crash the overlay or clear Owl mode state.

#### Scenario: Open succeeds
- **WHEN** the user taps Open system Game Booster and the intent resolves
- **THEN** the OEM tool or settings screen is launched

#### Scenario: Open fails
- **WHEN** the user taps Open system Game Booster and the intent fails
- **THEN** the user sees a brief failure message and Owl mode remains unchanged
