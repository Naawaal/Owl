// language: Dart, file: lib/core/utils/time_formatter.dart, target: Flutter / Owl MOBA HUD

/// Utility functions for formatting and parsing tactical match and countdown times.
class TimeFormatter {
  TimeFormatter._();

  /// Formats a [Duration] into `mm:ss` (or `hh:mm:ss` if hours > 0 or [forceHours] is true).
  ///
  /// Examples:
  /// - `Duration(minutes: 5, seconds: 42)` -> `'05:42'`
  /// - `Duration(seconds: 9)` -> `'00:09'`
  /// - `Duration(hours: 1, minutes: 2, seconds: 3)` -> `'01:02:03'`
  static String formatDuration(
    Duration duration, {
    bool forceHours = false,
  }) {
    if (duration.isNegative) {
      return forceHours ? '00:00:00' : '00:00';
    }

    final totalSeconds = duration.inSeconds;
    return formatSeconds(totalSeconds, forceHours: forceHours);
  }

  /// Formats an integer count of seconds into `mm:ss` or `hh:mm:ss`.
  ///
  /// Negative values are clamped to `'00:00'`.
  ///
  /// Examples:
  /// - `formatSeconds(65)` -> `'01:05'`
  /// - `formatSeconds(3665)` -> `'01:01:05'`
  static String formatSeconds(
    int totalSeconds, {
    bool forceHours = false,
  }) {
    if (totalSeconds <= 0) {
      return forceHours ? '00:00:00' : '00:00';
    }

    final hours = totalSeconds ~/ 3600;
    final remainingSeconds = totalSeconds % 3600;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');

    if (hours > 0 || forceHours) {
      final hourStr = hours.toString().padLeft(2, '0');
      return '$hourStr:$minStr:$secStr';
    }

    return '$minStr:$secStr';
  }

  /// Parses a time string formatted as `mm:ss`, `hh:mm:ss`, or single `ss` into total seconds.
  ///
  /// Throws [FormatException] if the string is not a valid time format.
  ///
  /// Examples:
  /// - `'05:30'` -> `330`
  /// - `'1:02:15'` -> `3735`
  /// - `'45'` -> `45`
  static int parseStringToSeconds(String timeStr) {
    final parsed = tryParseStringToSeconds(timeStr);
    if (parsed == null) {
      throw FormatException('Invalid time string format: "$timeStr"');
    }
    return parsed;
  }

  /// Safely attempts to parse a time string into seconds, returning null on failure.
  static int? tryParseStringToSeconds(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');

    if (parts.length == 1) {
      return int.tryParse(parts[0]);
    } else if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes == null || seconds == null || seconds < 0 || seconds >= 60) {
        return null;
      }
      return (minutes * 60) + seconds;
    } else if (parts.length == 3) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      final seconds = int.tryParse(parts[2]);
      if (hours == null ||
          minutes == null ||
          seconds == null ||
          minutes < 0 ||
          minutes >= 60 ||
          seconds < 0 ||
          seconds >= 60) {
        return null;
      }
      return (hours * 3600) + (minutes * 60) + seconds;
    }

    return null;
  }
}
