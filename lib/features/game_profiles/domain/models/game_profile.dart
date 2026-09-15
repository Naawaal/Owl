// language: Dart, file: game_profile.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/foundation.dart';
import 'objective_definition.dart';

/// Immutable domain model representing a supported MOBA game profile.
@immutable
class GameProfile {
  /// Unique identifier (e.g. 'wild_rift', 'mlbb', 'pokemon_unite').
  final String id;

  /// Full display name of the title.
  final String name;

  /// Asset path for the game emblem or icon.
  final String logoAsset;

  /// Default map or arena name (e.g. 'Wild Rift', 'Land of Dawn', 'Theia Sky Ruins').
  final String mapName;

  /// Complete list of trackable objectives for this profile.
  final List<ObjectiveDefinition> objectives;

  /// Optional short/abbreviated name (e.g., 'WR', 'MLBB', 'UNITE').
  final String? shortName;

  const GameProfile({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.mapName,
    required this.objectives,
    this.shortName,
  });

  /// All major game-turning boss objectives (Baron, Dragon, Lord, Rayquaza, etc.).
  List<ObjectiveDefinition> get majorObjectives =>
      objectives.where((o) => o.isMajor).toList(growable: false);

  /// All minor objectives (scouts, swarms, camps).
  List<ObjectiveDefinition> get minorObjectives =>
      objectives.where((o) => !o.isMajor).toList(growable: false);

  /// All jungle buff objectives.
  List<ObjectiveDefinition> get buffObjectives => objectives
      .where((o) => o.category == ObjectiveCategory.buff)
      .toList(growable: false);

  /// Find objective definition by its identifier.
  ObjectiveDefinition? findObjective(String objectiveId) {
    try {
      return objectives.firstWhere((o) => o.id == objectiveId);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy of this [GameProfile] with specified fields replaced.
  GameProfile copyWith({
    String? id,
    String? name,
    String? logoAsset,
    String? mapName,
    List<ObjectiveDefinition>? objectives,
    String? shortName,
  }) {
    return GameProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      logoAsset: logoAsset ?? this.logoAsset,
      mapName: mapName ?? this.mapName,
      objectives: objectives ?? this.objectives,
      shortName: shortName ?? this.shortName,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoAsset': logoAsset,
      'mapName': mapName,
      'objectives': objectives.map((o) => o.toMap()).toList(),
      if (shortName != null) 'shortName': shortName,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory GameProfile.fromMap(Map<String, dynamic> map) {
    return GameProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      logoAsset: map['logoAsset'] as String,
      mapName: map['mapName'] as String,
      objectives: (map['objectives'] as List<dynamic>?)
              ?.map((item) =>
                  ObjectiveDefinition.fromMap(item as Map<String, dynamic>))
              .toList() ??
          const [],
      shortName: map['shortName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory GameProfile.fromJson(Map<String, dynamic> json) =>
      GameProfile.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          logoAsset == other.logoAsset &&
          mapName == other.mapName &&
          shortName == other.shortName &&
          listEquals(objectives, other.objectives);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        logoAsset,
        mapName,
        shortName,
        Object.hashAll(objectives),
      );

  @override
  String toString() =>
      'GameProfile(id: $id, name: $name, map: $mapName, objectives: ${objectives.length})';
}
