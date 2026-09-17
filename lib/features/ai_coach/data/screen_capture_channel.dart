// language: Dart, file: screen_capture_channel.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/services.dart';

/// Platform channel interface coordinating Android MediaProjection screen capture.
class ScreenCaptureChannel {
  static const MethodChannel _channel =
      MethodChannel('com.example.owl/screen_capture');

  const ScreenCaptureChannel();

  /// Checks if MediaProjection capture permission is active.
  Future<bool> hasCapturePermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasCapturePermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests MediaProjection authorization from the user.
  Future<bool> requestCapturePermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestCapturePermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the latest screen frame captured via MediaProjection.
  Future<({Uint8List bytes, int width, int height})?> getLatestFrame() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getLatestFrame');
      if (result == null) return null;
      final bytes = result['bytes'] as Uint8List?;
      final width = (result['width'] as num?)?.toInt() ?? 0;
      final height = (result['height'] as num?)?.toInt() ?? 0;
      if (bytes == null || width <= 0 || height <= 0) return null;
      return (bytes: bytes, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  /// Releases and stops the screen capture stream.
  Future<bool> stopCapture() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopCapture');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
