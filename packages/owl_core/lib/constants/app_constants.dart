// language: Dart, file: lib/core/constants/app_constants.dart, target: Flutter / Owl MOBA HUD

/// Application-wide constants for Owl MOBA Companion HUD.
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appTitle = 'Owl';
  static const String appFullName = 'Owl - MOBA Companion HUD';
  static const String appVersion = '0.1.0+1';
  static const String appDescription =
      'Real-time tactical MOBA overlay companion and on-device AI coach.';

  // Default Overlay HUD Dimensions (OLED Tactical Pill)
  static const double pillWidth = 148.0;
  static const double pillHeight = 46.0;

  // Min / Max HUD Dimensions
  static const double minPillWidth = 120.0;
  static const double maxPillWidth = 240.0;
  static const double minPillHeight = 36.0;
  static const double maxPillHeight = 64.0;

  // Overlay Opacity and Scale Defaults
  static const double defaultOverlayOpacity = 0.92;
  static const double minOverlayOpacity = 0.20;
  static const double maxOverlayOpacity = 1.00;

  static const double defaultOverlayScale = 1.00;
  static const double minOverlayScale = 0.75;
  static const double maxOverlayScale = 1.50;

  // Default Supported Game Profiles
  static const String gameWildRift = 'Wild Rift';
  static const String gameMobileLegends = 'Mobile Legends';
  static const String gamePokemonUnite = 'Pokémon UNITE';

  static const List<String> defaultSupportedGames = [
    gameWildRift,
    gameMobileLegends,
    gamePokemonUnite,
  ];

  // Match Time and Tactical Timer Thresholds (in seconds)
  static const int warningAlertThresholdSeconds = 30;
  static const int criticalAlertThresholdSeconds = 10;
  static const int immediateSpawnThresholdSeconds = 0;

  // Default Timer Refresh Interval
  static const Duration timerTickInterval = Duration(seconds: 1);
  static const Duration highPrecisionTickInterval = Duration(milliseconds: 100);

  // Network Timeouts
  static const Duration networkTimeout = Duration(seconds: 15);
}
