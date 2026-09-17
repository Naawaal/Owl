// language: Dart, file: system_stats_service.dart, target: Flutter / Owl Game Turbo
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real-time hardware telemetry model for Gaming Console and Overlay HUD.
@immutable
class SystemStats {
  final int battery; // 0–100 %
  final int cpu; // 0–100 %
  final int gpu; // 0–100 %
  final int fps; // live measured FPS (e.g. 60, 90, 120, 144)
  final double? temperatureCelsius;
  final int? ramUsedMb;
  final bool isCharging;
  final DateTime timestamp;

  const SystemStats({
    required this.battery,
    required this.cpu,
    required this.gpu,
    required this.fps,
    this.temperatureCelsius,
    this.ramUsedMb,
    this.isCharging = false,
    required this.timestamp,
  });

  SystemStats copyWith({
    int? battery,
    int? cpu,
    int? gpu,
    int? fps,
    double? temperatureCelsius,
    int? ramUsedMb,
    bool? isCharging,
    DateTime? timestamp,
  }) {
    return SystemStats(
      battery: battery ?? this.battery,
      cpu: cpu ?? this.cpu,
      gpu: gpu ?? this.gpu,
      fps: fps ?? this.fps,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      ramUsedMb: ramUsedMb ?? this.ramUsedMb,
      isCharging: isCharging ?? this.isCharging,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// High-precision Flutter engine frame timing listener measuring real-time rendering FPS.
class RealTimeFpsTracker {
  static final RealTimeFpsTracker instance = RealTimeFpsTracker._();
  RealTimeFpsTracker._();

  final List<int> _recentDurationsMicros = [];
  int _currentFps = 120;
  int _lastKnownRefreshRate = 120;
  bool _isTracking = false;
  DateTime _lastFrameTime = DateTime.now();

  int get currentFps => _currentFps;
  int get displayRefreshRate => _lastKnownRefreshRate;

  void start() {
    if (_isTracking) return;
    _isTracking = true;
    _recentDurationsMicros.clear();
    _detectRefreshRate();
    try {
      WidgetsBinding.instance.addTimingsCallback(_onTimings);
    } catch (_) {}
  }

  void stop() {
    _isTracking = false;
    try {
      WidgetsBinding.instance.removeTimingsCallback(_onTimings);
    } catch (_) {}
  }

  void _detectRefreshRate() {
    try {
      final rate = WidgetsBinding.instance.platformDispatcher.views.firstOrNull?.display.refreshRate;
      if (rate != null && rate > 20) {
        _lastKnownRefreshRate = rate.round();
        _currentFps = _lastKnownRefreshRate;
      }
    } catch (_) {}
  }

  int _targetCeilingFps = 120;

  void setModeTarget(int targetFps) {
    _targetCeilingFps = targetFps;
    if (_currentFps > targetFps) {
      _currentFps = targetFps;
    }
  }

  void _onTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    _detectRefreshRate();
    _lastFrameTime = DateTime.now();

    for (final timing in timings) {
      final totalSpanMicros = timing.totalSpan.inMicroseconds;
      // Valid frame durations between 3ms (333 FPS) and 200ms (5 FPS)
      if (totalSpanMicros >= 3000 && totalSpanMicros <= 200000) {
        _recentDurationsMicros.add(totalSpanMicros);
        if (_recentDurationsMicros.length > 24) {
          _recentDurationsMicros.removeAt(0);
        }
      }
    }

    if (_recentDurationsMicros.isNotEmpty) {
      final avgMicros = _recentDurationsMicros.reduce((a, b) => a + b) / _recentDurationsMicros.length;
      final rawFps = (1000000.0 / avgMicros).round();
      final maxAllowed = math.min(_lastKnownRefreshRate, _targetCeilingFps);
      _currentFps = rawFps.clamp(15, maxAllowed);
    }
  }

  /// Get live FPS, accounting for active frames vs idle vsync settling
  int getLiveMeasuredFps() {
    final maxAllowed = math.min(_lastKnownRefreshRate, _targetCeilingFps);
    final elapsedMs = DateTime.now().difference(_lastFrameTime).inMilliseconds;
    if (elapsedMs < 600 && _recentDurationsMicros.isNotEmpty) {
      return _currentFps.clamp(15, maxAllowed);
    }
    // When idle between touches, the display controller sits at mode ceiling
    return maxAllowed;
  }
}

const _statsEventChannel = EventChannel('com.example.owl/stats');

/// Stream provider for live system stats pushed from native Android via EventChannel
/// with Flutter hardware FrameTiming tracker integration.
final systemStatsProvider = StreamProvider<SystemStats>((ref) {
  final controller = StreamController<SystemStats>();
  final fpsTracker = RealTimeFpsTracker.instance;
  fpsTracker.start();

  int currentBattery = 0;
  int currentCpu = 0;
  int currentGpu = 0;
  int currentFps = fpsTracker.getLiveMeasuredFps();
  double? currentTemperature;
  int? currentRam;
  DateTime lastNativeTick = DateTime.now();

  StreamSubscription? nativeSub;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    // Immediate initial sync from native single-shot readers
    const MethodChannel('com.example.owl/overlay')
        .invokeMethod<int>('getBatteryLevel')
        .then((val) {
      if (val != null && val > 0) {
        currentBattery = val;
        controller.add(SystemStats(
          battery: currentBattery,
          cpu: currentCpu,
          gpu: currentGpu,
          fps: currentFps,
          temperatureCelsius: currentTemperature,
          ramUsedMb: currentRam,
          isCharging: false,
          timestamp: DateTime.now(),
        ));
      }
    }).catchError((_) {});

    const MethodChannel('com.example.owl/overlay')
        .invokeMethod<int>('getCpuUsage')
        .then((val) {
      if (val != null && val >= 0) {
        currentCpu = val;
        controller.add(SystemStats(
          battery: currentBattery,
          cpu: currentCpu,
          gpu: currentGpu,
          fps: currentFps,
          temperatureCelsius: currentTemperature,
          ramUsedMb: currentRam,
          isCharging: false,
          timestamp: DateTime.now(),
        ));
      }
    }).catchError((_) {});

    try {
      nativeSub = _statsEventChannel.receiveBroadcastStream().listen(
        (dynamic raw) {
          if (raw is Map) {
            final b = (raw['battery'] as num?)?.toInt() ?? currentBattery;
            final c = (raw['cpu'] as num?)?.toInt() ?? currentCpu;
            final g = (raw['gpu'] as num?)?.toInt() ?? currentGpu;
            final f = (raw['fps'] as num?)?.toInt() ?? currentFps;
            final temp = (raw['temperature'] as num?)?.toDouble();
            final ram = (raw['ram'] as num?)?.toInt();

            currentBattery = b > 0 ? b : currentBattery;
            currentCpu = c >= 0 ? c : currentCpu;
            currentGpu = g >= 0 ? g : currentGpu;
            if (temp != null && temp > 0) currentTemperature = temp;
            if (ram != null && ram > 0) currentRam = ram;

            // Native sends live hardware Choreographer / sysfs FPS
            currentFps = f > 0 ? f : fpsTracker.getLiveMeasuredFps();
            lastNativeTick = DateTime.now();

            controller.add(SystemStats(
              battery: currentBattery,
              cpu: currentCpu,
              gpu: currentGpu,
              fps: currentFps,
              temperatureCelsius: currentTemperature,
              ramUsedMb: currentRam,
              isCharging: false,
              timestamp: lastNativeTick,
            ));
          }
        },
        onError: (_) {
          final liveFps = fpsTracker.getLiveMeasuredFps();
          controller.add(SystemStats(
            battery: currentBattery,
            cpu: currentCpu,
            gpu: currentGpu,
            fps: liveFps,
            temperatureCelsius: currentTemperature,
            ramUsedMb: currentRam,
            isCharging: false,
            timestamp: DateTime.now(),
          ));
        },
      );
    } catch (_) {}
  }

  // Active 1000ms ticker for truthful frame timing progression
  final timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
    final elapsed = DateTime.now().difference(lastNativeTick).inMilliseconds;
    if (elapsed > 1800) {
      final liveFps = fpsTracker.getLiveMeasuredFps();
      currentFps = liveFps;
      controller.add(SystemStats(
        battery: currentBattery,
        cpu: currentCpu,
        gpu: currentGpu,
        fps: currentFps,
        temperatureCelsius: currentTemperature,
        ramUsedMb: currentRam,
        isCharging: false,
        timestamp: DateTime.now(),
      ));
    }
  });

  ref.onDispose(() {
    nativeSub?.cancel();
    timer.cancel();
    fpsTracker.stop();
    controller.close();
  });

  // Initial immediate stats
  controller.add(SystemStats(
    battery: currentBattery,
    cpu: currentCpu,
    gpu: currentGpu,
    fps: fpsTracker.getLiveMeasuredFps(),
    temperatureCelsius: currentTemperature,
    ramUsedMb: currentRam,
    isCharging: false,
    timestamp: DateTime.now(),
  ));

  return controller.stream;
});
