## Why

As the Owl platform expands (with game catalog management, injector mod studio, skin packs, launcher services, and hero deck), single-package architecture risks unintended cross-feature coupling and makes it harder to reuse modules across future companion apps or tools. Transitioning to a true multi-package monorepo managed by Melos establishes strict package isolation, enforces unidirectional dependencies, and provides unified workspace tooling (synchronized bootstrapping, automated testing, and multi-package analysis).

## What Changes

- **BREAKING**: Reorganize repository root into a Melos workspace containing `apps/` and `packages/`.
- Introduce `melos.yaml` defining package locations (`apps/**`, `packages/**`) and lifecycle scripts (`bootstrap`, `analyze`, `test`).
- Move the runnable Flutter app shell into `apps/owl/` with its own `pubspec.yaml`, entry point (`lib/main.dart`), and Android/iOS runner targets.
- Extract `lib/core/` into `packages/owl_core/` containing theme tokens, tactile design system widgets, and storage/launcher services.
- Extract feature domains into independent packages under `packages/`:
  - `packages/owl_deck/`
  - `packages/owl_library/`
  - `packages/owl_mod_studio/`
  - `packages/owl_skins/`
- Configure local path dependencies and exports so `apps/owl` orchestrates features cleanly.
- Ensure all multi-package unit and widget tests pass via workspace-level testing scripts.

## Capabilities

### New Capabilities
- `melos-monorepo-orchestration`: Workspace root orchestration with Melos configuration, automated package bootstrapping, unified scripts, and strict multi-package separation.

### Modified Capabilities
- `feature-monorepo-structure`: Evolves from internal single-project directories (`lib/features/*`) into independent pub packages (`packages/owl_*`) with explicit package dependencies.

## Impact

- Repository structure: files relocate to `apps/owl` and `packages/owl_*`.
- Dependencies: Root workspace adds `melos` dev dependency and root `melos.yaml`.
- Build/Test workflows: tests and analysis run across packages via `melos run test` or direct package invocations.
