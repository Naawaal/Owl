import 'dart:typed_data';

/// Fast perceptual frame differ for real-time esports screen comparison.
///
/// Downsamples screen frames to a 32x32 single-channel grayscale thumbnail
/// (1024 bytes) and computes mean absolute deviation percentage to suppress
/// redundant AI inference during loading screens, menus, or paused gameplay.
class FrameDiffer {
  static const int thumbnailWidth = 32;
  static const int thumbnailHeight = 32;
  static const int totalPixels = thumbnailWidth * thumbnailHeight; // 1024

  /// Downsamples an RGBA byte buffer to a 32x32 8-bit grayscale thumbnail.
  /// Uses nearest-neighbor sampling for minimum CPU overhead (<1ms).
  static Uint8List downsampleRgbaTo32x32(
    Uint8List rgbaBytes,
    int srcWidth,
    int srcHeight,
  ) {
    if (srcWidth <= 0 || srcHeight <= 0 || rgbaBytes.isEmpty) {
      return Uint8List(totalPixels);
    }

    final result = Uint8List(totalPixels);
    final xRatio = srcWidth / thumbnailWidth;
    final yRatio = srcHeight / thumbnailHeight;

    for (int y = 0; y < thumbnailHeight; y++) {
      final srcY = (y * yRatio).floor().clamp(0, srcHeight - 1);
      final rowOffset = srcY * srcWidth * 4;
      final targetRowOffset = y * thumbnailWidth;

      for (int x = 0; x < thumbnailWidth; x++) {
        final srcX = (x * xRatio).floor().clamp(0, srcWidth - 1);
        final pixelIndex = rowOffset + (srcX * 4);

        if (pixelIndex + 3 < rgbaBytes.length) {
          final r = rgbaBytes[pixelIndex];
          final g = rgbaBytes[pixelIndex + 1];
          final b = rgbaBytes[pixelIndex + 2];
          // Standard ITU-R BT.601 luminance coefficients (R:0.299, G:0.587, B:0.114)
          final luma = ((r * 77) + (g * 150) + (b * 29)) >> 8;
          result[targetRowOffset + x] = luma;
        }
      }
    }

    return result;
  }

  /// Calculates the difference percentage between two 32x32 grayscale frames.
  /// Returns a value between 0.0 (identical) and 100.0 (maximum inverse).
  static double computeDifferencePercentage(
    Uint8List frameA,
    Uint8List frameB,
  ) {
    if (frameA.length != totalPixels || frameB.length != totalPixels) {
      if (frameA.isEmpty || frameB.isEmpty) return 100.0;
      final minLen = frameA.length < frameB.length ? frameA.length : frameB.length;
      int diffSum = 0;
      for (int i = 0; i < minLen; i++) {
        diffSum += (frameA[i] - frameB[i]).abs();
      }
      return (diffSum / (minLen * 255.0)) * 100.0;
    }

    int totalDiff = 0;
    for (int i = 0; i < totalPixels; i++) {
      totalDiff += (frameA[i] - frameB[i]).abs();
    }

    // Maximum theoretical difference is 1024 * 255 = 261,120
    return (totalDiff / (totalPixels * 255.0)) * 100.0;
  }

  /// Returns true if two consecutive frames deviate by less than [thresholdPercentage].
  /// Default threshold is 3.0% as specified in the tactical pipeline spec.
  static bool isStatic(
    Uint8List frameA,
    Uint8List frameB, {
    double thresholdPercentage = 3.0,
  }) {
    final diff = computeDifferencePercentage(frameA, frameB);
    return diff < thresholdPercentage;
  }
}
