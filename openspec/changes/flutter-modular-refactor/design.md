## Context

The repository contains 49 Dart files in `lib/`, with 18 files exceeding the 200-line threshold and several exceeding 1,000 to 2,294 lines. The codebase already utilizes `flutter_riverpod: 2.6.1`, but several UI screens directly perform asynchronous I/O and state orchestration via local `setState`. Deprecated modules (`features/timers/` and `OverlayConfig`) remain in the codebase without active callers.

## Goals / Non-Goals

**Goals:**
- Partition all 18 monolithic files (>200 lines) into focused, single-responsibility sub-components under 200 lines.
- Remove orphaned files (`features/timers/*` and `features/overlay/domain/models/overlay_config.dart`) and decouple test files.
- Ensure all business logic (game scanning, telemetry streaming, settings persistence, AI dispatch) runs through Riverpod providers.
- Maintain 100% static analysis pass rate (`flutter analyze` with 0 warnings/errors).

**Non-Goals:**
- Modifying build configurations (`pubspec.yaml`, `build.gradle.kts`, `AndroidManifest.xml`).
- Touching asset manifests or static image resources.
- Altering user-facing visual design, routes, or functional capabilities.

## Decisions

### Decision 1: Riverpod 2.6.1 as Sole Business State Manager
- **Context**: Some widgets perform direct SharedPreferences writes or asynchronous service invocations inside `setState` callbacks.
- **Choice**: Route all mutations through dedicated `StateNotifierProvider` or `FutureProvider` instances. Limit `setState` exclusively to local widget animations or immediate controller focus.
- **Alternative considered**: Converting to BLoC. Rejected because Riverpod is already deeply integrated across the codebase.

### Decision 2: Feature-Scoped Decomposition Architecture
- **Settings Screen (`app_settings_two_pane_screen.dart`, 2,294 LOC)**: Split into separate category pane widgets in `lib/features/settings/presentation/widgets/sections/` (`settings_general_section.dart`, `settings_guardian_ai_section.dart`, `settings_performance_section.dart`, `settings_latency_section.dart`, `settings_audio_section.dart`, `settings_display_section.dart`, `settings_dnd_section.dart`, and `settings_tile_components.dart`).
- **Settings Provider (`settings_provider.dart`, 713 LOC)**: Extract `ApiKeyManager` into `lib/features/settings/data/api_key_manager.dart` and dynamic model providers into `model_discovery_provider.dart`.
- **Floating Toolbox (`gameturbo_floating_toolbox.dart`, 1,080 LOC)**: Extract `_ReactorTachometerPainter` into `toolbox_telemetry_reactor.dart`, quick action buttons into `toolbox_quick_actions_grid.dart`, voice changer into `toolbox_voice_changer_sheet.dart`, and performance switcher into `toolbox_performance_mode_switch.dart`.
- **Game Space Stage (`game_space_main_stage.dart`, 720 LOC)**: Extract carousel cards into `game_card_carousel.dart` and launch bar/painter into `game_stage_launch_bar.dart`.
- **App Router (`app_router.dart`, 598 LOC)**: Extract `OwlPageRoute` & observer into `owl_page_transitions.dart`, and `TacticalRoutePlaceholder` into `tactical_route_placeholder.dart`.
- **AI Coach Service (`coach_service.dart`, 570 LOC)**: Extract multi-provider HTTP logic to `ai_inference_dispatcher.dart` and match budget tracking to `match_budget_tracker.dart`.

### Decision 3: Clean Deletion of Orphaned Models & Tests
- Remove `lib/features/timers/` (entire directory: `timers.dart`, `active_timer.dart`, `timer_state.dart`).
- Remove `lib/features/overlay/domain/models/overlay_config.dart`.
- Update `test/features/features_domain_test.dart` to drop the dead Timers and OverlayConfig test groups while retaining all Game Profiles, AI Coach, and Settings test coverage.

## Risks / Trade-offs

- **[Risk] Broken import references across decomposed widgets** → **Mitigation**: Use explicit relative/package imports and run `flutter analyze` after every modular file extraction.
- **[Risk] Stateful widget life-cycle regressions during extraction** → **Mitigation**: Pass needed controllers or bind directly to Riverpod providers rather than duplicating state holders.
- **[Risk] Test suite failures from deleted models** → **Mitigation**: Update `features_domain_test.dart` in sync with deletions and verify with `flutter test`.
