import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl_core/owl_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the platform [SharedPreferences] instance.
/// Typically overridden in `main.dart` with the asynchronously loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope with an initialized SharedPreferences instance.',
  );
});

/// Provider for [LocalStorageService].
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

/// Reactive provider for the active game profile.
final activeGameProfileProvider =
    StateNotifierProvider<ActiveGameNotifier, String>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ActiveGameNotifier(storage);
});

/// Reactive provider for sound effects enabled setting.
final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SoundEnabledNotifier(storage);
});

/// Reactive provider for haptic feedback enabled setting.
final hapticEnabledProvider =
    StateNotifierProvider<HapticEnabledNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return HapticEnabledNotifier(storage);
});

/// Reactive provider for overlay opacity setting.
final overlayOpacityProvider =
    StateNotifierProvider<OverlayOpacityNotifier, double>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return OverlayOpacityNotifier(storage);
});

/// Reactive provider for overlay scale setting.
final overlayScaleProvider =
    StateNotifierProvider<OverlayScaleNotifier, double>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return OverlayScaleNotifier(storage);
});

/// Reactive provider for the active theme mode (defaults to [ThemeMode.system]).
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  try {
    final storage = ref.watch(localStorageServiceProvider);
    return ThemeModeNotifier(storage);
  } catch (_) {
    // Fallback for headless tests or un-overridden scopes
    return ThemeModeNotifier(null);
  }
});

/// Service wrapping [SharedPreferences] for persistent preferences and HUD configuration.
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyThemeMode = 'owl_theme_mode';
  static const String _keyActiveGame = 'owl_active_game_profile';
  static const String _keySoundEnabled = 'owl_sound_enabled';
  static const String _keyHapticEnabled = 'owl_haptic_enabled';
  static const String _keyOverlayOpacity = 'owl_overlay_opacity';
  static const String _keyOverlayScale = 'owl_overlay_scale';

  // --- Theme Mode (defaults to ThemeMode.system) ---
  ThemeMode getThemeMode() {
    try {
      final value = _prefs.getString(_keyThemeMode);
      switch (value) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      throw StorageException.readFailed(_keyThemeMode, e);
    }
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      return await _prefs.setString(_keyThemeMode, value);
    } catch (e) {
      throw StorageException.writeFailed(_keyThemeMode, e);
    }
  }

  // --- Active Game Profile ---
  String getActiveGameProfile() {
    try {
      return _prefs.getString(_keyActiveGame) ?? AppConstants.gameWildRift;
    } catch (e) {
      throw StorageException.readFailed(_keyActiveGame, e);
    }
  }

  Future<bool> setActiveGameProfile(String gameName) async {
    try {
      return await _prefs.setString(_keyActiveGame, gameName);
    } catch (e) {
      throw StorageException.writeFailed(_keyActiveGame, e);
    }
  }

  // --- Sound Enabled ---
  bool isSoundEnabled() {
    try {
      return _prefs.getBool(_keySoundEnabled) ?? true;
    } catch (e) {
      throw StorageException.readFailed(_keySoundEnabled, e);
    }
  }

  Future<bool> setSoundEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_keySoundEnabled, enabled);
    } catch (e) {
      throw StorageException.writeFailed(_keySoundEnabled, e);
    }
  }

  // --- Haptic Enabled ---
  bool isHapticEnabled() {
    try {
      return _prefs.getBool(_keyHapticEnabled) ?? true;
    } catch (e) {
      throw StorageException.readFailed(_keyHapticEnabled, e);
    }
  }

  Future<bool> setHapticEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_keyHapticEnabled, enabled);
    } catch (e) {
      throw StorageException.writeFailed(_keyHapticEnabled, e);
    }
  }

  // --- Overlay Opacity ---
  double getOverlayOpacity() {
    try {
      return _prefs.getDouble(_keyOverlayOpacity) ??
          AppConstants.defaultOverlayOpacity;
    } catch (e) {
      throw StorageException.readFailed(_keyOverlayOpacity, e);
    }
  }

  Future<bool> setOverlayOpacity(double opacity) async {
    try {
      final clamped = opacity.clamp(
        AppConstants.minOverlayOpacity,
        AppConstants.maxOverlayOpacity,
      );
      return await _prefs.setDouble(_keyOverlayOpacity, clamped);
    } catch (e) {
      throw StorageException.writeFailed(_keyOverlayOpacity, e);
    }
  }

  // --- Overlay Scale ---
  double getOverlayScale() {
    try {
      return _prefs.getDouble(_keyOverlayScale) ??
          AppConstants.defaultOverlayScale;
    } catch (e) {
      throw StorageException.readFailed(_keyOverlayScale, e);
    }
  }

  Future<bool> setOverlayScale(double scale) async {
    try {
      final clamped = scale.clamp(
        AppConstants.minOverlayScale,
        AppConstants.maxOverlayScale,
      );
      return await _prefs.setDouble(_keyOverlayScale, clamped);
    } catch (e) {
      throw StorageException.writeFailed(_keyOverlayScale, e);
    }
  }

  // --- Clear all settings ---
  Future<bool> clearAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw StorageException(
        message: 'Failed to clear local preferences.',
        code: 'STORAGE_CLEAR_FAILED',
        details: e,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Reactive Notifiers
// ---------------------------------------------------------------------------

class ActiveGameNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;

  ActiveGameNotifier(this._storage) : super(_storage.getActiveGameProfile());

  Future<void> setGame(String game) async {
    state = game;
    await _storage.setActiveGameProfile(game);
  }
}

class SoundEnabledNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  SoundEnabledNotifier(this._storage) : super(_storage.isSoundEnabled());

  Future<void> toggle() async => setEnabled(!state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.setSoundEnabled(enabled);
  }
}

class HapticEnabledNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  HapticEnabledNotifier(this._storage) : super(_storage.isHapticEnabled());

  Future<void> toggle() async => setEnabled(!state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.setHapticEnabled(enabled);
  }
}

class OverlayOpacityNotifier extends StateNotifier<double> {
  final LocalStorageService _storage;

  OverlayOpacityNotifier(this._storage) : super(_storage.getOverlayOpacity());

  Future<void> setOpacity(double opacity) async {
    final clamped = opacity.clamp(
      AppConstants.minOverlayOpacity,
      AppConstants.maxOverlayOpacity,
    );
    state = clamped;
    await _storage.setOverlayOpacity(clamped);
  }
}

class OverlayScaleNotifier extends StateNotifier<double> {
  final LocalStorageService _storage;

  OverlayScaleNotifier(this._storage) : super(_storage.getOverlayScale());

  Future<void> setScale(double scale) async {
    final clamped = scale.clamp(
      AppConstants.minOverlayScale,
      AppConstants.maxOverlayScale,
    );
    state = clamped;
    await _storage.setOverlayScale(clamped);
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService? _storage;

  ThemeModeNotifier([this._storage])
      : super(_storage?.getThemeMode() ?? ThemeMode.system);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage?.setThemeMode(mode);
  }
}

