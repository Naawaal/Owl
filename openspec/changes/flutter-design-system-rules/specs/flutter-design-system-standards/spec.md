## Purpose

Establishes and enforces design system standards, token usage, Material 3 typography bindings, and responsive layout guidelines for all Flutter UI components in the application.

## ADDED Requirements

### Requirement: Elimination of Hardcoded UI Styling Values
The system MUST NOT permit raw hex color definitions, unconstrained double values for paddings or margins, or ad-hoc `TextStyle` instantiations in presentation UI code. All visual properties SHALL be sourced from designated design system tokens or theme context accessors.

#### Scenario: Developer attempts to apply raw hex color or raw EdgeInsets
- **WHEN** presentation widget code is reviewed or analyzed for design system compliance
- **THEN** any raw hex color literals (e.g. `Color(0xFF...)`) or raw numeric `EdgeInsets` (e.g. `EdgeInsets.all(16)`) SHALL fail validation and be required to use `context.colorScheme`, `owlColors`, or `SpacingTokens`

### Requirement: Strict Theme Context Binding
All UI colors and typography SHALL be resolved dynamically at runtime through `Theme.of(context)` or explicit context extensions (`context.colorScheme`, `context.textTheme`, `context.owlColors`, `context.owlTheme`).

#### Scenario: Dynamic theme brightness shift
- **WHEN** the application switches between dark tactical OLED mode and light minimalist mode
- **THEN** all rendered UI components MUST update their background, foreground, border, and text colors dynamically without hardcoded color artifacts

### Requirement: Material 3 Typography Scale Mapping
All UI text elements MUST map directly to standard Material 3 text style roles (`displayLarge`, `headlineMedium`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelSmall`, etc.) via `Theme.of(context).textTheme` or `context.textTheme`. Instantiating custom `TextStyle` constructors from scratch SHALL be prohibited, permitting `copyWith()` solely for weight or color tint overrides.

#### Scenario: Rendering structured interface text
- **WHEN** text is displayed within any card, modal, button, or header
- **THEN** the widget MUST consume a predefined text role from `Theme.of(context).textTheme` with the project-standard typeface (Outfit)

### Requirement: Tokenized Spacing and Radii
All padding, margin, layout gaps, and corner radii MUST utilize project token constants (`SpacingTokens`, `AppSpacing`, `AppSizes`, `RadiusTokens`).

#### Scenario: Layout spacing application
- **WHEN** a container or layout widget defines spacing or separators
- **THEN** it SHALL use tokenized units (e.g. `SpacingTokens.md`, `AppSpacing.md`, `SpacingTokens.gapMd`, `RadiusTokens.card`) rather than arbitrary double values

### Requirement: Adaptive Responsive Layouts
All top-level views and complex UI components MUST support flexible viewports and multi-window environments using `LayoutBuilder`, `MediaQuery`, or adaptive responsive wrappers, guaranteeing that interfaces gracefully adapt across mobile, tablet, and desktop display constraints without screen overflow or fixed-width clipping.

#### Scenario: Screen resized to tablet or wide viewport
- **WHEN** the viewport width expands beyond compact mobile breakpoints
- **THEN** the layout MUST dynamically expand or transition to multi-column/two-pane presentation without horizontal overflow or clipped content

### Requirement: Material 3 Component Prioritization
UI layouts SHALL default to standard Material 3 or design-system-provided widgets (`FilledButton`, `ElevatedButton`, `Card`, `OwlButton`, `OwlGlassCard`) that inherit theme styling and interactive states out of the box, avoiding bespoke `Container` + `GestureDetector` constructions unless specific custom HUD rendering is required.

#### Scenario: Interactive action trigger creation
- **WHEN** an action button or card element is created
- **THEN** the implementation MUST utilize standard M3 buttons or dedicated `owl_design` components with theme-driven state feedback
