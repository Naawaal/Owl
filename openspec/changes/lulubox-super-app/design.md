## Context

Greenfield MVP in `D:\Celora\owl` — Flutter ^3.12.2, `lib/main.dart` empty, `pubspec.yaml` has duplicate `http` entry. Target: Android-only (Lulubox-style hub). Specs: `plugin-launcher`, `skin-manager`. See proposal.md Why. No backend; local JSON catalog + SharedPreferences/file storage.

## Goals / Non-Goals

**Goals:**
- Single Flutter app shell with 4 tabs (Home / Games / Plugins / Me) + game detail flow.
- Local-first: mock catalog in `assets/`, persisted toggles/applied-pack state.
- Android launch via `android_intent_plus`-class intent + PackageManager query with graceful fallback.
- Legal-safe skin manager (user-provided configs only).

**Non-Goals:**
- No binary patching, memory injection, root, overlay cheating, or copyrighted asset hosting.
- No iOS support, no backend accounts, no real payments in MVP.
- No Play Store release hardening (signing, policy review) in this change.

## Decisions

- **Flutter + Provider (over Bloc/Riverpod):** MVP-simple state for toggles/applied packs; Alternatives: Riverpod (more boilerplate), Bloc (overkill for 2 entities).
- **Local JSON catalog (`assets/catalog.json`):** avoids backend; models `Game{id, packageName, minVersion, icon}` + `Plugin{id, gameIds, version, compatibleVersions}` + `SkinPack{id, gameId, version}`. Alternative: remote API — deferred to post-MVP.
- **Repository + Service layer:** `GameRepository`, `PluginRepository`, `SkinRepository` backed by asset JSON + `SharedPreferences` for state; `LauncherService` abstracts Android intents for testability.
- **Android integration via MethodChannel / `android_intent_plus`:** query `PackageManager.getLaunchIntentForPackage`, handle `ActivityNotFound`. Alternative: pure MethodChannel — use plugin lib to cut native code in MVP.
- **Fix `pubspec.yaml` duplicate `http`:** keep single `http: ^1.2.2`, add `provider`, `shared_preferences`, `android_intent_plus`, `package_info_plus`.

## Risks / Trade-offs

- [Risk] `QUERY_ALL_PACKAGES` restricted on Play → Mitigation: use `<queries>` per game package + `getInstalledPackages` fallback, document sideload distribution for MVP.
- [Risk] Game ToS violation if misused for cheats → Mitigation: legal-safe notice, no cheat APIs, user-provided configs only, store copy review.
- [Risk] Launch intent varies by OEM/game → Mitigation: `LauncherService.canLaunch()` check + error surface per spec scenario.
- [Trade-off] Local JSON means stale catalog → acceptable for MVP; version field enables future remote refresh.

## Migration Plan

1. Fix pubspec, add assets catalog scaffold.
2. Add models/repos/services + Provider wiring.
3. Build UI shell → game detail → plugin toggles → skin manager.
4. Android manifest `<queries>` + permissions, test on Android 12+ device/emulator.
5. Rollback: change is additive; delete new `lib/` files + revert pubspec if needed.

## Open Questions

- None blocking — deferred: exact initial game list (assume 4-6 popular titles as mock data), final visual theme (use Material 3 baseline).
