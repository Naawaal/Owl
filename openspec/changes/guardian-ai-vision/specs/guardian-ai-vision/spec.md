## Purpose

Enables Guardian AI to capture and visually inspect live gameplay frames to accurately identify champions, battle spells, minimap enemy movement, and active objectives without hallucination.

## ADDED Requirements

### Requirement: Real-Time Screen Frame Capture
The system SHALL capture the active gameplay screen buffer on-demand and at automated intervals when Guardian Vision is enabled.

#### Scenario: On-demand manual screen frame capture
- **WHEN** the player taps the Guardian AI card or requests a tactical review
- **THEN** the system grabs the top surface frame via MediaProjection/VirtualDisplay, downscales it to 640x360, and encodes it into a JPEG buffer under 50KB within 150ms

#### Scenario: Periodic automated visual sampling
- **WHEN** Guardian Vision is active and the overlay is floating over a running game
- **THEN** the system captures a fresh frame every 35 seconds to update in-game tactical context while keeping battery and thermal overhead under 3%

### Requirement: Multimodal Visual Game State Extraction
The system SHALL transmit the captured frame to a multimodal vision LLM to extract game identity, hero identity, active battle spell, lane state, and radar callouts.

#### Scenario: Accurate hero and spell identification from game screen
- **WHEN** a game screenshot is analyzed (e.g. Mobile Legends match with Balmond carrying Flicker)
- **THEN** the multimodal model accurately reads that the player is Balmond, has Flicker (not Retribution), is in lane, and references current cooldowns and match timeline in the analysis

#### Scenario: Visual minimap danger detection
- **WHEN** the minimap in the captured frame indicates missing enemy laners or jungle rotation toward the player's river
- **THEN** the system populates the radar warning field with a specific positional threat alert

### Requirement: Visual Tactical Directive Generation
The system SHALL format multimodal vision inferences into actionable HUD tactical directives adhering to the standardized JSON schema.

#### Scenario: Structured tactical output rendering
- **WHEN** multimodal inference completes successfully
- **THEN** the system updates the Guardian AI card with a bold action (max 6 words), a rationale (1 sentence), and a radar warning (max 8 words) tagged with `GUARDIAN AI • LIVE`

#### Scenario: Network or vision API error recovery
- **WHEN** vision inference fails due to quota or network interruption
- **THEN** the system falls back to text-assisted heuristic directives matching the identified game without interrupting gameplay

### Requirement: Privacy and Permission Consent Lifecycle
The system SHALL require explicit user authorization before accessing the screen capture pipeline and allow instantaneous revocation.

#### Scenario: User grants screen capture permission
- **WHEN** the user enables Guardian Vision in Owl settings or launches an accelerated game
- **THEN** the system displays the system MediaProjection permission prompt and begins capturing only after confirmation

#### Scenario: User disables or revokes vision
- **WHEN** the user toggles Guardian Vision off or denies screen capture consent
- **THEN** the system immediately releases virtual display buffers and falls back to non-visual tactical heuristics
