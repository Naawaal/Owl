// language: Dart, file: wild_rift_preset.dart, target: Flutter / Owl MOBA HUD
import '../../domain/models/game_profile.dart';
import '../../domain/models/objective_definition.dart';

/// League of Legends: Wild Rift official preset configuration.
/// Includes accurate spawn timings, respawns, warning thresholds, and objective metadata.
const wildRiftPreset = GameProfile(
  id: 'wild_rift',
  name: 'League of Legends: Wild Rift',
  shortName: 'Wild Rift',
  logoAsset: 'assets/games/wild_rift_logo.png',
  mapName: "Wild Rift (Summoner's Rift)",
  objectives: [
    // 1. Elemental Dragon
    ObjectiveDefinition(
      id: 'wr_elemental_dragon',
      name: 'Elemental Dragon',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 300, // 5:00
      respawnIntervalSeconds: 300, // 5:00
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/wr_dragon.png',
      isMajor: true,
      description:
          'Grants permanent elemental buffs (Mountain, Infernal, Ocean) to the slaying team.',
    ),

    // 2. Elder Dragon
    ObjectiveDefinition(
      id: 'wr_elder_dragon',
      name: 'Elder Dragon',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 1200, // 20:00
      respawnIntervalSeconds: 300, // 5:00
      warningLeadSeconds: 45,
      iconAsset: 'assets/icons/objectives/wr_elder.png',
      isMajor: true,
      description:
          'Empowered burn damage and execute below 20% health for decisive late-game teamfights.',
    ),

    // 3. Rift Herald
    ObjectiveDefinition(
      id: 'wr_rift_herald',
      name: 'Rift Herald',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 360, // 6:00
      respawnIntervalSeconds: 0, // Despawns before Baron
      warningLeadSeconds: 30,
      iconAsset: 'assets/icons/objectives/wr_herald.png',
      isMajor: true,
      description:
          'Summons Shelly to headbutt enemy towers and crack lane plates.',
    ),

    // 4. Baron Nashor
    ObjectiveDefinition(
      id: 'wr_baron_nashor',
      name: 'Baron Nashor',
      category: ObjectiveCategory.epic,
      initialSpawnSeconds: 720, // 12:00
      respawnIntervalSeconds: 210, // 3:30
      warningLeadSeconds: 45,
      iconAsset: 'assets/icons/objectives/wr_baron.png',
      isMajor: true,
      description:
          'Hand of Baron: Empowers nearby minions for coordinated high-ground pushes.',
    ),

    // 5. Blue Sentinel (Blue Buff)
    ObjectiveDefinition(
      id: 'wr_blue_buff',
      name: 'Blue Sentinel (Blue Buff)',
      category: ObjectiveCategory.buff,
      initialSpawnSeconds: 90, // 1:30
      respawnIntervalSeconds: 150, // 2:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/wr_blue_buff.png',
      isMajor: false,
      description:
          'Crest of Insight: Accelerates mana/energy regeneration and ability haste.',
    ),

    // 6. Red Brambleback (Red Buff)
    ObjectiveDefinition(
      id: 'wr_red_buff',
      name: 'Red Brambleback (Red Buff)',
      category: ObjectiveCategory.buff,
      initialSpawnSeconds: 90, // 1:30
      respawnIntervalSeconds: 150, // 2:30
      warningLeadSeconds: 15,
      iconAsset: 'assets/icons/objectives/wr_red_buff.png',
      isMajor: false,
      description:
          'Crest of Cinders: Applies true damage burn and movement speed slow on hit.',
    ),
  ],
);
