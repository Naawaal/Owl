## 1. Provider inference layer

- [x] 1.1 Add the `InferenceClient` interface (`verifyKey`, `generate`, `generateStream`) over the existing `ApiClient` plumbing with shared timeout, key injection, and error mapping
- [x] 1.2 Implement the Gemini client (`generateContent` + `streamGenerateContent`) with measured-latency key verification
- [x] 1.3 Implement the OpenAI client (`chat/completions`) behind the same interface
- [x] 1.4 Implement the Claude and OpenRouter clients behind the same interface

## 2. Coach service and UI feed

- [x] 2.1 Add the `CoachService` notifier: game-state prompt assembly, cooldown/cap/timeout budgets, `AsyncValue` latest-advice state with last-known caching
- [x] 2.2 Replace the simulated key test with the real verification call, reporting measured latency and distinct auth/network failures
- [x] 2.3 Feed the Guardian toolbox callout from live advice with cached, offline-heuristic, then silent fallback that never blocks gameplay

## 3. Verification

- [x] 3.1 Add mocked-dio tests for client parsing, key masking, budgets, and service fallback (no live calls)
- [x] 3.2 Run `flutter analyze` and fix all reported issues
- [x] 3.3 Run the full `flutter test` suite green plus a manual live-key pass per provider on Android
- [x] 3.4 Run `openspec validate --change ai-inference` and resolve any findings
