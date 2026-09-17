// language: Dart, file: overlay_channel.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/services.dart';

/// Platform channel interface communicating with Android GameTurboOverlayService.
class OverlayChannel {
  static const MethodChannel _channel = MethodChannel('com.example.owl/games');

  const OverlayChannel();

  /// Checks if SYSTEM_ALERT_WINDOW permission is granted.
  Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the user to enable display over other apps in system settings.
  Future<bool> requestOverlayPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestOverlayPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Displays the floating GameTurbo edge handle.
  Future<bool> showFloatingOverlay({String? gameName}) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'showFloatingOverlay',
        <String, dynamic>{
          if (gameName != null && gameName.isNotEmpty) 'gameName': gameName,
        },
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Hides the floating GameTurbo overlay.
  Future<bool> hideFloatingOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('hideFloatingOverlay');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Pushes real-time tactical guidance directly onto the native Guardian overlay HUD.
  Future<bool> updateTacticalAdvice({
    required String badge,
    required String action,
    String? warning,
  }) async {
    try {
      final payload = <String, dynamic>{
        'badge': badge,
        'action': action,
      };
      if (warning != null) {
        payload['warning'] = warning;
      }
      final result =
          await _channel.invokeMethod<bool>('updateTacticalAdvice', payload);
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Pushes live match context into the native Guardian AI overlay so the
  /// autonomous inference loop uses the same game grounding as Flutter.
  ///
  /// Silent no-op when the overlay service is not bound (try/catch swallows).
  Future<void> setGameContext({
    required String gameCategory,
    required String preferredRole,
    required String coachingLevel,
    required int matchElapsedSeconds,
  }) async {
    try {
      await _channel.invokeMethod<void>('setGameContext', <String, dynamic>{
        'gameCategory': gameCategory,
        'preferredRole': preferredRole,
        'coachingLevel': coachingLevel,
        'matchElapsedSeconds': matchElapsedSeconds,
      });
    } catch (_) {
      // Overlay not bound or platform call failed — non-fatal, continue silently.
    }
  }

  /// Shows the native Guardian AI coaching bubble over the game.
  Future<bool> showGuardianOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('showGuardianOverlay');
      return result ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Hides the native Guardian AI coaching bubble.
  Future<bool> hideGuardianOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('hideGuardianOverlay');
      return result ?? true;
    } catch (_) {
      return false;
    }
  }
}
