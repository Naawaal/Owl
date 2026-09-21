import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'storage_service.dart';

enum LaunchStatus {
  success,
  notInstalled,
  launchFailed,
  permissionDenied,
}

class LaunchResult {
  final LaunchStatus status;
  final String? errorMessage;

  const LaunchResult.success()
      : status = LaunchStatus.success,
        errorMessage = null;

  const LaunchResult.failure(this.status, this.errorMessage);

  bool get isSuccess => status == LaunchStatus.success;
}

class LauncherService {
  final StorageService? _storageService;

  LauncherService([this._storageService]);

  /// Checks whether a package is considered installed on the device.
  /// Checks mock override first, then platform capability.
  Future<bool> isGameInstalled(String packageName, {String gameId = ''}) async {
    // If mock toggle is enabled in storage, prioritize it
    if (_storageService != null && gameId.isNotEmpty) {
      if (_storageService.prefs.containsKey('mock_installed_$gameId')) {
        return _storageService.isMockGameInstalled(gameId);
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: packageName,
          category: 'android.intent.category.LAUNCHER',
        );
        final canResolve = await intent.canResolveActivity();
        return canResolve ?? false;
      } catch (e) {
        debugPrint('Error checking package resolution: $e');
        return false;
      }
    }

    // Default simulation on desktop or development: first 2 games installed
    return gameId == 'subway-surfers' || gameId == 'free-fire';
  }

  /// Check if the package can be launched right now
  Future<bool> canLaunch(String packageName, {String gameId = ''}) async {
    return await isGameInstalled(packageName, gameId: gameId);
  }

  /// Launch the game with enabled plugins
  Future<LaunchResult> launchGame(
    String packageName, {
    String gameId = '',
    List<dynamic> enabledPlugins = const [],
    List<String>? enabledPluginIds,
    bool simulateSuccessOnNonAndroid = true,
  }) async {
    final installed = await isGameInstalled(packageName, gameId: gameId);
    if (!installed) {
      return const LaunchResult.failure(
        LaunchStatus.notInstalled,
        'Game is not installed on this device. Please install it first.',
      );
    }

    if (!kIsWeb && Platform.isAndroid) {
      try {
        final List<String> activeIds = enabledPluginIds ??
            enabledPlugins.map((p) {
              if (p is String) return p;
              try {
                return (p as dynamic).id.toString();
              } catch (_) {
                return p.toString();
              }
            }).toList();

        // Collect plugin parameters/metadata to pass via intent extras if desired
        final Map<String, dynamic> arguments = {
          'lulubox_active_plugins': activeIds,
          'lulubox_timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: packageName,
          category: 'android.intent.category.LAUNCHER',
          arguments: arguments,
        );

        final canResolve = await intent.canResolveActivity();
        if (canResolve != true) {
          return const LaunchResult.failure(
            LaunchStatus.launchFailed,
            'Unable to resolve launch activity for this game package.',
          );
        }

        await intent.launch();
        return const LaunchResult.success();
      } on PlatformException catch (pe) {
        return LaunchResult.failure(
          LaunchStatus.launchFailed,
          'Platform error launching game: ${pe.message}',
        );
      } catch (e) {
        return LaunchResult.failure(
          LaunchStatus.launchFailed,
          'Failed to launch game: $e',
        );
      }
    }

    // Non-Android simulator / desktop testing environment
    if (simulateSuccessOnNonAndroid) {
      await Future.delayed(const Duration(milliseconds: 600));
      return const LaunchResult.success();
    }

    return const LaunchResult.failure(
      LaunchStatus.launchFailed,
      'Launching external games is only supported on Android devices.',
    );
  }
}
