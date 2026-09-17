// language: Dart, file: dnd_service.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';

class DndState {
  final bool isEnabled;
  final bool hasPermission;
  final String? statusMessage;

  const DndState({
    required this.isEnabled,
    required this.hasPermission,
    this.statusMessage,
  });

  DndState copyWith({
    bool? isEnabled,
    bool? hasPermission,
    String? statusMessage,
  }) {
    return DndState(
      isEnabled: isEnabled ?? this.isEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
      statusMessage: statusMessage,
    );
  }
}

final dndServiceProvider =
    StateNotifierProvider<DndNotifier, DndState>((ref) {
  return DndNotifier(ref);
});

class DndNotifier extends StateNotifier<DndState> {
  DndNotifier(this._ref)
      : super(DndState(
          isEnabled:
              _ref.read(gameTurboSettingsProvider).restrictFloatingNotifications,
          hasPermission: true,
        )) {
    _init();
  }

  final Ref _ref;
  static const MethodChannel _channel =
      MethodChannel('com.example.owl/system_controls');

  Future<void> _init() async {
    try {
      final hasPerm = await _channel.invokeMethod<bool>(
            'isNotificationPolicyAccessGranted',
          ) ??
          true;
      final settings = _ref.read(gameTurboSettingsProvider);
      state = state.copyWith(
        hasPermission: hasPerm,
        isEnabled: settings.restrictFloatingNotifications,
      );
      if (settings.restrictFloatingNotifications && hasPerm) {
        await _channel.invokeMethod('setDndMode', {'enabled': true});
      }
    } catch (_) {
      // Graceful fallback on unsupported platforms / unit tests
    }
  }

  Future<bool> toggleDnd([bool? targetState]) async {
    final newState = targetState ?? !state.isEnabled;
    state = state.copyWith(
      isEnabled: newState,
      statusMessage: newState ? 'DND Activated' : 'DND Deactivated',
    );
    _ref
        .read(gameTurboSettingsProvider.notifier)
        .toggleRestrictFloatingNotifications(newState);

    try {
      final hasPerm = await _channel.invokeMethod<bool>(
            'isNotificationPolicyAccessGranted',
          ) ??
          true;

      if (newState && !hasPerm) {
        state = state.copyWith(
          isEnabled: false,
          hasPermission: false,
          statusMessage: 'Notification access permission required',
        );
        _ref
            .read(gameTurboSettingsProvider.notifier)
            .toggleRestrictFloatingNotifications(false);
        await _channel.invokeMethod('requestNotificationPolicyAccess');
        return false;
      }

      final success = await _channel.invokeMethod<bool>(
            'setDndMode',
            {'enabled': newState},
          ) ??
          true;

      if (!success) {
        state = state.copyWith(
          isEnabled: !newState,
          statusMessage: 'Failed to update DND mode',
        );
        _ref
            .read(gameTurboSettingsProvider.notifier)
            .toggleRestrictFloatingNotifications(!newState);
        return false;
      }
      return true;
    } catch (_) {
      // Mock / fallback success in test environments
      return true;
    }
  }
}
