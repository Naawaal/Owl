## 1. Project Setup

- [x] 1.1 Fix `pubspec.yaml` duplicate `http`, add `provider`, `shared_preferences`, `android_intent_plus`, `package_info_plus`
- [x] 1.2 Create folder structure `lib/{models,repositories,services,providers,screens,widgets}` + `assets/catalog.json` wiring
- [x] 1.3 Add Android `<queries>` entries and storage permissions baseline in `android/app/src/main/AndroidManifest.xml`

## 2. Data Layer

- [x] 2.1 Implement models `Game`, `Plugin`, `SkinPack` with JSON parsing
- [x] 2.2 Implement `GameRepository`, `PluginRepository`, `SkinRepository` loading `assets/catalog.json` with mock data for 4-6 games
- [x] 2.3 Implement persistence for plugin toggles + applied skin state via `SharedPreferences`

## 3. Plugin Launcher

- [x] 3.1 Implement `LauncherService` with `canLaunch()` + `launchGame()` + failure mapping
- [x] 3.2 Build game library list UI (Installed / Not Installed + plugin count)
- [x] 3.3 Build game detail UI with plugin toggle list + version-mismatch blocking
- [x] 3.4 Wire Play action with launching state + error snackbar per spec

## 4. Skin Manager

- [x] 4.1 Build skin manager screen filtered by game + empty state + legal notice
- [x] 4.2 Implement preview → apply flow recording version + timestamp
- [x] 4.3 Implement clear/restore defaults with confirmation dialog

## 5. App Shell + Polish

- [x] 5.1 Build bottom-nav shell: Home / Games / Plugins / Me + navigation to detail screens
- [x] 5.2 Apply Material 3 baseline theme + app icons + empty/loading states
- [x] 5.3 Add widget tests for toggle persistence + apply/clear logic

## 6. Verification

- [x] 6.1 Run `flutter analyze` + `flutter test` and fix issues
- [x] 6.2 Smoke test on Android 12+ emulator/device: detect, toggle, launch (mock), apply/clear skin
- [x] 6.3 Run `openspec validate --change lulubox-super-app --strict`
