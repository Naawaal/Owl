# Owl Design System Specification & Architecture

This document serves as the canonical design system reference for the Owl MOBA Companion HUD & On-Device AI Coach. All UI presentation code across feature packages and apps must strictly conform to the standards, tokens, and modular guidelines outlined herein.

---

## 1. Core Philosophy & Foundations

1. **Dual-Theme Aesthetic (Xiaomi HyperOS Game Turbo & Scandinavian Minimalist)**:
   - **Dark Theme (Tactical Cyber-HUD)**: OLED pitch black (`#07090F` / `#08090C`), high-contrast telemetry accents (`#007AFF` / `#00F5D4`), hairline borders (`rgba(255,255,255,0.10)`), tactical neon glows, and glassmorphic HUD overlays.
   - **Light Theme (Modern Minimalist)**: Clean slate background (`#F8FAFC`), crisp borders (`#E2E8F0`), refined typography, and Scandinavian ergonomics.
2. **Permanent Typeface (Outfit)**:
   - A single unified font family (`Outfit`) is used across all UI elements, status bars, action sheets, numerical readouts, and timer telemetry.
3. **4dp Rigid Base Grid**:
   - Every padding, margin, sized box, and layout dimension adheres strictly to the 4dp mathematical scale.
4. **Zero Generic Elevators**:
   - Material elevation drops and fuzzy cast shadows are replaced with hairline tactical borders and localized status glows (`BoxShadow`).
5. **Modular Single Responsibility Architecture**:
   - Keep files focused and maintainable with a target cap of <200 lines per file. Monolithic screens must be decomposed into dedicated section panes and reusable presentation components.

---

## 2. Seven Absolute UI & Architecture Constraints

> [!IMPORTANT]
> These seven rules are absolute and must never be violated in any pull request, refactor, or generated Flutter code.

### Constraint 1: No Hardcoded Values
- **NEVER** use raw hex codes (e.g. `Color(0xFF1E1E1E)`).
- **NEVER** use raw numeric doubles for padding, margin, or layout sizing (e.g. `EdgeInsets.all(16.0)` or `SizedBox(height: 12)`).
- **NEVER** define `TextStyle()` from scratch.

### Constraint 2: Strict Theme Usage & ColorTokens Facade
- All colors and typography must be accessed through the `ColorTokens.of(context)` facade, `Theme.of(context)`, or ergonomic context extensions:
  - Preferred: `final colors = ColorTokens.of(context);` (returns active `OwlColors` adapting seamlessly between Light and Dark themes)
  - M3 Color Scheme: `context.colorScheme` / `Theme.of(context).colorScheme`
  - M3 Text Theme: `context.textTheme` / `Theme.of(context).textTheme`
  - Owl Colors Extension: `context.owlColors` / `Theme.of(context).extension<OwlColors>()!`

