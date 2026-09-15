// language: Dart, file: pokemon_unite_preset.dart, target: Flutter / Owl MOBA HUD
import '../../domain/models/game_profile.dart';
import '../../domain/models/objective_definition.dart';

/// Pokémon UNITE official preset configuration for Theia Sky Ruins.
/// Timings calibrated against standard 10-minute match elapsed seconds.
const pokemonUnitePreset = GameProfile(
  id: 'pokemon_unite',
  name: 'Pokémon UNITE',
  shortName: 'UNITE',
  logoAsset: 'assets/games/pokemon_unite_logo.png',
  mapName: 'Theia Sky Ruins',
  objectives: [
    // 1. Rayquaza (Final Stretch Boss)
    ObjectiveDefinition(
      id: 'pu_rayquaza',
      name: 'Rayquaza',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 480, // 8:00 elapsed (2:00 remaining)
      respawnIntervalSeconds: 0, // Single decisive spawn
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/pu_rayquaza.png',
      isMajor: true,
      description:
          'Spawns at Final Stretch in the center pit. Grants impenetrable score shields and accelerated scoring speed.',
    ),

    // 2. Regieleki (Top Path)
    ObjectiveDefinition(
      id: 'pu_regieleki',
      name: 'Regieleki',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 180, // 3:00 elapsed (7:00 remaining)
      respawnIntervalSeconds: 120, // 2:00
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/pu_regieleki.png',
      isMajor: true,
      description:
          'Marches towards enemy top goal zone. Upon reaching, deactivates goal defense for instant scoring.',
    ),

    // 3. Bottom Path Regis (Registeel / Regirock / Regice)
    ObjectiveDefinition(
      id: 'pu_regis_bottom',
      name: 'Bottom Path Regis (Registeel)',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 180, // 3:00 elapsed (7:00 remaining)
      respawnIntervalSeconds: 120, // 2:00
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/pu_registeel.png',
      isMajor: true,
      description:
          'Defeating gives entire team experience, shields, and attack/special attack buffs.',
    ),

    // 4. Altaria & Swablu (Lane)
    ObjectiveDefinition(
      id: 'pu_altaria_lane',
      name: 'Altaria & Swablu (Lane)',
      category: ObjectiveCategory.minor,
      initialSpawnSeconds: 130, // 2:10 elapsed (7:50 remaining)
      respawnIntervalSeconds: 90, // 1:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/pu_altaria.png',
      isMajor: false,
      description:
          'Dense wild Pokémon cluster appearing in top and bottom lane corridors for rapid Aeos energy farming.',
    ),

    // 5. Central Swablu / Central Altaria
    ObjectiveDefinition(
      id: 'pu_central_swablu',
      name: 'Central Swablu',
      category: ObjectiveCategory.minor,
      initialSpawnSeconds: 120, // 2:00 elapsed (8:00 remaining)
      respawnIntervalSeconds: 90, // 1:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/pu_swablu.png',
      isMajor: false,
      description:
          'Middle lane flock granting pivotal early-game catchup experience for junglers and speedsters.',
    ),
  ],
);
