// language: Dart, file: coach_service.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/ai_inference_dispatcher.dart';
import 'package:owl/features/ai_coach/data/match_budget_tracker.dart';
import 'package:owl/features/ai_coach/data/tts_announcer.dart';
import 'package:owl/features/ai_coach/domain/models/coach_prompt.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/ai_coach/domain/offline_tactical_heuristics_engine.dart';
import 'package:owl/features/ai_coach/domain/vision/moba_minimap_extractor.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/overlay/data/overlay_channel.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_network/owl_network.dart';

/// Reactive provider for the tactical coach service.
final coachServiceProvider =
    StateNotifierProvider<CoachService, AsyncValue<CoachResponse?>>(
  (ref) => CoachService(ref),
);

/// Orchestrates live tactical advice: builds [CoachPrompt]s from live game
/// state, enforces request budgets, calls the active provider client, and
/// exposes the latest advice reactively with last-known caching.
class CoachService extends StateNotifier<AsyncValue<CoachResponse?>> {
  CoachService(
    this._ref, {
    MatchBudgetTracker? budgetTracker,
    AiInferenceDispatcher? inferenceDispatcher,
  })  : _budgetTracker = budgetTracker ?? MatchBudgetTracker(),
        _inferenceDispatcher =
            inferenceDispatcher ?? const AiInferenceDispatcher(),
        super(const AsyncValue.data(null));

  final Ref _ref;
  final MatchBudgetTracker _budgetTracker;
  final AiInferenceDispatcher _inferenceDispatcher;

  CoachResponse? _lastKnown;
  bool _inFlight = false;
  String _lastPromptType = 'tactical';
  String _lastKnownTopic = 'tactical';
  int? _lastLatencyMs;

  final MobaMinimapExtractor _minimapExtractor = MobaMinimapExtractor();
  MobaTacticalSnapshot? _latestMinimapSnapshot;

  /// Underlying minimap extractor instance.
  MobaMinimapExtractor get minimapExtractor => _minimapExtractor;

  /// Most recent tactical snapshot extracted from vision minimap.
  MobaTacticalSnapshot? get latestMinimapSnapshot => _latestMinimapSnapshot;

  /// Last successfully received advice, if any.
  CoachResponse? get lastKnown => _lastKnown;

  /// Number of networked queries issued for the current match.
  int get callsThisMatch => _budgetTracker.callsThisMatch;

  /// Whether stress throttling is currently engaged.
  bool get isStressThrottled => _budgetTracker.isStressThrottled;

  /// Prompt type of the most recent query.
  String get lastPromptType => _lastPromptType;

  /// Topic of the cached [lastKnown] advice.
  String get lastKnownTopic => _lastKnownTopic;

  /// Measured milliseconds of the most recent networked query.
  int? get lastLatencyMs => _lastLatencyMs;

  /// Reports a device stress sample to the budget tracker.
  void reportStressSample({
    required GameTurboSettings settings,
    required int cpuPercent,
    required int batteryPercent,
  }) {
    _budgetTracker.reportStressSample(
      settings: settings,
      cpuPercent: cpuPercent,
      batteryPercent: batteryPercent,
    );
  }

  /// Cooldown actually enforced, accounting for stress throttle.
  Duration enforcedCooldown(GameTurboSettings settings) =>
      _budgetTracker.enforcedCooldown(settings);

  /// Cap actually enforced, accounting for stress throttle.
  int enforcedCap(GameTurboSettings settings) =>
      _budgetTracker.enforcedCap(settings);

  /// Effective cooldown after the warning-sensitivity multiplier.
  static Duration effectiveCooldown(GameTurboSettings settings) =>
      MatchBudgetTracker.effectiveCooldown(settings);

  /// Effective per-match cap after the warning-sensitivity multiplier.
  static int effectiveCap(GameTurboSettings settings) =>
      MatchBudgetTracker.effectiveCap(settings);

  /// Base cooldown per performance profile.
  static Duration baseCooldownFor(String performanceMode) =>
      MatchBudgetTracker.baseCooldownFor(performanceMode);

  /// Base per-match cap per performance profile.
  static int baseCapFor(String performanceMode) =>
      MatchBudgetTracker.baseCapFor(performanceMode);

