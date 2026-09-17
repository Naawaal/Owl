// language: Dart, file: coach_service.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl_core/owl_core.dart';
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
import 'package:owl_network/owl_network.dart';

/// Reactive provider for the tactical coach service.
final coachServiceProvider =
    StateNotifierProvider<CoachService, AsyncValue<CoachResponse?>>(
  (ref) => CoachService(ref),
);

/// Orchestrates live tactical advice: builds [CoachPrompt]s from live game
/// state, enforces request budgets, calls the active provider client, and
/// exposes the latest advice reactively with last-known caching.
///
/// The UI (Guardian toolbox callout) watches this state and never touches
/// the network directly. All failures resolve to error state; callers fall
/// back to [lastKnown] and then silence.
class CoachService extends StateNotifier<AsyncValue<CoachResponse?>> {
  CoachService(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Maximum wall-clock budget per inference request.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Minimum gap between networked queries; rapid refires resolve cached.
  /// Base for the `balanced` profile; see [baseCooldownFor].
  static const Duration queryCooldown = Duration(seconds: 30);

  /// Maximum networked queries per match before silence.
  /// Base for the `balanced` profile; see [baseCapFor].
  static const int maxCallsPerMatch = 20;

  /// Stress detection thresholds (CPU+battery proxy; no temp sensor).
  static const int stressCpuThreshold = 80;
  static const int stressBatteryCeiling = 25;

  /// Consecutive stressed readings to engage, unstressed to release.
  static const int stressWindow = 3;

  CoachResponse? _lastKnown;
  int _callsThisMatch = 0;
  DateTime? _lastCallAt;
  bool _inFlight = false;
  String? _matchKey;
  String _lastPromptType = 'tactical';
  String _lastKnownTopic = 'tactical';
  int? _lastLatencyMs;

  final MobaMinimapExtractor _minimapExtractor = MobaMinimapExtractor();
  MobaTacticalSnapshot? _latestMinimapSnapshot;

  /// Underlying minimap extractor instance.
  MobaMinimapExtractor get minimapExtractor => _minimapExtractor;

  /// Most recent tactical snapshot extracted from vision minimap.
  MobaTacticalSnapshot? get latestMinimapSnapshot => _latestMinimapSnapshot;

  /// High latency threshold (1500ms) beyond which tactical guidance
  /// degrades to fast localized heuristics with a warning flag.
  static const int latencyDegradationThresholdMs = 1500;

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

  /// Calculates latency-compensated game time in seconds, offsetting match duration
  /// by the measured provider RTT to project advice ahead in time.
  int computeCompensatedMatchTime(int rawMatchTimeSeconds) {
    if (_lastLatencyMs == null || _lastLatencyMs! <= 0) {
      return rawMatchTimeSeconds;
    }
    final latencySeconds = (_lastLatencyMs! / 1000.0).round();
    return rawMatchTimeSeconds + latencySeconds;
  }

  /// Last successfully received advice, if any. Survives errors and restarts
  /// of the query pipeline within the session.
  CoachResponse? get lastKnown => _lastKnown;

  /// Number of networked queries issued for the current match.
  int get callsThisMatch => _callsThisMatch;

  /// Prompt type of the most recent query (for topic filtering).
  String get lastPromptType => _lastPromptType;

  /// Topic of the cached [lastKnown] advice (for topic filtering).
  String get lastKnownTopic => _lastKnownTopic;

  /// Measured milliseconds of the most recent networked query, if any.
  /// Feeds the latency HUD readout.
  int? get lastLatencyMs => _lastLatencyMs;

  /// Effective cooldown after the warning-sensitivity multiplier.
  static Duration effectiveCooldown(GameTurboSettings settings) {
    final base = baseCooldownFor(settings.performanceMode);
    switch (settings.warningSensitivity) {
      case 'earlyWarning':
        return base ~/ 2;
      case 'conservative':
        return base * 2;
      default:
        return base;
    }
  }

  /// Effective per-match cap after the warning-sensitivity multiplier.
  static int effectiveCap(GameTurboSettings settings) {
    final base = baseCapFor(settings.performanceMode);
    switch (settings.warningSensitivity) {
      case 'earlyWarning':
        return (base * 1.5).round();
      case 'conservative':
        return (base * 0.5).round();
      default:
        return base;
    }
  }

  /// Base cooldown per performance profile.
  static Duration baseCooldownFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return const Duration(seconds: 60);
      case 'high':
        return const Duration(seconds: 15);
      default:
        return queryCooldown;
    }
  }

  /// Base per-match cap per performance profile.
  static int baseCapFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return 8;
      case 'high':
        return 30;
      default:
        return maxCallsPerMatch;
    }
  }

  /// FPS target per performance profile.
  static int fpsTargetFor(String performanceMode) {
    switch (performanceMode) {
      case 'saver':
        return 60;
      default:
        return 120;
    }
  }

  int _stressStreak = 0;
  int _reliefStreak = 0;
  bool _stressThrottled = false;

  /// Whether stress throttling is currently engaged.
  bool get isStressThrottled => _stressThrottled;

  /// Reports one device-stress sample. Engages saver budgets after
  /// [stressWindow] consecutive stressed readings (high CPU with low
  /// battery); releases after the same count of clear readings
  /// (hysteresis against spikes). No-op unless both adaptive workload
  /// and thermal protection are enabled.
  void reportStressSample({
    required GameTurboSettings settings,
    required int cpuPercent,
    required int batteryPercent,
  }) {
    if (!settings.adaptiveWorkload || !settings.thermalProtection) {
      _stressThrottled = false;
      _stressStreak = 0;
      _reliefStreak = 0;
      return;
    }
    final stressed =
        cpuPercent >= stressCpuThreshold && batteryPercent <= stressBatteryCeiling;
    if (stressed) {
      _stressStreak++;
      _reliefStreak = 0;
      if (_stressStreak >= stressWindow) _stressThrottled = true;
    } else {
      _reliefStreak++;
      _stressStreak = 0;
      if (_reliefStreak >= stressWindow) _stressThrottled = false;
    }
  }

  /// Cooldown actually enforced, accounting for stress throttle.
  Duration enforcedCooldown(GameTurboSettings settings) {
    if (_stressThrottled) {
      return baseCooldownFor('saver') * 2;
    }
    return effectiveCooldown(settings);
  }

  /// Cap actually enforced, accounting for stress throttle.
  int enforcedCap(GameTurboSettings settings) {
    if (_stressThrottled) {
      return (baseCapFor('saver') * 0.5).round();
    }
    return effectiveCap(settings);
  }

  /// Depth instruction block for [coachingLevel].
  static String depthBlock(String coachingLevel) {
    switch (coachingLevel) {
      case 'beginner':
        return '\nBriefing depth: Use plain fundamentals language. '
            'Explain the single most important basic concept. No jargon.';
      case 'advanced':
        return '\nBriefing depth: Include wave-control implications and '
            'enemy cooldown specifics alongside the call.';
      default:
        return '\nBriefing depth: Standard tactical briefing with one '
            'concrete reason.';
    }
  }

  /// Requests tactical advice for [situation].
  ///
  /// Automatic queries ([manual] false) are suppressed when the master
  /// switch is off or the assistant mode is not live; manual refreshes
  /// always go through (subject to keys and budgets). Otherwise no-ops
  /// (resolving cached) when a request is in flight, no key is stored,
  /// budgets are exhausted, or the cooldown is active. Never throws:
  /// failures land in [state] as [AsyncValue.error].
  Future<void> requestAdvice({
    required String situation,
    String promptType = 'tactical',
    int matchTimeSeconds = 0,
    Map<String, dynamic>? tacticalContext,
    String? heroChampion,
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

    final key =
        await _ref.read(apiKeyManagerProvider).getApiKey(settings.activeAiProvider);
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
      _lastCallAt = DateTime.now();
      state = AsyncValue.data(offlineResponse);
      unawaited(_maybeAnnounce(offlineResponse, settings));
      return;
    }

    final now = DateTime.now();
    final cooldown = enforcedCooldown(settings);
    if (_lastCallAt != null && now.difference(_lastCallAt!) < cooldown) {
      return;
    }
    if (_callsThisMatch >= enforcedCap(settings)) return;

    _trackMatch(settings.activeAiProvider);
    _lastPromptType = promptType;
    _sampleDeviceStress(settings);

    _inFlight = true;
    state = const AsyncValue.loading();
    final stopwatch = Stopwatch()..start();
    try {
      final game = _ref.read(activeGameProvider);
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
      final text = await client.generate(
        apiKey: key,
        model: settings.activeModel,
        prompt:
            '${prompt.toFormattedPrompt(explainRecommendations: settings.explainRecommendations)}${depthBlock(settings.coachingLevel)}',
        timeout: requestTimeout,
      );
      final elapsed = stopwatch.elapsedMilliseconds;
      _lastLatencyMs = elapsed;

      CoachResponse response;
      if (elapsed > latencyDegradationThresholdMs) {
        // High latency degradation: fallback to localized heuristic alerts + latency warning
        final heuristic = const OfflineTacticalHeuristicsEngine().generateAdvice(
          gameName: game?.name ?? 'Unknown Match',
          role: settings.preferredRole,
          matchTimeSeconds: compensatedTime,
          targetFps: game?.targetFps ?? 120,
          settings: settings,
        );
        response = heuristic.copyWith(
          warning:
              'High latency (${elapsed}ms) - using local tactical guidance. ${heuristic.warning ?? ""}'
                  .trim(),
        );
      } else {
        response = CoachResponse.fromRawText(text);
      }

      _lastKnown = response;
      _lastKnownTopic = promptType;
      _callsThisMatch++;
      _lastCallAt = now;
      state = AsyncValue.data(response);
      unawaited(_maybeAnnounce(response, settings));
    } on InferenceException catch (_) {
      final game = _ref.read(activeGameProvider);
      final fallback = const OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: compensatedTime,
        targetFps: game?.targetFps ?? 120,
        settings: settings,
      );
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
      unawaited(_maybeAnnounce(fallback, settings));
    } catch (e) {
      final game = _ref.read(activeGameProvider);
      final fallback = const OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: compensatedTime,
        targetFps: game?.targetFps ?? 120,
        settings: settings,
      );
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
      unawaited(_maybeAnnounce(fallback, settings));
    } finally {
      _inFlight = false;
    }
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
  /// The default `tactical` type (manual refreshes) is always allowed.
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
  /// No-op when no topics are subscribed. Honors all gates and budgets.
  Future<void> requestTopicRefresh() async {
    final settings = _ref.read(gameTurboSettingsProvider);
    final topics = subscribedTopics(settings);
    if (topics.isEmpty) return;
    final topic = topics[_topicCursor % topics.length];
    _topicCursor++;
    final stats = _ref.read(systemStatsProvider).valueOrNull;
    final role = settings.preferredRole == 'auto' ? 'your role' : settings.preferredRole;
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
    _callsThisMatch = 0;
    _lastCallAt = null;
    _matchKey = null;
  }

  /// Speaks [response] when all voice gates pass: master switch on,
  /// engine on, voice alerts enabled, priority filter satisfied, and
  /// speech cooldown elapsed. Also triggers tactical haptic alerts when
  /// haptics are enabled. Never throws; failures stay silent.
  Future<void> _maybeAnnounce(
    CoachResponse response,
    GameTurboSettings settings,
  ) async {
    try {
      if (!settings.gameTurboMaster) return;
      if (!settings.guardianTacticalEngine) return;

      // 1. Tactical Haptic Alert Feedback
      if (settings.hapticsEnabled) {
        if (response.warning?.trim().isNotEmpty == true) {
          HapticHelper.heavyImpact();
        } else {
          HapticHelper.lightImpact();
        }
      }

      // 2. Push to Android Native Floating Guardian HUD Window
      unawaited(
        const OverlayChannel().updateTacticalAdvice(
          badge: 'GUARDIAN AI',
          action: response.action,
          warning: response.warning,
        ),
      );

      // 3. Master Voice Alerts Gate
      if (!settings.voiceAlertsEnabled) return;

      // 3. Priority Filter Gate
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

      // 4. Speech Cooldown Gate
      final announcer = _ref.read(ttsAnnouncerProvider);
      final lastSpoke = announcer.lastSpokeAt;
      if (lastSpoke != null) {
        final gap = DateTime.now().difference(lastSpoke).inSeconds;
        if (gap < settings.speechCooldownSeconds) return;
      }

      // 5. Script Synthesis
      final script = response.warning?.trim().isNotEmpty == true
          ? '${response.action}. ${response.warning}'
          : (response.reason.trim().isNotEmpty
              ? '${response.action}. ${response.reason}'
              : response.action);

      // 6. Audio Ducking / Focus Control
      final audioFocus = !settings.avoidInterruptingGameAudio;
      await announcer.speak(script, focus: audioFocus);
    } catch (_) {}
  }

  void _trackMatch(String providerId) {
    final game = _ref.read(activeGameProvider);
    final key = '${game?.packageName ?? 'unknown'}|$providerId';
    if (_matchKey != null && _matchKey != key) {
      _callsThisMatch = 0;
      _lastCallAt = null;
    }
    _matchKey = key;
  }

  /// Samples current device stats into the stress detector. Silent when
  /// stats are unavailable (tests, desktop).
  void _sampleDeviceStress(GameTurboSettings settings) {
    try {
      final stats = _ref.read(systemStatsProvider).valueOrNull;
      if (stats == null) return;
      reportStressSample(
        settings: settings,
        cpuPercent: stats.cpu,
        batteryPercent: stats.battery,
      );
    } catch (_) {}
  }
}
