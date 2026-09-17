## Purpose

Defines the enhanced visual and interaction contract for the Guardian AI callout widget inside the in-game floating toolbox, providing users with clear warning severity, topic awareness, provider/latency feedback, and tactile refresh confirmation.

## ADDED Requirements

### Requirement: Warning pill displayed for critical warnings
The system SHALL display a colored pill badge above the action text when `CoachResponse.warning` is non-null and non-empty. The pill MUST use a critical color token (red/amber) distinct from normal action text to visually signal high-priority threats.

#### Scenario: Warning pill appears when response carries a warning
- **WHEN** the active `CoachResponse` has a non-empty `warning` field
- **THEN** the callout MUST render a pill-shaped container above the action row containing the warning text

#### Scenario: No warning pill when response has no warning
- **WHEN** the active `CoachResponse` has a null or empty `warning` field
- **THEN** the callout MUST NOT render the warning pill container

### Requirement: Topic chip shown beside the LIVE badge
The system SHALL render a small colored dot-badge next to the "GUARDIAN AI COACH" label indicating the active topic type. Each topic MUST use a distinct color: missing-enemy → critical-red, overextension → warning-amber, objective → emerald-green, wave → turbo-blue, tactical (default) → muted.

#### Scenario: Correct topic color shown after topic refresh
- **WHEN** the last completed advice was of topic `missing-enemy`
- **THEN** the dot-badge MUST be colored with the critical-red token

#### Scenario: Topic chip shows default color for manual/tactical requests
- **WHEN** the last completed advice was a manual `tactical` request
- **THEN** the dot-badge MUST render in the muted/default color

### Requirement: Provider and latency shown inline with LIVE badge
The system SHALL render a right-aligned `<provider> • <latency>ms` text string on the same line as the "GUARDIAN AI COACH • LIVE/LAST KNOWN" badge, using the muted text color at 8px. When no latency measurement is available, the latency portion MUST be omitted.

#### Scenario: Provider and latency displayed after a successful request
- **WHEN** a networked advice request completes with a measured latency of 420ms using the Groq provider
- **THEN** the callout header row MUST display text containing "groq" and "420ms"

#### Scenario: Latency omitted when no measurement exists
- **WHEN** the current advice came from the offline heuristic engine (no latency)
- **THEN** the callout header MUST NOT display an `ms` latency value

### Requirement: Shimmer placeholder shown during loading
The system SHALL render a shimmer/skeleton placeholder row inside the callout container bounds while `adviceAsync.isLoading` is true and no `lastKnown` advice exists, replacing the current spinner-outside-callout pattern.

#### Scenario: Shimmer rendered during initial AI fetch
- **WHEN** the toolbox opens, no cached advice exists, and a network request is in flight
- **THEN** the callout area MUST render an animated shimmer row of appropriate width/height matching the expected action+reason layout

### Requirement: Refresh tap produces micro-animation feedback
The system SHALL animate the refresh icon on tap: a quick scale-up (1.0 → 1.4) and scale-down (1.4 → 1.0) within 200ms, providing tactile confirmation that the tap registered before the loading state begins.

#### Scenario: Refresh icon animates on tap
- **WHEN** the user taps the callout (which triggers `_requestAdvice`)
- **THEN** the refresh icon MUST visibly scale up and then back down within 200ms of the tap event

### Requirement: Action text supports two lines
The system SHALL set `maxLines: 2` on the action text widget in the callout, ensuring multi-word MOBA tactical calls (e.g., "Rotate Dragon pit — counter turtle steal") are fully readable without ellipsis truncation.

#### Scenario: Two-line action renders without overflow
- **WHEN** the active `CoachResponse.action` contains more than 30 characters
- **THEN** the action text MUST wrap to a second line within the callout container without triggering a pixel overflow
