## Why

Users want a Lulubox-style "super" toolbox on Android to manage game plugins, skins/configs, and launch games from one hub. The current `owl/` Flutter project is empty (`lib/main.dart` blank) and needs a legal-safe MVP foundation focused on plugin launching + skin/config management.

## What Changes

- Add Android-first Flutter app shell: home hub, game library, plugin store/detail, My Plugins, Me tabs.
- Add Plugin Launcher capability: detect installed games, list compatible plugins, enable/disable plugins, launch game with selected plugins via Android intents.
- Add Skin/Config Manager capability: browse local/user-provided skin/config packs, preview, apply/clear per game, version + backup tracking (no redistribution of copyrighted game assets).
- Add local storage + mock plugin catalog (JSON/assets) for MVP; no backend required.
- Mark legal/safety boundary: no game binary patching, no memory cheating, no copyrighted skin redistribution, no Play Store policy-violating behavior in MVP.

## Capabilities

### New Capabilities
- `plugin-launcher`: detect installed games, manage plugin enablement, launch games with plugins.
- `skin-manager`: browse/preview/apply/clear user-provided skin/config packs per game with backup/restore metadata.

### Modified Capabilities
- None (greenfield — `openspec/specs/` is empty).

## Impact

- Affected code: `lib/` (new Flutter UI + models + services), `android/` (package queries, launch intents, storage permissions), `pubspec.yaml` (add `provider`/`shared_preferences`-class deps, remove duplicate `http`).
- APIs/systems: Android `PackageManager` / `QUERY_ALL_PACKAGES` considerations, `METHOD_CHANNEL` for launch if needed, local file storage.
- Dependencies: Flutter SDK ^3.12.2, Android-only MVP (iOS deferred).
