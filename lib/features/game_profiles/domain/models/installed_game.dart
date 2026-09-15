// language: Dart, file: installed_game.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/foundation.dart';
import 'package:owl/features/game_profiles/domain/models/game_profile.dart';

/// Representation of a dynamically discovered game installed on the device.
@immutable
class InstalledGame {
  /// Unique identifier (usually package name or normalized slug).
  final String id;

  /// Human-readable title of the game.
  final String name;

  /// Android Application Package Name (e.g. com.mobile.legends).
  final String packageName;

  /// Extracted native application icon bytes (PNG).
  final Uint8List? iconBytes;

  /// Game genre or category classification.
  final String category;

  /// Target refresh rate / FPS supported (60, 90, 120, 144).
  final int targetFps;

  /// True if verified as an OEM-classified game.
  final bool isGame;

  /// True if pre-installed system package.
  final bool isSystem;

  /// True if added to Game Space deck.
  final bool isInGameSpace;

  /// Optional deep MOBA tactical objective profile if mapped.
  final GameProfile? tacticalProfile;

  const InstalledGame({
    required this.id,
    required this.name,
    required this.packageName,
    this.iconBytes,
    this.category = '5v5 MOBA',
    this.targetFps = 120,
    this.isGame = true,
    this.isSystem = false,
    this.isInGameSpace = true,
    this.tacticalProfile,
  });

  InstalledGame copyWith({
    String? id,
    String? name,
    String? packageName,
    Uint8List? iconBytes,
    String? category,
    int? targetFps,
    bool? isGame,
    bool? isSystem,
    bool? isInGameSpace,
    GameProfile? tacticalProfile,
  }) {
    return InstalledGame(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      iconBytes: iconBytes ?? this.iconBytes,
      category: category ?? this.category,
      targetFps: targetFps ?? this.targetFps,
      isGame: isGame ?? this.isGame,
      isSystem: isSystem ?? this.isSystem,
      isInGameSpace: isInGameSpace ?? this.isInGameSpace,
      tacticalProfile: tacticalProfile ?? this.tacticalProfile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledGame &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          packageName == other.packageName &&
          name == other.name &&
          isInGameSpace == other.isInGameSpace;

  @override
  int get hashCode => Object.hash(id, packageName, name, isInGameSpace);

  @override
  String toString() =>
      'InstalledGame(name: $name, package: $packageName, targetFps: $targetFps)';
}
