// language: Dart, file: test/core/errors/errors_test.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';

void main() {
  group('Exceptions', () {
    test('NetworkException factories produce expected codes', () {
      final timeout = NetworkException.timeout();
      expect(timeout.code, equals('NETWORK_TIMEOUT'));
      expect(timeout.message, contains('timed out'));

      final serverError = NetworkException.serverError(statusCode: 500);
      expect(serverError.statusCode, equals(500));
      expect(serverError.code, equals('SERVER_ERROR'));
    });

    test('StorageException factories produce expected codes', () {
      final ex = StorageException.readFailed('test_key');
      expect(ex.code, equals('STORAGE_READ_FAILED'));
      expect(ex.message, contains('test_key'));
    });

    test('AICoachException factories produce expected codes and provider', () {
      final ex = AICoachException.invalidApiKey(provider: 'OpenAI');
      expect(ex.code, equals('INVALID_API_KEY'));
      expect(ex.provider, equals('OpenAI'));
    });

    test('OverlayPermissionException factories produce expected codes', () {
      final ex = OverlayPermissionException.systemAlertWindowDenied();
      expect(ex.code, equals('OVERLAY_PERMISSION_DENIED'));
    });
  });

  group('Failures', () {
    test('NetworkFailure from exception preserves attributes', () {
      final ex = NetworkException.serverError(statusCode: 404, message: 'Not found');
      final failure = NetworkFailure.fromException(ex);
      expect(failure.statusCode, equals(404));
      expect(failure.message, equals('Not found'));
      expect(failure.code, equals('SERVER_ERROR'));
    });

    test('StorageFailure equality and toString work correctly', () {
      const f1 = StorageFailure(message: 'Failed', code: 'CODE1');
      const f2 = StorageFailure(message: 'Failed', code: 'CODE1');
      const f3 = StorageFailure(message: 'Other', code: 'CODE2');

      expect(f1, equals(f2));
      expect(f1 == f3, isFalse);
      expect(f1.toString(), contains('StorageFailure: Failed (CODE1)'));
    });

    test('AICoachFailure from exception retains provider', () {
      final ex = AICoachException.quotaExceeded(provider: 'DeepSeek');
      final failure = AICoachFailure.fromException(ex);
      expect(failure.provider, equals('DeepSeek'));
      expect(failure.code, equals('QUOTA_EXCEEDED'));
    });

    test('PermissionFailure overlay and screen capture factories', () {
      final f1 = PermissionFailure.overlayDenied();
      expect(f1.code, equals('OVERLAY_PERMISSION_DENIED'));

      final f2 = PermissionFailure.screenCaptureDenied();
      expect(f2.code, equals('SCREEN_CAPTURE_DENIED'));
    });
  });
}
