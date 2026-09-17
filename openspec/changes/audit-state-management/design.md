## Context

The Owl gaming companion employs Riverpod 2.6.1 for global state and `owl_design` tokens for UI. An audit of the workspace revealed:
- Several large orchestrator widgets (`TacticalBattlefieldHud`, `GameSpaceTopStatusBar`, `ToolboxQuickActionsGrid`, `ToolboxTelemetryReactor`) subscribe to root providers without `.select(...)`, triggering rebuild cascades across entire screens when un-related settings change.
- `GameCardCarousel` and `GameSpaceConsoleScreen` were written as `ConsumerStatefulWidget`s maintaining state that was either nonexistent or out-of-sync with Riverpod.
- `OverlayEntryPage` called `setState(() {})` inside `_reloadPrefs()` where Riverpod already notifies listeners.
- `DesignSystemShowcaseView` runs a 1-second `Timer.periodic` calling `setState` at the root of a 1,525-line widget tree.
- `AppSettingsTwoPaneScreen` manages API key input, latency testing, and validation state in root state instead of a scoped Riverpod notifier.

See `proposal.md` for background and `specs/state-management-audit/spec.md` for requirement contracts.

## Goals / Non-Goals

**Goals:**
- Implement fine-grained selector scoping via `ref.watch(provider.select(...))` in rebuild-heavy HUD and status bar widgets.
- Remove unnecessary `setState` calls and convert static/derived stateful widgets to `ConsumerWidget`.
- Isolate the 1-second showcase countdown loop to a dedicated leaf component.
- Propose the extraction of API key form state into a dedicated Riverpod notifier for user review.
- Maintain 100% backward compatibility and 0 analyzer issues.

**Non-Goals:**
- Rewriting working business domain services or platform channels.
- Arbitrary package dependency additions.
- Prematurely refactoring complex settings screens without explicit user approval.

## Decisions

### 1. Fine-Grained Riverpod Selectors vs Entire Object Subscriptions
- **Decision**: Replace `ref.watch(gameTurboSettingsProvider)` with `ref.watch(gameTurboSettingsProvider.select((s) => ...))` where widgets only depend on a small subset of settings (e.g. edge position, inGameShortcuts, or performanceOptimization).
- **Rationale**: When any single toggle in the floating toolbox or settings is modified, unrelated widgets subscribing to the whole object re-render. Selectors restrict rebuild triggers strictly to value changes of the selected fields.
- **Alternatives Considered**: Splitting `GameTurboSettings` into 10 smaller state notifiers. Rejected to prevent disrupting the unified JSON serialization and persistence layer in `GameTurboSettingsNotifier`.

### 2. Derive Active Hero Index in `GameCardCarousel`
- **Decision**: Convert `GameCardCarousel` from `ConsumerStatefulWidget` to `ConsumerWidget`. Compute `activeIndex` dynamically:
  ```dart
  final activeIndex = (activeGame != null && deckGames.contains(activeGame))
      ? deckGames.indexOf(activeGame)
      : 0;
  ```
- **Rationale**: The previous local `_activeHeroIndex` desynchronized whenever games were selected via the sidebar dock or initialized from disk, and redundant `setState` calls conflicted with parent re-renders from `selectGame`.
- **Alternatives Considered**: Listening to `installedGamesProvider` inside `didUpdateWidget`. Rejected because calculating derived state in `build` is idiomatic in Flutter and eliminates all synchronization state.

### 3. High-Frequency Timer Isolation
- **Decision**: Wrap the countdown badge in `DesignSystemShowcaseView` into a dedicated leaf `StatefulWidget` (`_ShowcaseTickingCountdownBadge`) so that `setState` calls every second are restricted exclusively to that micro-badge.
- **Rationale**: Prevents re-rendering 1,500+ lines of complex design system widgets every second.

### 4. Separate API Key Form State (Gated Proposal)
- **Decision**: Present the extraction of API key testing state (`_keyController`, `_keyValidationError`, `_keyTestResult`, `_isValidatingKey`, `_obscureKey`) into `apiKeyFormNotifierProvider` as an opt-in architectural refactor requiring explicit user approval.
- **Rationale**: Minimizes risk in this turn while offering a clean long-term architecture.

## Risks / Trade-offs

- **[Risk] Selector equality checking overhead** → Dart primitive values (`bool`, `int`, `String`) and records compare by value in O(1); selector evaluation is vastly faster than re-executing widget build trees.
- **[Risk] Carousel touch gestures triggering selection** → Gesture handlers in `GameCardCarousel` continue calling `ref.read(installedGamesProvider.notifier).selectGame(...)`, preserving all tactile haptics and navigation.
