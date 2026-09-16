## Why

The live Game Space Console screen and the Settings screens ship hardcoded colors and raw `TextStyle`s that diverge from the `owl_design` token system (`ColorPrimitives` / `ColorSemantics` / `TypographyTokens` / `AppTheme`), so the design system no longer describes what the app actually renders. The four HTML prototypes in `prototypes/` (`guardian_overlay_prototype.html`, `overlay_hud_prototype.html`, `settings_prototype.html`, `home_screen_prototype.html`) are the canonical source of truth for color and type: tokenizing their palette and consolidating typography restores a single source of truth for color and type.

## What Changes

- Audit the Game Space Console screen (`game_space_console_screen.dart`), Settings screens (`app_settings_two_pane_screen.dart`, `gpu_settings_two_pane_screen.dart`), `AppTheme`, and all token files to catalog every hardcoded color and raw `TextStyle`.
- Promote the prototype palette into tokens: obsidian console base (`#07090F`), ambient horizon gradient (`#090B12 → #06070B`), purple ambient (`#8B2BE2` at ~18%) and blue glow (`#006EFF` at 10%), Play-wing gradient (`#0062EB → #0088FF`), GPU tab fill (`#121620` at 88%), cinematic gold ramp (white → `#FFE89E` → `#FFB703` → `#FB8500` / `#FFD700`), console purple ramp (`#7C3AED` → `#933AEA` / `#D8B4FE`), settings surfaces (`#080B10` base, `#0E131E` panel, `rgba(21,28,42,.7)` cards), turbo-cyan accent (`#00E5FF`), gamebox indigo ramp (`#4338CA → #6366F1`), and toolbox/radar/objective treatments (288px toolbox `rgba(14,18,27,.94)`, reactor gauge, CPU/GPU meter fills, urgency states).
- Reconcile divergences with prototype values winning: turbo-red `#E63946`, HUD crimson `#FF3B30`, alert crimson `#FF453A` (replacing token `#FF0055`), live/success emerald `#30D158` (replacing token `#06D6A0`), tactical amber `#FF9F0A` alongside gold `#FFB703` and badge yellow `#EAB308`, console muted `#8E9BAE` / dim `#546173` alongside slate `#94A3B8`, console background `#07090F` vs `oledBlack (#08090C)`, and status-bar whites (`#E2E8F0`/`#CBD5E1`). The home prototype's older companion alerts (`#F59E0B`/`#EF4444`/`#10B981`) are retired; neon `#00F5D4` / electric purple `#7928CA` stay as HUD/companion accents.
- Consolidate typography: add missing console/display roles (status-bar micro, section label, Play-wing title/subtitle, hero headline, gold cinematic headline, purple subpill, pagination is handled by color tokens) to `TypographyTokens`, migrate all raw `TextStyle`s in the console and settings screens onto tokens, and wire `AppTheme.lightTheme`/`darkTheme` `TextTheme` fully through `OwlColors` instead of duplicated hex literals.
- Lock the font stack: Outfit is the single permanent typeface for everything, including telemetry and numerals. JetBrains Mono, Orbitron, Inter, and Plus Jakarta Sans are all removed.
- Update `AppTheme` + `OwlColors` (copyWith/lerp/facade) and `OwlApp` wiring so light/dark resolve every new role with correct contrast; keep `DesignSystemShowcaseView` as the visual verification surface.
- No behavior, navigation, or game-launch logic changes; visual output stays pixel-equivalent except where the audit explicitly approves a canonical value.

## Capabilities

### New Capabilities
- `design-system`: console-aligned color tokens, component roles, elevation/glow additions, consolidated typography scale, and `AppTheme`/`OwlColors` wiring for the whole app.

### Modified Capabilities
- None — `openspec/specs/` is empty, so there are no existing capabilities to modify.

## Impact

- Affected code: `packages/owl_design/lib/theme/tokens/*` (`color_tokens.dart`, `typography_tokens.dart`, `elevation_tokens.dart`, `radius_tokens.dart` as needed), `packages/owl_design/lib/theme/app_theme.dart`, `packages/owl_design/lib/owl_design.dart` exports, `lib/app/app.dart`, `lib/features/game_profiles/presentation/game_space_console_screen.dart`, `lib/features/settings/presentation/*`, `lib/features/showcase/presentation/design_system_showcase_view.dart`.
- No API, storage, or dependency changes except Outfit font-loading fallback handling if Google Fonts needs an offline path.
- Verification: `flutter analyze`, widget/golden review via the showcase, light + dark visual pass on console and settings screens, side-by-side check of each migrated screen against its prototype.
