// language: Dart, file: lib/core/errors/failures.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter/foundation.dart';
import 'exceptions.dart';

/// Base failure class representing a handled domain error in Owl.
@immutable
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType.toString());
    buffer.write(': $message');
    if (code != null) buffer.write(' ($code)');
    return buffer.toString();
  }
}

/// Represents failure during network requests, timeouts, or remote server issues.
class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  factory NetworkFailure.fromException(NetworkException exception) =>
      NetworkFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
        statusCode: exception.statusCode,
      );

  factory NetworkFailure.timeout([String? message]) => NetworkFailure(
        message: message ?? 'Network request timed out.',
        code: 'NETWORK_TIMEOUT',
      );

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection detected.',
        code: 'NO_INTERNET',
      );
}

/// Represents failure during local or secure storage operations.
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageFailure.fromException(StorageException exception) =>
      StorageFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
}

/// Represents failure originating from AI coaching, inference, or streaming providers.
class AICoachFailure extends Failure {
  final String? provider;

  const AICoachFailure({
    required super.message,
    super.code,
    super.details,
    this.provider,
  });

  factory AICoachFailure.fromException(AICoachException exception) =>
      AICoachFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
        provider: exception.provider,
      );

  factory AICoachFailure.invalidApiKey({String? provider}) => AICoachFailure(
        message: 'Invalid or missing API key for ${provider ?? "AI"}.',
        code: 'INVALID_API_KEY',
        provider: provider,
      );
}

/// Represents failure due to missing or denied Android/system permissions (overlay, screen capture).
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory PermissionFailure.fromException(OverlayPermissionException exception) =>
      PermissionFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );

  factory PermissionFailure.overlayDenied() => const PermissionFailure(
        message: 'System alert overlay window permission is denied.',
        code: 'OVERLAY_PERMISSION_DENIED',
      );

  factory PermissionFailure.screenCaptureDenied() => const PermissionFailure(
        message: 'Screen recording/projection permission is denied.',
        code: 'SCREEN_CAPTURE_DENIED',
      );
}
