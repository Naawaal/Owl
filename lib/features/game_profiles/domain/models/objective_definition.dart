// language: Dart, file: objective_definition.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/foundation.dart';

/// Categories of in-game MOBA objectives.
enum ObjectiveCategory {
  /// Epic monsters / major boss objectives (e.g., Baron, Dragon, Lord, Rayquaza).
  epic,

  /// Jungle camp buffs (e.g., Red Buff, Blue Buff, Orange/Purple Buff).
  buff,

  /// Minor neutral camps or vision scouts (e.g., Lithowanderer, Altaria, Scuttle Crab).
  minor,

  /// General neutral objective.
  neutral;

  /// Human-readable display label.
  String get displayName {
    switch (this) {
      case ObjectiveCategory.epic:
        return 'Epic Objective';
      case ObjectiveCategory.buff:
        return 'Jungle Buff';
      case ObjectiveCategory.minor:
        return 'Minor Camp';
      case ObjectiveCategory.neutral:
        return 'Neutral Objective';
    }
  }
}

/// Immutable definition of a trackable MOBA objective.
@immutable
class ObjectiveDefinition {
  /// Unique identifier (e.g. 'wr_baron_nashor', 'mlbb_turtle').
  final String id;

  /// Display name (e.g. 'Baron Nashor', 'Turtle', 'Rayquaza').
  final String name;

  /// Category of the objective.
  final ObjectiveCategory category;

  /// Match elapsed time (in seconds) at which the objective first spawns.
  final int initialSpawnSeconds;

  /// Respawn timer duration (in seconds) after being slain. 0 if it does not respawn.
  final int respawnIntervalSeconds;

  /// Lead time (in seconds) before spawn/respawn to trigger warnings/alerts.
  final int warningLeadSeconds;

  /// Asset path or identifier for the objective icon.
  final String iconAsset;

  /// Flag indicating if this is a game-deciding major/epic objective.
  final bool isMajor;

  /// Optional contextual description or buff effect.
  final String? description;

  const ObjectiveDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.initialSpawnSeconds,
    required this.respawnIntervalSeconds,
    required this.warningLeadSeconds,
    required this.iconAsset,
    required this.isMajor,
    this.description,
  });

  /// Formatted initial spawn time in MM:SS.
  String get initialSpawnFormatted {
    final minutes = (initialSpawnSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (initialSpawnSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formatted respawn interval in MM:SS.
  String get respawnIntervalFormatted {
    if (respawnIntervalSeconds <= 0) return 'No Respawn';
    final minutes = (respawnIntervalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (respawnIntervalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Creates a copy of this [ObjectiveDefinition] with specified fields replaced.
  ObjectiveDefinition copyWith({
    String? id,
    String? name,
    ObjectiveCategory? category,
    int? initialSpawnSeconds,
    int? respawnIntervalSeconds,
    int? warningLeadSeconds,
    String? iconAsset,
    bool? isMajor,
    String? description,
  }) {
    return ObjectiveDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      initialSpawnSeconds: initialSpawnSeconds ?? this.initialSpawnSeconds,
      respawnIntervalSeconds:
          respawnIntervalSeconds ?? this.respawnIntervalSeconds,
      warningLeadSeconds: warningLeadSeconds ?? this.warningLeadSeconds,
      iconAsset: iconAsset ?? this.iconAsset,
      isMajor: isMajor ?? this.isMajor,
      description: description ?? this.description,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'initialSpawnSeconds': initialSpawnSeconds,
      'respawnIntervalSeconds': respawnIntervalSeconds,
      'warningLeadSeconds': warningLeadSeconds,
      'iconAsset': iconAsset,
      'isMajor': isMajor,
      if (description != null) 'description': description,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory ObjectiveDefinition.fromMap(Map<String, dynamic> map) {
    return ObjectiveDefinition(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ObjectiveCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ObjectiveCategory.neutral,
      ),
      initialSpawnSeconds: (map['initialSpawnSeconds'] as num).toInt(),
      respawnIntervalSeconds: (map['respawnIntervalSeconds'] as num).toInt(),
      warningLeadSeconds: (map['warningLeadSeconds'] as num).toInt(),
      iconAsset: map['iconAsset'] as String,
      isMajor: map['isMajor'] as bool? ?? false,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ObjectiveDefinition.fromJson(Map<String, dynamic> json) =>
      ObjectiveDefinition.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectiveDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          initialSpawnSeconds == other.initialSpawnSeconds &&
          respawnIntervalSeconds == other.respawnIntervalSeconds &&
          warningLeadSeconds == other.warningLeadSeconds &&
          iconAsset == other.iconAsset &&
          isMajor == other.isMajor &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        initialSpawnSeconds,
        respawnIntervalSeconds,
        warningLeadSeconds,
        iconAsset,
        isMajor,
        description,
      );

  @override
  String toString() =>
      'ObjectiveDefinition(id: $id, name: $name, category: ${category.name}, initial: $initialSpawnFormatted, respawn: $respawnIntervalFormatted, isMajor: $isMajor)';
}
