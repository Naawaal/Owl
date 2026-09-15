// language: Dart, file: lib/app/router/app_routes.dart, target: Flutter / Owl MOBA HUD

/// Application Route path definitions for the Owl MOBA Companion HUD.
///
/// Defines canonical URI paths for every navigation destination across
/// the companion HUD interface.
abstract final class AppRoutes {
  AppRoutes._();

  /// Default entry route: Flagship Xiaomi Game Turbo Game Space Console.
  static const String console = '/console';

  /// In-Game Live Match Tactical Overlay HUD with 2026 Game Turbo toolbox.
  static const String inGameHud = '/ingame';

  /// Two-Pane Global Application Settings (General, Performance, DND, AI Core).
  static const String appSettings = '/settings/app';

  /// Two-Pane Selected Game GPU Settings (Graphics, Display, Touch, AI Modules).
  static const String gpuSettings = '/settings/gpu';

  /// Default interactive component and design system showcase.
  static const String showcase = '/showcase';

  /// Live tactical MOBA HUD dashboard with real-time timers and telemetry.
  static const String dashboard = '/dashboard';

  /// Game profile management (Wild Rift, Mobile Legends, Pokémon UNITE).
  static const String gameProfiles = '/profiles';

  /// Main settings configuration screen.
  static const String settings = '/settings';

  /// AI Coach & Vision API credentials management.
  static const String apiKeys = '/settings/keys';

  /// Floating tactical overlay HUD configurator (opacity, scale, positioning).
  static const String overlaySettings = '/settings/overlay';

  /// Default entry route.
  static const String initial = console;

  /// Complete list of defined routes.
  static const List<String> all = [
    console,
    inGameHud,
    appSettings,
    gpuSettings,
    showcase,
    dashboard,
    gameProfiles,
    settings,
    apiKeys,
    overlaySettings,
  ];

  /// Validates whether a given path is a recognized application route.
  static bool isValidRoute(String? path) => all.contains(path);
}
