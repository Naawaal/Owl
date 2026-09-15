// language: Dart, file: test/features/showcase_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/showcase/presentation/design_system_showcase_view.dart';
import 'package:owl_design/owl_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DesignSystemShowcaseView tests', () {
    testWidgets('mounts showcase view with all sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ProviderScope(
            child: DesignSystemShowcaseView(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('OWL'), findsOneWidget);
      expect(find.text('SYSTEM ONLINE'), findsOneWidget);
      expect(find.text('TACTICAL HUD PILL'), findsOneWidget);
      expect(find.text('COOLDOWN GAUGE & TIMER BADGES'), findsOneWidget);
      expect(find.text('TACTICAL ACTION SHEET'), findsOneWidget);
      expect(find.text('INPUTS: OWL TEXT FIELD'), findsOneWidget);
    });
  });
}
