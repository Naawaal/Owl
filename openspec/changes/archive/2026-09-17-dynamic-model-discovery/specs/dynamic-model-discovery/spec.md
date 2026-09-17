## Purpose

Enables automatic discovery, normalization, and local caching of active LLM models from models.dev and live provider APIs, with explicit free-tier classification and visual indicators.

## ADDED Requirements

### Requirement: Multi-Source Model Ingestion
The system SHALL support dynamically discovering models from `https://models.dev/api.json` and fallback live provider `/models` endpoints (`https://api.xkiro.com/v1/models`, `https://openrouter.ai/api/v1/models`).

#### Scenario: Discovering models online
- **WHEN** model discovery is invoked while an internet connection is available
- **THEN** the system ingests models from `models.dev` for indexed providers and queries live endpoints for unindexed gateways, merging them into a cached model catalog

#### Scenario: Offline fallback
- **WHEN** model discovery is invoked without network connectivity
- **THEN** the system returns cached models or bundled fallback defaults without failing or throwing unhandled exceptions

### Requirement: Free-Tier Model Detection
The system SHALL evaluate model metadata to determine whether a model is available on a zero-cost free tier.

#### Scenario: Identifying a free model by id and access tier
- **WHEN** a model contains `:free` in its identifier, reports `access_tier: "free"`, or reports zero input and output pricing
- **THEN** the system flags the model as `isFree: true`

#### Scenario: Identifying a pro/paid model
- **WHEN** a model requires paid quota or has non-zero pricing
- **THEN** the system flags the model as `isFree: false`

### Requirement: Grouped and Filtered Model Selection UI
The system SHALL present discovered models in Game Turbo settings grouped by availability tier and permit filtering for free-only models.

#### Scenario: Displaying grouped model list
- **WHEN** the user opens the model selector in Game Turbo settings
- **THEN** the system displays distinct groups for free-tier models and pro/frontier models with `🟢 FREE` badges

#### Scenario: Filtering for free models
- **WHEN** the user toggles the "Show Free Models Only" filter
- **THEN** the system limits the model options exclusively to models flagged as `isFree: true`

### Requirement: Manual Catalog Refresh
The system SHALL provide a user-triggered catalog refresh mechanism in settings.

#### Scenario: Refreshing catalog manually
- **WHEN** user taps the refresh model catalog button
- **THEN** the system triggers an asynchronous fetch, updates the cache, updates the "last refreshed" timestamp, and refreshes the model dropdown without restarting the app
