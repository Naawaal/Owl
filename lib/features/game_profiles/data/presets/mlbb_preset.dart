// language: Dart, file: mlbb_preset.dart, target: Flutter / Owl MOBA HUD
import '../../domain/models/game_profile.dart';
import '../../domain/models/objective_definition.dart';

/// Mobile Legends: Bang Bang official preset configuration.
/// Standard Land of Dawn timers, buffs, and boss monsters.
const mlbbPreset = GameProfile(
  id: 'mlbb',
  name: 'Mobile Legends: Bang Bang',
  shortName: 'MLBB',
  logoAsset: 'assets/games/mlbb_logo.png',
  mapName: 'Land of Dawn',
  objectives: [
    // 1. Turtle
    ObjectiveDefinition(
      id: 'mlbb_turtle',
      name: 'Turtle',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 120, // 2:00
      respawnIntervalSeconds: 120, // 2:00 (until 8:00 Lord spawn)
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/mlbb_turtle.png',
      isMajor: true,
      description:
          'Provides team-wide gold, experience, and a decaying combat shield to the killer.',
    ),

    // 2. Lord (Evolved / Enhanced)
    ObjectiveDefinition(
      id: 'mlbb_lord',
      name: 'Lord (Evolved / Enhanced)',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 480, // 8:00
      respawnIntervalSeconds: 180, // 3:00
      warningLeadSeconds: 45,
      iconAsset: 'assets/icons/objectives/mlbb_lord.png',
      isMajor: true,
      description:
          'Marches down the lane with lowest turret HP; charges and disables defense towers at 12m+ / 18m+.',
    ),

    // 3. Lithowanderer
    ObjectiveDefinition(
      id: 'mlbb_lithowanderer',
      name: 'Lithowanderer',
      category: ObjectiveCategory.neutral,
      initialSpawnSeconds: 45, // 0:45
      respawnIntervalSeconds: 120, // 2:00
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/mlbb_lithowanderer.png',
      isMajor: false,
      description:
          'River scout that follows the killer, granting bonus vision and continuous mana/energy regeneration.',
    ),

    // 4. Purple Buff (Fiend)
    ObjectiveDefinition(
      id: 'mlbb_purple_buff',
      name: 'Purple Buff',
      category: ObjectiveCategory.buff,
      initialSpawnSeconds: 30, // 0:30
      respawnIntervalSeconds: 90, // 1:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/mlbb_purple_buff.png',
      isMajor: false,
      description:
          'Reduces cooldowns by 10% and significantly decreases energy/mana consumption.',
    ),

    // 5. Orange Buff (Statue)
    ObjectiveDefinition(
      id: 'mlbb_orange_buff',
      name: 'Orange Buff',
      category: ObjectiveCategory.buff,
      initialSpawnSeconds: 30, // 0:30
      respawnIntervalSeconds: 90, // 1:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/mlbb_orange_buff.png',
      isMajor: false,
      description:
          'Inflicts bonus true damage and a movement speed slowing debuff on basic attacks.',
    ),
  ],
);
