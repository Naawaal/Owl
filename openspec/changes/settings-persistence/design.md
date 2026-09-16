## Context

See `proposal.md` (Why) for motivation. Current state shaping this design:

- Two theme stores exist: `themeModeProvider` (`owl_theme_mode`, default `system`, read by `OwlApp` and the showcase) and `GameTurboSettings.themeMode` (JSON blob, default `dark`, written by App Settings, read by nobody). The App Settings theme selector is therefore a dead control.
- `GameTurboSettingsNotifier` calls `_syncPerformanceMode` in its constructor, invoking a native `MethodChannel` and `RealTimeFpsTracker` as a construction side effect. In widget tests this escapes as an unhandled async `MissingPluginException` (3 failing persistence tests).
- `_persist` and all load paths swallow errors with bare `catch (_) {}`; restart-time failures are invisible.
- The blob (`owl_game_turbo_settings_v2`) is unversioned; corrupt payloads silently reset to defaults.
- API keys (`SecureStorageService` + memory fallback) and the game deck (`GameDiscoveryService`) already persist correctly and are verified, not redesigned.

## Goals / Non-Goals

**Goals:**
- One theme store, one default, one key — theme choice applies and survives restart.
- Boot re-applies hardware state deterministically with zero construction side effects.
- Failures visible, schema versioned, full round-trip test coverage green.

**Non-Goals:**
- No new settings options, no settings UI redesign, no navigation changes.
- No change to secure-storage backends or encryption behavior.
- No fix for the pre-existing `resetOnError: true` keystore-wipe risk (flagged, not owned by this change).

## Decisions

### 0. Standalone theme provider wins; blob field retired

`themeModeProvider` becomes the canonical theme store: the App Settings theme selector writes through it, `OwlApp` keeps reading it, and `GameTurboSettings.themeMode` is removed from the model, serialization, equality, and tests. Default becomes `system` everywhere (the provider's existing default; the blob's `dark` default dies with the field).

Alternative considered: two-way sync between blob and provider. Rejected — two writers re-create the exact drift being fixed.

Alternative considered: keeping the blob field as canonical and rewiring the app to it. Rejected — the provider is already read by the app shell and showcase; migrating readers is larger churn than retiring one dead field.

### 1. Explicit boot re-apply step, never construction side effects

Native sync (`setPerformanceMode` channel call) and FPS-tracker targeting move into an explicit async `applyPersistedHardwareState()` invoked once after widget binding initialization (before first frame), guarded by platform checks. The notifier constructor becomes pure (load + assign). In tests the step is either skipped via the existing platform guards or driven through a mocked channel — no unhandled async errors either way.

Alternative considered: lazy sync on first toggle only. Rejected — cold boot would leave hardware in whatever state the OS defaulted to, violating the re-apply requirement.

### 2. Typed persist results surfaced to UI

`_persist` returns success/failure instead of `void`; failures surface as a snackbar/toast on the settings screen while the in-memory state still applies. Load-path fallbacks stay (defaults on corrupt payload) but log through the existing `AppObserver` channel instead of vanishing.

Alternative considered: throwing on persist failure. Rejected — a settings toggle must never crash the app because storage hiccuped.

### 3. Versioned settings envelope with forward migration

Blob format becomes `{'version': 3, 'settings': {...}}`. Unknown or unreadable versions fall back to defaults and schedule a clean rewrite. The old unversioned `v2` payload is accepted once and rewritten in the new envelope (implicit v2→v3 migration), so existing installs keep their settings.

Alternative considered: bumping the storage key and abandoning old payloads. Rejected — wipes every existing user's settings on update.

### 4. GPU screen joins the blob as one global profile (implementation discovery)

The GPU settings screen keeps all 13 options in local widget state — nothing persists today. They move into the settings blob as `gpu*` fields with the screen's current defaults, wired through new notifier setters; the screen becomes a `ConsumerStatefulWidget` reading provider state. One global profile, not per-game: matches current behavior (the screen already shows one shared state regardless of game title) at zero extra complexity.

Alternative considered: per-game GPU profiles keyed by package. Rejected — new behavior beyond "survive restart"; recommend as a follow-up.

## Risks / Trade-offs

- [Risk] Removing `themeMode` from the model breaks existing tests that assert it → Mitigation: update those assertions in the same change; the round-trip tests lock the new single-store behavior.
- [Risk] Native re-apply races first-frame render on slow devices → Mitigation: fire before `runApp` returns control; worst case the toggle state still applies in-memory and syncs within milliseconds.
- [Risk] `resetOnError: true` can wipe the keystore independently of this change → Flagged: out of scope, recommend a follow-up to back up key presence flags.
- [Trade-off] Extra boot step adds milliseconds to startup → Accepted: correctness of restored hardware state outweighs it; the step is a single channel call.

## Migration Plan

1. Land model, provider, boot wiring, and test updates in a single change (settings and tokens move together; app ships from trunk).
2. Verify: `flutter analyze`, full `flutter test` green (including the 3 currently failing persistence tests), manual cold-restart round-trip per category on Android.
3. Rollback: revert the single change; v2-blob readers tolerate the v3 envelope by falling back to defaults (documented data-loss-on-rollback edge, acceptable for a settings screen).
