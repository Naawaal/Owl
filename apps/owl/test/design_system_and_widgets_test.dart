import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_deck/owl_deck.dart';

Widget _wrapWithTheme(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Titanium Design System Tokens', () {
    test('Dark theme contains valid OwlThemeExtension and titanium background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);

      final extension = theme.extension<OwlThemeExtension>();
      expect(extension, isNotNull);
      expect(extension!.borderSubtle, AppColors.darkBorderSubtle);
      expect(extension.accentGlow, AppColors.accentGlow);
    });

    test('Light theme contains valid OwlThemeExtension and light background', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);

      final extension = theme.extension<OwlThemeExtension>();
      expect(extension, isNotNull);
      expect(extension!.textPrimary, AppColors.lightTextPrimary);
    });

    test('Typography defines Plus Jakarta Sans and JetBrains Mono fallbacks', () {
      expect(AppTypography.brandTitle.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.monoMetric.fontFamily, 'JetBrains Mono');
    });
  });

  group('OwlButton Widget', () {
    testWidgets('triggers onPressed callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          OwlButton(
            label: 'Test Button',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger onPressed when disabled or loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          OwlButton(
            label: 'Loading Button',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(OwlButton));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });

  group('OwlSwitch Widget', () {
    testWidgets('toggles and emits new value on tap', (tester) async {
      bool currentValue = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              OwlSwitch(
                value: currentValue,
                enableHaptics: false,
                onChanged: (val) {
                  setState(() => currentValue = val);
                },
              ),
            );
          },
        ),
      );

      expect(currentValue, isFalse);
      await tester.tap(find.byType(OwlSwitch));
      await tester.pumpAndSettle();

      expect(currentValue, isTrue);
    });
  });

  group('OwlSlider Widget', () {
    testWidgets('renders value and emits updates on drag', (tester) async {
      double sliderVal = 1.0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              OwlSlider(
                value: sliderVal,
                min: 1.0,
                max: 4.0,
                label: 'Multiplier',
                valueFormatter: (v) => '${v.toStringAsFixed(1)}x',
                onChanged: (newVal) {
                  setState(() => sliderVal = newVal);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Multiplier'), findsOneWidget);
      expect(find.text('1.0x'), findsOneWidget);

      await tester.drag(find.byType(OwlSlider), const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(sliderVal, greaterThan(1.0));
    });
  });

  group('HeroDeckCard Widget', () {
    testWidgets('renders game info, active mod badges, and handles launch tap', (tester) async {
      bool launched = false;
      final game = const Game(
        id: 'carrom_pool',
        name: 'Carrom Pool',
        packageName: 'com.miniclip.carrom',
        minVersion: '1.0.0',
        category: 'Physics',
        icon: 'circle',
        description: 'Real-time raycast guideline overlay.',
        isInstalled: true,
      );

      await tester.pumpWidget(
        _wrapWithTheme(
          HeroDeckCard(
            game: game,
            activeMods: const ['Aim Assist', '2.5x Raycast'],
            onTap: () {},
            onLaunch: () => launched = true,
          ),
        ),
      );

      expect(find.text('Carrom Pool'), findsOneWidget);
      expect(find.text('PHYSICS'), findsOneWidget);
      expect(find.text('INSTALLED'), findsOneWidget);
      expect(find.text('Aim Assist'), findsOneWidget);
      expect(find.text('2.5x Raycast'), findsOneWidget);

      await tester.tap(find.text('Launch Mod'));
      await tester.pumpAndSettle();

      expect(launched, isTrue);
    });
  });

  group('FloatingBottomNav Widget', () {
    testWidgets('switches selected tab index on tap', (tester) async {
      int activeIndex = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              FloatingBottomNav(
                currentIndex: activeIndex,
                onIndexChanged: (idx) {
                  setState(() => activeIndex = idx);
                },
                items: const [
                  FloatingNavItem(icon: Icons.compass_calibration, label: 'Deck'),
                  FloatingNavItem(icon: Icons.games, label: 'Games'),
                  FloatingNavItem(icon: Icons.tune, label: 'Studio'),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Deck'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(activeIndex, 1);
    });
  });

  group('OwlToast Overlay', () {
    testWidgets('displays message in overlay and dismisses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    OwlToast.show(
                      context,
                      message: 'Settings Synced',
                      type: OwlToastType.success,
                    );
                  },
                  child: const Text('Show Toast'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      expect(find.text('Settings Synced'), findsOneWidget);

      // Fast forward past the 2400ms auto-dismiss timer and settle animation
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
    });
  });
}