### Constraint 3: Material 3 Typography & Theme-Aware Tokens
- All text must map to predefined Material 3 text styles or context-aware `TypographyTokens`:
  - M3 Roles: `displayLarge`, `headlineMedium`, `titleMedium`, `titleSmall`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelSmall`
  - Theme-Aware Helpers: `TypographyTokens.headlineOf(context)`, `titleSmallOf(context)`, `bodySmallOf(context)`, `tacticalBadgeOf(context)`, `buttonTextOf(context)`, `statusMicroOf(context)`, `settingsRowTitleOf(context)`, `settingsRowDescOf(context)`, `dialogTitleOf(context)`
- Custom `TextStyle()` instantiations are prohibited. Use `.copyWith()` strictly to adjust font weight or tint if context requires.

### Constraint 4: Predefined Spacing & Token Constants
- All `Padding`, `Margin`, `SizedBox`, and border radii must consume token constants:
  - Spacing scalars: `SpacingTokens.md`, `AppSpacing.md`, `AppSizes.p16` (4, 8, 12, 16, 24, 32, 48)
  - Pre-baked insets: `SpacingTokens.cardInsets`, `SpacingTokens.screenInsets`, `SpacingTokens.buttonInsets`, `SpacingTokens.pillInsets`
  - Spacer widgets: `SpacingTokens.gapMd`, `SpacingTokens.gapH16`, `SpacingTokens.gapV16`, `AppSpacing.gapH8`, `AppSpacing.gapV12`
  - Border radii: `RadiusTokens.card`, `RadiusTokens.button`, `RadiusTokens.borderMd`, `RadiusTokens.borderPill`, `RadiusTokens.borderXl`

### Constraint 5: Adaptive Viewport Responsiveness
- Do not assume fixed phone dimensions.
- Interfaces must scale gracefully across phone portrait/landscape, foldable screens, desktop windows, and split-screen HUD views using:
  - `LayoutBuilder` for container-driven layouts
  - `MediaQuery.sizeOf(context)` or responsive breakpoints for multi-column grids
  - Flexible widgets (`Expanded`, `Flexible`, `ConstrainedBox`, `FittedBox`) to prevent layout clipping and pixel overflows.

### Constraint 6: Component Reuse & Design System Widget Catalog
- Always default to existing `owl_design` widgets or theme-inheriting standard Material 3 components (`FilledButton`, `ElevatedButton`, `Card`).
- Standard Design System Widgets (`package:owl_design/owl_design.dart`):
  - **Cards & Backdrops**: `OwlGlassCard`, `OwlAtmosphericBackground`
  - **Buttons**: `OwlButton`, `OwlIconButton`
  - **Badges & Pills**: `OwlBadge`, `OwlTimerBadge`, `OwlTacticalPill`
  - **Indicators**: `OwlCooldownRing`, `OwlStatusDot`
  - **Inputs & Switches**: `OwlTextField`, `MiuiSwitch`, `OemSegmentedChips`
  - **Overlays**: `OwlActionSheet`
- Avoid assembling custom `Container` + `GestureDetector` constructs for buttons or cards unless bespoke hardware telemetry rendering is explicitly required.

### Constraint 7: File Modularization (<200 LOC) & Riverpod State Management
- **Single Responsibility Principle**: Decompose any UI file exceeding 200 lines. Screen orchestrators should delegate layout chunks to subcomponents located in `presentation/widgets/` and `presentation/widgets/sections/`.
- **Riverpod State Management**: Shared state, asynchronous operations, settings mutations, and business logic must reside in Riverpod providers (`StateNotifierProvider`, `AsyncNotifierProvider`, `Provider`).
- **Ephemerality Rule**: `setState` is strictly forbidden for business logic or shared state and is reserved exclusively for local ephemeral UI concerns (e.g., animation ticker controllers, local text editing focus).
- **Code Hygiene**: Maintain zero dead code, zero unreferenced imports, zero unused fields, and continuous clean passes under `flutter analyze --no-pub`.

---

## 3. Code Patterns: Banned vs. Required

### Anti-Pattern (BANNED):
```dart
// ❌ REJECTED: Hardcoded color, hardcoded padding, raw TextStyle, custom container button, setState for business logic
class _BadViewState extends State<BadView> {
  bool isTurbo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFF1E1E1E),
      child: GestureDetector(
        onTap: () => setState(() => isTurbo = !isTurbo),
        child: const Text(
          'Launch Game',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

### Required Pattern (APPROVED):
```dart
// ✅ APPROVED: Token spacing, theme-driven colors, context typography, native component, Riverpod consumer
class GoodView extends ConsumerWidget {
  const GoodView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final isTurbo = ref.watch(gameTurboSettingsProvider).inGameShortcuts;

    return Padding(
      padding: SpacingTokens.cardInsets,
      child: OwlGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Launch Game',
              style: TypographyTokens.titleSmallOf(context).copyWith(
                color: colors.textPrimary,
              ),
            ),
            SpacingTokens.gapV12,
            OwlButton(
              label: 'Start Session',
              icon: LucideIcons.play,
              isPrimary: isTurbo,
              onPressed: () {
                ref.read(gameTurboSettingsProvider.notifier).toggleShortcuts();
              },
            ),
          ],
        ),
      ),
    );
  }
}
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
| `pill` / `pillBadge` / `borderPill` | `999.0` | Rounded badges, timer pills, status tags |

---

## 5. Typography Scale & Material 3 Mappings

Font family: **Outfit** (`TypographyTokens.uiFontFamily`)

| M3 Text Role (`Theme.of(context).textTheme`) | Design System Token | Size / Weight / Spacing | Target Usage |
|:---|:---|:---|:---|
| `displayLarge` | `displayTimerLarge` | `36sp / w800 / -0.8px` | Hero game clocks, major countdowns |
| `displayMedium` | `displayTimer` | `28sp / w700 / -0.5px` | Objective timers, respawn meters |
| `displaySmall` | `displayTimerSmall` | `18sp / w700 / -0.2px` | Compact HUD timers, overlay telemetry |
| `headlineMedium` | `headline` / `headlineOf(context)` | `20sp / w600 / -0.5px` | Screen titles, console major sections |
| `titleMedium` | `titleMedium` | `16sp / w500 / -0.2px` | Card headers, modal headlines |
| `titleSmall` | `titleSmall` / `titleSmallOf(context)` | `14sp / w600 / -0.1px` | Sub-headers, telemetry labels |
| `bodyLarge` | `bodyLarge` | `16sp / w400 / 0.0px` | Primary narrative text, descriptions |
| `bodyMedium` | `bodyMedium` | `14sp / w400 / 0.0px` | Standard UI body, form field labels |
| `bodySmall` | `bodySmall` / `bodySmallOf(context)` | `12sp / w400 / 0.1px` | Secondary descriptors, footnotes |
| `labelLarge` | `buttonText` / `buttonTextOf(context)` | `14sp / w600 / 0.5px` | Buttons, action sheet items |
| `labelMedium` | `tacticalLabel` | `11sp / w700 / 1.2px` | Tactical status indicators, chips |
| `labelSmall` | `tacticalBadge` / `tacticalBadgeOf(context)` | `10sp / w700 / 1.0px` | Micro telemetry badges, kill trackers |

---

## 6. Color Scheme & Semantic Tokens

All screens resolve colors dynamically through `ColorTokens.of(context)` or `Theme.of(context).colorScheme`:

```dart
final colors = ColorTokens.of(context);
```

- **Surfaces & Backgrounds**:
  - `colors.background` (Root canvas)
  - `colors.surfaceCard` (Standard card surface)
  - `colors.surfaceElevated` (Elevated tiles)
  - `colors.surfaceGlass` (Glassmorphic containers)
  - `colors.consoleBase` (Deep cockpit console background)
  - `colors.settingsBase`, `colors.settingsPanel`, `colors.settingsCard` (Settings views)
- **Borders & Outlines**:
  - `colors.borderGlass` (Subtle 10% white / dark hairline border)
  - `colors.borderGlassStrong` (Emphasized border)
  - `colors.borderGlow` (Cyan/Neon glow border)
- **Status & Telemetry Accents**:
  - `colors.turboBlue`, `colors.turboBlueLight` (Flagship Game Turbo blue accents)
  - `colors.emeraldLive` (Live session status, 60+ FPS, good Wi-Fi)
  - `colors.badgeYellow`, `colors.tacticalAmber` (Objective warnings, medium battery)
  - `colors.telemetryCritical`, `colors.alertCrimson` (Thermal throttle, low battery, FPS drops)
  - `colors.turboCyan`, `colors.accentPurple` (Tactical AI coach modes, voice effects)
- **Text & Contrast**:
  - `colors.textPrimary` (High-contrast title text)
  - `colors.textSecondary` (Body copy, subheads)
  - `colors.textMuted` (Micro labels, footnotes)
  - `colors.isLight` / `colors.isDark` (Theme identification flags)

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
