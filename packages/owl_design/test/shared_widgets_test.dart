// language: Dart, file: shared_widgets_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_design/owl_design.dart';

void main() {
  group('OwlButton tests', () {
    testWidgets('renders label and handles tap interaction', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OwlButton(
            label: 'CONTEST BARON',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('CONTEST BARON'), findsOneWidget);

      await tester.tap(find.text('CONTEST BARON'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders loading state with spinner and ignores taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OwlButton(
            label: 'INITIALIZING',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('INITIALIZING'));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('renders all variants without errors', (tester) async {
      for (final variant in OwlButtonVariant.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: OwlButton(
              label: variant.name,
              variant: variant,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });
  });

  group('OwlIconButton tests', () {
    testWidgets('renders icon and triggers callback on tap', (tester) async {
      var clicked = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OwlIconButton(
            icon: const SizedBox(width: 16, height: 16, key: Key('icon_key')),
            onPressed: () => clicked = true,
          ),
        ),
      );

      expect(find.byKey(const Key('icon_key')), findsOneWidget);
      await tester.tap(find.byType(OwlIconButton));
      await tester.pump();
      expect(clicked, isTrue);
    });

    testWidgets('renders active state with glowing border', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlIconButton(
            icon: SizedBox(width: 16, height: 16),
            isActive: true,
          ),
        ),
      );
      expect(find.byType(OwlIconButton), findsOneWidget);
    });
  });

  group('OwlGlassCard tests', () {
    testWidgets('renders child inside glassmorphic backdrop filter', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlGlassCard(
            child: Text('TELEMETRY ACTIVE'),
          ),
        ),
      );

      expect(find.text('TELEMETRY ACTIVE'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('supports interactive tap callback and scaling', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OwlGlassCard(
            onTap: () => tapped = true,
            child: const Text('TAPPABLE CARD'),
          ),
        ),
      );

      await tester.tap(find.text('TAPPABLE CARD'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('OwlBadge tests', () {
    testWidgets('renders uppercase label with dot indicator', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlBadge(
            label: 'dragon ready',
            showDot: true,
            variant: OwlBadgeVariant.cyan,
          ),
        ),
      );

      expect(find.text('DRAGON READY'), findsOneWidget);
    });

    testWidgets('renders all badge variants cleanly', (tester) async {
      for (final variant in OwlBadgeVariant.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: OwlBadge(
              label: variant.name,
              variant: variant,
            ),
          ),
        );
        expect(find.text(variant.name.toUpperCase()), findsOneWidget);
      }
    });
  });

  group('OwlTimerBadge tests', () {
    testWidgets('formats time correctly for normal, warning, urgent, and spawned', (tester) async {
      // Normal (> 30s)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlTimerBadge(
            remainingSeconds: 75,
            label: 'Baron',
          ),
        ),
      );
      expect(find.text('BARON'), findsOneWidget);
      expect(find.text('01:15'), findsOneWidget);

      // Warning (<= 30s)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlTimerBadge(
            remainingSeconds: 24,
            label: 'Dragon',
          ),
        ),
      );
      expect(find.text('DRAGON'), findsOneWidget);
      expect(find.text('00:24'), findsOneWidget);

      // Urgent (<= 10s)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlTimerBadge(
            remainingSeconds: 6,
            label: 'Elder',
          ),
        ),
      );
      expect(find.text('ELDER'), findsOneWidget);
      expect(find.text('00:06'), findsOneWidget);

      // Spawned (<= 0s)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlTimerBadge(
            remainingSeconds: 0,
            label: 'Buff',
          ),
        ),
      );
      expect(find.text('READY'), findsOneWidget);
    });
  });

  group('OwlStatusDot tests', () {
    testWidgets('renders for all roles', (tester) async {
      for (final role in OwlStatusDotRole.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: OwlStatusDot(role: role),
          ),
        );
        expect(find.byType(OwlStatusDot), findsOneWidget);
      }
    });
  });

  group('OwlCooldownRing tests', () {
    testWidgets('renders with progress and center text', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const OwlCooldownRing(
            progress: 0.65,
            centerText: '14',
          ),
        ),
      );

      expect(find.text('14'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
