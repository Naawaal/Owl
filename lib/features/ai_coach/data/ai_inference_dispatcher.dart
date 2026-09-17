// language: Dart, file: ai_inference_dispatcher.dart, target: Flutter / Owl Game Turbo
import 'dart:convert';
import 'package:owl/features/ai_coach/data/screen_capture_channel.dart';
import 'package:owl/features/ai_coach/domain/models/coach_prompt.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/ai_coach/domain/offline_tactical_heuristics_engine.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl_network/owl_network.dart';

/// Result container holding parsed coach response and measured network RTT.
class AiInferenceResult {
  const AiInferenceResult({
    required this.response,
    required this.latencyMs,
    this.usedVision = false,
  });

  final CoachResponse response;
  final int latencyMs;
  final bool usedVision;
}

/// Dispatches multi-provider inference calls, measures latency, and handles vision frames.
class AiInferenceDispatcher {
  const AiInferenceDispatcher({
    this.screenCaptureChannel = const ScreenCaptureChannel(),
    this.heuristicsEngine = const OfflineTacticalHeuristicsEngine(),
  });

  final ScreenCaptureChannel screenCaptureChannel;
  final OfflineTacticalHeuristicsEngine heuristicsEngine;

  /// Maximum wall-clock budget per inference request.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// High latency threshold (1500ms) beyond which tactical guidance
  /// degrades to fast localized heuristics with a warning flag.
  static const int latencyDegradationThresholdMs = 1500;

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

  /// Dispatches the inference prompt to the specified provider client.
  Future<AiInferenceResult> dispatch({
    required InferenceClient client,
    required String apiKey,
    required GameTurboSettings settings,
    required CoachPrompt prompt,
    InstalledGame? activeGame,
    String? base64Frame,
  }) async {
    final stopwatch = Stopwatch()..start();

    String? activeFrame = base64Frame;
    if (activeFrame == null && settings.guardianVisionEnabled) {
      try {
        final frame = await screenCaptureChannel.getLatestFrame();
        if (frame != null && frame.bytes.isNotEmpty) {
          activeFrame = base64Encode(frame.bytes);
        }
      } catch (_) {}
    }

    final visionDirective = activeFrame != null
        ? '\nInspect attached live screenshot: identify hero, battle spell, lane state, and minimap objectives for the ${prompt.role} role.'
        : '';

    final fullPrompt =
        '${prompt.toFormattedPrompt(explainRecommendations: settings.explainRecommendations)}'
        '${depthBlock(settings.coachingLevel)}$visionDirective';

    final text = await client.generate(
      apiKey: apiKey,
      model: settings.activeModel,
      prompt: fullPrompt,
      base64Image: activeFrame,
      timeout: requestTimeout,
    );

    final elapsed = stopwatch.elapsedMilliseconds;
    CoachResponse response;

    if (elapsed > latencyDegradationThresholdMs) {
      final heuristic = heuristicsEngine.generateAdvice(
        gameName: activeGame?.name ?? 'Unknown Match',
        role: settings.preferredRole,
        matchTimeSeconds: prompt.matchTimeSeconds,
        targetFps: activeGame?.targetFps ?? 120,
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

    return AiInferenceResult(
      response: response,
      latencyMs: elapsed,
      usedVision: activeFrame != null,
    );
  }
}
