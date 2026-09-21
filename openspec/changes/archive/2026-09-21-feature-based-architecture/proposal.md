## Why

The current codebase is organized in a flat, layer-based hierarchy (`lib/models`, `lib/providers`, `lib/repositories`, `lib/screens`, `lib/services`, `lib/widgets`, `lib/theme`), where files belonging to different functional domains are mixed together. As the Owl companion grows to support vision overlays, Carrom aim physics, universal game scanning, and skin packaging, this layer-based layout impairs scalability, isolation, and future extraction into monorepo packages. We must restructure the codebase into a feature-based architecture with isolated feature modules and a clean shared core.

## What Changes

- Reorganize `lib/` into a feature-driven monorepo layout:
  - `lib/core/`: Shared design system (`theme/`), reusable UI primitives (`widgets/`), shared infrastructure (`services/`), and global contracts.
  - `lib/features/deck/`: Home snap carousel, hero cards, telemetry badges, and quick-launch triggers.
  - `lib/features/library/`: Game catalog, installed packages management, search, and custom game scanner/adder modal.
  - `lib/features/mod_studio/`: Mod configuration bottom sheet, trajectory raycast multipliers, vision aim toggles, and parameter controllers.
  - `lib/features/skins/`: Skin catalog, asset swapping, and preview managers.
- Structure each feature module with clean internal separation:
  - `models/` (feature-specific data structures)
  - `providers/` (state management and business logic)
  - `presentation/` (screens and feature-scoped widgets)
- Provide barrel exports for each feature to enforce clear boundaries and avoid spaghetti imports.
- Update `lib/main.dart`, app shell routing, and test suites to import through the clean feature-driven architecture.

## Capabilities

### New Capabilities
- `feature-monorepo-structure`: Defines standard feature module boundaries, shared core contracts, directory conventions, and public barrel exports across features.

### Modified Capabilities
<!-- No requirement changes to existing capability specs -->

## Impact

- Directory moves across `lib/` (layer-based directories transitioned into `lib/core/` and `lib/features/`).
- Import paths updated across all screens, widgets, providers, and test suites.
- No breaking changes to user-facing behavior, persistence keys, or Android intent launching.
