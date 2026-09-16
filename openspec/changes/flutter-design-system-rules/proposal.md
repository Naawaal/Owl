## Why

The Flutter codebase requires strict, systematic adherence to the design system, Material 3 typography, dynamic theme switching, responsive viewport adaptability, and component reuse. Without formalized constraints, UI code risks accumulating hardcoded hex codes, arbitrary double paddings, unscaled text styles, and rigid mobile-only assumptions that break across multi-window HUD and tablet/desktop layouts. Establishing explicit rules, root design documentation (`DESIGN.md`), and IDE/agent instructions (`GEMINI.md`) guarantees that all generated and authored Flutter code is strictly theme-driven, responsive, and maintainable.

## What Changes

- Establish and enforce six absolute Flutter UI constraints across the repository:
  1. **No Hardcoded Values**: Total ban on raw hex codes (`Color(0xFF...)`), raw double values for padding/margins (`EdgeInsets.all(16)`), and raw `TextStyle()` declarations.
  2. **Strict Theme Usage**: Mandatory access for all colors and typography via `Theme.of(context)` or ergonomic extensions (`context.colorScheme`, `context.textTheme`, `context.owlColors`, `context.owlTheme`).
  3. **Material 3 Typography**: Strict mapping of all UI text to standard Material 3 text styles (`bodyLarge`, `titleMedium`, `labelSmall`, etc.) with `copyWith()` reserved exclusively for weight or tint adjustments.
  4. **Spacing & Tokens**: Mandatory utilization of token constants (`SpacingTokens`, `AppSpacing`, `AppSizes`, `RadiusTokens`) for all `Padding`, `Margin`, `SizedBox`, and border radii.
  5. **Responsiveness**: Responsive viewport handling via `LayoutBuilder`, `MediaQuery`, or adaptive breakpoints; zero assumption of fixed mobile widths.
  6. **Component Reuse**: Prioritize standard theme-inheriting widgets (`ElevatedButton`, `FilledButton`, `Card`, `OwlButton`, `OwlGlassCard`) over custom `Container` + `GestureDetector` constructs.
- Create root `DESIGN.md` documenting the full design system tokens, typography scales, spacing grid, component bindings, and responsive layout strategies.
- Create root `GEMINI.md` codifying these absolute constraints as permanent agent and developer rules.
- Enrich `packages/owl_design` with ergonomic aliases (`AppSpacing`, `AppSizes`) and context accessors (`context.colorScheme`, `context.textTheme`) to ensure complete compatibility with standard and project token conventions.

## Capabilities

### New Capabilities
- `flutter-design-system-standards`: Formal requirements, constraints, and validation criteria for all Flutter UI presentation code in the repository.

### Modified Capabilities
- None.

## Impact

- Affected files: `DESIGN.md`, `GEMINI.md`, `packages/owl_design/lib/theme/tokens/spacing_tokens.dart`, `packages/owl_design/lib/theme/app_theme.dart`, `packages/owl_design/lib/owl_design.dart`, and feature presentation widgets.
- Dependencies: Uses existing `owl_design`, `google_fonts`, and Flutter M3 foundation.
- Verification: `flutter analyze`, token verification in `packages/owl_design`, and OpenSpec validation.
