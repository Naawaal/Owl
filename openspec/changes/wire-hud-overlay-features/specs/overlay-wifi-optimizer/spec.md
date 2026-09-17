## Purpose

Optimizes mobile gaming network connectivity by acquiring Android low-latency Wi-Fi locks and monitoring live game server latency.

## ADDED Requirements

### Requirement: Low-Latency Wi-Fi Locking
The system SHALL acquire an Android `WifiLock` in low-latency mode to prioritize gaming packets and reduce jitter.

#### Scenario: Activate Wi-Fi boost
- **WHEN** the player taps the Wi-Fi action button in the overlay toolbox
- **THEN** the system acquires an Android `WIFI_MODE_FULL_LOW_LATENCY` lock, starts live ping latency tracking, and reflects active status in the overlay

#### Scenario: Deactivate Wi-Fi boost
- **WHEN** the player taps the active Wi-Fi action button in the overlay toolbox
- **THEN** the system releases the low-latency Wi-Fi lock and updates the button to inactive

### Requirement: Live Latency Telemetry
The system SHALL continuously measure network latency to game endpoints when Wi-Fi boost is engaged.

#### Scenario: High latency detected
- **WHEN** network ping exceeds 120ms while Wi-Fi boost is active
- **THEN** the system marks network telemetry with warning indicators in the HUD status bar
