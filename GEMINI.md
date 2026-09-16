# Owl Flutter UI Developer Rules & Constraints

**Role:** Expert Flutter UI Developer.  
**Objective:** Generate highly maintainable, responsive Flutter UI code that strictly adheres to the established design system.

---

## ABSOLUTE CONSTRAINTS (DO NOT VIOLATE)

1. **No Hardcoded Values:**
   - **NEVER** use raw hex codes (e.g., `Color(0xFF...)`).
   - **NEVER** use raw double values for padding/margins (e.g., `padding: EdgeInsets.all(16)`).
   - **NEVER** declare raw text styles (e.g., `TextStyle(...)`).

2. **Strict Theme Usage:**
   - **ALL** colors and typography must be accessed via `Theme.of(context)` or explicit context extensions:
     - `context.colorScheme` / `Theme.of(context).colorScheme`
     - `context.textTheme` / `Theme.of(context).textTheme`
     - `context.owlColors` / `Theme.of(context).extension<OwlColors>()!`
     - `context.owlTheme` / `Theme.of(context).extension<OwlThemeExtension>()!`

3. **Typography:**
   - Map all text to Material 3 text styles (e.g., `displayLarge`, `headlineMedium`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelLarge`, `labelSmall`).
   - **NEVER** define `TextStyle()` from scratch.
   - Only use `copyWith()` on theme styles to alter font weight or tint if absolutely necessary.

4. **Spacing & Tokens:**
   - Use the project's predefined spacing tokens and constants for all `Padding`, `Margin`, `SizedBox`, and border radii:
     - `SpacingTokens` / `AppSpacing` (e.g., `AppSpacing.sm`, `SpacingTokens.md`, `SpacingTokens.cardInsets`)
     - `AppSizes` (e.g., `AppSizes.p8`, `AppSizes.p16`, `AppSizes.p24`)
     - `RadiusTokens` (e.g., `RadiusTokens.card`, `RadiusTokens.button`, `RadiusTokens.pillBadge`)

5. **Responsiveness:**
   - Do not assume a mobile screen width.
   - Use `LayoutBuilder`, `MediaQuery`, or project responsive wrappers to handle layout shifts between mobile portrait/landscape, tablet, and desktop HUD windows.
   - Ensure components expand or shrink gracefully without pixel overflows.

6. **Component Reuse:**
   - Default to standard Material 3 widgets (`FilledButton`, `ElevatedButton`, `Card`) or design system components (`OwlButton`, `OwlGlassCard`, `OwlTacticalPill`) which already inherit theme data.
   - Avoid building custom `Container` setups with `GestureDetector` unless highly specific low-level HUD graphics are requested.

---

## CODE PATTERN EXAMPLES

### DO NOT DO THIS (BANNED):

```dart
Container(
  padding: const EdgeInsets.all(16.0),
  color: const Color(0xFF1E1E1E),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
  ),
)
```

### DO THIS (REQUIRED):

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  color: Theme.of(context).colorScheme.surface, // Or context.colorScheme.surface
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

---

## WORKFLOW GUIDELINES

- Before writing UI code, confirm you understand the target layout.
- Verify `packages/owl_design/lib/theme/app_theme.dart`, `packages/owl_design/lib/theme/tokens/spacing_tokens.dart`, and `DESIGN.md` in root if they are not already in your context window.
- When creating buttons, cards, or dialogs, verify whether an existing widget in `packages/owl_design/lib/widgets/` already provides the needed capability.
