// language: Dart, file: coach_service.dart, target: Flutter / Owl MOBA HUD
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/tts_announcer.dart';
import 'package:owl/features/ai_coach/domain/models/coach_prompt.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/ai_coach/domain/offline_tactical_heuristics_engine.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
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
    if (!manual) {
      if (!settings.gameTurboMaster) return;
      if (settings.assistantMode != 'live') return;
    }

    final key =
        await _ref.read(apiKeyManagerProvider).getApiKey(settings.activeAiProvider);
    if (key == null || key.isEmpty) {
      final game = _ref.read(activeGameProvider);
      final offlineResponse =
          OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: matchTimeSeconds,
        targetFps: game?.targetFps ?? 120,
      );
      _lastKnown = offlineResponse;
      _lastKnownTopic = promptType;
      _lastPromptType = promptType;
      _lastCallAt = DateTime.now();
      state = AsyncValue.data(offlineResponse);
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
      final prompt = CoachPrompt(
        gameName: game?.name ?? 'Unknown Match',
        matchTimeSeconds: matchTimeSeconds,
        role: settings.preferredRole,
        currentSituation: situation,
        promptType: promptType,
        heroChampion: heroChampion,
        tacticalContext: tacticalContext,
      );
      final client = inferenceClientFor(
        providerId: settings.activeAiProvider,
        api: _ref.read(apiClientProvider),
      );
      final text = await client.generate(
        apiKey: key,
        model: settings.activeModel,
        prompt: '${prompt.toFormattedPrompt()}${depthBlock(settings.coachingLevel)}',
        timeout: requestTimeout,
      );
      final response = CoachResponse.fromRawText(text);
      _lastKnown = response;
      _lastKnownTopic = promptType;
      _callsThisMatch++;
      _lastCallAt = now;
      _lastLatencyMs = stopwatch.elapsedMilliseconds;
      state = AsyncValue.data(response);
      unawaited(_maybeAnnounce(response, settings));
    } on InferenceException catch (_) {
      final game = _ref.read(activeGameProvider);
      final fallback = OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: matchTimeSeconds,
        targetFps: game?.targetFps ?? 120,
      );
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
    } catch (e) {
      final game = _ref.read(activeGameProvider);
      final fallback = OfflineTacticalHeuristicsEngine().generateAdvice(
        gameName: game?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: matchTimeSeconds,
        targetFps: game?.targetFps ?? 120,
      );
      _lastKnown = fallback;
      _lastKnownTopic = promptType;
      state = AsyncValue.data(fallback);
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
    await requestAdvice(
      situation: 'Scheduled $topic check-in. Report only if actionable, '
          'otherwise reply HOLD with a one-line reason.',
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
  /// speech cooldown elapsed. Never throws; failures stay silent.
  Future<void> _maybeAnnounce(
    CoachResponse response,
    GameTurboSettings settings,
  ) async {
    try {
      if (!settings.gameTurboMaster) return;
      if (!settings.guardianTacticalEngine) return;
      if (!settings.voiceAlertsEnabled) return;
      if (settings.alertPriority == 'criticalOnly' &&
          (response.warning == null || response.warning!.trim().isEmpty)) {
        return;
      }
      final announcer = _ref.read(ttsAnnouncerProvider);
      final lastSpoke = announcer.lastSpokeAt;
      if (lastSpoke != null) {
        final gap = DateTime.now().difference(lastSpoke).inSeconds;
        if (gap < settings.speechCooldownSeconds) return;
      }
      final script = response.warning?.trim().isNotEmpty == true
          ? '${response.action}. ${response.warning}'
          : '${response.action}. ${response.reason}';
      await announcer.speak(script);
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
