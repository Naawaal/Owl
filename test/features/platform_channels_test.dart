// language: Dart, file: platform_channels_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/data/screen_capture_channel.dart';
import 'package:owl/features/overlay/data/overlay_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScreenCaptureChannel Platform Channel Tests', () {
    const captureChannel = MethodChannel('com.example.owl/screen_capture');
    const screenCapture = ScreenCaptureChannel();

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, null);
    });

    test('hasCapturePermission queries native method', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, (call) async {
        if (call.method == 'hasCapturePermission') return true;
        return null;
      });

      expect(await screenCapture.hasCapturePermission(), isTrue);
    });

    test('requestCapturePermission forwards request to platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, (call) async {
        if (call.method == 'requestCapturePermission') return true;
        return null;
      });

      expect(await screenCapture.requestCapturePermission(), isTrue);
    });

    test('getLatestFrame deserializes raw frame payload', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4]);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, (call) async {
        if (call.method == 'getLatestFrame') {
          return {
            'bytes': sampleBytes,
            'width': 320,
            'height': 180,
          };
        }
        return null;
      });

      final frame = await screenCapture.getLatestFrame();
      expect(frame, isNotNull);
      expect(frame!.width, equals(320));
      expect(frame.height, equals(180));
      expect(frame.bytes, equals(sampleBytes));
    });

    test('stopCapture invokes stop on platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, (call) async {
        if (call.method == 'stopCapture') return true;
        return null;
      });

      expect(await screenCapture.stopCapture(), isTrue);
    });

    test('handles platform exceptions gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(captureChannel, (call) async {
        throw PlatformException(code: 'ERROR', message: 'Capture failure');
      });

      expect(await screenCapture.hasCapturePermission(), isFalse);
      expect(await screenCapture.getLatestFrame(), isNull);
    });
  });

  group('OverlayChannel Platform Channel Tests', () {
    const gamesChannel = MethodChannel('com.example.owl/games');
    const overlay = OverlayChannel();

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(gamesChannel, null);
    });

    test('hasOverlayPermission queries native method', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(gamesChannel, (call) async {
        if (call.method == 'hasOverlayPermission') return true;
        return null;
      });

      expect(await overlay.hasOverlayPermission(), isTrue);
    });

    test('showFloatingOverlay and hideFloatingOverlay invoke platform', () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(gamesChannel, (call) async {
        calls.add(call.method);
        return true;
      });

      expect(await overlay.showFloatingOverlay(), isTrue);
      expect(await overlay.hideFloatingOverlay(), isTrue);
      expect(calls, contains('showFloatingOverlay'));
      expect(calls, contains('hideFloatingOverlay'));
    });

    test('updateTacticalAdvice passes structured directive payload', () async {
      MethodCall? lastCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(gamesChannel, (call) async {
        lastCall = call;
        return true;
      });

      final success = await overlay.updateTacticalAdvice(
        badge: 'TACTICAL • LIVE',
        action: 'Rotate to Lord Pit',
        warning: 'Enemy Mid laner missing',
      );

      expect(success, isTrue);
      expect(lastCall, isNotNull);
      expect(lastCall!.method, equals('updateTacticalAdvice'));
      expect(lastCall!.arguments['badge'], equals('TACTICAL • LIVE'));
      expect(lastCall!.arguments['action'], equals('Rotate to Lord Pit'));
      expect(lastCall!.arguments['warning'], equals('Enemy Mid laner missing'));
    });
  });
}
