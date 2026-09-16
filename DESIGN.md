# Owl Design System Specification & Architecture

This document serves as the canonical design system reference for the Owl MOBA Companion HUD & On-Device AI Coach. All UI presentation code across feature packages and apps must strictly conform to the standards and tokens outlined herein.

---

## 1. Core Philosophy & Foundations

1. **Dual-Theme Aesthetic**:
   - **Dark Theme (Tactical Cyber-HUD)**: OLED pitch black (`#07090F` / `#08090C`), high-contrast telemetry accents, subtle borders (`rgba(255,255,255,0.08)`), tactical neon glows, and glassmorphic HUD overlays.
   - **Light Theme (Modern Minimalist)**: Clean slate background (`#F8FAFC`), crisp borders (`#E2E8F0`), refined typography, and Scandinavian ergonomics.
2. **Permanent Typeface (Outfit)**:
   - A single unified font family (`Outfit`) is used across all UI elements, status bars, action sheets, numerical readouts, and timer telemetry.
3. **4dp Rigid Base Grid**:
   - Every padding, margin, sized box, and layout dimension adheres to the 4dp mathematical scale.
4. **Zero Generic Elevators**:
   - Material elevation drops and fuzzy cast shadows are replaced with hairline tactical borders and localized status glows (`BoxShadow`).

---

## 2. Six Absolute UI Constraints

> [!IMPORTANT]
> These six rules are absolute and must never be violated in any pull request, refactor, or generated Flutter code.

### Constraint 1: No Hardcoded Values
- **NEVER** use raw hex codes (e.g. `Color(0xFF1E1E1E)`).
- **NEVER** use raw numeric doubles for padding, margin, or layout sizing (e.g. `EdgeInsets.all(16.0)` or `SizedBox(height: 12)`).
- **NEVER** define `TextStyle()` from scratch.

### Constraint 2: Strict Theme Usage
- All colors and typography must be accessed through `Theme.of(context)` or ergonomic extensions:
  - `context.colorScheme` / `Theme.of(context).colorScheme`
  - `context.textTheme` / `Theme.of(context).textTheme`
  - `context.owlColors` / `Theme.of(context).extension<OwlColors>()!`
  - `context.owlTheme` / `Theme.of(context).extension<OwlThemeExtension>()!`

### Constraint 3: Material 3 Typography Scale Mapping
- All text must map to predefined Material 3 text styles:
  - `displayLarge`, `displayMedium`, `displaySmall`
  - `headlineMedium`, `headlineSmall`
  - `titleLarge`, `titleMedium`, `titleSmall`
  - `bodyLarge`, `bodyMedium`, `bodySmall`
  - `labelLarge`, `labelMedium`, `labelSmall`
- Custom `TextStyle()` instantiations are prohibited. Use `.copyWith()` strictly to adjust font weight or override color if context requires.

### Constraint 4: Predefined Spacing & Token Constants
- All `Padding`, `Margin`, `SizedBox`, and border radii must consume token constants:
  - Spacing scalars: `SpacingTokens.md`, `AppSpacing.md`, `AppSizes.p16`
  - Pre-baked insets: `SpacingTokens.cardInsets`, `SpacingTokens.screenInsets`, `SpacingTokens.buttonInsets`
  - Spacer widgets: `SpacingTokens.gapMd`, `SpacingTokens.gapH16`, `SpacingTokens.gapV16`
  - Border radii: `RadiusTokens.card`, `RadiusTokens.button`, `RadiusTokens.borderMd`, `RadiusTokens.pillBadge`

### Constraint 5: Adaptive Viewport Responsiveness
- Do not assume fixed phone dimensions (e.g., hardcoded 360px widths).
- Interfaces must scale gracefully across phone portrait/landscape, foldable screens, desktop windows, and split-screen HUD views using:
  - `LayoutBuilder` for container-driven layouts
  - `MediaQuery.sizeOf(context)` or responsive breakpoints for multi-column grids
  - Flexible widgets (`Expanded`, `Flexible`, `ConstrainedBox`, `FittedBox`) to prevent layout clipping and pixel overflows.

### Constraint 6: Component Reuse & Native M3 Widgets
- Default to theme-inheriting standard Material 3 components (`FilledButton`, `ElevatedButton`, `Card`) and dedicated `owl_design` widgets (`OwlButton`, `OwlGlassCard`, `OwlTacticalPill`, `OwlBadge`).
- Avoid assembling custom `Container` + `GestureDetector` constructs for buttons or cards unless bespoke HUD hardware rendering is explicitly required.

---

## 3. Code Patterns: Banned vs. Required

### Anti-Pattern (BANNED):
```dart
// ❌ REJECTED: Hardcoded color, hardcoded padding, raw TextStyle, custom container button
Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: const Color(0xFF1E1E1E),
    borderRadius: BorderRadius.circular(8.0),
  ),
  child: GestureDetector(
    onTap: () {},
    child: const Text(
      'Launch Game',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
)
```

### Required Pattern (APPROVED):
```dart
// ✅ APPROVED: Token spacing, theme-driven colors, M3 typography, native component
Padding(
  padding: SpacingTokens.cardInsets,
  child: Card(
    shape: RoundedRectangleBorder(borderRadius: RadiusTokens.card),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Launch Game',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SpacingTokens.gapV12,
          FilledButton(
            onPressed: () {},
            child: Text(
              'Start Session',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    ),
  ),
)
```

---

## 4. Spacing & Radius Token Catalog

