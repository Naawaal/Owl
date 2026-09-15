// language: Dart, file: active_timer.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/foundation.dart';
import 'timer_state.dart';

/// Immutable domain model representing a running or pending objective timer.
@immutable
class ActiveTimer {
  /// Unique instance identifier for this timer run.
  final String id;

  /// Identifier of the underlying [ObjectiveDefinition].
  final String objectiveId;

  /// Human-readable objective name (e.g. 'Elemental Dragon', 'Lord').
  final String name;

  /// Remaining countdown duration in seconds.
  final int remainingSeconds;

  /// Total timer duration in seconds (full spawn/respawn cycle).
  final int totalSeconds;

  /// Target completion timestamp in milliseconds since epoch.
  final int targetEpochMs;

  /// Whether the timer is currently actively counting down.
  final bool isRunning;

  /// Whether this timer has reached the urgent countdown threshold (<= 10s or custom).
  final bool isUrgent;

  const ActiveTimer({
    required this.id,
    required this.objectiveId,
    required this.name,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.targetEpochMs,
    required this.isRunning,
    required this.isUrgent,
  });

  /// Computed [TimerStatus] reflecting current countdown state.
  TimerStatus get status {
    if (remainingSeconds <= 0) {
      return TimerStatus.ready;
    }
    if (!isRunning) {
      return TimerStatus.idle;
    }
    if (isUrgent) {
      return TimerStatus.urgent;
    }
    // If remaining is <= 30 seconds or 20% of total time, consider it warning
    if (remainingSeconds <= 30) {
      return TimerStatus.warning;
    }
    return TimerStatus.running;
  }

  /// Completion progress ratio from 0.0 (just started) to 1.0 (spawned/expired).
  double get progressRatio {
    if (totalSeconds <= 0) return 1.0;
    final elapsed = totalSeconds - remainingSeconds;
    final ratio = elapsed / totalSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Cooldown remaining ratio from 1.0 (full duration left) to 0.0 (ready).
  double get cooldownRatio {
    if (totalSeconds <= 0) return 0.0;
    final ratio = remainingSeconds / totalSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Whether the objective has spawned or countdown reached zero.
  bool get isReady => remainingSeconds <= 0;

  /// Formatted remaining countdown string (e.g. "04:32" or "00:08").
  String get formattedRemaining {
    if (remainingSeconds <= 0) return '00:00';
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Creates a copy of this [ActiveTimer] with specified fields replaced.
  ActiveTimer copyWith({
    String? id,
    String? objectiveId,
    String? name,
    int? remainingSeconds,
    int? totalSeconds,
    int? targetEpochMs,
    bool? isRunning,
    bool? isUrgent,
  }) {
    return ActiveTimer(
      id: id ?? this.id,
      objectiveId: objectiveId ?? this.objectiveId,
      name: name ?? this.name,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      targetEpochMs: targetEpochMs ?? this.targetEpochMs,
      isRunning: isRunning ?? this.isRunning,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'objectiveId': objectiveId,
      'name': name,
      'remainingSeconds': remainingSeconds,
      'totalSeconds': totalSeconds,
      'targetEpochMs': targetEpochMs,
      'isRunning': isRunning,
      'isUrgent': isUrgent,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory ActiveTimer.fromMap(Map<String, dynamic> map) {
    return ActiveTimer(
      id: map['id'] as String,
      objectiveId: map['objectiveId'] as String,
      name: map['name'] as String,
      remainingSeconds: (map['remainingSeconds'] as num).toInt(),
      totalSeconds: (map['totalSeconds'] as num).toInt(),
      targetEpochMs: (map['targetEpochMs'] as num).toInt(),
      isRunning: map['isRunning'] as bool? ?? false,
      isUrgent: map['isUrgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ActiveTimer.fromJson(Map<String, dynamic> json) =>
      ActiveTimer.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveTimer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          objectiveId == other.objectiveId &&
          name == other.name &&
          remainingSeconds == other.remainingSeconds &&
          totalSeconds == other.totalSeconds &&
          targetEpochMs == other.targetEpochMs &&
          isRunning == other.isRunning &&
          isUrgent == other.isUrgent;

  @override
  int get hashCode => Object.hash(
        id,
        objectiveId,
        name,
        remainingSeconds,
        totalSeconds,
        targetEpochMs,
        isRunning,
        isUrgent,
      );

  @override
  String toString() =>
      'ActiveTimer(id: $id, name: $name, remaining: $formattedRemaining, status: ${status.name}, running: $isRunning)';
}
