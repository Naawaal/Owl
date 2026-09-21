## 1. Titanium Design System Foundation

- [x] 1.1 Create `lib/theme/app_colors.dart` with Titanium and Slate dark color tokens, subtle borders, and electric indigo accents
- [x] 1.2 Create `lib/theme/app_typography.dart` with font styling, letter-spacing hierarchy, and semantic text styles
- [x] 1.3 Create `lib/theme/owl_theme_extension.dart` defining custom design tokens (borders, glass fills, glows, card gradients)
- [x] 1.4 Implement `lib/theme/app_theme.dart` assembling `ThemeData` with dark/light palettes and binding `OwlThemeExtension`

## 2. Core Interactive Controls & Primitives

- [x] 2.1 Implement `lib/widgets/owl_button.dart` supporting primary, secondary glass, outline, and ghost variants with tap scale animation
- [x] 2.2 Implement `lib/widgets/owl_switch.dart` featuring tactile thumb movement and electric blue active glow
- [x] 2.3 Implement `lib/widgets/owl_slider.dart` with custom slider track and rounded thumb styling

## 3. Structural & Overlay Widgets

- [x] 3.1 Implement `lib/widgets/hero_deck_card.dart` with blurred backdrop artwork, status badges, and quick-action trigger
- [x] 3.2 Implement `lib/widgets/floating_bottom_nav.dart` with frosted pill blur effect, navigation icons, and active indicator
- [x] 3.3 Implement `lib/widgets/owl_bottom_sheet.dart` modal surface with drag handle and titanium styling
- [x] 3.4 Implement `lib/widgets/owl_toast.dart` top overlay HUD notification system with auto-dismiss

## 4. Verification & Testing

- [x] 4.1 Create unit and widget tests for `OwlButton`, `OwlSwitch`, `OwlSlider`, and `HeroDeckCard`
- [x] 4.2 Verify theme switching and token resolution across dark and light modes
- [x] 4.3 Run `flutter analyze` and `flutter test` to ensure complete static analysis compliance
