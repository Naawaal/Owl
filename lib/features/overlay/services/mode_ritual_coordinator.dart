// language: Dart, file: mode_ritual_coordinator.dart, target: Flutter / Owl Game Turbo
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot of focus-tool state before entering Performance (restored on Balanced).
class ModeRitualPriors {
  const ModeRitualPriors({
    required this.dnd,
    required this.wifiBoost,
    required this.restrictGestures,
    required this.mistouchRejection,
    required this.horizonBrightness,
  });

  final bool dnd;
  final bool wifiBoost;
  final bool restrictGestures;
  final String mistouchRejection;
  final bool horizonBrightness;

  Map<String, dynamic> toJson() => {
        'dnd': dnd,
        'wifiBoost': wifiBoost,
        'restrictGestures': restrictGestures,
        'mistouchRejection': mistouchRejection,
        'horizonBrightness': horizonBrightness,
      };

  factory ModeRitualPriors.fromJson(Map<String, dynamic> json) {
    return ModeRitualPriors(
      dnd: json['dnd'] as bool? ?? false,
      wifiBoost: json['wifiBoost'] as bool? ?? false,
      restrictGestures: json['restrictGestures'] as bool? ?? false,
      mistouchRejection: json['mistouchRejection'] as String? ?? 'Medium',
      horizonBrightness: json['horizonBrightness'] as bool? ?? true,
    );
  }
}

/// Result of applying a Balanced/Performance ritual package.
class ModeRitualResult {
  const ModeRitualResult({
    required this.isPerformance,
    required this.targetFps,
    required this.message,
  });

  final bool isPerformance;
  final int targetFps;
  final String message;
}

/// Applies portable focus package + restores priors. Best-effort; never throws.
class ModeRitualCoordinator {
  ModeRitualCoordinator._();
  static final ModeRitualCoordinator instance = ModeRitualCoordinator._();

  static const _priorsKey = 'owl_mode_ritual_priors_v1';
  static const _sysChannel = MethodChannel('com.example.owl/system_controls');
  static const _gamesChannel = MethodChannel('com.example.owl/games');

  /// Called after mode prefs + native FPS/refresh apply.
  Future<ModeRitualResult> apply({
    required SharedPreferences? prefs,
    required GameTurboSettings settings,
    required bool isPerformance,
    required int targetFps,
    required void Function(GameTurboSettings Function(GameTurboSettings)) patch,
  }) async {
    if (isPerformance) {
      await _captureAndSavePriors(prefs, settings);
      await _setDnd(true);
      await _setWifi(true);
      await _setGestures(true);
      patch(
        (s) => s.copyWith(
          restrictFloatingNotifications: true,
          wifiSpeedBoost: true,
          restrictButtonsAndGestures: true,
          gpuMistouchRejection: 'High',
          gpuHorizonBrightness: true,
        ),
      );
      final message =
          'Performance · quieter + faster net · $targetFps FPS';
      await _showNativeToast(message);
      return ModeRitualResult(
        isPerformance: true,
        targetFps: targetFps,
        message: message,
      );
    }

    final priors = _loadPriors(prefs) ??
        const ModeRitualPriors(
          dnd: false,
          wifiBoost: false,
          restrictGestures: false,
          mistouchRejection: 'Medium',
          horizonBrightness: true,
        );
    await _setDnd(priors.dnd);
    await _setWifi(priors.wifiBoost);
    await _setGestures(priors.restrictGestures);
    patch(
      (s) => s.copyWith(
        restrictFloatingNotifications: priors.dnd,
        wifiSpeedBoost: priors.wifiBoost,
        restrictButtonsAndGestures: priors.restrictGestures,
        gpuMistouchRejection: priors.mistouchRejection,
        gpuHorizonBrightness: priors.horizonBrightness,
      ),
    );
    const message = 'Balanced · cooler for sustained FPS';
    await _showNativeToast(message);
    return const ModeRitualResult(
      isPerformance: false,
      targetFps: 60,
      message: message,
    );
  }

  Future<void> _captureAndSavePriors(
    SharedPreferences? prefs,
    GameTurboSettings settings,
  ) async {
    final priors = ModeRitualPriors(
      dnd: settings.restrictFloatingNotifications,
      wifiBoost: settings.wifiSpeedBoost,
      restrictGestures: settings.restrictButtonsAndGestures,
      mistouchRejection: settings.gpuMistouchRejection,
      horizonBrightness: settings.gpuHorizonBrightness,
    );
    try {
      await prefs?.setString(_priorsKey, jsonEncode(priors.toJson()));
    } catch (_) {}
  }

  ModeRitualPriors? _loadPriors(SharedPreferences? prefs) {
    try {
      final raw = prefs?.getString(_priorsKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ModeRitualPriors.fromJson(decoded);
      }
      if (decoded is Map) {
        return ModeRitualPriors.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  Future<void> _setDnd(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final hasPerm = await _sysChannel.invokeMethod<bool>(
            'isNotificationPolicyAccessGranted',
          ) ??
          false;
      if (enabled && !hasPerm) return;
      await _sysChannel.invokeMethod('setDndMode', {'enabled': enabled});
    } catch (_) {}
  }

  Future<void> _setWifi(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _sysChannel.invokeMethod('setWifiLowLatency', {'enabled': enabled});
    } catch (_) {}
  }

  Future<void> _setGestures(bool restrict) async {
    try {
      if (restrict) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    } catch (_) {}
  }

  Future<void> _showNativeToast(String message) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _gamesChannel.invokeMethod('showModeRitualToast', {
        'message': message,
      });
    } catch (_) {}
  }
}

/// Sync DND/Wi‑Fi Riverpod notifiers after a silent ritual patch (when available).
void syncRitualProviders({
  required bool dnd,
  required bool wifi,
  void Function(bool)? setDndUi,
  void Function(bool)? setWifiUi,
}) {
  setDndUi?.call(dnd);
  setWifiUi?.call(wifi);
}
