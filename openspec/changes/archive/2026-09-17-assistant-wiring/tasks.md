## 1. Assistant behavior

- [x] 1.1 Gate coach auto-querying on `assistantMode` (off suppresses automatic queries, manual refresh still allowed)
- [x] 1.2 Shape prompts by `coachingLevel` depth blocks and scale budgets by `warningSensitivity` multipliers
- [x] 1.3 Subscribe topic toggles to auto-refresh and filter callout display; honor `explainRecommendations` for the reason line

## 2. Performance and voice

- [x] 2.1 Map `performanceMode` to budget presets and wire `adaptiveWorkload` plus CPU/battery stress throttling behind `thermalProtection`
- [x] 2.2 Surface last measured inference latency in the toolbox and edge handle behind `showInGameLatencyHud`
- [x] 2.3 Add the TTS engine behind `voiceAlertsEnabled`, `alertPriority`, `speechCooldownSeconds`, and mix-don't-duck audio config (adds `flutter_tts`)
- [x] 2.4 Route all haptic sites through a central `hapticsEnabled` gate; enforce immersive boot plus master kill-switch for all automation

## 3. Verification

- [x] 3.1 Add mocked tests for prompt shaping, budget scaling, topic gating, TTS guards, haptics gate, and kill-switch (no live calls)
- [x] 3.2 Run `flutter analyze` and fix all reported issues
- [x] 3.3 Run the full `flutter test` suite green plus a manual device pass toggling each wired control observably
- [x] 3.4 Run `openspec validate --change assistant-wiring` and resolve any findings
