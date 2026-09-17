// language: Dart, file: heuristic_rules.dart, target: Flutter / Owl MOBA HUD
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';

/// Predefined tactical rules and strategic heuristics catalogue for offline coaching.
abstract final class HeuristicRules {
  /// MOBA tactical heuristic generator (Early game 0-5m vs Mid/Late game 5m+).
  static CoachResponse generateMobaAdvice(
    String? role,
    int matchTime,
    DateTime now,
    GameTurboSettings? settings,
  ) {
    final normalizedRole = role?.toLowerCase() ?? 'auto';
    final isBeginner = settings?.coachingLevel == 'beginner';
    final isAdvanced = settings?.coachingLevel == 'advanced';
    final allowObjectives = settings?.objectiveTimers ?? true;
    final allowWaves = settings?.laneWaveAdvice ?? true;

    // Early game (0 - 5 min)
    if (matchTime < 300) {
      if (normalizedRole.contains('jung') ||
          normalizedRole.contains('assassin')) {
        if (!allowObjectives) {
          return CoachResponse(
            action: isBeginner
                ? 'Clear jungle monsters'
                : 'Farm jungle quadrant & gank lane',
            reason: 'Builds gold lead and pressures enemy outer lanes.',
            warning: 'Track enemy jungler rotation.',
            rawText: 'Farm jungle quadrant & gank lane',
            timestamp: now,
          );
        }
        return CoachResponse(
          action: isBeginner
              ? 'Defeat Red Monster → Help at Turtle at 2:00'
              : isAdvanced
                  ? 'Clear Red Buff (Smite reserve) → Path Top for 2:00 Turtle contest'
                  : 'Clear Red Buff → Rotate Top for 2:00 Turtle',
          reason:
              'Enemy jungler pathing towards bot lane; top river offers uncontested vision.',
          warning: 'Keep Retribution off cooldown for the Turtle objective.',
          rawText: 'Clear Red Buff → Rotate Top for 2:00 Turtle',
          timestamp: now,
        );
      } else if (normalizedRole.contains('roam') ||
          normalizedRole.contains('tank')) {
        return CoachResponse(
          action: isBeginner
              ? 'Protect teammates and check bushes'
              : 'Zone enemy mid-laner & secure river vision',
          reason:
              'Provides safety for your gold-laner while protecting jungle camps from invasion.',
          warning: 'Do not overextend into enemy jungle without team backup.',
          rawText: 'Zone enemy mid-laner & secure river vision',
          timestamp: now,
        );
      } else {
        if (!allowWaves) {
          return CoachResponse(
            action: isBeginner
                ? 'Stay near your tower'
                : 'Trade carefully near turret range',
            reason:
                'Minimizes gank vulnerability before your core items are completed.',
            warning: 'Enemy mid roamer is missing from minimap.',
            rawText: 'Trade carefully near turret range',
            timestamp: now,
          );
        }
        return CoachResponse(
          action: isBeginner
              ? 'Stay near tower and defeat minions safely'
              : 'Freeze wave near outer turret & poke safely',
          reason:
              'Minimizes gank vulnerability before your core items are completed.',
          warning: 'Enemy mid roamer is missing from minimap.',
          rawText: 'Freeze wave near outer turret & poke safely',
          timestamp: now,
        );
      }
    }

    // Mid to Late game (5+ min)
    if (!allowObjectives) {
      return CoachResponse(
        action: isBeginner
            ? 'Group up with team for fights'
            : 'Group 5v4 for teamfight advantage',
        reason: 'Numerical advantage guarantees successful turret siege.',
        warning: 'Disengage immediately if enemy flanks from behind.',
        rawText: 'Group 5v4 for teamfight advantage',
        timestamp: now,
      );
    }
    return CoachResponse(
      action: isBeginner
          ? 'Help team defeat Lord after winning fight'
          : 'Force 5v4 contest at Lord Pit after pick-off',
      reason:
          'Enemy team lacks split-push wave clear; Lord push guarantees inhibitor turret.',
      warning:
          'Disengage immediately if enemy mage flanks through mid bushes.',
      rawText: 'Force 5v4 contest at Lord Pit after pick-off',
      timestamp: now,
    );
  }

  /// Battle Royale positioning and zone rotation heuristics.
  static CoachResponse generateBattleRoyaleAdvice(
    String? role,
    int matchTime,
    DateTime now,
    GameTurboSettings? settings,
  ) {
    final isBeginner = settings?.coachingLevel == 'beginner';
    if (matchTime < 360) {
      return CoachResponse(
        action: isBeginner
            ? 'Move inside the safe circle on a hill'
            : 'Secure compound on high ground inside next safe zone',
        reason:
            'Elevated terrain provides 360° sightlines against incoming zone stragglers.',
        warning: 'Beware third-party snipers from northern ridge.',
        rawText: 'Secure compound on high ground inside next safe zone',
        timestamp: now,
      );
    }

    return CoachResponse(
      action: isBeginner
          ? 'Use smoke grenades when moving through open areas'
          : 'Hold zone edge rotation with smoke cover',
      reason:
          'Opponents are battling on east hill; flanking the survivors grants easy cleanup kills.',
      warning:
          'Check rear ridge before committing to the open river crossing.',
      rawText: 'Hold zone edge rotation with smoke cover',
      timestamp: now,
    );
  }

  /// Action RPG elemental rotation advice.
  static CoachResponse generateActionRpgAdvice(
    int currentFps,
    int targetFps,
    DateTime now,
    GameTurboSettings? settings,
  ) {
    return CoachResponse(
      action: 'Optimize elemental burst rotations',
      reason:
          'Chaining continuous reaction procs amplifies total combat DPS by 2.4x.',
      warning: currentFps < targetFps - 10
          ? 'Thermal throttling detected; reduce bloom effects for stable 120 FPS.'
          : 'Conserve stamina for defensive dodge frames.',
      rawText: 'Optimize elemental burst rotations',
      timestamp: now,
    );
  }

  /// Fallback heuristic for unrecognized titles.
  static CoachResponse generateUniversalAdvice(
    String gameName,
    int currentFps,
    int targetFps,
    DateTime now,
    GameTurboSettings? settings,
  ) {
    return CoachResponse(
      action: 'High-Performance Tactical Mode Active',
      reason:
          'Display locked at $targetFps Hz with optimized touch sampling for $gameName.',
      warning:
          'Monitor device temperature if playing during extended charging.',
      rawText: 'High-Performance Tactical Mode Active for $gameName',
      timestamp: now,
    );
  }
}
