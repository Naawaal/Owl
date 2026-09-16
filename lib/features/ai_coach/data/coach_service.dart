// language: Dart, file: coach_service.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/domain/models/coach_prompt.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
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
  static const Duration queryCooldown = Duration(seconds: 30);

  /// Maximum networked queries per match before silence.
  static const int maxCallsPerMatch = 20;

  CoachResponse? _lastKnown;
  int _callsThisMatch = 0;
  DateTime? _lastCallAt;
  bool _inFlight = false;
  String? _matchKey;

  /// Last successfully received advice, if any. Survives errors and restarts
  /// of the query pipeline within the session.
  CoachResponse? get lastKnown => _lastKnown;

  /// Number of networked queries issued for the current match.
  int get callsThisMatch => _callsThisMatch;

  /// Requests tactical advice for [situation].
  ///
  /// No-ops (resolving cached) when a request is in flight, the coach is
  /// disabled, no key is stored, budgets are exhausted, or the cooldown is
  /// active. Never throws: failures land in [state] as [AsyncValue.error].
  Future<void> requestAdvice({
    required String situation,
    String promptType = 'tactical',
    int matchTimeSeconds = 0,
    Map<String, dynamic>? tacticalContext,
    String? heroChampion,
  }) async {
    if (_inFlight) return;

    final settings = _ref.read(gameTurboSettingsProvider);
    if (!settings.guardianTacticalEngine) return;

    final key =
        await _ref.read(apiKeyManagerProvider).getApiKey(settings.activeAiProvider);
    if (key == null || key.isEmpty) return;

    final now = DateTime.now();
    if (_lastCallAt != null &&
        now.difference(_lastCallAt!) < queryCooldown) {
      return;
    }
    if (_callsThisMatch >= maxCallsPerMatch) return;

    _trackMatch(settings.activeAiProvider);

    _inFlight = true;
    state = const AsyncValue.loading();
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
        prompt: prompt.toFormattedPrompt(),
        timeout: requestTimeout,
      );
      final response = CoachResponse.fromRawText(text);
      _lastKnown = response;
      _callsThisMatch++;
      _lastCallAt = now;
      state = AsyncValue.data(response);
    } on InferenceException catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        InferenceException(
          failure: InferenceFailure.unknown,
          message: 'Coach query failed.',
        ),
        stackTrace,
      );
    } finally {
      _inFlight = false;
    }
  }

  /// Resets the per-match call budget, e.g. when a new match is detected.
  void resetMatchBudget() {
    _callsThisMatch = 0;
    _lastCallAt = null;
    _matchKey = null;
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
}
