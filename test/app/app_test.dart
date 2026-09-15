// language: Dart, file: test/app/app_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/app/app.dart';
import 'package:owl/app/app_observer.dart';
import 'package:owl/app/router/app_router.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl_storage/owl_storage.dart';

void main() {
  group('OwlApp root widget tests', () {
    testWidgets('renders OwlApp within ProviderScope and sets dark overlay style',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          observers: [AppObserver(enableLogging: false)],
          child: OwlApp(
            initialRoute: AppRoutes.dashboard,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify AnnotatedRegion for SystemUiOverlayStyle is present
      final annotatedRegionFinder =
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>);
      expect(annotatedRegionFinder, findsAtLeastNWidgets(1));

      // Verify Dashboard is mounted
      expect(find.text('Tactical Dashboard'), findsWidgets);
    });

    testWidgets('OwlApp.standalone constructor encapsulates internal ProviderScope',
        (tester) async {
      await tester.pumpWidget(
        const OwlApp.standalone(
          initialRoute: AppRoutes.dashboard,
          observers: [AppObserver(enableLogging: false)],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.text('Tactical Dashboard'), findsWidgets);
    });

    testWidgets('synchronizes currentRouteProvider when navigation changes occur',
        (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OwlApp(
            initialRoute: AppRoutes.dashboard,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(currentRouteProvider), equals(AppRoutes.dashboard));

      // Navigate to settings
      AppRouter.toSettings();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(currentRouteProvider), equals(AppRoutes.settings));
      expect(find.text('HUD Settings'), findsWidgets);

      container.dispose();
    });

    testWidgets('defaults themeMode to system and provides both lightTheme and darkTheme',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          observers: [AppObserver(enableLogging: false)],
          child: OwlApp(
            initialRoute: AppRoutes.dashboard,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.system));
      expect(materialApp.theme?.brightness, equals(Brightness.light));
      expect(materialApp.darkTheme?.brightness, equals(Brightness.dark));
    });

    testWidgets('reactively switches themeMode when themeModeProvider changes',
        (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OwlApp(
            initialRoute: AppRoutes.dashboard,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.system));

      // Switch to light
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pump();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.light));

      // Switch to dark
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));

      container.dispose();
    });
  });
}
