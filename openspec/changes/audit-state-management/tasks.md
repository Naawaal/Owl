## 1. Selective Subscription Scoping

- [x] 1.1 Apply `.select(...)` in `TacticalBattlefieldHud` for `shortcutEdgePosition` and `inGameShortcuts`
- [x] 1.2 Apply `.select(...)` in `GameSpaceTopStatusBar` for `performanceOptimization` and `targetFps`
- [x] 1.3 Apply `.select(...)` in `ToolboxQuickActionsGrid` for `guardianTacticalEngine`, `isEnabled`, and `isBoostActive`
- [x] 1.4 Apply `.select(...)` in `ToolboxTelemetryReactor` for `latencyMs` and `isBoostActive`

## 2. Redundant State & Lifecycle Cleanup

- [x] 2.1 Convert `GameSpaceConsoleScreen` to `ConsumerWidget` and remove unused `ConsumerStatefulWidget` wrapper
- [x] 2.2 Convert `GameCardCarousel` to `ConsumerWidget` and derive active hero index dynamically from `activeGame`
- [x] 2.3 Remove redundant `setState(() {});` invocation from `OverlayEntryPage._reloadPrefs()`
- [x] 2.4 Isolate 1-second countdown timer in `DesignSystemShowcaseView` with `ValueNotifier` leaf listeners

## 3. Verification & Static Quality Gates

- [x] 3.1 Run `flutter analyze --no-pub` to confirm 0 errors and 0 warnings
- [x] 3.2 Run test suite to verify no regressions in widget tree behavior and navigation
