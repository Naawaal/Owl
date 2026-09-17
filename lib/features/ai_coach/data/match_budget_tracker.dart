// language: Dart, file: match_budget_tracker.dart, target: Flutter / Owl Game Turbo
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';

/// Enforces request frequency limits, match call quotas, and device stress throttling.
class MatchBudgetTracker {
  MatchBudgetTracker();

  /// Minimum gap between networked queries; rapid refires resolve cached.
  static const Duration queryCooldown = Duration(seconds: 30);

  /// Maximum networked queries per match before silence.
  static const int maxCallsPerMatch = 20;

  /// Stress detection thresholds (CPU+battery proxy; no temp sensor).
  static const int stressCpuThreshold = 80;
  static const int stressBatteryCeiling = 25;

  /// Consecutive stressed readings to engage, unstressed to release.
  static const int stressWindow = 3;

  int _callsThisMatch = 0;
  DateTime? _lastCallAt;
  String? _matchKey;

  int _stressStreak = 0;
  int _reliefStreak = 0;
  bool _stressThrottled = false;

  /// Number of networked queries issued for the current match.
  int get callsThisMatch => _callsThisMatch;

  /// Timestamp of the most recent networked query.
  DateTime? get lastCallAt => _lastCallAt;

  /// Whether stress throttling is currently engaged.
  bool get isStressThrottled => _stressThrottled;

  /// Resets match budget tracking, e.g. when a new match begins.
  void reset() {
    _callsThisMatch = 0;
    _lastCallAt = null;
    _matchKey = null;
  }

  /// Checks and updates the active match key. If changed, resets counters.
  void trackMatch(String newMatchKey) {
    if (_matchKey != null && _matchKey != newMatchKey) {
      _callsThisMatch = 0;
      _lastCallAt = null;
    }
    _matchKey = newMatchKey;
  }

  /// Returns true if a request is permitted within cooldown and quota limits.
  bool canMakeRequest(GameTurboSettings settings, DateTime now) {
    final cooldown = enforcedCooldown(settings);
    if (_lastCallAt != null && now.difference(_lastCallAt!) < cooldown) {
      return false;
    }
    if (_callsThisMatch >= enforcedCap(settings)) {
      return false;
    }
    return true;
  }

  /// Increments calls for the current match and updates the timestamp.
  void recordCall(DateTime now) {
    _callsThisMatch++;
    _lastCallAt = now;
  }

  /// Reports one device-stress sample. Engages saver budgets after [stressWindow]
  /// consecutive stressed readings.
  void reportStressSample({
    required GameTurboSettings settings,
    required int cpuPercent,
    required int batteryPercent,
  }) {
    if (!settings.adaptiveWorkload || !settings.thermalProtection) {
      _stressThrottled = false;
      _stressStreak = 0;
      _reliefStreak = 0;
      return;
    }
    final stressed = cpuPercent >= stressCpuThreshold &&
        batteryPercent <= stressBatteryCeiling;
    if (stressed) {
      _stressStreak++;
      _reliefStreak = 0;
      if (_stressStreak >= stressWindow) _stressThrottled = true;
    } else {
      _reliefStreak++;
      _stressStreak = 0;
      if (_reliefStreak >= stressWindow) _stressThrottled = false;
    }
  }

  /// Cooldown actually enforced, accounting for stress throttle.
  Duration enforcedCooldown(GameTurboSettings settings) {
    if (_stressThrottled) {
      return baseCooldownFor('saver') * 2;
    }
    return effectiveCooldown(settings);
  }

  /// Cap actually enforced, accounting for stress throttle.
  int enforcedCap(GameTurboSettings settings) {
    if (_stressThrottled) {
      return (baseCapFor('saver') * 0.5).round();
    }
    return effectiveCap(settings);
  }

  /// Effective cooldown after the warning-sensitivity multiplier.
  static Duration effectiveCooldown(GameTurboSettings settings) {
    final base = baseCooldownFor(settings.performanceMode);
    switch (settings.warningSensitivity) {
      case 'earlyWarning':
        return base ~/ 2;
      case 'conservative':
        return base * 2;
      default:
        return base;
    }
  }

  /// Effective per-match cap after the warning-sensitivity multiplier.
  static int effectiveCap(GameTurboSettings settings) {
    final base = baseCapFor(settings.performanceMode);
    switch (settings.warningSensitivity) {
      case 'earlyWarning':
        return (base * 1.5).round();
      case 'conservative':
        return (base * 0.5).round();
      default:
        return base;
    }
  }

  /// Base cooldown per performance profile.
  static Duration baseCooldownFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return const Duration(seconds: 60);
      case 'high':
        return const Duration(seconds: 15);
      default:
        return queryCooldown;
    }
  }

  /// Base per-match cap per performance profile.
  static int baseCapFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return 8;
      case 'high':
        return 30;
      default:
        return maxCallsPerMatch;
    }
  }
}
