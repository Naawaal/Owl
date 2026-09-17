// language: Dart, file: lib/app/app_observer.dart, target: Flutter / Owl MOBA HUD
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ProviderObserver for Riverpod tracking state mutations and logging state lifecycle in debug mode.
///
/// Logs provider initialization, mutations, disposal, and errors to DevTools
/// and diagnostic streams when [kDebugMode] is active (or when explicitly enabled).
class AppObserver extends ProviderObserver {
  const AppObserver({
    this.enableLogging = kDebugMode,
    this.onLog,
  });

  /// Whether logging output should be generated.
  final bool enableLogging;

  /// Optional listener callback for telemetry sinks or test verifications.
  final void Function(String message, {Object? error, StackTrace? stackTrace})?
      onLog;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (!enableLogging) return;

    if (onLog != null) {
      onLog!(message, error: error, stackTrace: stackTrace);
    } else {
      developer.log(
        message,
        name: 'Owl.Riverpod',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Live telemetry updates every ~1s; logging them floods logcat.
  bool _isHighChurnProvider(
    ProviderBase<Object?> provider, [
    Object? value,
  ]) {
    final name = provider.name;
    if (name == 'systemStats') return true;
    final type = provider.runtimeType.toString();
    if (type.contains('SystemStats')) return true;
    // Defensive: AsyncValue / Instance of 'SystemStats' when type erasure differs.
    if (value != null && value.toString().contains('SystemStats')) return true;
    return false;
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (_isHighChurnProvider(provider, value)) {
      _log('[Riverpod:Add] ${provider.name ?? provider.runtimeType}');
      return;
    }
    _log(
      '[Riverpod:Add] ${provider.name ?? provider.runtimeType} -> $value',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (_isHighChurnProvider(provider, newValue)) return;
    _log(
      '[Riverpod:Update] ${provider.name ?? provider.runtimeType}\n'
      '  previous: $previousValue\n'
      '  current:  $newValue',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    _log(
      '[Riverpod:Dispose] ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _log(
      '[Riverpod:Fail] ${provider.name ?? provider.runtimeType} -> $error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
