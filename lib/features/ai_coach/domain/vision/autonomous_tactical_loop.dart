// language: Dart, file: autonomous_tactical_loop.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/ai_coach/data/screen_capture_channel.dart';
import 'package:owl/features/ai_coach/domain/vision/frame_differ.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';

/// Central Riverpod provider managing the background autonomous vision and tactical game-tick loop.
final autonomousTacticalLoopProvider =
    ChangeNotifierProvider<AutonomousTacticalLoop>((ref) {
  final loop = AutonomousTacticalLoop(
    onCaptureFrame: () => const ScreenCaptureChannel().getLatestFrame(),
    onActiveTick: (bytes, width, height, matchTime) async {
      final currentSettings = ref.read(gameTurboSettingsProvider);
      if (currentSettings.guardianVisionEnabled &&
          currentSettings.guardianTacticalEngine &&
          currentSettings.assistantMode == 'live') {
        await ref.read(coachServiceProvider.notifier).requestTopicRefresh();
      }
    },
  );

  final initialSettings = ref.read(gameTurboSettingsProvider);
  loop.setPerformanceMode(initialSettings.performanceMode);

  // Dynamically adapt cadence and lifecycle to settings changes without recreating loop
  ref.listen<GameTurboSettings>(gameTurboSettingsProvider, (_, next) {
    loop.setPerformanceMode(next.performanceMode);
    if (!next.guardianTacticalEngine ||
        next.assistantMode == 'off' ||
        !next.gameTurboMaster) {
      if (loop.isRunning && !loop.isPaused) loop.pause();
    } else if (loop.isRunning && loop.isPaused) {
      loop.resume();
    }
  });

  ref.onDispose(() => loop.dispose());
  return loop;
});

/// Performance-driven autonomous background game-tick loop.
///
/// Continuously samples game frames at a cadence determined by the user's
/// performance profile (1 FPS for battery saver, 5 FPS for balanced, 12 FPS for high).
/// Compares successive frames using [FrameDiffer]; if the screen is static or loading
/// (deviation < 3.0%), redundant tactical evaluation is suppressed.
class AutonomousTacticalLoop extends ChangeNotifier {
  AutonomousTacticalLoop({
    this.onCaptureFrame,
    this.onActiveTick,
    this.onStaticTick,
    this.staticThreshold = 3.0,
  });

  /// Function invoked to retrieve the current screen frame (RGBA buffer, width, height).
  final Future<({Uint8List bytes, int width, int height})?> Function()? onCaptureFrame;

  /// Callback executed when dynamic gameplay is detected on the active frame.
  final Future<void> Function(
    Uint8List frameBytes,
    int width,
    int height,
    int matchTimeSeconds,
  )? onActiveTick;

  /// Optional callback executed on a tick where the screen was determined to be static.
  final void Function(int matchTimeSeconds, double diffPercent)? onStaticTick;

  final double staticThreshold;

  Timer? _tickTimer;
  Timer? _clockTimer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isProcessingTick = false;
  bool _isStaticScreen = false;

  String _performanceMode = 'balanced';
  int _matchTimeSeconds = 0;
  int _framesProcessed = 0;
  int _framesSuppressed = 0;
  double _lastDiffPercent = 0.0;
  Uint8List? _lastThumbnail;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isStaticScreen => _isStaticScreen;
  String get performanceMode => _performanceMode;
  int get matchTimeSeconds => _matchTimeSeconds;
  int get framesProcessed => _framesProcessed;
  int get framesSuppressed => _framesSuppressed;
  double get lastDiffPercent => _lastDiffPercent;

  /// Returns the configured sampling frequency in Hertz (frames per second).
  int get targetCadenceFps {
    switch (_performanceMode) {
      case 'saver':
        return 1;
      case 'high':
        return 12;
      case 'balanced':
      default:
        return 5;
    }
  }

  /// The tick interval corresponding to [targetCadenceFps].
  Duration get cadenceInterval {
    final fps = targetCadenceFps;
    return Duration(milliseconds: (1000 / fps).round());
  }

  /// Starts the autonomous tactical loop.
  void start({String performanceMode = 'balanced', int initialMatchTimeSeconds = 0}) {
    if (_isRunning) stop();

    _performanceMode = performanceMode;
    _matchTimeSeconds = initialMatchTimeSeconds;
    _isRunning = true;
    _isPaused = false;
    _isProcessingTick = false;
    _isStaticScreen = false;
    _framesProcessed = 0;
    _framesSuppressed = 0;
    _lastThumbnail = null;

    // Start 1-second match clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isRunning) {
        _matchTimeSeconds++;
        notifyListeners();
      }
    });

    _scheduleCadenceTimer();
    notifyListeners();
  }

  /// Updates the performance mode and dynamically resets the timer cadence.
  void setPerformanceMode(String mode) {
    if (_performanceMode == mode) return;
    _performanceMode = mode;
    if (_isRunning && !_isPaused) {
      _scheduleCadenceTimer();
    }
    notifyListeners();
  }

  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _tickTimer?.cancel();
    _tickTimer = null;
    notifyListeners();
  }

  void resume() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _scheduleCadenceTimer();
    notifyListeners();
  }

  /// Stops the background loop and cleans up timers and buffers.
  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _clockTimer?.cancel();
    _clockTimer = null;
    _isRunning = false;
    _isPaused = false;
    _isProcessingTick = false;
    _lastThumbnail = null;
    notifyListeners();
  }

  void _scheduleCadenceTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(cadenceInterval, (_) => _handleTick());
  }

  /// Executes a single sampling iteration.
  Future<void> _handleTick() async {
    if (!_isRunning || _isPaused || _isProcessingTick) return;
    if (onCaptureFrame == null) return;

    _isProcessingTick = true;
    try {
      final frame = await onCaptureFrame!();
      if (frame == null) {
        _isProcessingTick = false;
        return;
      }

      _framesProcessed++;

      // Downsample to 32x32 single-channel grayscale thumbnail
      final currentThumb = FrameDiffer.downsampleRgbaTo32x32(
        frame.bytes,
        frame.width,
        frame.height,
      );

      if (_lastThumbnail != null) {
        _lastDiffPercent = FrameDiffer.computeDifferencePercentage(
          _lastThumbnail!,
          currentThumb,
        );

        if (_lastDiffPercent < staticThreshold) {
          // Static screen detected (e.g. pause, shop, or loading screen)
          _isStaticScreen = true;
          _framesSuppressed++;
          onStaticTick?.call(_matchTimeSeconds, _lastDiffPercent);
          notifyListeners();
          return;
        }
      }

      // Frame has dynamic content
      _isStaticScreen = false;
      _lastThumbnail = currentThumb;

      if (onActiveTick != null) {
        await onActiveTick!(
          frame.bytes,
          frame.width,
          frame.height,
          _matchTimeSeconds,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AutonomousTacticalLoop tick error: $e');
    } finally {
      _isProcessingTick = false;
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
