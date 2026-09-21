## 1. Core Shared Domain Scaffolding

- [x] 1.1 Move `theme/` and shared widget primitives (`owl_button.dart`, `owl_switch.dart`, `owl_slider.dart`, `owl_bottom_sheet.dart`, `owl_toast.dart`, `floating_bottom_nav.dart`, `legal_notice_banner.dart`) into `lib/core/`
- [x] 1.2 Move cross-cutting services (`launcher_service.dart`, `storage_service.dart`) into `lib/core/services/`
- [x] 1.3 Create `lib/core/core.dart` barrel export consolidating themes, core widgets, and services

## 2. Feature Modules Partitioning

- [x] 2.1 Migrate Deck components into `lib/features/deck/` (`presentation/hero_deck_card.dart`) and create `deck.dart` barrel
- [x] 2.2 Migrate Library components into `lib/features/library/` (`models/game.dart`, repositories, `game_provider.dart`, screens, cards) and create `library.dart` barrel
- [x] 2.3 Migrate Mod Studio components into `lib/features/mod_studio/` (`models/plugin.dart`, repository, `plugin_provider.dart`, screens, cards) and create `mod_studio.dart` barrel
- [x] 2.4 Migrate Skins components into `lib/features/skins/` (`models/skin_pack.dart`, repository, `skin_provider.dart`, screens) and create `skins.dart` barrel
- [x] 2.5 Migrate App Shell into `lib/features/app_shell/` (`presentation/app_shell.dart`) and create `app_shell.dart` barrel

## 3. Integration, Cleanup & Verification

- [x] 3.1 Update `lib/main.dart` to initialize repositories, providers, and app shell via feature barrel exports
- [x] 3.2 Remove legacy layer directories (`lib/models`, `lib/providers`, `lib/repositories`, `lib/screens`, `lib/services`, `lib/widgets`, `lib/theme`)
- [x] 3.3 Update import paths in `test/` suite to reference `lib/core/` and `lib/features/` barrels
- [x] 3.4 Run `flutter analyze` and `flutter test` to ensure complete project build and test integrity
