## Context

See `proposal.md` (Why) for motivation. Current state shaping this design:

- `CoachPrompt.toFormattedPrompt()` already synthesizes the LLM prompt; `CoachResponse.fromRawText()` already parses JSON, labeled lines, or fallback text. Both are tested and stay untouched.
- `ApiClient` (dio) offers generic get/post/put/delete plus `postStream`; the SSE reader is tested. Nothing in `lib/` consumes them yet.
- `ApiKeyManager` holds validate/get/save per provider against secure storage plus a memory fallback; `testConnection` is currently simulated and must become real.
- Settings persist the active provider, model, role, and toggles (see `settings-persistence` change); the toolbox owns the Guardian callout surface.
- No inference may run on desktop test hosts against real endpoints in automated tests — all network tests use mocked dio.

## Goals / Non-Goals

**Goals:**
- Real end-to-end advice: game state in, parsed tactical directive out, rendered in the toolbox.
- Honest key verification with measured latency and distinct auth/network failures.
- Bounded cost and battery impact via budgets; silent degradation, never gameplay-blocking.

**Non-Goals:**
- No new settings options or settings UI redesign (provider/model selectors already exist).
- No on-device/NPU inference, no voice synthesis changes, no chat history or multi-turn memory.
- No server-side proxy — calls go directly from device to provider APIs with the user's own key.

## Decisions

### 0. Provider interface with Gemini-first implementation

A small `InferenceClient` interface (`verifyKey`, `generate`, `generateStream`) is implemented first for Gemini (`generateContent` + `streamGenerateContent`), second for OpenAI (`chat/completions`); Claude and OpenRouter follow the same interface in that order. Shared HTTP behavior (timeout, key injection, error mapping) lives in the existing `ApiClient` layer.

Alternative considered: one provider only (Gemini). Rejected — settings already offer four providers; shipping one live and three dead preserves the dead-end problem.

Alternative considered: direct dio calls per provider without the shared client. Rejected — duplicates timeout, retry, and error-mapping logic four times.

### 1. Key verification via lightweight listing, not generation

`testConnection` calls the cheapest read-only endpoint (`models/list` or equivalent) and measures wall-clock latency. This verifies auth without spending generation budget or producing stray content.

Alternative considered: minimal generation call. Rejected — costs tokens on every key test and is slower.

### 2. Coach service owns prompt assembly, budgets, and reactive state

A `CoachService` Riverpod notifier builds `CoachPrompt`s from live state (active game, role, clock, timers), enforces cooldown/cap/timeout, calls the active `InferenceClient`, parses via `CoachResponse.fromRawText`, and exposes `AsyncValue<CoachResponse?>` latest-advice state plus last-known caching. Failed keyed queries fall back to the offline heuristics engine (game-specific rule-based advice, no error state, budget-neutral). The toolbox watches this state; it never calls the network directly.

Alternative considered: toolbox calls the client directly. Rejected — scatters budgeting, caching, and fallback logic across UI widgets.

### 3. Budgets: timeout, cooldown, per-match cap

One in-flight request at a time; minimum cooldown between calls; per-match call cap with counter reset on new match detection; request timeout fails fast to unavailable. These are constants in the service, tunable without UI changes.

Alternative considered: unbounded requests on every game event. Rejected — API cost and battery risk with no user benefit.

## Risks / Trade-offs

- [Risk] Provider response shapes drift over time → Mitigation: `fromRawText` triple fallback (JSON → labeled lines → raw block) already absorbs most drift; client maps only status codes, never schema details.
- [Risk] Keys in memory could leak via logs/diagnostics → Mitigation: masking rule (last-4 only) enforced in client error paths and the key manager; tests assert no full key in error strings.
- [Risk] Streaming over unstable mobile networks stalls → Mitigation: timeout applies to stream silence, not total duration; stalled streams resolve to last-known advice.
- [Trade-off] Direct device-to-provider calls expose traffic patterns to networks → Accepted: BYOK architecture already assumes this; no proxy is in scope.

## Migration Plan

1. Land clients, service, key-verification swap, and toolbox feed in a single change (no persisted format changes; keys and settings untouched).
2. Verify: `flutter analyze`, `flutter test` with mocked dio (no live calls in CI), manual live-key pass per provider on Android.
3. Rollback: revert the single change; `testConnection` returns to simulated behavior and the callout to static text. No data migration involved.
