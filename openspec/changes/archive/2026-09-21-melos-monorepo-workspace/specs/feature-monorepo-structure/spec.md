## MODIFIED Requirements

### Requirement: Feature Domain Isolation
The codebase SHALL organize domain-specific logic, state, and UI into isolated pub packages located under `packages/` (`packages/owl_deck`, `packages/owl_library`, `packages/owl_mod_studio`, `packages/owl_skins`).

#### Scenario: Navigating Feature Modules
- **WHEN** a developer inspects or develops a specific functional domain (e.g. deck, library, mod studio, skins)
- **THEN** all associated presentation screens, widgets, controllers, and models reside within that feature's dedicated package with its own `pubspec.yaml`.

### Requirement: Shared Core Foundation
The codebase SHALL consolidate cross-cutting design tokens, reusable UI primitives, and platform infrastructure services into a dedicated `packages/owl_core` package.

#### Scenario: Consuming Core Tokens and Primitives
- **WHEN** a feature package requires theme tokens, buttons, sliders, switches, or platform services
- **THEN** it declares a dependency on `owl_core` and imports them from `package:owl_core/owl_core.dart` without reaching into other unrelated feature internals.
