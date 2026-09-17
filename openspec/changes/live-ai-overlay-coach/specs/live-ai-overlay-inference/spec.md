## Purpose

Provides autonomous on-device cloud LLM inference directly from the native Android floating HUD overlay during live mobile gameplay, delivering real-time tactical guidance with offline heuristic fallback.

## ADDED Requirements

### Requirement: Bridged AI Credentials and Config in Overlay
The system SHALL bridge the user's active AI provider name, selected model identifier, and stored API key from secure app storage to the native Android overlay service during game launch and settings updates.

#### Scenario: Overlay launched with stored AI credentials
- **WHEN** user launches a configured game with a saved Gemini API key
- **THEN** the overlay service receives the API key, provider ID, and model name without exposing plain text in logs

#### Scenario: Overlay launched without stored AI credentials
- **WHEN** user launches a game with no AI API key saved
- **THEN** the overlay service registers empty credentials and activates offline heuristic mode

### Requirement: Native Asynchronous AI Inference
The system SHALL issue non-blocking HTTPS requests to the configured provider API (Google Gemini `generateContent`) when tactical analysis is requested from the floating HUD overlay.

#### Scenario: On-demand tactical refresh with active API key
- **WHEN** user taps the refresh icon or directive card on the floating Guardian AI overlay while in a match
- **THEN** the overlay displays an active analyzing indicator and issues an asynchronous prompt containing game name, elapsed time, and preferred role to the Gemini API

#### Scenario: Successful AI directive update
- **WHEN** the Gemini API returns a valid tactical response
- **THEN** the overlay parses the Action, Rationale, and Warning, smoothly updating the floating card UI within the game view

### Requirement: Resilient Offline and Network Failure Fallback
The system SHALL immediately fall back to local heuristic tactical directives whenever an API request fails, times out, or encounters rate limits.

#### Scenario: Network drop or timeout during inference
- **WHEN** an in-game AI inference request times out or experiences an HTTP network error
- **THEN** the overlay smoothly displays the corresponding offline tactical heuristic without crashing or freezing the HUD window

#### Scenario: Quota limit or invalid API key
- **WHEN** the provider returns an HTTP 401 or 429 error code
- **THEN** the overlay displays an actionable fallback directive and indicates key validation needed
