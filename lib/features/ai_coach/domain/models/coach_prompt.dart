// language: Dart, file: coach_prompt.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/foundation.dart';

/// Immutable domain model encapsulating input parameters for an AI tactical coaching query.
@immutable
class CoachPrompt {
  /// Name of the game (e.g. 'Wild Rift', 'Mobile Legends', 'Pokémon UNITE').
  final String gameName;

  /// Elapsed match time in seconds.
  final int matchTimeSeconds;

  /// User's in-game role or lane (e.g. 'Jungler', 'Mid Lane', 'Gold Laner', 'Speedster').
  final String role;

  /// Live game state or dilemma described by player or captured via HUD.
  final String currentSituation;

  /// Type of advice requested (e.g. 'tactical', 'objectiveRush', 'macro', 'tiltRecovery').
  final String promptType;

  /// Optional champion or hero being piloted by the player.
  final String? heroChampion;

  /// Optional list of upcoming objective timers or active map states.
  final Map<String, dynamic>? tacticalContext;

  /// Game genre/category (e.g. '5v5 MOBA', 'Battle Royale', 'Strategy').
  final String? gameCategory;

  /// Current device CPU utilisation percentage (0–100).
  final int? cpuPercent;

  /// Current device battery level percentage (0–100).
  final int? batteryPercent;

  /// Live measured frames per second at the time of the request.
  final int? liveFps;

  const CoachPrompt({
    required this.gameName,
    required this.matchTimeSeconds,
    required this.role,
    required this.currentSituation,
    required this.promptType,
    this.heroChampion,
    this.tacticalContext,
    this.gameCategory,
    this.cpuPercent,
    this.batteryPercent,
    this.liveFps,
  });

  /// Formatted match time in MM:SS.
  String get formattedMatchTime {
    final minutes = (matchTimeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (matchTimeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Synthesizes a structured, high-signal system/user prompt for the LLM.
  String toFormattedPrompt({bool explainRecommendations = true}) {
    final heroLine = heroChampion != null ? ' Playing: $heroChampion.' : '';
    final contextLine = tacticalContext != null && tacticalContext!.isNotEmpty
        ? ' Context: $tacticalContext.'
        : '';
    final explainDirective = explainRecommendations
        ? 'Action (immediate verb), Reason (1 sentence), Warning (risk if any).'
        : 'Action (immediate verb), Warning (risk if any). Omit Reason.';

    // Assemble device + game-state grounding block from any available fields.
    final deviceParts = <String>[];
    if (gameCategory != null) deviceParts.add('Category: $gameCategory');
    if (cpuPercent != null) deviceParts.add('CPU: $cpuPercent%');
    if (batteryPercent != null) deviceParts.add('Battery: $batteryPercent%');
    if (liveFps != null) deviceParts.add('FPS: $liveFps');
    final deviceLine =
        deviceParts.isNotEmpty ? '\nDevice: ${deviceParts.join(' | ')}' : '';

    return 'Game: $gameName | Match Time: $formattedMatchTime | Role: $role.$heroLine$deviceLine\n'
        'Intent: $promptType\n'
        'Situation: $currentSituation$contextLine\n'
        'Respond in short, high-urgency tactical HUD style: $explainDirective';
  }

  /// Creates a copy of this [CoachPrompt] with specified fields replaced.
  CoachPrompt copyWith({
    String? gameName,
    int? matchTimeSeconds,
    String? role,
    String? currentSituation,
    String? promptType,
    String? heroChampion,
    Map<String, dynamic>? tacticalContext,
    String? gameCategory,
    int? cpuPercent,
    int? batteryPercent,
    int? liveFps,
  }) {
    return CoachPrompt(
      gameName: gameName ?? this.gameName,
      matchTimeSeconds: matchTimeSeconds ?? this.matchTimeSeconds,
      role: role ?? this.role,
      currentSituation: currentSituation ?? this.currentSituation,
      promptType: promptType ?? this.promptType,
      heroChampion: heroChampion ?? this.heroChampion,
      tacticalContext: tacticalContext ?? this.tacticalContext,
      gameCategory: gameCategory ?? this.gameCategory,
      cpuPercent: cpuPercent ?? this.cpuPercent,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      liveFps: liveFps ?? this.liveFps,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'gameName': gameName,
      'matchTimeSeconds': matchTimeSeconds,
      'role': role,
      'currentSituation': currentSituation,
      'promptType': promptType,
      if (heroChampion != null) 'heroChampion': heroChampion,
      if (tacticalContext != null) 'tacticalContext': tacticalContext,
      if (gameCategory != null) 'gameCategory': gameCategory,
      if (cpuPercent != null) 'cpuPercent': cpuPercent,
      if (batteryPercent != null) 'batteryPercent': batteryPercent,
      if (liveFps != null) 'liveFps': liveFps,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory CoachPrompt.fromMap(Map<String, dynamic> map) {
    return CoachPrompt(
      gameName: map['gameName'] as String,
      matchTimeSeconds: (map['matchTimeSeconds'] as num).toInt(),
      role: map['role'] as String,
      currentSituation: map['currentSituation'] as String,
      promptType: map['promptType'] as String,
      heroChampion: map['heroChampion'] as String?,
      tacticalContext: map['tacticalContext'] != null
          ? Map<String, dynamic>.from(map['tacticalContext'] as Map)
          : null,
      gameCategory: map['gameCategory'] as String?,
      cpuPercent: (map['cpuPercent'] as num?)?.toInt(),
      batteryPercent: (map['batteryPercent'] as num?)?.toInt(),
      liveFps: (map['liveFps'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CoachPrompt.fromJson(Map<String, dynamic> json) =>
      CoachPrompt.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachPrompt &&
          runtimeType == other.runtimeType &&
          gameName == other.gameName &&
          matchTimeSeconds == other.matchTimeSeconds &&
          role == other.role &&
          currentSituation == other.currentSituation &&
          promptType == other.promptType &&
          heroChampion == other.heroChampion &&
          gameCategory == other.gameCategory &&
          cpuPercent == other.cpuPercent &&
          batteryPercent == other.batteryPercent &&
          liveFps == other.liveFps &&
          mapEquals(tacticalContext, other.tacticalContext);

  @override
  int get hashCode => Object.hash(
        gameName,
        matchTimeSeconds,
        role,
        currentSituation,
        promptType,
        heroChampion,
        gameCategory,
        cpuPercent,
        batteryPercent,
        liveFps,
      );

  @override
  String toString() =>
      'CoachPrompt(game: $gameName, time: $formattedMatchTime, role: $role, type: $promptType)';
}
