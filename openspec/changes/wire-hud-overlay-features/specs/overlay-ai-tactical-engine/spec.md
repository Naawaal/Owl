## Purpose

Delivers actionable tactical coaching directives and warnings during gameplay using online cloud LLMs with an offline heuristic fallback engine.

## ADDED Requirements

### Requirement: Interactive AI Coach Triggering
The system SHALL initiate tactical coaching analysis when the player taps the AI button in the overlay toolbox.

#### Scenario: Online AI inference with configured key
- **WHEN** the player taps the AI button and an API key is configured for the active AI provider
- **THEN** the system generates a tactical prompt from match context, queries the provider LLM, and renders the live tactical advice card in the toolbox

#### Scenario: Offline tactical heuristic fallback
- **WHEN** the player taps the AI button and no API key is configured or network is disconnected
- **THEN** the system generates rule-based situational directives tailored to the active game, role, and match time, displaying an offline tactical advice card with zero silence

### Requirement: Tactical Insight Navigation
The system SHALL allow players to inspect, expand, and refresh tactical advice from the overlay toolbox.

#### Scenario: Refresh tactical advice
- **WHEN** the player taps the refresh button on the advice card
- **THEN** the system initiates a fresh analysis cycle respecting match cooldown limits
