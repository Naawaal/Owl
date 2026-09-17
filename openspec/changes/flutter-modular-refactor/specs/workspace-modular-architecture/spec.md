## Purpose

Enforces structured modular architecture across the Flutter workspace, ensuring clean layer separation, a 200-line modularity threshold, centralized Riverpod state management, and removal of unreferenced code.

## ADDED Requirements

### Requirement: Modular File Organization and Single Responsibility
All source code files in the Flutter workspace SHALL adhere to the Single Responsibility Principle and MUST target fewer than 200 lines per file by separating UI widgets, state notifiers, data services, and models into dedicated files.

#### Scenario: File length within threshold
- **WHEN** static analysis or line-count verification runs across `lib/`
- **THEN** monolithic source files exceeding 200 lines are partitioned into focused, single-responsibility components under appropriate feature subdirectories

#### Scenario: Layer separation integrity
- **WHEN** inspecting feature modules
- **THEN** presentation widgets, domain models, and state notifiers reside in separate files with explicit dependencies

### Requirement: Centralized Riverpod State Management
All business logic, app-wide settings, system telemetry streams, and shared state SHALL be managed through Riverpod providers and StateNotifiers, with local `setState` strictly limited to ephemeral UI states.

#### Scenario: Business logic execution
- **WHEN** user actions or telemetry triggers occur (e.g. settings persistence, Wi-Fi boost, app scanning, tactical advice requests)
- **THEN** the action executes through a Riverpod provider or notifier rather than widget-internal `setState`

#### Scenario: Ephemeral UI state scoping
- **WHEN** a widget manages transient visual behavior such as animation controller ticks or tab index highlights
- **THEN** local state is permitted only for purely visual, non-business ephemeral transitions

### Requirement: Dead Code and Orphan Pruning
The workspace SHALL contain no orphaned Dart source files, unreferenced imports, or unused domain models that have been superseded by production architecture.

#### Scenario: Pruning orphaned features
- **WHEN** the refactor is executed
- **THEN** unreferenced legacy features (`lib/features/timers/` and `lib/features/overlay/domain/models/overlay_config.dart`) are safely removed without breaking build configurations or active runtime features

#### Scenario: Analyzer cleanliness
- **WHEN** `flutter analyze` runs against the workspace
- **THEN** zero errors, warnings, or unused import lints are reported
