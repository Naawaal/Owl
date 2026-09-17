## 1. Mode ritual coordinator

- [x] 1.1 Add `ModeRitualCoordinator` with prior snapshot (DND, Wi‑Fi, immersion) in memory + prefs
- [x] 1.2 Implement Performance apply: best-effort DND on, Wi‑Fi boost on, immersion locks on
- [x] 1.3 Implement Balanced apply: restore priors + safe defaults if none
- [x] 1.4 Call coordinator from `togglePerformanceOptimization` / shared apply path (Console + HUD)

## 2. Owl performance budget

- [x] 2.1 Gate autonomous coach / topic refresh cadence on Balanced vs Performance
- [x] 2.2 Native: do not keep MediaProjection warm under Balanced; rarefy/stop guardian auto-refresh
- [x] 2.3 Apply budget on cold start from persisted `performanceOptimization`

## 3. Feedback + immersion

- [x] 3.1 Haptic + toast/snack on mode change with truthful copy (no GPU unlock claims)
- [x] 3.2 Native Toast when toolbox collapsed so in-game toggle still confirms
- [x] 3.3 Wire brightness / mistouch / gesture locks into ritual using existing settings toggles

## 4. OEM bridge

- [x] 4.1–4.2 ~~OEM Game Booster detect/open UI~~ — **removed from product** (no “Open Xiaomi Game Turbo” chip; Owl owns mode UX)

## 5. Verification

- [ ] 5.1 Manual: Performance → DND/Wi‑Fi/immersion engage; Balanced restores priors
- [ ] 5.2 Manual: Balanced mid-match → coach/vision load drops; rail stays smooth
- [x] 5.3 ~~Manual: OEM chip~~ — N/A (OEM open UI removed)
- [x] 5.4 Run `flutter analyze --no-fatal-warnings` on touched Dart files
