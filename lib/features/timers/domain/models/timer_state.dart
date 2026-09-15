// language: Dart, file: timer_state.dart, target: Flutter / Owl MOBA HUD

/// Operating status of an active objective countdown timer.
enum TimerStatus {
  /// Timer has not been started yet or is queued.
  idle,

  /// Active countdown progressing normally (> warning lead time).
  running,

  /// Objective will spawn soon (entered warning lead time window).
  warning,

  /// Objective spawn is imminent (urgent threshold, typically <= 10s).
  urgent,

  /// Objective has spawned and is live on the battlefield.
  ready;

  /// Whether the timer is currently in an active countdown state.
  bool get isCounting =>
      this == TimerStatus.running ||
      this == TimerStatus.warning ||
      this == TimerStatus.urgent;

  /// Whether the timer represents an urgent or warning alert condition.
  bool get isAlert =>
      this == TimerStatus.warning ||
      this == TimerStatus.urgent ||
      this == TimerStatus.ready;

  /// Human-readable badge text.
  String get label {
    switch (this) {
      case TimerStatus.idle:
        return 'IDLE';
      case TimerStatus.running:
        return 'ACTIVE';
      case TimerStatus.warning:
        return 'WARNING';
      case TimerStatus.urgent:
        return 'URGENT';
      case TimerStatus.ready:
        return 'LIVE';
    }
  }
}
