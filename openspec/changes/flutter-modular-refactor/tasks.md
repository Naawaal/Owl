## 1. Dead Code and Orphan Pruning

- [x] 1.1 Remove orphaned `lib/features/timers/` directory (`timers.dart`, `domain/models/active_timer.dart`, `domain/models/timer_state.dart`)
- [x] 1.2 Remove unreferenced `lib/features/overlay/domain/models/overlay_config.dart` and update `lib/features/overlay/overlay.dart`
- [x] 1.3 Update `test/features/features_domain_test.dart` to remove tests for deleted timer and overlay_config models
- [x] 1.4 Run `flutter analyze` and `flutter test` to verify clean baseline

## 2. Settings Feature Modularization

- [x] 2.1 Extract `ApiKeyManager` and provider from `settings_provider.dart` to `lib/features/settings/data/api_key_manager.dart`
- [x] 2.2 Extract dynamic model discovery providers from `settings_provider.dart` to `lib/features/settings/presentation/model_discovery_provider.dart`
- [x] 2.3 Extract reusable settings tiles, section headers, and sliders to `lib/features/settings/presentation/widgets/common/settings_tile_components.dart`
- [x] 2.4 Extract General and Guardian AI sections from `app_settings_two_pane_screen.dart` to `widgets/sections/settings_general_section.dart` and `widgets/sections/settings_guardian_ai_section.dart`
- [x] 2.5 Extract Performance and Latency sections to `widgets/sections/settings_performance_section.dart` and `widgets/sections/settings_latency_section.dart`
- [x] 2.6 Extract Audio, Display, and DND sections to `widgets/sections/settings_audio_section.dart`, `widgets/sections/settings_display_section.dart`, and `widgets/sections/settings_dnd_section.dart`
- [x] 2.7 Refactor `app_settings_two_pane_screen.dart` into a concise shell (<200 LOC) hosting sidebar and active section pane
- [x] 2.8 Modularize `gpu_settings_two_pane_screen.dart` by extracting rendering panes into `widgets/sections/gpu_settings_content_pane.dart`

## 3. Overlay and Floating Toolbox Modularization

- [x] 3.1 Extract `_ReactorTachometerPainter` and telemetry gauges to `lib/features/overlay/presentation/widgets/toolbox_telemetry_reactor.dart`
- [x] 3.2 Extract quick action buttons to `lib/features/overlay/presentation/widgets/toolbox_quick_actions_grid.dart`
- [x] 3.3 Extract voice changer sheet to `lib/features/overlay/presentation/widgets/toolbox_voice_changer_sheet.dart`
- [x] 3.4 Extract performance mode switch to `lib/features/overlay/presentation/widgets/toolbox_performance_mode_switch.dart`
- [x] 3.5 Refactor `gameturbo_floating_toolbox.dart` into a streamlined container widget (<200 LOC)
- [x] 3.6 Modularize `tactical_battlefield_hud.dart` and `overlay_entry.dart` by extracting touch handlers and floating pills

## 4. Game Space Presentation Modularization

- [x] 4.1 Extract cover art carousel and tilt effects from `game_space_main_stage.dart` to `widgets/game_card_carousel.dart`
- [x] 4.2 Extract launch bar and GPU tab painter from `game_space_main_stage.dart` to `widgets/game_stage_launch_bar.dart`
- [x] 4.3 Refactor `game_space_main_stage.dart` into a clean orchestrator (<200 LOC)
- [x] 4.4 Extract status metrics pill from `game_space_top_status_bar.dart`
- [x] 4.5 Extract list tiles and Riverpod selection provider from `add_games_modal.dart`

## 5. AI Coach and Vision Pipeline Modularization

- [x] 5.1 Extract HTTP multi-provider inference logic from `coach_service.dart` to `lib/features/ai_coach/data/ai_inference_dispatcher.dart`
- [x] 5.2 Extract match token budget tracker to `lib/features/ai_coach/data/match_budget_tracker.dart`
- [x] 5.3 Modularize `moba_minimap_extractor.dart` by extracting contour detection
- [x] 5.4 Modularize `autonomous_tactical_loop.dart` by extracting loop configuration and lifecycle handlers
- [x] 5.5 Modularize `offline_tactical_heuristics_engine.dart` by extracting rule definitions

## 6. App Router and Transitions Modularization

- [x] 6.1 Extract `OwlPageRoute` and `OwlRouteObserver` to `lib/app/router/owl_page_transitions.dart`
- [x] 6.2 Extract `TacticalRoutePlaceholder` to `lib/app/router/tactical_route_placeholder.dart`
- [x] 6.3 Refactor `app_router.dart` to focus solely on GoRouter route declarations (<200 LOC)

## 7. Verification and Quality Gate

- [x] 7.1 Verify line count across all refactored files in `lib/`
- [x] 7.2 Run `flutter analyze` ensuring 0 warnings, 0 errors, and 0 lint issues
- [x] 7.3 Run full test suite with `flutter test`
- [x] 7.4 Validate that build configs and asset manifests were untouched
