## Purpose

Assembles and injects structured game context — role, game category, device stats (CPU%, battery%, live FPS), and match elapsed time — into every AI coaching request, ensuring the model receives accurate, game-grounded input instead of generic context.

## ADDED Requirements

### Requirement: CoachPrompt carries live device and game state
The system SHALL augment every `CoachPrompt` with optional fields: `gameCategory`, `cpuPercent`, `batteryPercent`, and `liveFps`. When these fields are present, `toFormattedPrompt()` MUST include them in the formatted prompt string so the LLM receives accurate device load and game type grounding.

#### Scenario: Prompt includes category and device stats when fields are set
- **WHEN** a `CoachPrompt` is constructed with `gameCategory = "5v5 MOBA"`, `cpuPercent = 65`, `batteryPercent = 48`, `liveFps = 114`
- **THEN** `toFormattedPrompt()` output MUST contain strings representing category, CPU, battery, and FPS values

#### Scenario: Prompt remains valid when optional context fields are absent
- **WHEN** a `CoachPrompt` is constructed without the optional fields
- **THEN** `toFormattedPrompt()` MUST produce a valid, non-empty prompt string without error

### Requirement: CoachService injects live stats at request time
The system SHALL read `systemStatsProvider` (CPU%, battery%, live FPS) and `activeGameProvider` (category) at the moment `requestAdvice()` is called, and pass them into the `CoachPrompt` constructor so the AI always receives the latest device snapshot.

#### Scenario: Stats are included in the prompt when the provider has data
- **WHEN** `systemStatsProvider` yields a stats object and `requestAdvice()` is called
- **THEN** the resulting `CoachPrompt` MUST carry `cpuPercent`, `batteryPercent`, and `liveFps` from that stats object

#### Scenario: Missing stats do not block advice
- **WHEN** `systemStatsProvider` has no data (first boot, race condition)
- **THEN** `requestAdvice()` MUST still issue the AI call with the remaining context and SHALL NOT throw or fall back to offline heuristics solely because stats are absent

### Requirement: Topic refresh carries enriched situation string
The system SHALL replace the bare `'Scheduled <topic> check-in'` situation string in `requestTopicRefresh()` with a rich string that includes the player's role, live FPS, and CPU%, so the AI understands device pressure when evaluating auto-triggered topic queries.

#### Scenario: Topic refresh prompt includes role and device metrics
- **WHEN** `requestTopicRefresh()` fires for the `missing-enemy` topic
- **THEN** the situation string passed to `requestAdvice()` MUST reference the player's configured role and at least one live device metric (FPS or CPU)

### Requirement: Match elapsed time is propagated to every advice call
The system SHALL track a session clock (started when the in-game HUD is first rendered) and pass `matchElapsedSeconds` to every `requestAdvice()` invocation so that match-time-sensitive advice (early-game vs late-game objectives) is accurate.

#### Scenario: Match time increases between consecutive requests
- **WHEN** the HUD has been active for 120 seconds and `requestAdvice()` is called
- **THEN** `matchTimeSeconds` passed to `CoachPrompt` MUST be ≥ 120

#### Scenario: Match time does not reset when toolbox is toggled
- **WHEN** the toolbox is opened, closed, and reopened within the same HUD session
- **THEN** `matchTimeSeconds` MUST continue from the total elapsed session time, not reset to 0
