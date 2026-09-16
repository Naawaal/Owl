## Why

App settings do not reliably survive a restart: the theme selector in App Settings writes to a JSON blob field (`GameTurboSettings.themeMode`) that nothing reads, while the app actually follows a separate provider (`themeModeProvider`, key `owl_theme_mode`, different default) — so the user's theme choice is silently lost. Native side-effects fire from the settings constructor (crashing widget tests), persistence failures are swallowed invisibly, and the settings blob has no schema migration path.

## What Changes

- Unify theme persistence on a single source of truth: the App Settings theme selector drives the same persisted theme the app boots with, with one default and one storage key. **BREAKING** (behavior): the orphaned `GameTurboSettings.themeMode` blob field is retired; the standalone provider becomes the canonical store.
- Move native side-effects out of the settings notifier constructor: performance-mode native sync and FPS-tracker targeting become an explicit, test-safe post-init re-apply step that also runs on every cold start, so hardware state matches persisted settings after restart.
- Make persistence failures visible: replace silent `catch (_) {}` swallows in the settings persist path with a typed result surfaced to the UI (toast/snackbar), keeping offline-safe fallbacks.
- Add schema versioning and migration to the settings blob (`v2` → versioned envelope with forward-migration of unknown/corrupt payloads to defaults instead of silent reset).
- Verify the surviving paths end-to-end: game-space deck + active game (via `GameDiscoveryService`), per-provider API keys (secure storage + memory fallback), overlay HUD toggles, and AI provider/model selection — each with a restart round-trip test.
- Fix the 3 failing persistence tests (`MissingPluginException` from the constructor channel call) by removing the construction-time native call; keep all other test expectations intact.
- Persist the GPU settings screen (frame-rate target, resolution, MSAA, anisotropic filtering, color profile, touch sampling, tactical AI toggles) into the settings blob. **Implementation discovery:** the screen currently keeps everything in local widget state — nothing survives even navigation away, let alone restart. Stored as one global GPU profile (per-game profiles are out of scope).

## Capabilities

### New Capabilities
- `settings-persistence`: restart-surviving app settings — unified theme store, deferred native re-apply on boot, visible persistence errors, versioned settings schema with migration, and restart round-trip coverage for deck, keys, toggles, and provider selection.

### Modified Capabilities
- None — `openspec/specs/` is empty, so there are no existing capabilities to modify.

## Impact

- Affected code: `lib/features/settings/presentation/settings_provider.dart`, `lib/features/settings/domain/models/game_turbo_settings.dart`, `lib/features/settings/presentation/app_settings_two_pane_screen.dart`, `lib/features/showcase/presentation/design_system_showcase_view.dart` (theme switcher), `lib/app/app.dart` (theme wiring), `packages/owl_storage/lib/storage/local_storage_service.dart`, `test/features/game_turbo_settings_test.dart`.
- No new dependencies; no API or storage-backend changes (SharedPreferences + secure storage stay).
- Verification: `flutter analyze`, `flutter test` (all persistence tests green), cold-restart round-trip checks per settings category.
