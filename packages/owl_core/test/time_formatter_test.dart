// language: Dart, file: test/core/utils/time_formatter_test.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';

void main() {
  group('TimeFormatter', () {
    test('formatDuration converts durations accurately', () {
      expect(TimeFormatter.formatDuration(const Duration(minutes: 5, seconds: 30)), equals('05:30'));
      expect(TimeFormatter.formatDuration(const Duration(seconds: 7)), equals('00:07'));
      expect(TimeFormatter.formatDuration(const Duration(seconds: 0)), equals('00:00'));
      expect(TimeFormatter.formatDuration(const Duration(seconds: -10)), equals('00:00'));
      expect(TimeFormatter.formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)), equals('01:02:03'));
      expect(TimeFormatter.formatDuration(const Duration(minutes: 10), forceHours: true), equals('00:10:00'));
    });

    test('formatSeconds converts seconds accurately', () {
      expect(TimeFormatter.formatSeconds(65), equals('01:05'));
      expect(TimeFormatter.formatSeconds(0), equals('00:00'));
      expect(TimeFormatter.formatSeconds(-5), equals('00:00'));
      expect(TimeFormatter.formatSeconds(3600), equals('01:00:00'));
      expect(TimeFormatter.formatSeconds(3665), equals('01:01:05'));
    });

    test('parseStringToSeconds parses mm:ss and hh:mm:ss correctly', () {
      expect(TimeFormatter.parseStringToSeconds('05:30'), equals(330));
      expect(TimeFormatter.parseStringToSeconds('00:09'), equals(9));
      expect(TimeFormatter.parseStringToSeconds('01:02:03'), equals(3723));
      expect(TimeFormatter.parseStringToSeconds('45'), equals(45));
    });

    test('tryParseStringToSeconds handles invalid inputs safely', () {
      expect(TimeFormatter.tryParseStringToSeconds(''), isNull);
      expect(TimeFormatter.tryParseStringToSeconds('invalid'), isNull);
      expect(TimeFormatter.tryParseStringToSeconds('05:75'), isNull); // 75 seconds is invalid
      expect(TimeFormatter.tryParseStringToSeconds('01:65:20'), isNull); // 65 minutes is invalid
    });
  });
}
