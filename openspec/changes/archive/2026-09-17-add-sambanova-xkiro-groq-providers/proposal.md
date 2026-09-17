## Why

Owl's live Guardian AI tactical coach relies on ultra-low latency inference to generate recommendations within critical MOBA combat windows (under 500ms). Currently, the app supports Google Gemini, OpenAI, Claude, and OpenRouter. Expanding to SambaNova Systems (reconfigurable dataflow SN40L), xKiro (unified multi-model gateway with generous free tiers), and GroqCloud (custom LPU tensor stream inference) unlocks sub-100ms response latencies and zero-cost high-throughput options. Crucially, older models (e.g., decommissioned Llama 3.1/3.3 on developer tiers) must not be used; only verified, currently active production and preview models are provided.

## What Changes

- Add three new LLM providers to `AIProvider` enum: `sambanova`, `xkiro`, and `groq`.
- Integrate non-deprecated, verified latest models for each provider:
  - **SambaNova**: `Meta-Llama-3.3-70B-Instruct`, `DeepSeek-R1-0528`, `DeepSeek-V3.1`, `openai/gpt-oss-120b`, `MiniMax-M2.7`.
  - **xKiro**: `deepseek/deepseek-v4.1-flash`, `qwen/qwen3.8-max`, `qwen/qwen3.7-flash:free`, `google/gemini-2.5-flash`, `openai/gpt-5.6-luna`, `z-ai/glm-5.3-flash`, `anthropic/claude-haiku-4.5`, `minimax/minimax-m3:free`.
  - **Groq**: `openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.6-27b`, `meta-llama/llama-3.3-70b-instruct`.
- Implement dedicated OpenAI-compatible inference clients in `packages/owl_network`:
  - `SambaNovaInferenceClient` targeting `https://api.sambanova.ai/v1`.
  - `XKiroInferenceClient` targeting `https://api.xkiro.com/v1`.
  - `GroqInferenceClient` targeting `https://api.groq.com/openai/v1`.
- Update `InferenceClientFactory` to resolve the new providers.
- Extend Settings domain, provider state, API key secure storage (`owl_api_key_sambanova`, `owl_api_key_xkiro`, `owl_api_key_groq`), and the two-pane Game Turbo settings UI with interactive provider selection cards, model dropdowns, latency indicators, and credential validation.

## Capabilities

### New Capabilities
- `fast-inference-providers`: Support for SambaNova, xKiro, and Groq ultra-low latency inference clients with active model catalogs, secure credential storage, and runtime selection in Game Turbo settings.

### Modified Capabilities

## Impact

- **Packages**:
  - `packages/owl_network`: New client classes and factory updates.
- **Application (`lib/`)**:
  - `lib/features/ai_coach/domain/models/ai_provider.dart`: Enum entries, display names, storage keys, and active model lists.
  - `lib/features/settings/presentation/settings_provider.dart`: API key validators and default model mapping.
  - `lib/features/settings/presentation/app_settings_two_pane_screen.dart`: Provider selector grid, model options, latency badges, and key inputs.
- **Tests**:
  - New and updated unit tests in `test/features/` verifying provider models, factory dispatch, and key storage conventions.
