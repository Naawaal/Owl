## Why

The current Flutter implementation uses standard Material 3 default styling which does not match the finalized, approved HTML prototype. To transition from prototype to production, we must establish a cohesive "Minimal Titanium & Slate" design system followed by modular, reusable Flutter widgets before refactoring screen layouts.

## What Changes

- Establish an enterprise Flutter design system architecture in `lib/theme/` featuring the Minimal Titanium & Slate palette (Frosted Dark Graphite, Razor Silver, Electric Royal Indigo) for both Dark and Light themes.
- Define design tokens for surface elevations, micro-borders, blur/glassmorphism, typography scales (Plus Jakarta Sans / JetBrains Mono), and glow accents.
- Implement reusable, production-ready Flutter widgets in `lib/widgets/`:
  - `HeroDeckCard`: Horizontal snap card with game badge pills and launch action.
  - `OwlButton`: Primary glowing action button and secondary elevated button.
  - `OwlSwitch`: Tactile custom toggle switch.
  - `OwlSlider`: Range slider for mod parameters (e.g. 1.0x - 4.0x raycast multipliers).
  - `FloatingBottomNav`: Floating pill dock with animated sliding selection indicator.
  - `OwlBottomSheet`: Sleek bottom drawer container for mod configuration and game selection.
  - `OwlToast`: Non-blocking floating status notification.

## Capabilities

### New Capabilities
- `titanium-design-system`: Core theme tokens, color definitions, typography styles, and dark/light ThemeData builders.
- `core-reusable-widgets`: High-polish reusable Flutter UI widgets matching the prototype component specifications.

### Modified Capabilities
<!-- No modified capabilities; openspec/specs is currently empty. -->

## Impact

- `lib/theme/`: New theme definitions (`app_colors.dart`, `app_typography.dart`, `app_theme.dart`).
- `lib/widgets/`: New modular widgets (`hero_deck_card.dart`, `owl_button.dart`, `owl_switch.dart`, `owl_slider.dart`, `floating_bottom_nav.dart`, `owl_bottom_sheet.dart`, `owl_toast.dart`).
- `lib/main.dart`: Theme configuration updated to bind `AppTheme.darkTheme` and `AppTheme.lightTheme`.
- No breaking changes to existing data repositories or launcher services.
