## Why

State management across the Owl Flutter application has accumulated redundant `setState` calls, un-selected Riverpod provider subscriptions causing wide-scope rebuild cascades, and state hoisted to parent screens that causes entire pages to rebuild on ephemeral updates. Furthermore, high-frequency timers at the root of large views and `ConsumerStatefulWidget` instances with zero local state or desynchronized state introduce unnecessary overhead.

Auditing and optimizing state management will ensure the application adheres strictly to Owl's Riverpod state architecture, eliminates janky rebuilds, and keeps frame rates smooth.

## What Changes

- **Safe Direct Optimizations**:
  - **Eliminate Root Rebuild Cascades via Riverpod `.select(...)`**:
    - `TacticalBattlefieldHud`: Select only `shortcutEdgePosition` and `inGameShortcuts` from `gameTurboSettingsProvider` rather than watching the entire settings object.
    - `GameSpaceTopStatusBar`: Select only `performanceOptimization` from `gameTurboSettingsProvider`, and `activeGame?.targetFps` from `installedGamesProvider`.
    - `ToolboxQuickActionsGrid`: Select discrete booleans (`guardianTacticalEngine`, `dndState.isEnabled`, `wifiState.isBoostActive`, `voiceState.isActive`, `voiceState.currentPreset.name`) to prevent cross-toggle rebuilds.
    - `ToolboxTelemetryReactor`: Select only `latencyMs` from `wifiOptimizerProvider`.
  - **Convert Stateless `ConsumerStatefulWidget` to `ConsumerWidget`**:
    - `GameSpaceConsoleScreen`: Convert from `ConsumerStatefulWidget` to `ConsumerWidget` as it maintains no local state.
    - `GameCardCarousel`: Derive active hero index directly from `activeGame` and `deckGames` rather than maintaining a desynchronized `_activeHeroIndex` in `setState`.
  - **Prune Redundant `setState` in Lifecycle Hooks**:
    - `OverlayEntryPage`: Remove redundant `setState(() {})` in `_reloadPrefs()` where Riverpod's `reloadFromDisk()` already drives reactive updates.
  - **Isolate High-Frequency Timer Ticking**:
    - `DesignSystemShowcaseView`: Isolate the 1-second countdown ticker from the 1500+ line root widget so ticking does not trigger full-page rebuilds.

- **Proposed Architectural Refactor (Requires Review)**:
  - Extract API Key validation/test state from `AppSettingsTwoPaneScreen` into a dedicated Riverpod notifier (`apiKeyFormNotifierProvider`) to prevent whole-settings-screen rebuilds on every keystroke/validation event.

## Capabilities

### New Capabilities
- `state-management-audit`: Comprehensive state management audit, selector scoping, and elimination of unnecessary `setState` calls across the Owl workspace.

### Modified Capabilities

## Impact

- **Affected Code**:
  - `lib/features/overlay/presentation/tactical_battlefield_hud.dart`
  - `lib/features/overlay/presentation/widgets/toolbox_quick_actions_grid.dart`
  - `lib/features/overlay/presentation/widgets/toolbox_telemetry_reactor.dart`
  - `lib/features/game_profiles/presentation/widgets/game_space_top_status_bar.dart`
  - `lib/features/game_profiles/presentation/game_space_console_screen.dart`
  - `lib/features/game_profiles/presentation/widgets/game_card_carousel.dart`
  - `lib/overlay_entry.dart`
  - `lib/features/showcase/presentation/design_system_showcase_view.dart`
  - `lib/features/settings/presentation/app_settings_two_pane_screen.dart`
- **APIs & Dependencies**: No external package additions. Built purely on existing Flutter & Riverpod 2.6.1 primitives.
- **Breaking Changes**: None. All public interfaces, widget signatures, and reactive behaviors remain 100% backward compatible.
