## Context

The repository contains a dedicated design system package (`packages/owl_design`) with comprehensive 3-tier tokens (`SpacingTokens`, `RadiusTokens`, `ColorTokens`/`OwlColors`, `TypographyTokens`, `AppTheme`). However, historical UI implementations contained ad-hoc hex values, arbitrary numeric paddings, and raw `TextStyle` declarations. To establish permanent consistency across human contributors and AI agents, explicit constraints, root documentation (`DESIGN.md`), and rule enforcement (`GEMINI.md`) must be codified alongside ergonomic helper aliases.

## Goals / Non-Goals

**Goals:**
- Provide complete root documentation (`DESIGN.md`) specifying design tokens, typography scales, spacing units, and responsive principles.
- Configure permanent root agent instructions (`GEMINI.md`) establishing the six absolute constraints (no hardcoded colors/paddings/styles, strict theme usage, Material 3 typography, tokenized spacing, responsive viewports, and component reuse).
- Provide ergonomic token aliases in `packages/owl_design` (`AppSpacing`, `AppSizes`) and context extensions (`context.colorScheme`, `context.textTheme` in `OwlThemeContextX`).
- Establish standard responsive layout patterns (`LayoutBuilder`, adaptive column/grid wrappers).

**Non-Goals:**
- Rewriting low-level game HUD shaders or canvas rendering loops in `packages/owl_design/build/unit_test_assets/shaders`.
- Modifying network or storage business logic.

## Decisions

### Decision 1: Token Bridge Aliases (`AppSpacing` and `AppSizes`)
- **Rationale**: While `SpacingTokens` is the existing class in `packages/owl_design/lib/theme/tokens/spacing_tokens.dart`, standard Flutter developer patterns frequently look for `AppSpacing.md` and `AppSizes.p16`. We declare `typedef AppSpacing = SpacingTokens` and define `AppSizes` with standard `p4`, `p8`, `p12`, `p16`, `p24`, `p32`, `p48` constants referencing `SpacingTokens`.
- **Alternatives Considered**: Renaming `SpacingTokens` to `AppSpacing` (rejected: would break existing call sites throughout `packages/owl_design`).

### Decision 2: Ergonomic BuildContext Extensions
- **Rationale**: `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` can be verbose in deeply nested build trees. Extending `OwlThemeContextX` with `colorScheme` and `textTheme` getters ensures zero-friction compliance with strict theme rules:
  ```dart
  extension OwlThemeContextX on BuildContext {
    ThemeData get theme => Theme.of(this);
    ColorScheme get colorScheme => Theme.of(this).colorScheme;
    TextTheme get textTheme => Theme.of(this).textTheme;
    OwlThemeExtension get owlTheme => Theme.of(this).extension<OwlThemeExtension>()!;
    OwlColors get owlColors => ColorTokens.of(this);
  }
  ```
- **Alternatives Considered**: Requiring explicit `Theme.of(context)` everywhere without helpers (rejected: leads to developer fatigue and shortcuts).

### Decision 3: Root `DESIGN.md` as Repository Source of Truth
- **Rationale**: `DESIGN.md` at the project root provides an immediate, discoverable design system reference for developers, listing color ramps, typography pairings, spacing tokens, and component guidelines.
- **Alternatives Considered**: Storing design docs only inside `packages/owl_design/README.md` (rejected: root files are prioritized by developers and IDE agents).

### Decision 4: Root `GEMINI.md` as Immutable Guardrail
- **Rationale**: Antigravity and Gemini automatically discover `GEMINI.md` at the project root as project instructions. Embedding the absolute UI constraints and banned vs. required patterns into `GEMINI.md` ensures consistent adherence across all future agent prompts and edits.

### Decision 5: Responsive Layout Strategy
- **Rationale**: The MOBA companion app operates across phone screens in portrait/landscape, foldable displays, desktop debugging windows, and multi-window split views. UI screens must employ `LayoutBuilder` with adaptive column/row switches or `SingleChildScrollView` + `ConstrainedBox` bounds to prevent pixel overflow errors.

## Risks / Trade-offs

- **[Risk]** Existing screens still contain legacy hardcoded values.
  → **Mitigation**: The governance files define the standard; subsequent screen migration passes systematically update existing widgets to comply.
- **[Risk]** Developers might use custom `Container` + `GestureDetector` instead of accessible M3 components.
  → **Mitigation**: Explicitly ban unstyled custom buttons in `GEMINI.md` and document `OwlButton`, `FilledButton`, and `ElevatedButton` alternatives.

## Migration Plan

1. Generate root `DESIGN.md` and `GEMINI.md`.
2. Update `packages/owl_design` spacing tokens and context extensions to export `AppSpacing`, `AppSizes`, `context.colorScheme`, and `context.textTheme`.
3. Validate with `flutter analyze` and `openspec validate`.
