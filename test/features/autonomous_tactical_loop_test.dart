// language: Dart, file: autonomous_tactical_loop_test.dart, target: Flutter / Owl MOBA HUD
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/domain/vision/autonomous_tactical_loop.dart';
import 'package:owl/features/ai_coach/domain/vision/frame_differ.dart';

void main() {
  group('FrameDiffer Unit Tests', () {
    test('downsampleRgbaTo32x32 handles empty or invalid dimensions gracefully', () {
      final emptyResult = FrameDiffer.downsampleRgbaTo32x32(Uint8List(0), 0, 0);
      expect(emptyResult.length, equals(1024));
      expect(emptyResult.every((b) => b == 0), isTrue);
    });

    test('downsampleRgbaTo32x32 converts white RGBA to white grayscale', () {
      // 100x100 white image (RGBA: 255, 255, 255, 255)
      final whiteBytes = Uint8List(100 * 100 * 4);
      whiteBytes.fillRange(0, whiteBytes.length, 255);

      final thumb = FrameDiffer.downsampleRgbaTo32x32(whiteBytes, 100, 100);
      expect(thumb.length, equals(1024));
      // White pixel in ITU-R BT.601: (255*77 + 255*150 + 255*29) >> 8 = (255 * 256) >> 8 = 255
      expect(thumb[0], inInclusiveRange(254, 255));
    });

    test('computeDifferencePercentage returns 0.0 for identical frames', () {
      final frameA = Uint8List(1024)..fillRange(0, 1024, 128);
      final frameB = Uint8List(1024)..fillRange(0, 1024, 128);

      final diff = FrameDiffer.computeDifferencePercentage(frameA, frameB);
      expect(diff, equals(0.0));
      expect(FrameDiffer.isStatic(frameA, frameB), isTrue);
    });

    test('computeDifferencePercentage returns 100.0 for opposite extremes', () {
      final black = Uint8List(1024)..fillRange(0, 1024, 0);
      final white = Uint8List(1024)..fillRange(0, 1024, 255);

      final diff = FrameDiffer.computeDifferencePercentage(black, white);
      expect(diff, closeTo(100.0, 0.01));
      expect(FrameDiffer.isStatic(black, white), isFalse);
    });

    test('isStatic correctly discriminates between < 3.0% and > 3.0% deviation', () {
      final base = Uint8List(1024)..fillRange(0, 1024, 100);
      // Subtle change: 2 pixels differ by 50 units (2 * 50 / (1024 * 255) = 0.038%)
      final slightChange = Uint8List.fromList(base);
      slightChange[10] = 150;
      slightChange[20] = 150;

      expect(FrameDiffer.isStatic(base, slightChange), isTrue);

      // Major change: 200 pixels differ by 200 units (200 * 200 / (1024 * 255) = 15.3%)
      final majorChange = Uint8List.fromList(base);
      for (int i = 0; i < 200; i++) {
        majorChange[i] = 200;
      }
      expect(FrameDiffer.isStatic(base, majorChange), isFalse);
    });
  });

  group('AutonomousTacticalLoop Unit Tests', () {
    test('targetCadenceFps and interval reflect performance modes', () {
      final loop = AutonomousTacticalLoop();

      loop.start(performanceMode: 'saver');
      expect(loop.targetCadenceFps, equals(1));
      expect(loop.cadenceInterval, equals(const Duration(milliseconds: 1000)));

      loop.setPerformanceMode('balanced');
      expect(loop.targetCadenceFps, equals(5));
      expect(loop.cadenceInterval, equals(const Duration(milliseconds: 200)));

      loop.setPerformanceMode('high');
      expect(loop.targetCadenceFps, equals(12));
      expect(loop.cadenceInterval, equals(const Duration(milliseconds: 83)));

      loop.stop();
    });

    test('lifecycle: start, pause, resume, stop updates state flags', () {
      final loop = AutonomousTacticalLoop();
      expect(loop.isRunning, isFalse);
      expect(loop.isPaused, isFalse);

      loop.start();
      expect(loop.isRunning, isTrue);
      expect(loop.isPaused, isFalse);

      loop.pause();
      expect(loop.isRunning, isTrue);
      expect(loop.isPaused, isTrue);

      loop.resume();
      expect(loop.isRunning, isTrue);
      expect(loop.isPaused, isFalse);

      loop.stop();
      expect(loop.isRunning, isFalse);
      expect(loop.isPaused, isFalse);
    });

    test('suppresses redundant inference when consecutive frames are static', () async {
      int activeTicks = 0;
      int staticTicks = 0;

      // Simulated static screen: same frame returned repeatedly
      final dummyBytes = Uint8List(64 * 64 * 4)..fillRange(0, 64 * 64 * 4, 100);

      final loop = AutonomousTacticalLoop(
        onCaptureFrame: () async => (bytes: dummyBytes, width: 64, height: 64),
        onActiveTick: (bytes, width, height, matchTime) async {
          activeTicks++;
        },
        onStaticTick: (matchTime, diff) {
          staticTicks++;
        },
      );

      loop.start(performanceMode: 'balanced');

      // First tick should be active (initial baseline)
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(activeTicks, equals(1));
      expect(loop.isStaticScreen, isFalse);

      // Subsequent ticks should detect identical frame and suppress
      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(activeTicks, equals(1)); // Still 1 active tick
      expect(staticTicks, greaterThanOrEqualTo(1)); // Static ticks triggered
      expect(loop.isStaticScreen, isTrue);
      expect(loop.framesSuppressed, greaterThanOrEqualTo(1));

      loop.stop();
    });
  });
}
