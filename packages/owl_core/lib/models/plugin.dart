class GamePlugin {
  final String id;
  final String name;
  final String description;
  final String version;
  final List<String> gameIds;
  final List<String> compatibleVersions;
  final String category;
  final bool isEnabled;

  const GamePlugin({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.gameIds,
    required this.compatibleVersions,
    required this.category,
    this.isEnabled = false,
  });

  bool isCompatibleWith(String? gameVersion) {
    if (gameVersion == null || gameVersion.isEmpty) return true;
    if (compatibleVersions.isEmpty) return true;
    return compatibleVersions.contains(gameVersion);
  }

  GamePlugin copyWith({
    bool? isEnabled,
  }) {
    return GamePlugin(
      id: id,
      name: name,
      description: description,
      version: version,
      gameIds: gameIds,
      compatibleVersions: compatibleVersions,
      category: category,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  factory GamePlugin.fromJson(Map<String, dynamic> json) {
    return GamePlugin(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      gameIds: (json['gameIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      compatibleVersions:
          (json['compatibleVersions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: json['category'] as String? ?? 'General',
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'gameIds': gameIds,
      'compatibleVersions': compatibleVersions,
      'category': category,
      'isEnabled': isEnabled,
    };
  }
}
