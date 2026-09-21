## Context

See `proposal.md` for motivation. The Flutter application currently uses standard Material 3 theme defaults in `lib/main.dart` and rudimentary cards in `lib/widgets/game_card.dart`. The prototype has locked the Minimal Titanium & Slate visual identity (colors, radiuses, shadows, transitions, custom controls, floating bottom nav).

## Goals / Non-Goals

**Goals:**
- Implement the design tokens as reusable static const classes (`AppColors`, `AppTypography`, `AppRadii`, `AppShadows`).
- Configure `AppTheme.darkTheme` and `AppTheme.lightTheme` with `ThemeExtension` or `ColorScheme` mappings for seamless brightness switching.
- Build pure, self-contained widgets in `lib/widgets/` matching prototype layout parameters:
  - `HeroDeckCard`
  - `OwlButton`
  - `OwlSwitch`
  - `OwlSlider`
  - `FloatingBottomNav`
  - `OwlBottomSheet`
  - `OwlToast`
- Verify widgets via unit and widget tests before updating full screen layouts.

**Non-Goals:**
- Full screen layout refactoring (HomeScreen, GameLibraryScreen, PluginsCatalogScreen) will be handled in subsequent changes using these widgets.
- Modifying backend repository logic, persistence, or android intent launching.

## Decisions

### Decision 1: Dedicated Custom Theme Extensions over raw Material Colors
- **Rationale**: Standard Flutter `ColorScheme` does not have semantic slots for frosted glass backgrounds, telemetry pills, or glow borders. By using custom `ThemeExtension<OwlThemeTokens>` alongside standard `ColorScheme`, widgets have compile-time safe access to titanium tokens.
- **Alternatives Considered**: Using global singleton constants directly. Rejected because it breaks Flutter Theme inheritance and context-aware dark/light theme switching.

### Decision 2: Self-Contained Custom Widget Primitives
- **Rationale**: Flutter's native `Switch` and `Slider` have platform-specific thumb behaviors and padding that clash with the clean slate prototype styling. Custom interactive widgets built using `GestureDetector`, `AnimatedContainer`, and `CustomPainter` guarantee pixel-fidelity to the prototype.
- **Alternatives Considered**: Modifying global `SwitchThemeData` and `SliderThemeData`. Rejected because Material 3 thumb padding and splash ripples cannot achieve the exact pill slider look without invasive overrides.

### Decision 3: OverlayEntry-based Toast Notification
- **Rationale**: Using `ScaffoldMessenger.showSnackBar` restricts toast positioning and blocks bottom navigation interactions. A custom `OverlayEntry` float provides non-blocking, centered pill toasts that match the prototype behavior.

## Risks / Trade-offs

- **[Font Dependency]** Google Fonts runtime fetch might fail offline → Mitigation: Use standard system fallback font stacks (`Plus Jakarta Sans` with fallback to `sans-serif` and `JetBrains Mono` with fallback to `monospace`).
- **[Widget State Complexity]** Slider and switch gesture hit testing → Mitigation: Implement clear `ValueChanged<T>` callbacks and verify with Flutter widget tests simulating drag and tap gestures.
