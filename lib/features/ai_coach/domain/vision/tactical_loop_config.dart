// language: Dart, file: tactical_loop_config.dart, target: Flutter / Owl MOBA Companion

/// Configuration and sampling frequency calculation for the autonomous tactical loop.
class TacticalLoopConfig {
  const TacticalLoopConfig({
    this.staticThreshold = 3.0,
    this.defaultPerformanceMode = 'balanced',
  });

  final double staticThreshold;
  final String defaultPerformanceMode;

  /// Returns the configured sampling frequency in Hertz (frames per second).
  static int targetCadenceFpsFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return 1;
      case 'high':
        return 12;
      case 'balanced':
      default:
        return 5;
    }
  }

  /// Calculates the tick interval corresponding to the specified performance mode.
  static Duration cadenceIntervalFor(String performanceMode) {
    final fps = targetCadenceFpsFor(performanceMode);
    return Duration(milliseconds: (1000 / fps).round());
  }
}
