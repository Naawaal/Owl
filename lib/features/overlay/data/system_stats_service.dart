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

int _quantizePercent(int value, {int step = 2}) {
  if (value <= 0) return 0;
  return ((value / step).round() * step).clamp(0, 100);
}

int _quantizeFps(int value, {int step = 5}) {
  if (value <= 0) return 0;
  return (value / step).round() * step;
}

double? _quantizeTemp(double? value) {
  if (value == null || value <= 0) return value;
  return (value * 2).round() / 2.0;
}

int? _quantizeRamMb(int? value) {
  if (value == null || value <= 0) return value;
  return ((value / 16).round() * 16);
}

/// Stream provider for live system stats pushed from native Android via EventChannel
/// with Flutter hardware FrameTiming tracker integration.
final systemStatsProvider = StreamProvider<SystemStats>(
  name: 'systemStats',
  (ref) {
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

  void emitIfChanged({
    required int battery,
    required int cpu,
    required int gpu,
    required int fps,
    double? temperature,
    int? ram,
    DateTime? at,
  }) {
    final nextBattery = battery;
    final nextCpu = _quantizePercent(cpu);
    final nextGpu = _quantizePercent(gpu);
    final nextFps = _quantizeFps(fps);
    final nextTemp = _quantizeTemp(temperature);
    final nextRam = _quantizeRamMb(ram);

    final unchanged = nextBattery == currentBattery &&
        nextCpu == currentCpu &&
        nextGpu == currentGpu &&
        nextFps == currentFps &&
        nextTemp == currentTemperature &&
        nextRam == currentRam;
    if (unchanged) return;

    currentBattery = nextBattery;
    currentCpu = nextCpu;
    currentGpu = nextGpu;
    currentFps = nextFps;
    currentTemperature = nextTemp;
    currentRam = nextRam;

    controller.add(SystemStats(
      battery: currentBattery,
      cpu: currentCpu,
      gpu: currentGpu,
      fps: currentFps,
      temperatureCelsius: currentTemperature,
      ramUsedMb: currentRam,
      isCharging: false,
      timestamp: at ?? DateTime.now(),
    ));
  }

  StreamSubscription? nativeSub;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    // Immediate initial sync from native single-shot readers
    const MethodChannel('com.example.owl/overlay')
        .invokeMethod<int>('getBatteryLevel')
        .then((val) {
      if (val != null && val > 0) {
        emitIfChanged(
          battery: val,
          cpu: currentCpu,
          gpu: currentGpu,
          fps: currentFps,
          temperature: currentTemperature,
          ram: currentRam,
        );
      }
    }).catchError((_) {});

    const MethodChannel('com.example.owl/overlay')
        .invokeMethod<int>('getCpuUsage')
        .then((val) {
      if (val != null && val >= 0) {
        emitIfChanged(
          battery: currentBattery,
          cpu: val,
          gpu: currentGpu,
          fps: currentFps,
          temperature: currentTemperature,
          ram: currentRam,
        );
      }
    }).catchError((_) {});

    try {
      nativeSub = _statsEventChannel.receiveBroadcastStream().listen(
        (dynamic raw) {
          if (raw is Map) {
            lastNativeTick = DateTime.now();
            // Native skip of unchanged quantized values still pings keepalive.
            if (raw['keepalive'] == true) return;

            final b = (raw['battery'] as num?)?.toInt() ?? currentBattery;
            final c = (raw['cpu'] as num?)?.toInt() ?? currentCpu;
            final g = (raw['gpu'] as num?)?.toInt() ?? currentGpu;
            final f = (raw['fps'] as num?)?.toInt() ?? currentFps;
            final temp = (raw['temperature'] as num?)?.toDouble();
            final ram = (raw['ram'] as num?)?.toInt();

            emitIfChanged(
              battery: b > 0 ? b : currentBattery,
              cpu: c >= 0 ? c : currentCpu,
              gpu: g >= 0 ? g : currentGpu,
              fps: f > 0 ? f : fpsTracker.getLiveMeasuredFps(),
              temperature:
                  (temp != null && temp > 0) ? temp : currentTemperature,
              ram: (ram != null && ram > 0) ? ram : currentRam,
              at: lastNativeTick,
            );
          }
        },
        onError: (_) {
          emitIfChanged(
            battery: currentBattery,
            cpu: currentCpu,
            gpu: currentGpu,
            fps: fpsTracker.getLiveMeasuredFps(),
            temperature: currentTemperature,
            ram: currentRam,
          );
        },
      );
    } catch (_) {}
  }

  // Active 1000ms ticker for truthful frame timing progression
  final timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
    final elapsed = DateTime.now().difference(lastNativeTick).inMilliseconds;
    if (elapsed > 1800) {
      emitIfChanged(
        battery: currentBattery,
        cpu: currentCpu,
        gpu: currentGpu,
        fps: fpsTracker.getLiveMeasuredFps(),
        temperature: currentTemperature,
        ram: currentRam,
      );
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
  },
);
