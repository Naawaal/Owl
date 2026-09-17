// language: Dart, file: lib/app/router/app_router.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl/app/router/owl_page_transitions.dart';
import 'package:owl/app/router/tactical_route_placeholder.dart';
import 'package:owl/features/game_profiles/presentation/game_space_console_screen.dart';
import 'package:owl/features/overlay/presentation/tactical_battlefield_hud.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/showcase/presentation/design_system_showcase_view.dart';

export 'owl_page_transitions.dart';
export 'tactical_route_placeholder.dart';

/// Riverpod provider delivering the global [AppRouter] instance.
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

/// Riverpod provider exposing the current active route name.
final currentRouteProvider =
    StateProvider<String>((ref) => AppRoutes.console);

/// Application Router & Navigator abstraction for the Owl MOBA HUD.
///
/// Provides centralized routing, type-safe navigation helpers, smooth tactical
/// page transitions, and route generation for all app destinations.
class AppRouter {
  AppRouter();

  /// Global navigator key allowing context-free navigation when necessary.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Global route observer tracking active routes.
  static final OwlRouteObserver routeObserver = OwlRouteObserver();

  /// Access the underlying [NavigatorState].
  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Access current build context if mounted.
  static BuildContext? get context => navigatorKey.currentContext;

  // ---------------------------------------------------------------------------
  // ROUTE GENERATION
  // ---------------------------------------------------------------------------

  /// Central route factory generating customized [OwlPageRoute] transitions.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.console;

    switch (name) {
      case '/':
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const SizedBox.shrink(),
        );

      case AppRoutes.console:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const GameSpaceConsoleScreen(),
        );

      case AppRoutes.inGameHud:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalBattlefieldHud(),
        );

      case AppRoutes.appSettings:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const AppSettingsTwoPaneScreen(),
        );

      case AppRoutes.gpuSettings:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const GpuSettingsTwoPaneScreen(),
        );

      case AppRoutes.showcase:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const DesignSystemShowcaseView(),
        );

      case AppRoutes.dashboard:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalRoutePlaceholder(
            routeName: AppRoutes.dashboard,
            title: 'Tactical Dashboard',
            subtitle: 'Live MOBA match telemetry & on-device AI HUD',
            icon: Icons.dashboard_outlined,
          ),
        );

      case AppRoutes.gameProfiles:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalRoutePlaceholder(
            routeName: AppRoutes.gameProfiles,
            title: 'Game Profiles',
            subtitle: 'Wild Rift, MLBB & Pokémon UNITE objectives',
            icon: Icons.sports_esports_outlined,
          ),
        );

      case AppRoutes.settings:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalRoutePlaceholder(
            routeName: AppRoutes.settings,
            title: 'HUD Settings',
            subtitle: 'Companion preferences, audio pings & theme overrides',
            icon: Icons.tune_outlined,
          ),
        );

      case AppRoutes.apiKeys:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalRoutePlaceholder(
            routeName: AppRoutes.apiKeys,
            title: 'API Key Configuration',
            subtitle: 'On-device Gemini / Vision AI credentials',
            icon: Icons.key_outlined,
          ),
        );

      case AppRoutes.overlaySettings:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => const TacticalRoutePlaceholder(
            routeName: AppRoutes.overlaySettings,
            title: 'Overlay HUD Configurator',
            subtitle:
                'Floating pill scale, opacity, snap bounds & telemetry layout',
            icon: Icons.layers_outlined,
          ),
        );

      default:
        return OwlPageRoute(
          settings: settings,
          builder: (context) => TacticalRoutePlaceholder(
            routeName: name,
            title: 'Route Not Found',
            subtitle: 'Navigation error: Unknown destination coordinate',
            icon: Icons.error_outline,
            isError: true,
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION HELPERS (Static & Instance)
  // ---------------------------------------------------------------------------

  /// Push a named route with optional arguments.
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed<T>(
          routeName,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  /// Replace current route with a new named route.
  static Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
          routeName,
          result: result,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  /// Push named route and remove routes until predicate returns true.
  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
          routeName,
          predicate,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  /// Pop top route from navigation stack.
  static void pop<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  /// Check whether navigation stack can be popped.
  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  // Convenience Route Shortcuts
  static Future<T?> toShowcase<T>() => pushNamed<T>(AppRoutes.showcase);
  static Future<T?> toDashboard<T>() => pushNamed<T>(AppRoutes.dashboard);
  static Future<T?> toGameProfiles<T>() => pushNamed<T>(AppRoutes.gameProfiles);
  static Future<T?> toSettings<T>() => pushNamed<T>(AppRoutes.settings);
  static Future<T?> toApiKeys<T>() => pushNamed<T>(AppRoutes.apiKeys);
  static Future<T?> toOverlaySettings<T>() =>
      pushNamed<T>(AppRoutes.overlaySettings);

  // Instance methods for Riverpod dependency injection
  Future<T?> push<T>(String routeName, {Object? arguments}) =>
      pushNamed<T>(routeName, arguments: arguments);

  Future<T?> replace<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) =>
      pushReplacementNamed<T, TO>(
        routeName,
        result: result,
        arguments: arguments,
      );

  void goBack<T>([T? result]) => pop<T>(result);
}
