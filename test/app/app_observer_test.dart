// language: Dart, file: test/app/app_observer_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/app/app_observer.dart';

void main() {
  group('AppObserver tests', () {
    test('captures didAddProvider, didUpdateProvider, and didDisposeProvider events',
        () {
      final logs = <String>[];
      final observer = AppObserver(
        enableLogging: true,
        onLog: (msg, {error, stackTrace}) => logs.add(msg),
      );

      final counterProvider = StateProvider<int>((ref) => 0);

      final container = ProviderContainer(
        observers: [observer],
      );

      // Read triggers didAddProvider
      final initial = container.read(counterProvider);
      expect(initial, 0);
      expect(logs.any((l) => l.contains('[Riverpod:Add]')), isTrue);

      // Mutate triggers didUpdateProvider
      container.read(counterProvider.notifier).state = 42;
      expect(logs.any((l) => l.contains('[Riverpod:Update]')), isTrue);
      expect(logs.any((l) => l.contains('42')), isTrue);

      // Dispose container triggers didDisposeProvider
      container.dispose();
      expect(logs.any((l) => l.contains('[Riverpod:Dispose]')), isTrue);
    });

    test('captures provider errors via providerDidFail', () {
      final errorLogs = <String>[];
      final observer = AppObserver(
        enableLogging: true,
        onLog: (msg, {error, stackTrace}) => errorLogs.add(msg),
      );

      final failingProvider = Provider<int>((ref) {
        throw Exception('Tactical telemetry fault');
      });

      final container = ProviderContainer(observers: [observer]);

      expect(() => container.read(failingProvider), throwsA(isA<Exception>()));
      expect(errorLogs.any((l) => l.contains('[Riverpod:Fail]')), isTrue);
      expect(
        errorLogs.any((l) => l.contains('Tactical telemetry fault')),
        isTrue,
      );

      container.dispose();
    });

    test('respects enableLogging = false flag', () {
      final logs = <String>[];
      final observer = AppObserver(
        enableLogging: false,
        onLog: (msg, {error, stackTrace}) => logs.add(msg),
      );

      final testProvider = StateProvider<String>((ref) => 'idle');
      final container = ProviderContainer(observers: [observer]);

      container.read(testProvider.notifier).state = 'combat';
      container.dispose();

      expect(logs.isEmpty, isTrue);
    });
  });
}
