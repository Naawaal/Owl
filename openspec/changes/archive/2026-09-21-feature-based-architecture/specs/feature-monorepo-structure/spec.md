## Purpose

Defines the feature-based architectural boundaries, domain module isolation rules, shared core contracts, and public API barrel structures.

## ADDED Requirements

### Requirement: Feature Domain Isolation
The codebase SHALL organize domain-specific logic, state, and UI into isolated feature directories under `lib/features/`.

#### Scenario: Navigating Feature Modules
- **WHEN** a developer inspects or develops a specific functional domain (e.g. deck, library, mod studio, skins)
- **THEN** all associated presentation screens, widgets, controllers, and models reside within that feature's dedicated directory.

### Requirement: Shared Core Foundation
The codebase SHALL consolidate cross-cutting design tokens, reusable UI primitives, and platform infrastructure services under `lib/core/`.

#### Scenario: Consuming Core Tokens and Primitives
- **WHEN** a feature component requires theme tokens, buttons, sliders, switches, or platform services
- **THEN** it imports them from `lib/core/` without reaching into other unrelated feature internals.

### Requirement: Public Feature Interface Contracts
Each feature module SHALL expose its public entry points and interfaces through a top-level feature barrel file.

#### Scenario: External Feature Consumption
- **WHEN** the application shell or another feature interfaces with a feature module
- **THEN** it imports the feature via its public barrel without direct coupling to private internal implementation files.
