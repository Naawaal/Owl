// language: Dart, file: lib/core/errors/exceptions.dart, target: Flutter / Owl MOBA HUD

/// Base exception class for all domain and infrastructure errors in Owl.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType.toString());
    buffer.write(': $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (details != null) {
      buffer.write(' [Details: $details]');
    }
    return buffer.toString();
  }
}

/// Thrown when a network request fails, times out, or receives an error status code.
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  factory NetworkException.timeout({String? message}) => NetworkException(
        message: message ?? 'Network request timed out. Please verify connection.',
        code: 'NETWORK_TIMEOUT',
      );

  factory NetworkException.noInternet({String? message}) => NetworkException(
        message: message ?? 'No active network connection detected.',
        code: 'NO_INTERNET',
      );

  factory NetworkException.serverError({
    int? statusCode,
    String? message,
    dynamic details,
  }) =>
      NetworkException(
        message: message ?? 'Server responded with error status $statusCode.',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
        details: details,
      );
}

/// Thrown when local or secure storage read/write operations fail.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageException.readFailed(String key, [dynamic error]) =>
      StorageException(
        message: 'Failed to read data for key "$key" from storage.',
        code: 'STORAGE_READ_FAILED',
        details: error,
      );

  factory StorageException.writeFailed(String key, [dynamic error]) =>
      StorageException(
        message: 'Failed to persist data for key "$key" to storage.',
        code: 'STORAGE_WRITE_FAILED',
        details: error,
      );

  factory StorageException.deleteFailed(String key, [dynamic error]) =>
      StorageException(
        message: 'Failed to delete key "$key" from storage.',
        code: 'STORAGE_DELETE_FAILED',
        details: error,
      );
}

/// Thrown when AI LLM completion, token streaming, or tactical coaching logic fails.
class AICoachException extends AppException {
  final String? provider;

  const AICoachException({
    required super.message,
    super.code,
    super.details,
    this.provider,
  });

  factory AICoachException.invalidApiKey({String? provider}) =>
      AICoachException(
        message: 'Missing or invalid API key for provider ${provider ?? "AI"}.',
        code: 'INVALID_API_KEY',
        provider: provider,
      );

  factory AICoachException.quotaExceeded({String? provider}) =>
      AICoachException(
        message: 'API rate limit or quota exceeded for ${provider ?? "AI"}.',
        code: 'QUOTA_EXCEEDED',
        provider: provider,
      );

  factory AICoachException.streamInterrupted({String? provider, dynamic details}) =>
      AICoachException(
        message: 'AI streaming response was interrupted or terminated prematurely.',
        code: 'STREAM_INTERRUPTED',
        provider: provider,
        details: details,
      );
}

/// Thrown when Android overlay window (`SYSTEM_ALERT_WINDOW`) or screen capture permissions are denied.
class OverlayPermissionException extends AppException {
  const OverlayPermissionException({
    required super.message,
    super.code,
    super.details,
  });

  factory OverlayPermissionException.systemAlertWindowDenied() =>
      const OverlayPermissionException(
        message: 'Overlay permission (SYSTEM_ALERT_WINDOW) is required to show the tactical HUD.',
        code: 'OVERLAY_PERMISSION_DENIED',
      );

  factory OverlayPermissionException.screenCaptureDenied() =>
      const OverlayPermissionException(
        message: 'Screen capture permission was denied by user.',
        code: 'SCREEN_CAPTURE_DENIED',
      );
}
