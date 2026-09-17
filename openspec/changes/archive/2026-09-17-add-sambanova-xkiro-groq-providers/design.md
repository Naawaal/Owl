## Context

See `proposal.md` for motivation and context. Owl's networking architecture (`packages/owl_network`) uses `BaseInferenceClient` as the contract for LLM inference, with shared SSE parsing in `SseStreamReader` and OpenAI response extraction in `OpenAiInferenceClient`. Settings and UI state are coordinated via Riverpod in `lib/features/settings/` and `lib/features/ai_coach/domain/models/ai_provider.dart`.

## Goals / Non-Goals

**Goals:**
- Provide full end-to-end integration of SambaNova, xKiro, and Groq providers across networking, domain models, settings persistence, and settings UI.
- Filter out deprecated or decommissioned models, offering only verified active models.
- Support both non-streaming (`generate`) and streaming (`generateStream`) inference with 500ms budget timeouts suitable for live HUD overlay coaching.
- Adhere strictly to Owl design tokens (`packages/owl_design`) and the repository's UI developer rules.

**Non-Goals:**
- Custom SDK installations (all providers are consumed via lightweight HTTP/SSE over `ApiClient` / Dio, avoiding bloated third-party vendor SDKs).
- Enterprise-only private network gateways or custom VPC peering.

## Decisions

### 1. Dedicated Inference Client Classes extending `BaseInferenceClient`
- **Decision**: Create `SambaNovaInferenceClient`, `XKiroInferenceClient`, and `GroqInferenceClient` in `packages/owl_network/lib/network/inference/`.
- **Rationale**: Each provider has distinct base URLs, specific header requirements (e.g., xKiro client tags, Groq user-agent), and key validation endpoints. Having dedicated classes ensures strict type safety, clear error mapping, and isolated testability while delegating message body parsing to `OpenAiInferenceClient.extractText` and `extractDelta`.
- **Alternatives considered**: A single parameterized `GenericOpenAiCompatibleClient`. Rejected because error codes, key validation endpoints, and auth headers differ subtly between vendors.

### 2. Up-To-Date Model Catalogs & Non-Deprecated Defaults
- **Decision**:
  - **SambaNova**: Base `https://api.sambanova.ai/v1`. Default: `Meta-Llama-3.3-70B-Instruct`. Available: `Meta-Llama-3.3-70B-Instruct`, `DeepSeek-R1-0528`, `DeepSeek-V3.1`, `openai/gpt-oss-120b`, `MiniMax-M2.7`.
  - **xKiro**: Base `https://api.xkiro.com/v1`. Default: `deepseek/deepseek-v4.1-flash`. Available: `deepseek/deepseek-v4.1-flash`, `qwen/qwen3.8-max`, `qwen/qwen3.7-flash:free`, `google/gemini-2.5-flash`, `openai/gpt-5.6-luna`, `z-ai/glm-5.3-flash`, `anthropic/claude-haiku-4.5`, `minimax/minimax-m3:free`.
  - **Groq**: Base `https://api.groq.com/openai/v1`. Default: `openai/gpt-oss-120b`. Available: `openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.6-27b`, `meta-llama/llama-3.3-70b-instruct`.
- **Rationale**: In late 2025/2026, Groq moved older Llama 3.1 8B Instant and Llama 3.3 70B Versatile to enterprise-only/decommissioned on standard developer tiers, recommending GPT-OSS and Qwen 3.6. Exposing decommissioned models breaks user onboarding.
- **Alternatives considered**: Hardcoding old Llama 3.1 8B. Rejected due to imminent `model_decommissioned` 400 errors.

### 3. Key Storage & Validation
- **Decision**: Store keys under secure storage keys:
  - `owl_api_key_sambanova`
  - `owl_api_key_xkiro`
  - `owl_api_key_groq`
  Validate Groq keys requiring `gsk_` prefix and standard length constraints; validate SambaNova and xKiro keys with appropriate length guards.
- **Rationale**: Keeps credentials strictly sandboxed and prevents cross-provider credential collision.

### 4. Settings UI Representation
- **Decision**: Add provider option cards in `AppSettingsTwoPaneScreen` with distinctive branding, latency indicators (~45 ms for Groq LPU, ~65 ms for SambaNova SN40L, ~95 ms for xKiro), and model selector dropdowns.
- **Rationale**: Gives users immediate clarity on latency and capabilities directly in the Game Turbo HUD settings.

## Risks / Trade-offs

- **[Risk]** Cloud provider model IDs can rotate or change preview suffixes over time.
  - *Mitigation*: Support model string override or custom selection, and configure fallback to provider defaults if a saved model returns 404/decommissioned.
- **[Risk]** Free-tier rate limits on gateways (e.g. xKiro / Groq public tiers).
  - *Mitigation*: Graceful error mapping to `InferenceFailure.rateLimit` with clear user-facing messages in the tactical HUD.
