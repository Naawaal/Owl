class Game {
  final String id;
  final String name;
  final String packageName;
  final String minVersion;
  final String category;
  final String icon;
  final String description;
  final bool isInstalled;
  final String? installedVersion;

  const Game({
    required this.id,
    required this.name,
    required this.packageName,
    required this.minVersion,
    required this.category,
    required this.icon,
    required this.description,
    this.isInstalled = false,
    this.installedVersion,
  });

  Game copyWith({
    bool? isInstalled,
    String? installedVersion,
  }) {
    return Game(
      id: id,
      name: name,
      packageName: packageName,
      minVersion: minVersion,
      category: category,
      icon: icon,
      description: description,
      isInstalled: isInstalled ?? this.isInstalled,
      installedVersion: installedVersion ?? this.installedVersion,
    );
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      packageName: json['packageName'] as String,
      minVersion: json['minVersion'] as String? ?? '1.0.0',
      category: json['category'] as String? ?? 'General',
      icon: json['icon'] as String? ?? 'videogame_asset',
      description: json['description'] as String? ?? '',
      isInstalled: json['isInstalled'] as bool? ?? false,
      installedVersion: json['installedVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'packageName': packageName,
      'minVersion': minVersion,
      'category': category,
      'icon': icon,
      'description': description,
      'isInstalled': isInstalled,
      'installedVersion': installedVersion,
    };
  }
}
