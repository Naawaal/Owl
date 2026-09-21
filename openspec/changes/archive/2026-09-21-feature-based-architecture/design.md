## Context

See `proposal.md` for motivation. Currently, the project uses a layer-first structure:
- `lib/models/`
- `lib/providers/`
- `lib/repositories/`
- `lib/screens/`
- `lib/services/`
- `lib/theme/`
- `lib/widgets/`

This structure distributes domain concepts (e.g. game catalog logic, plugin management, and skin swapping) across multiple disjoint folders, making it difficult to maintain, test in isolation, or extract into independent monorepo packages.

## Goals / Non-Goals

**Goals:**
- Restructure `lib/` into a monorepo-ready, feature-first architecture:
  - `lib/core/`: Common theme tokens, reusable tactile UI widgets, shared infrastructure services, and barrel export (`core.dart`).
  - `lib/features/deck/`: Home carousel, hero cards, deck providers, and presentation.
  - `lib/features/library/`: Game catalog models, game repository, game provider, search, and library screens.
  - `lib/features/mod_studio/`: Plugin models, repository, state provider, and mod tuning screens.
  - `lib/features/skins/`: Skin models, skin repository, provider, and skin manager screens.
  - `lib/features/app_shell/`: Root navigation shell and floating dock integration.
- Provide clean public API barrel files for each module (`core.dart`, `deck.dart`, `library.dart`, `mod_studio.dart`, `skins.dart`).
- Update all internal and test imports to verify zero static analysis or runtime regression.

**Non-Goals:**
- Introducing multi-package tooling (e.g. Melos) or separating into independent `pubspec.yaml` sub-packages at this phase.
- Modifying underlying business logic, state mutations, or storage schemas.

## Decisions

### Decision 1: Feature Modules with Standardized Sub-Folders
- **Rationale**: Each feature folder (`deck`, `library`, `mod_studio`, `skins`) will follow a standardized 3-tier structure:
  - `models/`: Domain entities and data structures
  - `repositories/` & `providers/`: State management and persistence bridges
  - `presentation/`: Screens and feature-specific widgets
- **Alternatives Considered**: Keeping all widgets in a global `widgets/` folder. Rejected because feature-specific widgets (like `HeroDeckCard` or `PluginCard`) should live alongside their feature domain.

### Decision 2: Core Shared Domain (`lib/core/`)
- **Rationale**: Truly cross-cutting primitives (e.g. `AppColors`, `AppTypography`, `AppTheme`, `OwlButton`, `OwlSwitch`, `OwlSlider`, `OwlBottomSheet`, `OwlToast`, `FloatingBottomNav`) belong in `lib/core/` to ensure features can depend on core, while core never depends on features (strict unidirectional dependency).
- **Alternatives Considered**: Distributing theme tokens into feature directories. Rejected because consistent visual branding requires a single source of truth.

### Decision 3: Public Barrel Exports
- **Rationale**: Each feature will expose a `<feature_name>.dart` barrel file at its root. Other features and `main.dart` only import through the barrel, preventing deep-link import coupling and making future package extraction frictionless.
- **Alternatives Considered**: Deep direct file imports everywhere. Rejected because it exposes internal implementation details and complicates refactoring.

## Risks / Trade-offs

- **[Broken Import Paths]** Moving dozens of files simultaneously can produce compile errors → Mitigation: Create new folders, move files systematically, add barrel exports, update imports in batches, and run `flutter analyze` and `flutter test` at each stage.
