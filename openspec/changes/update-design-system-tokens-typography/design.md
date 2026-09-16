## Context

See `proposal.md` (Why) for motivation. Current state shaping this design:

- `packages/owl_design/lib/theme/tokens/color_tokens.dart` implements a 3-layer system (primitives → semantics → components) plus an `OwlColors` ThemeExtension with full `copyWith`/`lerp` for light/dark. The dark default is an OLED tactical palette (`oledBlack #08090C`, neon cyan `#00F5D4`, electric purple `#7928CA`).
- The Game Space Console (`lib/features/game_profiles/presentation/game_space_console_screen.dart`) bypasses that system: scaffold `0xFF07090F`, horizon `#090B12 → #06070B`, purple ambient `#8B2BE2`, blue glow `#006EFF`, Play-wing `#0062EB → #0088FF`, GPU tab `#121620`, gold ramp (white → `#FFE89E` → `#FFB703` → `#FB8500` / `#FFD700`), purple pill (`#7C3AED → #933AEA` / `#D8B4FE`), battery red/yellow (`#E63946`/`#EAB308`), and ~15 raw `TextStyle`s.
- `AppTheme.lightTheme` duplicates hex literals instead of referencing `OwlColors.light`, and `TypographyTokens` hardcodes dark colors, so neither theme resolves through a single path.
- `openspec/specs/` is empty: no existing spec contracts to preserve. `DesignSystemShowcaseView` already renders most token families and is the natural verification surface.
- The four HTML prototypes in `prototypes/` are the canonical visual spec and agree with each other on the core system: turbo blue `#007AFF` / light `#389BFF` (all four), console base `#07090F` + horizon `#090B12 → #06070B` + purple/blue ambients (guardian, overlay, shipped app), white 8%/15% borders (unanimous), JetBrains Mono for all telemetry (unanimous). They disagree in five spots, resolved in Decision 0.

## Goals / Non-Goals

**Goals:**
- Single source of truth: every color and text style on the console and settings screens resolves through tokens/theme.
- Pixel-equivalence in dark mode except for explicitly approved canonical values.
- Complete light-theme coverage for all new roles with verified contrast.

**Non-Goals:**
- No navigation, game-launch, overlay-permission, or telemetry-logic changes.
- No new widgets or screens; no rebranding beyond tokenizing what already ships.
- No UI font switch (Outfit is already the UI font); the change makes it the single permanent typeface and removes all others.

## Decisions

### 0. Prototypes win conflicts; ties broken by vote and screen ownership

Where the prototypes and the app tokens disagree, the prototypes win. Where the prototypes disagree with each other, two rules apply: majority vote wins, and the most detailed prototype owns its screen (settings prototype owns settings surfaces, home prototype owns the light theme, guardian + overlay own the console/HUD).

| Conflict | Winner | Loser(s) retired |
|---|---|---|
| Danger/alert red | Turbo-red `#E63946`, HUD crimson `#FF3B30`, alert crimson `#FF453A`, each in its role | Token `#FF0055`; home `#EF4444` |
| Success/live green | Emerald `#30D158` everywhere | Token `#06D6A0`; home `#10B981` |
| Warning amber | Tactical `#FF9F0A` for warnings; gold `#FFB703` ramp + `#EAB308` badge kept as cinematic accents | Home `#F59E0B` |
| Muted text | Slate `#94A3B8` stays as textSecondary; `#8E9BAE` added as console-muted role, `#546173` as dim | — (additive, no churn) |
| Settings surfaces | Own roles: base `#080B10`, panel `#0E131E`, card `rgba(21,28,42,.7)` | — (did not exist as tokens) |
| Light theme | Home prototype ramp (canvas `#E2E8F0`, screen `#F8FAFC`), which already matches `OwlColors.light` | — (confirms current light tokens) |
| UI font | Outfit (settings prototype + shipped app agree) | Inter, Plus Jakarta Sans (older prototypes only) |
| Numerals + telemetry | Outfit everywhere — operator decision; JetBrains Mono fully removed including `monoFontFamily`, `tabularFigures`/`slashedZero` features, and all direct usages | JetBrains Mono, Orbitron (not adopted) |

Neon `#00F5D4` / electric purple `#7928CA` stay as HUD/companion accents (home prototype and current tokens agree).

### 1. Console palette wins divergences; legacy primitives stay as aliases

