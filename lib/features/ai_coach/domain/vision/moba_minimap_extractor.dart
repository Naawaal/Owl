// language: Dart, file: moba_minimap_extractor.dart, target: Flutter / Owl MOBA Companion
import 'dart:typed_data';
import 'package:owl/features/ai_coach/domain/vision/minimap_models.dart';

export 'minimap_models.dart';

/// Extracts MOBA tactical state from landscape minimap viewport.
///
/// Assumes landscape layout where the minimap occupies the top-left:
/// x: 0.0 to 0.34 of screen width (34%)
/// y: 0.0 to 0.20 of screen height (20%)
class MobaMinimapExtractor {
  MobaMinimapExtractor({
    this.missingThresholdSeconds = 5,
  });

  /// Seconds without vision before an enemy is classified as "missing" (default 5s).
  final int missingThresholdSeconds;

  // Tracked hero states keyed by token id
  final Map<String, MinimapHeroToken> _knownEnemies = {};

  /// Crops the minimap bounding box from full screen RGBA bytes.
  /// Returns the cropped sub-image bytes, crop width, and crop height.
  ({Uint8List bytes, int width, int height}) cropMinimap(
    Uint8List screenRgba,
    int screenWidth,
    int screenHeight,
  ) {
    if (screenWidth <= 0 || screenHeight <= 0 || screenRgba.isEmpty) {
      return (bytes: Uint8List(0), width: 0, height: 0);
    }

    final cropW = (screenWidth * 0.34).round().clamp(1, screenWidth);
    final cropH = (screenHeight * 0.20).round().clamp(1, screenHeight);
    final cropBytes = Uint8List(cropW * cropH * 4);

    for (int y = 0; y < cropH; y++) {
      final srcOffset = (y * screenWidth * 4);
      final destOffset = (y * cropW * 4);
      final lineLength = cropW * 4;

      if (srcOffset + lineLength <= screenRgba.length) {
        cropBytes.setRange(
          destOffset,
          destOffset + lineLength,
          screenRgba,
          srcOffset,
        );
      }
    }

    return (bytes: cropBytes, width: cropW, height: cropH);
  }

  /// Ingests detected raw hero tokens and updates temporal missing laner states.
  MobaTacticalSnapshot processTokens({
    required List<MinimapHeroToken> detectedTokens,
    required int matchTimeSeconds,
    List<NeutralObjectiveState>? objectiveOverrides,
  }) {
    final allies = <MinimapHeroToken>[];
    final visibleEnemies = <MinimapHeroToken>[];
    final newlySeenIds = <String>{};

    for (final token in detectedTokens) {
      if (token.team == 'ally') {
        allies.add(token);
      } else {
        visibleEnemies.add(token);
        newlySeenIds.add(token.id);
        _knownEnemies[token.id] = token.copyWith(
          lastSeenMatchTimeSeconds: matchTimeSeconds,
          isMissing: false,
          missingDurationSeconds: 0,
        );
      }
    }

    // Check for missing enemies among previously tracked enemies
    final missing = <MinimapHeroToken>[];
    final alerts = <String>[];

    for (final entry in _knownEnemies.entries) {
      if (!newlySeenIds.contains(entry.key)) {
        final lastSeen = entry.value.lastSeenMatchTimeSeconds;
        final elapsed = matchTimeSeconds - lastSeen;
        if (elapsed >= missingThresholdSeconds) {
          final missingToken = entry.value.copyWith(
            isMissing: true,
            missingDurationSeconds: elapsed,
          );
          _knownEnemies[entry.key] = missingToken;
          missing.add(missingToken);
          alerts.add(
            'Enemy ${missingToken.lane} missing for ${elapsed}s (Possible flank/gank)',
          );
        }
      }
    }

    // Default neutral objective progression if none provided
    final objectives = objectiveOverrides ??
        _computeObjectiveTimers(matchTimeSeconds, allies, visibleEnemies);
    for (final obj in objectives) {
      if (obj.isContested) {
        alerts.add('${obj.name} is actively contested!');
      } else if (obj.status == 'upcoming' && obj.timeUntilSpawnSeconds <= 15) {
        alerts.add(
          '${obj.name} spawning in ${obj.timeUntilSpawnSeconds}s - Prepare positioning',
        );
      }
    }

    return MobaTacticalSnapshot(
      matchTimeSeconds: matchTimeSeconds,
      visibleAllies: allies,
      visibleEnemies: visibleEnemies,
      missingEnemies: missing,
      objectives: objectives,
      tacticalAlerts: alerts,
    );
  }

  /// Calculates objective spawn cadence based on standard MOBA progression.
  List<NeutralObjectiveState> _computeObjectiveTimers(
    int matchTimeSeconds,
    List<MinimapHeroToken> allies,
    List<MinimapHeroToken> enemies,
  ) {
    final list = <NeutralObjectiveState>[];

    // Turtle spawns at 2:00 (120s), despawns/replaced by Lord at 8:00 (480s)
    if (matchTimeSeconds < 120) {
      list.add(NeutralObjectiveState(
        name: 'Turtle',
        status: 'upcoming',
        timeUntilSpawnSeconds: 120 - matchTimeSeconds,
      ));
    } else if (matchTimeSeconds < 480) {
      final isContested =
          _isObjectivePitContested(allies, enemies, 0.20, 0.12);
      list.add(NeutralObjectiveState(
        name: 'Turtle',
        status: isContested ? 'contested' : 'alive',
        isContested: isContested,
      ));
    }

    // Lord spawns at 8:00 (480s) and respawns every 180s thereafter
    if (matchTimeSeconds >= 420 && matchTimeSeconds < 480) {
      list.add(NeutralObjectiveState(
        name: 'Lord',
        status: 'upcoming',
        timeUntilSpawnSeconds: 480 - matchTimeSeconds,
      ));
    } else if (matchTimeSeconds >= 480) {
      final isContested =
          _isObjectivePitContested(allies, enemies, 0.80, 0.88);
      list.add(NeutralObjectiveState(
        name: 'Lord',
        status: isContested ? 'contested' : 'alive',
        isContested: isContested,
      ));
    }

    return list;
  }

  /// Checks if both ally and enemy clusters are within 0.15 normalized distance of pit.
  bool _isObjectivePitContested(
    List<MinimapHeroToken> allies,
    List<MinimapHeroToken> enemies,
    double pitX,
    double pitY,
  ) {
    bool allyNear = false;
    bool enemyNear = false;

    for (final a in allies) {
      final dx = a.normalizedX - pitX;
      final dy = a.normalizedY - pitY;
      if ((dx * dx + dy * dy) < (0.15 * 0.15)) {
        allyNear = true;
        break;
      }
    }

    for (final e in enemies) {
      final dx = e.normalizedX - pitX;
      final dy = e.normalizedY - pitY;
      if ((dx * dx + dy * dy) < (0.15 * 0.15)) {
        enemyNear = true;
        break;
      }
    }

    return allyNear && enemyNear;
  }

  void reset() {
    _knownEnemies.clear();
  }
}
