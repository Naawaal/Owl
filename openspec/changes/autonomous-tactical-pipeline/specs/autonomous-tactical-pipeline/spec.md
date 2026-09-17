## Purpose

Provides autonomous background vision sampling, MOBA minimap and objective state extraction, latency-compensated tactical coaching triggers, and native floating overlay HUD integration for live esports gameplay.

## ADDED Requirements

### Requirement: Autonomous Background Frame Sampling Cadence
The system SHALL continuously sample screen frames in the background during active matches according to the user's selected performance profile (1 FPS for battery saver mode, 5 FPS for balanced mode, and 12 FPS for high performance mode).

#### Scenario: Frame sampling respects performance mode cadence
- **WHEN** the tactical coach session starts in "balanced" performance mode
- **THEN** the system samples the game screen at a frequency of 5 frames per second

#### Scenario: Background sampling stops when session ends
- **WHEN** the user pauses or ends the tactical coaching session
- **THEN** the system immediately ceases screen frame capture and releases capture buffers

### Requirement: Static Screen and Redundant Inference Suppression
The system SHALL compute difference metrics between consecutive frames and suppress tactical AI inference whenever frame deviation falls below a defined perceptual threshold (such as loading screens, hero pick/ban phase, or paused state).

#### Scenario: Static menu screen suppresses model calls
- **WHEN** consecutive sampled frames exhibit less than 3% visual deviation over a 2-second window
- **THEN** the system skips external AI model inference requests while maintaining local clock state

#### Scenario: Dynamic gameplay triggers immediate evaluation
- **WHEN** frame deviation exceeds the threshold indicating active teamfighting or lane movement
- **THEN** the system proceeds with tactical state extraction and model inference

### Requirement: MOBA Minimap and Objective State Extraction
The system SHALL extract and crop the landscape minimap region (normalized coordinates top-left 0.0, 0.0 to 0.34, 0.20), identify visible champion tokens, compute missing enemy laner duration, and track neutral objective indicators (Turtle and Lord).

#### Scenario: Missing enemy laner detected
- **WHEN** an enemy champion token visible on the minimap disappears for 5 consecutive seconds
- **THEN** the system flags that enemy as "missing" and generates a flank/gank vulnerability alert

#### Scenario: Neutral objective spawn detected
- **WHEN** the minimap indicates Lord or Turtle pit activity or impending spawn
- **THEN** the system populates objective countdown state into the tactical context

### Requirement: Latency-Compensated Tactical Game Clock
The system SHALL measure network round-trip latency to the active inference provider and adjust tactical guidance timestamps so coaching recommendations synchronize with real-time match progression.

#### Scenario: Round-trip latency offset added to game time
- **WHEN** provider response latency is measured at 350 milliseconds
- **THEN** the tactical engine projects match timestamps forward by 350 milliseconds when issuing positioning recommendations

#### Scenario: High latency degrades to localized audio cues
- **WHEN** provider latency exceeds 1500 milliseconds
- **THEN** the system falls back to localized heuristic alerts and issues a network latency warning

### Requirement: Native Android Floating Overlay HUD Activation
The system SHALL interface with Android `SYSTEM_ALERT_WINDOW` permissions and communicate with `GameTurboOverlayService` via platform channels to display tactical warnings, floating radar alerts, and performance metrics on top of active game processes.

#### Scenario: Overlay displays on game launch with granted permission
- **WHEN** a target game launches and overlay permission is granted
- **THEN** the system activates the native floating overlay widget displaying current tactical advice and coach status

#### Scenario: Missing overlay permission requests system dialog
- **WHEN** the user activates overlay mode without `SYSTEM_ALERT_WINDOW` permission
- **THEN** the system redirects the user to the Android system settings to grant overlay permission
