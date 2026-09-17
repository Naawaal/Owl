// language: Dart, file: lib/core/utils/haptic_helper.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter/services.dart';

/// Tactical haptic alert pattern types for MOBA countdown thresholds.
enum TacticalHapticType {
  /// Subtle alert (e.g., 30-second objective pre-warning)
  warning30s,

  /// Urgent pulsating alert (e.g., 10-second countdown alert)
  critical10s,

  /// Immediate high-priority alert (e.g., objective spawn, baron, dragon)
  spawn,

  /// Interactive button/pill tap feedback
  tap,
}

/// Helper wrapper around [HapticFeedback] for in-game HUD alerts and tactile feedback.
class HapticHelper {
  HapticHelper._();

  /// Global kill-switch driven by the persisted `hapticsEnabled` setting.
  /// All helpers below consult it in addition to their per-call [enabled]
  /// flag, so one assignment silences the entire app.
  static bool globalEnabled = true;

  /// Subtle light impact feedback.
  static Future<void> lightImpact({bool enabled = true}) async {
    if (!enabled || !globalEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium tactile impact feedback.
  static Future<void> mediumImpact({bool enabled = true}) async {
    if (!enabled || !globalEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy impact feedback for critical notifications.
  static Future<void> heavyImpact({bool enabled = true}) async {
    if (!enabled || !globalEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Standard vibration.
  static Future<void> vibrate({bool enabled = true}) async {
    if (!enabled || !globalEnabled) return;
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// UI selection click.
  static Future<void> selectionClick({bool enabled = true}) async {
    if (!enabled || !globalEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Tactical alert triggered at 30 seconds before objective spawn.
  static Future<void> alert30s({bool enabled = true}) async {
    if (!enabled) return;
    await lightImpact(enabled: enabled);
  }

  /// Urgent warning triggered at 10 seconds before objective spawn.
  static Future<void> warning10s({bool enabled = true}) async {
    if (!enabled) return;
    await mediumImpact(enabled: enabled);
    await Future.delayed(const Duration(milliseconds: 120));
    await mediumImpact(enabled: enabled);
  }

  /// High-priority alert triggered at 0s (objective spawn).
  static Future<void> spawnAlert({bool enabled = true}) async {
    if (!enabled) return;
    await heavyImpact(enabled: enabled);
    await Future.delayed(const Duration(milliseconds: 100));
    await vibrate(enabled: enabled);
  }

  /// Dispatches a tactical alert based on [TacticalHapticType].
  static Future<void> triggerAlert(
    TacticalHapticType type, {
    bool enabled = true,
  }) async {
    if (!enabled) return;

    switch (type) {
      case TacticalHapticType.warning30s:
        await alert30s(enabled: enabled);
        break;
      case TacticalHapticType.critical10s:
        await warning10s(enabled: enabled);
        break;
      case TacticalHapticType.spawn:
        await spawnAlert(enabled: enabled);
        break;
      case TacticalHapticType.tap:
        await selectionClick(enabled: enabled);
        break;
    }
  }
}
