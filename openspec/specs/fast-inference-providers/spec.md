# fast-inference-providers Specification

## Purpose
Provides ultra-low-latency, verified, non-deprecated AI inference options from SambaNova Systems, xKiro Gateway, and GroqCloud for real-time tactical game coaching.
## Requirements
### Requirement: SambaNova Inference Provider Support
The system SHALL support SambaNova Systems as an inference provider using the OpenAI-compatible endpoint at `https://api.sambanova.ai/v1`. The system SHALL provide only non-deprecated production models, defaulting to `Meta-Llama-3.3-70B-Instruct`.

#### Scenario: Selecting SambaNova provider
- **WHEN** user chooses SambaNova as the active AI provider in Game Turbo settings
- **THEN** the system sets default model to `Meta-Llama-3.3-70B-Instruct` and allows choosing among `DeepSeek-R1-0528`, `DeepSeek-V3.1`, `openai/gpt-oss-120b`, and `MiniMax-M2.7`

#### Scenario: Executing inference via SambaNova
- **WHEN** tactical advice is generated with SambaNova selected and a valid API key configured
- **THEN** the system issues requests to `https://api.sambanova.ai/v1/chat/completions` with Bearer authentication and parses responses conforming to the OpenAI schema

### Requirement: xKiro AI Gateway Provider Support
The system SHALL support xKiro as an AI gateway inference provider using the OpenAI-compatible endpoint at `https://api.xkiro.com/v1`. The system SHALL provide active, verified models with support for both free-tier and premium models, defaulting to `deepseek/deepseek-v4.1-flash`.

#### Scenario: Selecting xKiro provider
- **WHEN** user chooses xKiro as the active AI provider in Game Turbo settings
- **THEN** the system sets default model to `deepseek/deepseek-v4.1-flash` and exposes verified models including `qwen/qwen3.8-max`, `qwen/qwen3.7-flash:free`, `google/gemini-2.5-flash`, `openai/gpt-5.6-luna`, and `minimax/minimax-m3:free`

#### Scenario: Executing streaming inference via xKiro
- **WHEN** live overlay coaching streams tokens via xKiro with a valid API key
- **THEN** the system opens an SSE stream to `https://api.xkiro.com/v1/chat/completions` and delivers real-time delta tokens to the HUD

### Requirement: GroqCloud High-Speed Inference Provider Support
The system SHALL support GroqCloud as an inference provider using `https://api.groq.com/openai/v1`. The system SHALL exclude decommissioned developer-tier models and provide active production models, defaulting to `openai/gpt-oss-120b`.

#### Scenario: Selecting Groq provider
- **WHEN** user chooses Groq as the active AI provider in Game Turbo settings
- **THEN** the system sets default model to `openai/gpt-oss-120b` and permits switching to `openai/gpt-oss-20b`, `qwen/qwen3.6-27b`, or `meta-llama/llama-3.3-70b-instruct`

#### Scenario: Groq key validation
- **WHEN** user enters a Groq API key in the credentials card
- **THEN** the system validates that the key follows the standard Groq format (`gsk_` prefix) and stores it in secure storage under `owl_api_key_groq`

### Requirement: Provider Selection and Credential Persistence
The system SHALL persist user selections for active provider, chosen model, and encrypted API keys across application sessions for all new providers.

#### Scenario: Restoring saved provider on startup
- **WHEN** the application starts up after a user previously selected SambaNova, xKiro, or Groq
- **THEN** the settings manager initializes with the persisted provider and model, and resolves the correct client implementation from the inference client factory