  /// FPS target per performance profile.
  static int fpsTargetFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return 60;
      default:
        return 120;
    }
  }

  /// Depth instruction block for [coachingLevel].
  static String depthBlock(String coachingLevel) =>
      AiInferenceDispatcher.depthBlock(coachingLevel);

  /// Ingests detected raw minimap hero tokens and updates current tactical context.
  void ingestMinimapTokens({
    required List<MinimapHeroToken> detectedTokens,
    required int matchTimeSeconds,
    List<NeutralObjectiveState>? objectiveOverrides,
  }) {
    _latestMinimapSnapshot = _minimapExtractor.processTokens(
      detectedTokens: detectedTokens,
      matchTimeSeconds: matchTimeSeconds,
      objectiveOverrides: objectiveOverrides,
    );
  }

  /// Calculates latency-compensated game time in seconds.
  int computeCompensatedMatchTime(int rawMatchTimeSeconds) {
    if (_lastLatencyMs == null || _lastLatencyMs! <= 0) {
      return rawMatchTimeSeconds;
    }
    final latencySeconds = (_lastLatencyMs! / 1000.0).round();
    return rawMatchTimeSeconds + latencySeconds;
  }

  /// Requests tactical advice for [situation].
  Future<void> requestAdvice({
    required String situation,
    String promptType = 'tactical',
    int matchTimeSeconds = 0,
    Map<String, dynamic>? tacticalContext,
    String? heroChampion,
    String? base64Frame,
    bool manual = false,
  }) async {
    if (_inFlight) return;

    final settings = _ref.read(gameTurboSettingsProvider);
    if (!settings.guardianTacticalEngine) return;
    if (settings.assistantMode == 'off') return;
    if (!manual) {
      if (!settings.gameTurboMaster) return;
      if (settings.assistantMode != 'live') return;
    }

    final compensatedTime = computeCompensatedMatchTime(matchTimeSeconds);
    final effectiveContext =
        tacticalContext ?? _latestMinimapSnapshot?.toTacticalContext();

    final key = await _ref
        .read(apiKeyManagerProvider)
        .getApiKey(settings.activeAiProvider);
    if (key == null || key.isEmpty) {
      final game = _ref.read(activeGameProvider);
      final offlineResponse =
          const OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: compensatedTime,
        targetFps: game?.targetFps ?? 120,
        settings: settings,
      );
      _lastKnown = offlineResponse;
      _lastKnownTopic = promptType;
      _lastPromptType = promptType;
      state = AsyncValue.data(offlineResponse);
      unawaited(_maybeAnnounce(offlineResponse, settings));
      return;
    }

    final now = DateTime.now();
    if (!_budgetTracker.canMakeRequest(settings, now)) return;

    final game = _ref.read(activeGameProvider);
    _budgetTracker.trackMatch(
      '${game?.packageName ?? 'unknown'}|${settings.activeAiProvider}',
    );
    _lastPromptType = promptType;
    _sampleDeviceStress(settings);

    _inFlight = true;
    state = const AsyncValue.loading();
    try {
      final stats = _ref.read(systemStatsProvider).valueOrNull;
      final prompt = CoachPrompt(
        gameName: game?.name ?? 'Unknown Match',
        matchTimeSeconds: compensatedTime,
        role: settings.preferredRole,
        currentSituation: situation,
        promptType: promptType,
        heroChampion: heroChampion,
        tacticalContext: effectiveContext,
        gameCategory: game?.category,
        cpuPercent: stats?.cpu,
        batteryPercent: stats?.battery,
        liveFps: stats?.fps,
      );
      final client = inferenceClientFor(
        providerId: settings.activeAiProvider,
        api: _ref.read(apiClientProvider),
      );

      final result = await _inferenceDispatcher.dispatch(
        client: client,
        apiKey: key,
        settings: settings,
        prompt: prompt,
        activeGame: game,
        base64Frame: base64Frame,
      );

      _lastLatencyMs = result.latencyMs;
      _lastKnown = result.response;
      _lastKnownTopic = promptType;
      _budgetTracker.recordCall(now);
      state = AsyncValue.data(result.response);
      unawaited(_maybeAnnounce(
        result.response,
        settings,
        usedVision: result.usedVision,
      ));
    } on InferenceException catch (_) {
      final fallback = _generateOfflineFallback(settings, compensatedTime);
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
      unawaited(_maybeAnnounce(fallback, settings));
    } catch (_) {
      final fallback = _generateOfflineFallback(settings, compensatedTime);
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
      unawaited(_maybeAnnounce(fallback, settings));
    } finally {
      _inFlight = false;
    }
  }

  CoachResponse _generateOfflineFallback(
    GameTurboSettings settings,
    int compensatedTime,
  ) {
    final game = _ref.read(activeGameProvider);
    return const OfflineTacticalHeuristicsEngine().generateAdvice(
      gameName: game?.name ?? 'Unknown Match',
      role: settings.preferredRole,
      matchTimeSeconds: compensatedTime,
      targetFps: game?.targetFps ?? 120,
      settings: settings,
    );
  }

  /// Prompt types issued by the topic auto-refresh loop.
  static const String topicMissingEnemy = 'missing-enemy';
  static const String topicOverextension = 'overextension';
  static const String topicObjective = 'objective';
  static const String topicWave = 'wave';

  /// Prompt types subscribed by the topic toggles, in refresh order.
  static List<String> subscribedTopics(GameTurboSettings settings) {
    final topics = <String>[];
    if (settings.missingEnemyAlerts) topics.add(topicMissingEnemy);
    if (settings.overextensionRadar) topics.add(topicOverextension);
    if (settings.objectiveTimers) topics.add(topicObjective);
    if (settings.laneWaveAdvice) topics.add(topicWave);
    return topics;
  }

  /// Whether advice of [promptType] may auto-query and display.
  static bool isTopicEnabled(GameTurboSettings settings, String promptType) {
    switch (promptType) {
      case topicMissingEnemy:
        return settings.missingEnemyAlerts;
      case topicOverextension:
        return settings.overextensionRadar;
      case topicObjective:
        return settings.objectiveTimers;
      case topicWave:
        return settings.laneWaveAdvice;
      default:
        return true;
    }
  }

  int _topicCursor = 0;

  /// Issues one auto-refresh query for the next subscribed topic.
  Future<void> requestTopicRefresh() async {
    final settings = _ref.read(gameTurboSettingsProvider);
    // Balanced mode: skip scheduled coach traffic to free thermal headroom.
    if (!settings.performanceOptimization) return;
    final topics = subscribedTopics(settings);
    if (topics.isEmpty) return;
    final topic = topics[_topicCursor % topics.length];
    _topicCursor++;
    final stats = _ref.read(systemStatsProvider).valueOrNull;
    final role =
        settings.preferredRole == 'auto' ? 'your role' : settings.preferredRole;
    final fpsPart = stats?.fps != null ? ' | Live FPS: ${stats!.fps}' : '';
    final cpuPart = stats?.cpu != null ? ' | CPU: ${stats!.cpu}%' : '';
    await requestAdvice(
      situation: 'Scheduled $topic check-in for $role$fpsPart$cpuPart. '
          'Report only if actionable, otherwise reply HOLD with a one-line reason.',
      promptType: topic,
    );
  }

  /// Resets the per-match call budget, e.g. when a new match is detected.
  void resetMatchBudget() {
    _budgetTracker.reset();
  }

  /// Speaks [response] when voice gates pass and triggers haptic alerts.
  Future<void> _maybeAnnounce(
    CoachResponse response,
    GameTurboSettings settings, {
    bool usedVision = false,
  }) async {
    try {
      if (!settings.gameTurboMaster) return;
      if (!settings.guardianTacticalEngine) return;

      if (settings.hapticsEnabled) {
        if (response.warning?.trim().isNotEmpty == true) {
          HapticHelper.heavyImpact();
        } else {
          HapticHelper.lightImpact();
        }
      }

      unawaited(
        const OverlayChannel().updateTacticalAdvice(
          badge: usedVision ? 'GUARDIAN AI • VISION' : 'GUARDIAN AI • LIVE',
          action: response.action,
          warning: response.warning,
        ),
      );

      if (!settings.voiceAlertsEnabled) return;

      final hasWarning =
          response.warning != null && response.warning!.trim().isNotEmpty;
      if (settings.alertPriority == 'criticalOnly' && !hasWarning) {
        return;
      }
      if (settings.alertPriority == 'important') {
        final actionUpper = response.action.toUpperCase();
        final isImportant = hasWarning ||
            actionUpper.contains('TURTLE') ||
            actionUpper.contains('LORD') ||
            actionUpper.contains('STEAL') ||
            actionUpper.contains('BASE') ||
            actionUpper.contains('GANK') ||
            actionUpper.contains('RETREAT') ||
            actionUpper.contains('DISENGAGE');
        if (!isImportant) return;
      }

      final announcer = _ref.read(ttsAnnouncerProvider);
      final lastSpoke = announcer.lastSpokeAt;
      if (lastSpoke != null) {
        final gap = DateTime.now().difference(lastSpoke).inSeconds;
        if (gap < settings.speechCooldownSeconds) return;
      }

      final script = response.warning?.trim().isNotEmpty == true
          ? '${response.action}. ${response.warning}'
          : (response.reason.trim().isNotEmpty
              ? '${response.action}. ${response.reason}'
              : response.action);

      final audioFocus = !settings.avoidInterruptingGameAudio;
      await announcer.speak(script, focus: audioFocus);
    } catch (_) {}
  }

  void _sampleDeviceStress(GameTurboSettings settings) {
    try {
      final stats = _ref.read(systemStatsProvider).valueOrNull;
      if (stats == null) return;
      _budgetTracker.reportStressSample(
        settings: settings,
        cpuPercent: stats.cpu,
        batteryPercent: stats.battery,
      );
    } catch (_) {}
  }
}
