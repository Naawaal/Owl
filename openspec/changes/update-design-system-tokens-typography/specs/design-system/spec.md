## Purpose

Unifies the app's color tokens, typography scale, and theme wiring around the real Game Space Console and Settings palette so every screen renders from a single design-system source of truth.

## ADDED Requirements

### Requirement: Console surface palette is tokenized

The system SHALL expose the Game Space Console's real surfaces as design tokens: the obsidian console base, the ambient horizon gradient pair, the purple ambient glow, the right-anchored blue glow, the Play-wing gradient pair, and the GPU tab fill, each with a light-theme counterpart that preserves contrast.

#### Scenario: Console renders from tokens

- **WHEN** the Game Space Console screen is displayed in dark mode
- **THEN** its scaffold base, horizon gradient, ambient glows, Play wing, and GPU tab SHALL visually match the current shipped console pixel-for-pixel

#### Scenario: Console supports light theme

- **WHEN** the app runs in light mode
- **THEN** every console surface token SHALL resolve to a light value with a contrast ratio of at least 4.5:1 for text-bearing surfaces

### Requirement: Status and telemetry colors are canonical

The system SHALL define a single canonical color for each telemetry state (battery critical, battery low, battery normal, CPU badge, Turbo HUD active/inactive) so the console top bar, dialogs, and settings badges never disagree.

#### Scenario: Battery states agree everywhere

- **WHEN** battery level crosses the critical and low thresholds
- **THEN** the console battery fill, any settings battery indicator, and the alert palette SHALL all show the same canonical color for that state

#### Scenario: No divergent hardcoded status colors

- **WHEN** the codebase is searched for the legacy divergent values used only by the console top bar
- **THEN** no screen SHALL use them except through the canonical telemetry tokens

### Requirement: Cinematic accent ramps are tokenized

The system SHALL expose the console's cinematic treatments as tokens: the gold headline gradient ramp, the gold border/glow treatment, and the purple subpill gradient with its border, each with light-theme counterparts.

#### Scenario: Hero showcase keeps its cinematic look

- **WHEN** the center-stage hero card is displayed
- **THEN** the gold headline gradient, gameplay inset border, triple-kill badge, and purple subpill SHALL match the current shipped appearance

### Requirement: Console typography roles exist

The system SHALL provide typography roles covering every text treatment used by the console and settings screens: status-bar micro, telemetry badge, section label, Play-wing title and subtitle, hero gold headline, purple subpill label, dialog title/body/actions, and GPU tab label — each with a defined size, weight, letter spacing, and line height.

#### Scenario: Designer can spec any console text

- **WHEN** a reviewer inspects any text element on the console or settings screens against the type scale
- **THEN** each element SHALL map to exactly one named typography role with no ambiguous fallback

### Requirement: Screens use tokens instead of raw styles

The system SHALL render all text and color on the Game Space Console screen and both Settings screens exclusively through design tokens and theme resolution, with zero hardcoded colors and zero inline text styles.

#### Scenario: Audit finds no hardcoded styling in scope

- **WHEN** the console screen and settings screens are audited for hardcoded color literals and inline text styles
- **THEN** every instance SHALL resolve through tokens or theme extensions, except asset-driven artwork sampling which MUST be explicitly listed as exempt

### Requirement: Dual-theme wiring is complete

The system SHALL resolve every color and typography role through the active brightness (light or dark) across the app shell, including the system UI overlay style, scaffold, app bar, cards, buttons, chips, inputs, dividers, tooltips, and dialogs.

#### Scenario: Theme switch preserves legibility

- **WHEN** the user switches between light and dark mode on the console and settings screens
- **THEN** all text SHALL remain legible (minimum 4.5:1 contrast for body text), all interactive states (hover, pressed, disabled, selected) SHALL remain distinguishable, and no surface SHALL fall back to an untokenized default

#### Scenario: Animated theme transitions stay smooth

- **WHEN** the theme interpolates between light and dark
- **THEN** every extended color role SHALL blend continuously with no snapping or unthemed flash

### Requirement: Showcase verifies the system

The system SHALL present every new or changed color role and typography role in the Design System Showcase view so a reviewer can verify the full palette and type scale in both themes without opening each feature screen.

#### Scenario: Reviewer verifies roles in one place

- **WHEN** a reviewer opens the showcase in dark mode and then in light mode
- **THEN** each console surface, telemetry state, cinematic accent, and typography role SHALL be visible with its correct themed value

### Requirement: Screens match their prototypes

The system SHALL render the Game Space Console, the in-game toolbox and HUD overlays, and both Settings screens to match their prototypes (`guardian_overlay_prototype.html` and `overlay_hud_prototype.html` for console/HUD, `settings_prototype.html` for settings), with prototype values winning every conflict against legacy tokens per the decision table in `design.md`.

#### Scenario: Console matches guardian lobby prototype

- **WHEN** the Game Space Console is compared side-by-side with the guardian lobby prototype
- **THEN** the ambient horizon, top status bar, hero card with gold headline and purple subpill, Play wing, GPU tab, and pagination SHALL match the prototype treatment-for-treatment

#### Scenario: Settings match settings prototype

- **WHEN** either Settings screen is compared side-by-side with the settings prototype
- **THEN** the two-pane layout, category sidebar with active indicator, setting rows, segmented chips, switches, provider cards, key inputs, telemetry bar, and perf tier cards SHALL match the prototype treatment-for-treatment

### Requirement: Font stack follows the prototypes

Outfit SHALL be the single permanent typeface for all text, including telemetry and tabular numerals. No other font family (JetBrains Mono, Orbitron, Inter, Plus Jakarta Sans) SHALL remain in code, dependencies, or loaded assets, and text SHALL render in Outfit even offline via bundled fallback.

#### Scenario: Typeface audit passes

- **WHEN** the codebase, dependencies, and asset bundle are audited for typeface usage
- **THEN** every text element SHALL resolve to Outfit, zero references to any other font family SHALL exist, and all countdown, gauge, and telemetry numerals SHALL render legibly with no layout breakage
