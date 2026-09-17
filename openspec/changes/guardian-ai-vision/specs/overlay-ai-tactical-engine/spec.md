## Purpose

Upgrade the tactical overlay coach engine from text-only heuristics to support multimodal visual screen context ingestion, delivering verified gameplay guidance.

## MODIFIED Requirements

### Requirement: Interactive AI Coach Triggering
The tactical engine SHALL trigger tactical analysis either via manual HUD interaction or automated background intervals, including current visual screen frame buffers when Guardian Vision is enabled.

#### Scenario: Manual refresh with visual context
- **GIVEN** Guardian Vision is enabled and screen capture is authorized
- **WHEN** the player taps the Guardian AI HUD card
- **THEN** the overlay engine captures the current screen buffer, passes it to the tactical engine as an inline image payload, and returns a verified visual directive within 2 seconds

#### Scenario: Fallback when screen capture is unavailable
- **GIVEN** Guardian Vision is disabled or permission has not been granted
- **WHEN** the player requests a tactical directive
- **THEN** the overlay engine falls back to foreground package identity and telemetry heuristics without visual frame data

### Requirement: Tactical Directive Payload
The tactical engine SHALL return structured JSON directives containing action, rationale, and radar alerts informed by visual hero, spell, and minimap analysis.

#### Scenario: Directive schema with vision verification
- **WHEN** multimodal inference completes
- **THEN** the returned directive MUST conform to `{ action: string, rationale: string, radar: string }` and reflect the visual match state
