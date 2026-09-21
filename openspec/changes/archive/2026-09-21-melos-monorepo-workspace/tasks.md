## 1. Root Workspace & Melos Configuration

- [x] 1.1 Create root `melos.yaml` configuring `apps/**` and `packages/**` with lifecycle scripts (`bootstrap`, `analyze`, `test`)
- [x] 1.2 Update root `pubspec.yaml` to declare workspace root and dev dependency on `melos`

## 2. Core Package Extraction

- [x] 2.1 Scaffold `packages/owl_core/` with `pubspec.yaml`
- [x] 2.2 Migrate theme tokens, tactile widgets, and platform services from `lib/core/` to `packages/owl_core/lib/`
- [x] 2.3 Expose public barrel `packages/owl_core/lib/owl_core.dart`

## 3. Feature Packages Extraction

- [x] 3.1 Scaffold and migrate `packages/owl_deck/` with `pubspec.yaml` and `deck.dart`
- [x] 3.2 Scaffold and migrate `packages/owl_library/` with `pubspec.yaml`, `assets/`, and `library.dart`
- [x] 3.3 Scaffold and migrate `packages/owl_mod_studio/` with `pubspec.yaml` and `mod_studio.dart`
- [x] 3.4 Scaffold and migrate `packages/owl_skins/` with `pubspec.yaml` and `skins.dart`

## 4. Application Runner Setup

- [x] 4.1 Scaffold `apps/owl/` with `pubspec.yaml` referencing all local package dependencies
- [x] 4.2 Move platform folders (`android/`, `ios/`, `web/`, etc.), `assets/`, and `lib/main.dart` into `apps/owl/`
- [x] 4.3 Move app shell and root navigation into `apps/owl/lib/`

## 5. Verification & Clean-up

- [x] 5.1 Clean up root legacy `lib/` files
- [x] 5.2 Migrate and update test suites across packages/apps
- [x] 5.3 Run multi-package analysis and tests to ensure 100% pass rate
