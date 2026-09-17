## Why

The Flutter codebase has grown to include several monolithic files exceeding 1,000 to 2,200 lines (most notably `app_settings_two_pane_screen.dart`, `gameturbo_floating_toolbox.dart`, `design_system_showcase_view.dart`, and `settings_provider.dart`). These monolithic files blend presentation widgets, business state manipulation, secure credential storage, and custom canvas rendering into single files, violating the Single Responsibility Principle (SRP). Additionally, deprecated/orphaned files (`features/timers/` and `features/overlay/domain/models/overlay_config.dart`) remain unreferenced by production code.

Refactoring the workspace to enforce a 200-line modularity threshold, standardizing shared state on Riverpod 2.6.1, and pruning orphaned code will drastically improve maintainability, testability, and developer velocity.

## What Changes

- **Dead Code & Orphan Cleanup**: Remove orphaned domain models and feature folders that are unreferenced in production (`lib/features/timers/*` and `lib/features/overlay/domain/models/overlay_config.dart`). Clean up unneeded test scaffolding in `test/features/features_domain_test.dart`.
- **State Management Hardening**: Consolidate all shared state and business actions onto Riverpod 2.6.1 (`StateNotifierProvider`, `StreamProvider`, `FutureProvider`). Restrict `setState` strictly to local, ephemeral presentation states (e.g. animation progress, immediate UI toggles).
- **File Modularization (<200 LOC)**: Decompose 18 files exceeding 200 lines into focused, single-responsibility files across:
  - Settings UI & Providers (Sidebar, 7 category sections, API Key Manager, Model Discovery).
  - Floating Toolbox & HUD (Telemetry reactor, quick actions grid, voice changer sheet, performance mode switch).
  - Game Space Console & Stage (Cover carousel, launch bar, top status bar).
  - AI Coach & Vision Loop (Inference dispatcher, match budget tracker, minimap contour detector).
  - App Router & Transitions (Custom page routes, tactical route placeholders).
- **Strict Execution Gating**: Present explicit deletion lists and file splitting plans for user approval before modifying code.

## Capabilities

### New Capabilities
- `workspace-modular-architecture`: Establishes workspace architectural standards including a 200-line modularity guideline, strict layer separation (presentation vs. business logic vs. domain models), centralized Riverpod state management, and continuous zero-warning static analysis.

### Modified Capabilities

## Impact

- **Affected Code**: `lib/features/settings/`, `lib/features/overlay/`, `lib/features/game_profiles/`, `lib/features/ai_coach/`, `lib/app/router/`, `lib/overlay_entry.dart`, `test/features/features_domain_test.dart`.
- **APIs & Dependencies**: No external API or dependency changes; build configs (`pubspec.yaml`, `build.gradle.kts`, `AndroidManifest.xml`) and asset manifests remain strictly untouched.
- **Breaking Changes**: None. All public routes, providers, and design system contracts remain intact.