### Spacing Grid (4dp Basis)
| Token (`SpacingTokens` / `AppSpacing`) | `AppSizes` Alias | Value | Usage |
|:---|:---|:---|:---|
| `xxs` | `p4` | `4.0` | Micro indicators, badge paddings |
| `xs` | `p8` | `8.0` | Compact gaps, chip insets |
| `sm` | `p12` | `12.0` | Sub-item spacing, compact card padding |
| `md` | `p16` | `16.0` | Standard layout spacing, card insets |
| `lg` | `p24` | `24.0` | Major section separators, modal paddings |
| `xl` | `p32` | `32.0` | Screen margins, large hero gaps |
| `xxl` | `p48` | `48.0` | Screen headers, floating HUD offsets |

### Pre-baked Insets & Spacers
- **Insets**: `SpacingTokens.screenInsets` (16dp all), `SpacingTokens.cardInsets` (16dp all), `SpacingTokens.cardCompactInsets` (12dp all), `SpacingTokens.pillInsets` (12dp H / 6dp V), `SpacingTokens.buttonInsets` (16dp H / 12dp V).
- **Spacers**:
  - Squares: `SpacingTokens.gapXxs` (4), `gapXs` (8), `gapSm` (12), `gapMd` (16), `gapLg` (24), `gapXl` (32)
  - Horizontal: `SpacingTokens.gapH4`, `gapH8`, `gapH12`, `gapH16`, `gapH24`, `gapH32`
  - Vertical: `SpacingTokens.gapV4`, `gapV8`, `gapV12`, `gapV16`, `gapV24`, `gapV32`

### Radius Geometries
| Token (`RadiusTokens`) | Value | Usage |
|:---|:---|:---|
| `xs` / `borderXs` | `4.0` | Small tags, status dots, telemetry bars |
| `sm` / `button` / `borderSm` | `8.0` | Buttons, action sheet tiles, inputs |
| `md` / `card` / `borderMd` | `12.0` | Standard cards, telemetry panels |
| `lg` / `modal` / `borderLg` | `16.0` | Dialogs, bottom sheets, console cards |
| `xl` / `borderXl` | `24.0` | Hero containers, floating overlays |
| `pill` / `pillBadge` / `hudChip` | `999.0` | Rounded badges, timer pills, status tags |

---

## 5. Typography Scale & Material 3 Mappings

Font family: **Outfit** (`TypographyTokens.uiFontFamily`)

| M3 Text Role (`Theme.of(context).textTheme`) | Design System Token | Size / Weight / Spacing | Target Usage |
|:---|:---|:---|:---|
| `displayLarge` | `displayTimerLarge` | `36sp / w800 / -0.8px` | Hero game clocks, major countdowns |
| `displayMedium` | `displayTimer` | `28sp / w700 / -0.5px` | Objective timers, respawn meters |
| `displaySmall` | `displayTimerSmall` | `18sp / w700 / -0.2px` | Compact HUD timers, overlay telemetry |
| `headlineMedium` | `headline` | `20sp / w600 / -0.5px` | Screen titles, console major sections |
| `titleMedium` | `titleMedium` | `16sp / w500 / -0.2px` | Card headers, modal headlines |
| `titleSmall` | `titleSmall` | `14sp / w500 / 0.0px` | Sub-headers, telemetry labels |
| `bodyLarge` | `bodyLarge` | `16sp / w400 / 0.0px` | Primary narrative text, descriptions |
| `bodyMedium` | `bodyMedium` | `14sp / w400 / 0.0px` | Standard UI body, form field labels |
| `bodySmall` | `bodySmall` | `12sp / w400 / 0.0px` | Secondary descriptors, footnotes |
| `labelLarge` | `buttonText` | `14sp / w600 / 0.1px` | Buttons, action sheet items |
| `labelMedium` | `tacticalLabel` | `11sp / w600 / 0.5px` | Tactical status indicators, chips |
| `labelSmall` | `tacticalBadge` | `10sp / w700 / 0.8px` | Micro telemetry badges, kill trackers |

---

## 6. Color Scheme & Semantic Tokens

All screens resolve colors through `Theme.of(context).colorScheme` or `context.owlColors`:

- **Background & Canvas**:
  - Dark: `colorScheme.surface` (`#07090F` / `#08090C`), `owlColors.cardBackground` (`#0E131E`)
  - Light: `colorScheme.surface` (`#F8FAFC`), `owlColors.cardBackground` (`#FFFFFF`)
- **Primary / Secondary Accents**:
  - Dark Accent: Electric Purple / Cyber Blue (`#0062EB → #0088FF`)
  - Status Indicators:
    - **Live / Success**: Emerald (`#30D158`)
    - **Warning / Objective**: Gold / Amber (`#FFB703` / `#FF9F0A`)
    - **Alert / Danger**: Crimson (`#FF3B30` / `#E63946`)
    - **Turbo / AI**: Cyan (`#00E5FF`)
- **Text & Content**:
  - `colorScheme.onSurface` (Primary contrast text)
  - `owlColors.textSecondary` (Dimmed guidance text)
  - `owlColors.textMuted` (Micro telemetry labels)

---

## 7. Responsive Layout Patterns

To support phone, tablet, and multi-window game HUD views:

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 600;
      return Padding(
        padding: SpacingTokens.screenInsets,
        child: isWide ? _buildTwoColumnLayout(context) : _buildSingleColumnLayout(context),
      );
    },
  );
}
```

- When constructing scrollable views, wrap with `SingleChildScrollView` + `AppTheme.scrollPhysics` (`BouncingScrollPhysics`).
- Never rely on fixed pixel container widths unless contained within an explicitly bounded horizontal scrolling strip.