The shipped console is the visual truth, so where console literals and tokens disagree, the console value becomes canonical: console base `#07090F` becomes the console surface (distinct from `oledBlack`, which is retained for HUD overlays), battery red/yellow adopt `#E63946`/`#EAB308` as the canonical critical/low states (replacing `#FF0055`/`#FFB703` in telemetry roles only — HUD urgency accents keep their neon values), and status whites resolve to the existing slate scale (`#E2E8F0`/`#CBD5E1` map onto text-primary/secondary steps).

Alternative considered: keep both values side by side. Rejected — parallel near-duplicates are what caused this drift.

### 2. New tokens follow the existing 3-layer pattern in console/cinematic namespaces

New primitives (obsidian, horizon pair, console purple/blue glow values, play-wing pair, GPU tab fill, gold ramp stops) → new semantics (`consoleBase`, `consoleHorizon`, `cinematicGold`, `consolePurple`) → new component roles (`playWing*`, `gpuTab*`, `heroCard*`, `telemetry*`). `OwlColors` gains one field per new semantic/component role with matching `copyWith`/`lerp` entries; gradient ramps are exposed as lerped stop-tuples next to their solid roles. Elevation additions (play-wing side glow, hero purple bloom, gold badge glow) go in `elevation_tokens.dart`; no radius/spacing changes are expected beyond referencing existing values.

Alternative considered: a separate `ConsoleTokens` class outside the 3-layer system. Rejected — a parallel system recreates the two-sources problem.

### 3. Typography grows console roles; themes reference tokens instead of hex

`TypographyTokens` gains the missing roles (status micro, telemetry badge, section label, play-wing title/subtitle, hero gold headline, subpill label, dialog title/body/actions, GPU tab label, settings row title/desc, gauge numerals), each defined once in Outfit without baked-in color where the theme supplies it. Outfit is the single permanent typeface: every `GoogleFonts.jetBrainsMono` call site, every `monoFontFamily` reference, and every `tabularFigures`/`slashedZero` feature goes to Outfit equivalents, since Outfit cannot guarantee tabular figures. `AppTheme` `lightTheme`/`darkTheme` `TextTheme`s map every role through the active `OwlColors` instead of duplicated literals. Font loading stays on Google Fonts with the existing static family fallback; if offline loading proves flaky during implementation, bundle Outfit as an asset — a packaging detail, not a design change.

Alternative considered: full Material 3 type-scale rename. Rejected — renames churn every consumer for no visual gain.

Alternative considered: keeping JetBrains Mono for telemetry numerals (unanimous across all four prototypes, tabular figures prevent countdown jitter). Rejected by operator — Outfit is permanent everywhere; countdown stability is verified visually instead (see Risks).

### 4. Migrate showcase → console → settings, verifying visually at each step

Showcase first (adds the new roles as reference swatches/specimens), then the console screen, then both settings screens. Each step is verified with a side-by-side screenshot against the pre-change render before moving on, so drift is caught at its source.

## Risks / Trade-offs

- [Risk] Token surface grows (~25 new roles now, with settings + toolbox + gauge families) → Mitigation: group strictly under console/cinematic/telemetry/settings namespaces; reuse existing slate/alert steps wherever the delta is imperceptible.
- [Risk] Pixel drift during migration → Mitigation: screenshot comparison at each of the three migration steps; any intentional change recorded in the tasks audit table.
- [Risk] Light-mode cinematic treatments (gold on light canvas) fail contrast → Mitigation: dedicated darker light-mode gold/purple ramps, verified against 4.5:1 for text-bearing uses.
- [Risk] `OwlColors` constructor churn touches every `copyWith`/`lerp` call site → Mitigation: new fields are required but defaulted through the `dark`/`light` consts; compiler errors surface missed sites, and `flutter analyze` gates the change.
- [Risk] Outfit numerals are proportional, so countdowns/timers may visibly jitter per tick → Mitigation: verify every timer, gauge readout, and telemetry strip visually during migration (task 3.4); if jitter is unacceptable, contain it with fixed-width layout or right-alignment — never by reintroducing a second typeface.
- [Trade-off] Pixel-equivalence constraint slows cleanup of near-duplicate values → Accepted: correctness of the visual contract outweighs fewer tokens.

## Migration Plan

1. Land token + typography + theme changes with the three screen migrations in a single change (no intermediate release contract to preserve; app ships from trunk).
2. Verify: `flutter analyze`, showcase review in both themes, console + settings visual pass on Android (primary target) and one desktop size.
3. Rollback: revert the single change; screens and tokens move together so no partial-token state can ship.
