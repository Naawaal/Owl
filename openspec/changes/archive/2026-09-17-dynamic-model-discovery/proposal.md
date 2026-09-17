## Why

Currently, AI model catalogs across all supported providers (Google Gemini, OpenAI, Claude, OpenRouter, SambaNova, xKiro, Groq) are statically defined. When providers release new model checkpoints or deprecate older ones, users cannot access them without an app code update. Furthermore, providers like xKiro, OpenRouter, and SambaNova offer zero-cost free-tier models (such as `:free` suffix models, free access tiers, or generous developer quotas), but users cannot easily distinguish free models from paid/pro models or filter for zero-cost tactical coaching.

## What Changes

- Create `ModelDiscoveryService` in `packages/owl_network` to fetch, normalize, and cache AI models dynamically:
  - Ingest the community AI database from `https://models.dev/api.json` for indexed providers (Groq, OpenRouter, Google, OpenAI, Anthropic).
  - Query native live endpoints for gateways not yet indexed on models.dev: `https://api.xkiro.com/v1/models` (xKiro public catalog) and `https://openrouter.ai/api/v1/models` (OpenRouter public catalog).
  - Cache results locally with timestamps, with an instant offline fallback to curated defaults so app startup latency remains 0ms.
- Support Free vs. Pro Model Detection & Metadata:
  - Tag models as free based on `:free` identifier, `access_tier: "free"`, or `pricing.input == 0 && pricing.output == 0`.
  - Store model metadata (context window, input/output modality, free vs pro status).
- Enhance Game Turbo Settings UI:
  - Model selection dropdown grouped into `🟢 Free Tier Models (Zero Cost)` and `⚡ Pro & Frontier Models (Quota / BYOK)`.
  - Tactical badges: `🟢 FREE`, `⚡ PRO`, and context size tags (`128K`, `1M`).
  - Add an inline filter toggle: `Show Free Models Only`.
  - Add a manual `↻ Refresh Model Catalog` button with a last-updated indicator.

## Capabilities

### New Capabilities
- `dynamic-model-discovery`: Automated multi-source AI model discovery from `models.dev` and live provider endpoints with caching, free-tier classification, and grouped UI selection.

### Modified Capabilities

## Impact

- **Packages**:
  - `packages/owl_network`: New `ModelDiscoveryService`, `DiscoveredModel` domain class, and catalog fetching logic.
- **Application (`lib/`)**:
  - `lib/features/settings/presentation/settings_provider.dart`: State management for discovered models, free-only filter toggle, and cache coordination.
  - `lib/features/settings/presentation/app_settings_two_pane_screen.dart`: Grouped model dropdown, `🟢 FREE` badges, filter toggle, and refresh trigger.
- **Tests**:
  - Unit tests verifying model parsing, free-tier detection, caching, and fallback behavior.
