## 1. Root Governance & Documentation

- [x] 1.1 Create `DESIGN.md` in repository root documenting complete design system tokens, typography scales, spacing grid, component catalogue, and responsive layout guidelines
- [x] 1.2 Create `GEMINI.md` in repository root codifying absolute constraints, banned anti-patterns, required code patterns, and UI developer workflow

## 2. Design Token Bridge & Ergonomics

- [x] 2.1 Add `AppSpacing` alias and `AppSizes` token definitions in `packages/owl_design/lib/theme/tokens/spacing_tokens.dart`
- [x] 2.2 Add `colorScheme` and `textTheme` getters to `OwlThemeContextX` extension in `packages/owl_design/lib/theme/app_theme.dart`
- [x] 2.3 Verify `packages/owl_design/lib/owl_design.dart` barrel exports all tokens and aliases cleanly

## 3. Verification & Compliance

- [x] 3.1 Run `flutter analyze` across `packages/owl_design` and main app to ensure clean compilation
- [x] 3.2 Run `openspec validate --change flutter-design-system-rules` to confirm change integrity
