## Context

See `proposal.md` for motivation. Currently, the repository uses a single `pubspec.yaml` at root with `lib/core/` and `lib/features/`. To achieve true multi-package modularity and prevent accidental cross-domain imports, we are splitting the codebase into a Melos workspace with isolated packages under `packages/` and the runnable mobile app under `apps/owl/`.

## Goals / Non-Goals

**Goals:**
- Create root `melos.yaml` configuring `apps/**` and `packages/**` as workspace packages.
- Define a root `pubspec.yaml` with `publish_to: 'none'` and `melos` dev dependency.
- Extract `packages/owl_core/` with its own `pubspec.yaml` containing theme tokens, tactile widgets, and platform services.
- Extract domain feature packages under `packages/`:
  - `packages/owl_deck/`
  - `packages/owl_library/`
  - `packages/owl_mod_studio/`
  - `packages/owl_skins/`
- Move runnable application shell and runners (Android/iOS platforms, assets, entry point) to `apps/owl/`.
- Wire local path dependencies:
  - Feature packages depend on `owl_core` (`path: ../owl_core`).
  - `owl_deck` depends on `owl_core` and `owl_library` (`path: ../owl_library`).
  - `apps/owl` depends on `owl_core`, `owl_deck`, `owl_library`, `owl_mod_studio`, `owl_skins`.
- Migrate tests into their corresponding packages/apps and ensure 100% test pass rate.

**Non-Goals:**
- Publishing packages to pub.dev (all packages set `publish_to: 'none'`).
- Altering existing UI designs, business logic, or SharedPreferences keys.

## Decisions

### Decision 1: Monorepo Layout (`apps/` and `packages/`)
- **Rationale**: Separating runnable targets (`apps/`) from reusable packages (`packages/`) is the Flutter standard for monorepos (e.g., Very Good Ventures, Flutter community).
- **Alternatives Considered**: Flat `packages/` only, where the app is just another package. Rejected because `apps/owl` has platform folders (`android/`, `ios/`) and deployment configuration that should not mix with pure Dart/Flutter library packages.

### Decision 2: Melos Workspace Orchestration
- **Rationale**: Melos handles unified dependency resolution (`flutter pub get`), script running, and simultaneous multi-package testing without having to `cd` into 6 directories.
- **Alternatives Considered**: Pure manual path dependencies without Melos. Rejected because running tests or static analysis across multiple packages would require complex manual shell scripting.

### Decision 3: Asset Scoping
- **Rationale**: `assets/catalog.json` is packaged in `apps/owl/` and accessible to the app runner, or declared as package asset in `owl_library`. Keeping assets in `apps/owl/` or scoped within `owl_library` ensures self-contained testability.

## Risks / Trade-offs

- **[Path Dependency Inconsistencies]** Relative paths can break if nested folder depths mismatch → Mitigation: Enforce uniform directory depth (`packages/*` and `apps/*`).
- **[Flutter Asset Loading]** Tests relying on `rootBundle.loadString('assets/catalog.json')` need correct asset declarations → Mitigation: Ensure `apps/owl/pubspec.yaml` and `owl_library/pubspec.yaml` expose mock fallback data when assets are unbundled.
