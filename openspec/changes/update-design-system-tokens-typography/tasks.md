## 1. Audit current styling

- [x] 1.1 Catalog every hardcoded color literal and raw `TextStyle` in `game_space_console_screen.dart` with its location, value, and proposed token role
- [x] 1.2 Catalog every hardcoded color literal and raw `TextStyle` in `app_settings_two_pane_screen.dart` and `gpu_settings_two_pane_screen.dart`, plus duplicated hex literals in `AppTheme.lightTheme`
- [x] 1.3 Record canonical-value decisions for each divergence (console base vs `oledBlack`, battery red/yellow vs alert tokens, status whites, Play-wing/GPU-tab treatments) in an audit table
- [x] 1.4 Cross-check the audit table against all four prototypes in `prototypes/`, recording the winning value per the design Decision 0 conflict table (turbo-red/HUD-crimson/alert-crimson, emerald `#30D158`, tactical amber, settings surfaces, Outfit-only typeface)

## 2. Color tokens

- [x] 2.1 Add console/cinematic/settings primitives, semantics, and component roles (console base, horizon pair, ambient glows, Play-wing pair, GPU tab fill, gold ramp, console purple ramp, settings base/panel/card, turbo-cyan, gamebox indigo ramp, toolbox/gauge/meter/radar/objective roles, telemetry states with prototype reds and emerald) to `color_tokens.dart` for dark
- [x] 2.2 Add light-theme counterparts for every new role with 4.5:1 contrast on text-bearing surfaces
- [x] 2.3 Extend `OwlColors` with the new fields including `dark`/`light` consts, `copyWith`, `lerp`, facade accessor, and static aliases
- [x] 2.4 Add console glow treatments (Play-wing side glow, hero purple bloom, gold badge glow) to `elevation_tokens.dart`

## 3. Typography and theme wiring

- [x] 3.1 Add missing console/display roles (status micro, telemetry badge, section label, Play-wing title/subtitle, hero gold headline, subpill label, dialog title/body/actions, GPU tab label, settings row title/desc, gauge numerals) to `typography_tokens.dart`
- [x] 3.2 Rewire `AppTheme.lightTheme` and `darkTheme` `TextTheme`s to resolve through the active `OwlColors`, removing duplicated hex literals
- [x] 3.3 Verify Outfit loading with offline fallback, bundling it as an asset if runtime loading proves flaky, and drop all other font families from dependencies
- [x] 3.4 Migrate every `GoogleFonts.jetBrainsMono` call site, `monoFontFamily` reference, and `tabularFigures`/`slashedZero` feature to Outfit roles, then visually verify all countdowns, gauge readouts, and telemetry strips for numeral jitter, containing any jitter with fixed-width layout

## 4. Screen migration

- [x] 4.1 Extend `DesignSystemShowcaseView` with swatches and specimens for every new or changed color and typography role
- [x] 4.2 Migrate `game_space_console_screen.dart` to tokens and theme roles, verifying pixel-equivalence with side-by-side screenshots in dark mode
- [x] 4.3 Migrate `app_settings_two_pane_screen.dart` and `gpu_settings_two_pane_screen.dart` to tokens and theme roles
- [x] 4.4 Verify `OwlApp` theme wiring (overlay style per brightness, scaffold/app bar/cards/buttons/chips/inputs/dividers/tooltips/dialogs) in both themes
- [x] 4.5 Verify each migrated screen side-by-side against its prototype (console vs guardian lobby, toolbox/HUD vs overlay prototype, settings vs settings prototype)

## 5. Verification

- [x] 5.1 Run `flutter analyze` and fix all reported issues
- [x] 5.2 Complete light/dark visual pass on console, settings, and showcase screens with contrast checks on text-bearing surfaces
- [x] 5.3 Run `openspec validate --change update-design-system-tokens-typography` and resolve any findings
