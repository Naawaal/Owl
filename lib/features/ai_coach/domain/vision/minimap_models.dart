// language: Dart, file: minimap_models.dart, target: Flutter / Owl MOBA Companion

/// Represents a hero token detected on the minimap.
class MinimapHeroToken {
  final String id;
  final String team; // 'ally' | 'enemy'
  final String lane; // 'top' | 'mid' | 'bot' | 'jungle' | 'unknown'
  final double normalizedX; // 0.0 to 1.0 within minimap
  final double normalizedY; // 0.0 to 1.0 within minimap
  final int lastSeenMatchTimeSeconds;
  final bool isMissing;
  final int missingDurationSeconds;

  const MinimapHeroToken({
    required this.id,
    required this.team,
    this.lane = 'unknown',
    required this.normalizedX,
    required this.normalizedY,
    required this.lastSeenMatchTimeSeconds,
    this.isMissing = false,
    this.missingDurationSeconds = 0,
  });

  MinimapHeroToken copyWith({
    String? id,
    String? team,
    String? lane,
    double? normalizedX,
    double? normalizedY,
    int? lastSeenMatchTimeSeconds,
    bool? isMissing,
    int? missingDurationSeconds,
  }) {
    return MinimapHeroToken(
      id: id ?? this.id,
      team: team ?? this.team,
      lane: lane ?? this.lane,
      normalizedX: normalizedX ?? this.normalizedX,
      normalizedY: normalizedY ?? this.normalizedY,
      lastSeenMatchTimeSeconds:
          lastSeenMatchTimeSeconds ?? this.lastSeenMatchTimeSeconds,
      isMissing: isMissing ?? this.isMissing,
      missingDurationSeconds:
          missingDurationSeconds ?? this.missingDurationSeconds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'team': team,
        'lane': lane,
        'x': double.parse(normalizedX.toStringAsFixed(2)),
        'y': double.parse(normalizedY.toStringAsFixed(2)),
        'isMissing': isMissing,
        'missingDurationSeconds': missingDurationSeconds,
      };
}

/// Status of neutral major objectives (Turtle, Lord, Dragon).
class NeutralObjectiveState {
  final String name; // 'Turtle' | 'Lord'
  final String status; // 'upcoming' | 'alive' | 'contested' | 'slain'
  final int timeUntilSpawnSeconds;
  final bool isContested;

  const NeutralObjectiveState({
    required this.name,
    required this.status,
    this.timeUntilSpawnSeconds = 0,
    this.isContested = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'status': status,
        'timeUntilSpawnSeconds': timeUntilSpawnSeconds,
        'isContested': isContested,
      };
}

/// Comprehensive tactical snapshot extracted from minimap vision.
class MobaTacticalSnapshot {
  final int matchTimeSeconds;
  final List<MinimapHeroToken> visibleAllies;
  final List<MinimapHeroToken> visibleEnemies;
  final List<MinimapHeroToken> missingEnemies;
  final List<NeutralObjectiveState> objectives;
  final List<String> tacticalAlerts;

  const MobaTacticalSnapshot({
    required this.matchTimeSeconds,
    this.visibleAllies = const [],
    this.visibleEnemies = const [],
    this.missingEnemies = const [],
    this.objectives = const [],
    this.tacticalAlerts = const [],
  });

  /// Serializes into the structured map accepted by [CoachPrompt.tacticalContext].
  Map<String, dynamic> toTacticalContext() {
    return {
      'matchTime': matchTimeSeconds,
      'visibleAlliesCount': visibleAllies.length,
      'visibleEnemiesCount': visibleEnemies.length,
      'missingEnemies': missingEnemies.map((e) => e.toMap()).toList(),
      'objectives': objectives.map((o) => o.toMap()).toList(),
      'activeAlerts': tacticalAlerts,
    };
  }
}
