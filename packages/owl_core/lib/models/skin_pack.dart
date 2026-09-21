class SkinPack {
  final String id;
  final String gameId;
  final String name;
  final String description;
  final String version;
  final String author;
  final String accentColor;
  final List<String> previewTags;
  final bool isApplied;
  final DateTime? appliedAt;

  const SkinPack({
    required this.id,
    required this.gameId,
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    required this.accentColor,
    this.previewTags = const [],
    this.isApplied = false,
    this.appliedAt,
  });

  SkinPack copyWith({
    bool? isApplied,
    DateTime? appliedAt,
  }) {
    return SkinPack(
      id: id,
      gameId: gameId,
      name: name,
      description: description,
      version: version,
      author: author,
      accentColor: accentColor,
      previewTags: previewTags,
      isApplied: isApplied ?? this.isApplied,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  factory SkinPack.fromJson(Map<String, dynamic> json) {
    return SkinPack(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? 'Unknown',
      accentColor: json['accentColor'] as String? ?? '#2196F3',
      previewTags: (json['previewTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isApplied: json['isApplied'] as bool? ?? false,
      appliedAt: json['appliedAt'] != null ? DateTime.tryParse(json['appliedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'name': name,
      'description': description,
      'version': version,
      'author': author,
      'accentColor': accentColor,
      'previewTags': previewTags,
      'isApplied': isApplied,
      'appliedAt': appliedAt?.toIso8601String(),
    };
  }
}
