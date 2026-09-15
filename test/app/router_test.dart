// language: Dart, file: test/app/router_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/app/router/app_router.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl/features/showcase/presentation/design_system_showcase_view.dart';

void main() {
  group('AppRoutes definitions', () {
    test('constants match exact project specifications', () {
      expect(AppRoutes.console, equals('/console'));
      expect(AppRoutes.inGameHud, equals('/ingame'));
      expect(AppRoutes.appSettings, equals('/settings/app'));
      expect(AppRoutes.gpuSettings, equals('/settings/gpu'));
      expect(AppRoutes.showcase, equals('/showcase'));
      expect(AppRoutes.dashboard, equals('/dashboard'));
      expect(AppRoutes.gameProfiles, equals('/profiles'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.apiKeys, equals('/settings/keys'));
      expect(AppRoutes.overlaySettings, equals('/settings/overlay'));
      expect(AppRoutes.initial, equals(AppRoutes.console));
    });

    test('validates route existence', () {
      expect(AppRoutes.isValidRoute('/console'), isTrue);
      expect(AppRoutes.isValidRoute('/ingame'), isTrue);
      expect(AppRoutes.isValidRoute('/settings/app'), isTrue);
      expect(AppRoutes.isValidRoute('/settings/gpu'), isTrue);
      expect(AppRoutes.isValidRoute('/showcase'), isTrue);
      expect(AppRoutes.isValidRoute('/dashboard'), isTrue);
      expect(AppRoutes.isValidRoute('/profiles'), isTrue);
      expect(AppRoutes.isValidRoute('/settings'), isTrue);
      expect(AppRoutes.isValidRoute('/settings/keys'), isTrue);
      expect(AppRoutes.isValidRoute('/settings/overlay'), isTrue);
      expect(AppRoutes.isValidRoute('/invalid_destination'), isFalse);
    });
  });

  group('AppRouter routing generation', () {
    test('resolves all canonical routes into OwlPageRoute instances', () {
      for (final routeName in AppRoutes.all) {
        final settings = RouteSettings(name: routeName);
        final route = AppRouter.onGenerateRoute(settings);

        expect(route, isA<OwlPageRoute>());
        expect(route.settings.name, equals(routeName));
      }
    });

    test('generates fallback route for unrecognized paths', () {
      final settings = const RouteSettings(name: '/unknown_coordinate');
      final route = AppRouter.onGenerateRoute(settings);

      expect(route, isA<OwlPageRoute>());
      expect(route.settings.name, equals('/unknown_coordinate'));
    });
  });

  group('AppRouter navigation interactions', () {
    testWidgets('navigates cleanly between dashboard, settings, and showcase',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            navigatorKey: AppRouter.navigatorKey,
            initialRoute: AppRoutes.dashboard,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Tactical Dashboard is mounted
      expect(find.text('Tactical Dashboard'), findsWidgets);
      expect(find.text(AppRoutes.dashboard), findsOneWidget);

      // Navigate to Game Profiles using router helper
      AppRouter.toGameProfiles();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Game Profiles'), findsWidgets);
      expect(find.text(AppRoutes.gameProfiles), findsOneWidget);

      // Navigate to Settings
      AppRouter.toSettings();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('HUD Settings'), findsWidgets);
      expect(find.text(AppRoutes.settings), findsOneWidget);

      // Navigate to API Keys
      AppRouter.toApiKeys();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('API Key Configuration'), findsWidgets);
      expect(find.text(AppRoutes.apiKeys), findsOneWidget);

      // Navigate to Overlay Settings
      AppRouter.toOverlaySettings();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Overlay HUD Configurator'), findsWidgets);
      expect(find.text(AppRoutes.overlaySettings), findsOneWidget);

      // Pop navigation stack
      AppRouter.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('API Key Configuration'), findsWidgets);
    });

    testWidgets('resolves showcase view on initial root route',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            navigatorKey: AppRouter.navigatorKey,
            initialRoute: AppRoutes.showcase,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DesignSystemShowcaseView), findsOneWidget);
    });
  });
}
