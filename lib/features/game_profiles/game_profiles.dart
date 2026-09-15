// language: Dart, file: game_profiles.dart, target: Flutter / Owl MOBA HUD
/// Feature barrel for Game Profiles & MOBA Objective Presets.
library;

import 'data/presets/mlbb_preset.dart';
import 'data/presets/pokemon_unite_preset.dart';
import 'data/presets/wild_rift_preset.dart';
import 'domain/models/game_profile.dart';

export 'domain/models/game_profile.dart';
export 'domain/models/objective_definition.dart';
export 'data/presets/wild_rift_preset.dart';
export 'data/presets/mlbb_preset.dart';
export 'data/presets/pokemon_unite_preset.dart';

/// All default pre-configured MOBA game profiles shipped with Owl.
const List<GameProfile> kDefaultGameProfiles = [
  wildRiftPreset,
  mlbbPreset,
  pokemonUnitePreset,
];

/// Helper to lookup a default game profile by its unique string identifier.
GameProfile? findGameProfileById(String id) {
  try {
    return kDefaultGameProfiles.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
