// language: Dart, file: overlay_session_args.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/foundation.dart';

/// Session args pushed from Kotlin before/after the FlutterView attaches.
class OverlaySessionArgs extends ChangeNotifier {
  OverlaySessionArgs._();
  static final OverlaySessionArgs instance = OverlaySessionArgs._();

  String gameTitle = 'Game';
  int targetFps = 120;
  int matchElapsedSeconds = 0;
  bool edgeOnRight = false;
  bool? isPerformance;

  /// Absolute Y of the edge-rail center in screen pixels (TOP gravity).
  double? anchorY;
  double? screenHeight;

  void apply({
    String? gameTitle,
    int? targetFps,
    int? matchElapsedSeconds,
    bool? edgeOnRight,
    bool? isPerformance,
    double? anchorY,
    double? screenHeight,
  }) {
    var changed = false;
    if (gameTitle != null &&
        gameTitle.isNotEmpty &&
        gameTitle != this.gameTitle) {
      this.gameTitle = gameTitle;
      changed = true;
    }
    if (targetFps != null && targetFps > 0 && targetFps != this.targetFps) {
      this.targetFps = targetFps;
      changed = true;
    }
    if (matchElapsedSeconds != null &&
        matchElapsedSeconds != this.matchElapsedSeconds) {
      this.matchElapsedSeconds = matchElapsedSeconds;
      changed = true;
    }
    if (edgeOnRight != null && edgeOnRight != this.edgeOnRight) {
      this.edgeOnRight = edgeOnRight;
      changed = true;
    }
    if (isPerformance != null && isPerformance != this.isPerformance) {
      this.isPerformance = isPerformance;
      changed = true;
    }
    if (anchorY != null && anchorY != this.anchorY) {
      this.anchorY = anchorY;
      changed = true;
    }
    if (screenHeight != null &&
        screenHeight > 0 &&
        screenHeight != this.screenHeight) {
      this.screenHeight = screenHeight;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void applyMap(Map<dynamic, dynamic> args) {
    apply(
      gameTitle: args['gameTitle'] as String?,
      targetFps: args['targetFps'] as int?,
      matchElapsedSeconds: args['matchElapsedSeconds'] as int?,
      edgeOnRight: args['edgeOnRight'] as bool?,
      isPerformance: args['isPerformance'] as bool?,
      anchorY: (args['anchorY'] as num?)?.toDouble(),
      screenHeight: (args['screenHeight'] as num?)?.toDouble(),
    );
  }
}
