## 1. Shared Top Status Bar

- [x] 1.1 Extract `GameSpaceTopStatusBar` into `lib/features/game_profiles/presentation/widgets/game_space_top_status_bar.dart` with callbacks for pill toggle, leading action, settings, and `leadingIcon`
- [x] 1.2 Refactor `GameSpaceConsoleScreen` to use `GameSpaceTopStatusBar` with `Icons.add` leading action
- [x] 1.3 Wire `TacticalBattlefieldHud` to `GameSpaceTopStatusBar` with `Icons.chevron_left` that `maybePop()`s back to Console

## 2. HUD Layout Parity

- [x] 2.1 Rewrite `TacticalBattlefieldHud` body to mirror Console layout: left sidebar, cinematic center stage, Play wing, bottom GPU tab using `installedGamesProvider`
- [x] 2.2 Align toolbox animation timings/offsets with Console (`240ms`, slide `-0.06`) and preserve `autoOpenToolbox` / `matchElapsedSeconds`
- [x] 2.3 Remove simplified hero card, `Game Space` pill nav, and circled settings chrome that diverge from Console

## 3. Xiaomi Edge Rail Gesture

- [x] 3.1 Replace `_buildEdgeHandle` with a thin vertical edge rail (~3–4dp × ~48–56dp) placed from `shortcutEdgePosition` when `inGameShortcuts` is enabled
- [x] 3.2 Implement inward horizontal drag with ~40–60dp threshold to open `GameturboFloatingToolbox`; hide/disable rail while toolbox is open
- [x] 3.3 Anchor toolbox near the active edge (left: `top: 48, left: 28`; right: mirrored `top/right`) and keep center pill as secondary toggle

## 4. Verification

- [x] 4.1 Manually verify HUD top bar and main stage match Console in light and dark themes
- [x] 4.2 Manually verify left/right edge slide opens toolbox, shortcuts-off hides rail, and tap-outside / pill close still work
- [x] 4.3 Run `flutter analyze --no-fatal-warnings` on touched Dart files and fix new issues
