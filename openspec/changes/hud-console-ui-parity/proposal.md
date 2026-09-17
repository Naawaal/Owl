## Why

The Flutter In-Game HUD (`TacticalBattlefieldHud`) does not match the Game Space Console screen: different top-bar chrome, a simplified hero-only body, and a TURBO pill edge handle instead of Xiaomi Game Turbo’s vertical side rail with slide-to-open. Users expect the same Console UI/UX in the HUD companion, and a familiar edge-slide gesture to open Game Turbo tools.

## What Changes

- **Console 1:1 HUD chrome**: Align `TacticalBattlefieldHud` top status bar with `GameSpaceConsoleScreen` (battery, CPU, FPS badges; center TURBO/BALANCED pill; plain right-side icons with back chevron instead of add).
- **Console 1:1 HUD layout**: Port the Console body into the HUD — left game sidebar, cinematic center stage, right Play wing, bottom GPU trapezoid tab.
- **Shared top bar widget**: Extract a reusable top status bar used by both Console and HUD to prevent future drift.
- **Xiaomi-style edge open**: Replace the floating TURBO FPS pill handle with a thin vertical edge rail; slide inward to open `GameturboFloatingToolbox`; respect `shortcutEdgePosition` / `inGameShortcuts`.
- **Toolbox anchoring**: Match Console toolbox animation; anchor near the active edge rail.

## Capabilities

### New Capabilities
- `game-space-hud-parity`: Flutter In-Game HUD matches Game Space Console UI/UX 1:1, plus Xiaomi-style vertical edge rail with inward slide to open the Game Turbo toolbox.

### Modified Capabilities
<!-- None -->

## Impact

- `lib/features/overlay/presentation/tactical_battlefield_hud.dart`: Full layout rewrite, edge rail + slide gesture, remove pill handle.
- `lib/features/game_profiles/presentation/game_space_console_screen.dart`: Consume shared top status bar.
- `lib/features/game_profiles/presentation/widgets/game_space_top_status_bar.dart`: New shared widget (to be added).
- `lib/features/overlay/presentation/gameturbo_floating_toolbox.dart`: Unchanged visually; HUD wiring/anchor only.
- Native Kotlin overlay is out of scope for this change.
