## Context

See `proposal.md` for motivation. Currently, models are returned via static lists in `AIProvider.availableModels`. To keep models up-to-date and surface free-tier models across providers, a client-side dynamic model discovery service is needed.

## Goals / Non-Goals

**Goals:**
- Provide a resilient, non-blocking `ModelDiscoveryService` that fetches model definitions from `models.dev/api.json` and direct endpoints (`api.xkiro.com/v1/models`, `openrouter.ai/api/v1/models`).
- Normalize models into a structured `DiscoveredModel` model carrying `id`, `name`, `isFree`, `contextLength`, and `providerId`.
- Tag and surface free models with high visibility (`🟢 FREE` pills, grouped sections, filter toggle).
- Guarantee zero startup delay by loading immediately from local cache or static fallback defaults.

**Non-Goals:**
- Setting up an external backend proxy server; all fetching happens directly on the client over HTTPS.
- Modifying inference contracts; `InferenceClient` uses the model string as-is.

## Decisions

### 1. Unified `DiscoveredModel` Domain Representation
- **Decision**: Define `DiscoveredModel` in `packages/owl_network/lib/network/models/discovered_model.dart`:
  ```dart
  class DiscoveredModel {
    final String id;
    final String name;
    final String providerId;
    final bool isFree;
    final int? contextLength;
  }
  ```
- **Rationale**: Keeps model metadata uniform across different upstream schemas (`models.dev`, `xKiro`, and `OpenRouter`).

### 2. Multi-Tiered Discovery Pipeline
- **Decision**:
  1. `models.dev/api.json` is consulted for `groq`, `openrouter`, `gemini`, `openai`, and `claude`.
  2. `https://api.xkiro.com/v1/models` is queried directly since xKiro is a newer gateway with a public models API.
  3. `https://openrouter.ai/api/v1/models` is queried directly for OpenRouter's live `:free` models.
  4. Local cache stores JSON snapshots in `SharedPreferences`.
  5. Static fallback catalogs in `AIProvider.availableModels` serve as the guaranteed baseline if offline.

### 3. Free-Tier Classification Heuristics
- **Decision**:
  - OpenRouter: Model ID contains `:free` or pricing prompt/completion == "0".
  - xKiro: Model ID contains `:free`, `access_tier == 'free'`, or pricing input/output == 0.
  - SambaNova / Groq: Entire platform provides free developer tiers, with top recommended low-friction production models highlighted.
- **Rationale**: Provides clarity to gamers who want free tactical guidance without entering credit cards.

### 4. UI Grouping & Filter Integration
- **Decision**:
  - In `AppSettingsTwoPaneScreen`, render model items with badge indicators (`🟢 FREE` or `⚡ PRO`).
  - Add a switch toggle `Show Free Models Only` above the model dropdown.
  - Add a refresh button `↻ Refresh Catalog` next to the model count.

## Risks / Trade-offs

- **[Risk]** `models.dev` or gateway APIs might be unreachable or change format.
  - *Mitigation*: Defensive parsing wrapped in `try/catch`, falling back immediately to cached models or bundled static catalogs without user-facing disruption.
