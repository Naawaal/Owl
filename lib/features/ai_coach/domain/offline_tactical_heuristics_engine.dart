// language: Dart, file: offline_tactical_heuristics_engine.dart, target: Flutter / Owl MOBA HUD
import 'package:owl/features/ai_coach/domain/heuristic_rules.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';

export 'heuristic_rules.dart';

/// Autonomous tactical rule engine that provides game-specific strategic
/// coaching when cloud LLM inference is offline or unconfigured.
class OfflineTacticalHeuristicsEngine {
  const OfflineTacticalHeuristicsEngine();

  /// Generates real-time tactical directives tailored to the active game,
  /// player role, match progression, and user tactical settings.
  CoachResponse generateAdvice({
    required String gameName,
    String? role,
    int matchTimeSeconds = 0,
    int targetFps = 120,
    int currentFps = 120,
    GameTurboSettings? settings,
  }) {
    final lowerTitle = gameName.toLowerCase();
    final now = DateTime.now();

    final effectiveRole = (settings != null &&
            settings.preferredRole.isNotEmpty &&
            settings.preferredRole != 'auto')
        ? settings.preferredRole
        : role;

    CoachResponse base;
    if (lowerTitle.contains('mobile legend') ||
        lowerTitle.contains('mlbb') ||
        lowerTitle.contains('wild rift') ||
        lowerTitle.contains('arena of valor') ||
        lowerTitle.contains('honor of kings')) {
      base = HeuristicRules.generateMobaAdvice(
        effectiveRole,
        matchTimeSeconds,
        now,
        settings,
      );
    } else if (lowerTitle.contains('free fire') ||
        lowerTitle.contains('pubg') ||
        lowerTitle.contains('codm') ||
        lowerTitle.contains('battleground') ||
        lowerTitle.contains('apex')) {
      base = HeuristicRules.generateBattleRoyaleAdvice(
        effectiveRole,
        matchTimeSeconds,
        now,
        settings,
      );
    } else if (lowerTitle.contains('genshin') ||
        lowerTitle.contains('honkai') ||
        lowerTitle.contains('wuthering')) {
      base = HeuristicRules.generateActionRpgAdvice(
        currentFps,
        targetFps,
        now,
        settings,
      );
    } else {
      base = HeuristicRules.generateUniversalAdvice(
        gameName,
        currentFps,
        targetFps,
        now,
        settings,
      );
    }

    if (settings != null) {
      return _applyTacticalFilters(base, settings);
    }
    return base;
  }

  CoachResponse _applyTacticalFilters(
    CoachResponse base,
    GameTurboSettings settings,
  ) {
    String? warning = base.warning;
    String reason = base.reason;

    if (!settings.explainRecommendations) {
      reason = '';
    }

    if (!settings.missingEnemyAlerts && warning != null) {
      if (warning.toLowerCase().contains('missing')) {
        warning = null;
      }
    }

    if (!settings.overextensionRadar && warning != null) {
      if (warning.toLowerCase().contains('overextend')) {
        warning = null;
      }
    }

    return CoachResponse(
      action: base.action,
      reason: reason,
      warning: warning,
      rawText: base.rawText,
      timestamp: base.timestamp,
    );
  }
}
