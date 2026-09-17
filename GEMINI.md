# Owl Flutter UI Developer Rules & Constraints

**Role:** Expert Flutter UI Developer & Architecture Specialist.  
**Objective:** Generate highly maintainable, responsive Flutter UI code that strictly adheres to the established design system, Riverpod state patterns, and modular architecture.

---

## ABSOLUTE CONSTRAINTS (DO NOT VIOLATE)

### 1. No Hardcoded Values:
- **NEVER** use raw hex codes (e.g., `Color(0xFF...)`, `Color(0x...)`).
- **NEVER** use raw numeric double values for padding, margins, or spacers (e.g., `padding: EdgeInsets.all(16)`, `SizedBox(height: 12)`).
- **NEVER** declare raw text styles (e.g., `TextStyle(fontSize: 14)`).

### 2. Strict Theme Usage & ColorTokens Facade:
- **ALL** colors must be accessed dynamically via `ColorTokens.of(context)` or explicit context extensions:
  - `final colors = ColorTokens.of(context);` (Preferred — resolves active `OwlColors` reacting to Light/Dark mode)
  - `Theme.of(context).colorScheme` / `context.colorScheme`
  - `Theme.of(context).extension<OwlColors>()!` / `context.owlColors`

### 3. Typography & Context Resolvers:
- Map all text to Material 3 text styles or context-aware `TypographyTokens`:
  - Material 3 scale: `displayLarge`, `headlineMedium`, `titleMedium`, `titleSmall`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelSmall`
  - Theme-aware token helpers:
    - `TypographyTokens.headlineOf(context)`
    - `TypographyTokens.titleSmallOf(context)`
    - `TypographyTokens.bodySmallOf(context)`
    - `TypographyTokens.tacticalBadgeOf(context)`
    - `TypographyTokens.buttonTextOf(context)`
    - `TypographyTokens.statusMicroOf(context)`
    - `TypographyTokens.settingsRowTitleOf(context)`
    - `TypographyTokens.settingsRowDescOf(context)`
    - `TypographyTokens.dialogTitleOf(context)`
    - `TypographyTokens.keyInputOf(context)`
- **NEVER** define `TextStyle()` from scratch. Use `.copyWith()` strictly to adjust font weight or tint when context requires.

### 4. Spacing, Insets & Geometry Tokens:
- Use predefined design system tokens for all `Padding`, `Margin`, `SizedBox`, and border radii:
  - Spacing scalars: `AppSpacing.md`, `SpacingTokens.md`, `AppSizes.p16` (4, 8, 12, 16, 24, 32, 48)
  - Spacers: `SpacingTokens.gapMd`, `SpacingTokens.gapH16`, `SpacingTokens.gapV12`, `AppSpacing.gapH8`, `AppSpacing.gapV12`
  - Predefined insets: `SpacingTokens.cardInsets`, `SpacingTokens.screenInsets`, `SpacingTokens.buttonInsets`, `SpacingTokens.pillInsets`
  - Border radii: `RadiusTokens.card`, `RadiusTokens.button`, `RadiusTokens.borderMd`, `RadiusTokens.borderPill`, `RadiusTokens.borderXl`

### 5. Adaptive Viewport Responsiveness:
- Do not assume fixed phone dimensions (e.g., 360px portrait).
- Support responsive viewport shifts between phone portrait/landscape, foldable screens, tablet consoles, and split-screen HUD windows:
  - Use `LayoutBuilder` for container-adaptive layout branching.
  - Use `MediaQuery.sizeOf(context)` for multi-column grids and orientation breakpoints.
  - Wrap flexing elements in `Expanded`, `Flexible`, `ConstrainedBox`, or `FittedBox` to prevent pixel overflows.

### 6. Component Reuse & Canonical Widget Catalog:
- Default to existing `owl_design` widgets or theme-inheriting standard Material 3 widgets (`FilledButton`, `ElevatedButton`, `Card`):
  - **Cards**: `OwlGlassCard`, `OwlAtmosphericBackground`
  - **Buttons**: `OwlButton`, `OwlIconButton`
  - **Badges**: `OwlBadge`, `OwlTimerBadge`, `OwlTacticalPill`
  - **Indicators**: `OwlCooldownRing`, `OwlStatusDot`
  - **Inputs & Switches**: `OwlTextField`, `MiuiSwitch`, `OemSegmentedChips`
  - **Overlays**: `OwlActionSheet`
- Avoid building ad-hoc `Container` + `GestureDetector` constructs unless implementing bespoke low-level HUD telemetry graphics.

### 7. File Modularization (<200 LOC Soft Cap & SRP):
- Keep all files focused and adhere strictly to the Single Responsibility Principle.
- Target a soft cap of **< 200 lines per file**.
- When screens grow beyond 200 lines:
  - Extract subcomponents into `lib/features/<feature>/presentation/widgets/`.
  - Extract distinct functional panels into `lib/features/<feature>/presentation/widgets/sections/`.
  - Separate data/security management into `data/` services and state into dedicated providers.

### 8. Riverpod State Management & Ephemerality Rule:
- All business logic, asynchronous data loading, shared settings, and application state must reside in Riverpod providers (`StateNotifierProvider`, `AsyncNotifierProvider`, `Provider`).
- Screens and components should extend `ConsumerWidget` or `ConsumerStatefulWidget`.
- **`setState` is strictly forbidden for business logic**. Limit `setState` exclusively to local ephemeral presentation states (e.g., animation controllers, local ticker loops, local text input focus).

### 9. Code Hygiene & Zero Dead Code:
- Zero unused imports, zero unused fields, and zero orphaned models.
- Always verify changes with `flutter analyze --no-pub` to ensure 0 errors, 0 warnings, and 0 lints.

### 10. Build Configuration Protection:
- **NEVER** edit build configs (`pubspec.yaml`, `build.gradle.kts`, `AndroidManifest.xml`) or asset manifests unless explicitly requested.

---

## CODE PATTERN EXAMPLES

### DO NOT DO THIS (BANNED):

```dart
// ❌ REJECTED: Hardcoded color, hardcoded padding, raw TextStyle, custom button, setState for business logic
class _BadState extends State<BadWidget> {
  bool _turboActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFF1E1E1E),
      child: GestureDetector(
        onTap: () => setState(() => _turboActive = !_turboActive),
        child: const Text(
          'Turbo Mode',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
```

### DO THIS (REQUIRED):

```dart
// ✅ APPROVED: ColorTokens facade, token spacing, theme typography, native component, Riverpod state
class GoodWidget extends ConsumerWidget {
  const GoodWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final isTurbo = ref.watch(gameTurboSettingsProvider).inGameShortcuts;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: RadiusTokens.card,
        border: Border.all(color: colors.borderGlass),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Turbo Mode',
            style: TypographyTokens.titleSmallOf(context).copyWith(
              color: colors.textPrimary,
            ),
          ),
          MiuiSwitch(
            value: isTurbo,
            onChanged: (val) {
              ref.read(gameTurboSettingsProvider.notifier).toggleShortcuts();
            },
          ),
        ],
      ),
    );
  }
}
```

---

## WORKFLOW GUIDELINES

1. **Pre-Flight**:
   - Confirm target layout requirements and check existing widgets in `packages/owl_design/lib/widgets/`.
   - Verify token references in `packages/owl_design/lib/theme/tokens/` (`color_tokens.dart`, `spacing_tokens.dart`, `typography_tokens.dart`, `radius_tokens.dart`).

2. **Modular Decomposition**:
   - Plan component breakdown before writing code. Aim for <200 lines per file.
   - Place child widgets in `widgets/` and section panes in `widgets/sections/`.

3. **Post-Implementation Quality Gate**:
   - Run `flutter analyze --no-pub` to confirm 0 errors, 0 warnings, and 0 lints.
   - Run `flutter test` on affected test suites to ensure 100% green pass rate.
