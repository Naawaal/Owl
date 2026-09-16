// language: Dart, file: lib/app/router/app_router.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl/features/game_profiles/presentation/game_space_console_screen.dart';
import 'package:owl/features/overlay/presentation/tactical_battlefield_hud.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/showcase/presentation/design_system_showcase_view.dart';
import 'package:owl_design/owl_design.dart';

/// Riverpod provider delivering the global [AppRouter] instance.
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

/// Riverpod provider exposing the current active route name.
final currentRouteProvider =
    StateProvider<String>((ref) => AppRoutes.console);

/// Tactical Route Observer that synchronizes route transitions with telemetry and Riverpod.
class OwlRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  OwlRouteObserver({this.onRouteChanged});

  final void Function(String? routeName)? onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onRouteChanged?.call(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onRouteChanged?.call(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onRouteChanged?.call(newRoute?.settings.name);
  }
}

/// Custom PageRoute featuring ultra-smooth OLED tactical HUD transitions.
///
/// Implements Emil Kowalski's responsive design engineering:
/// - 220ms easeOutCubic forward curve for snappy responsiveness.
/// - 180ms easeInCubic reverse curve for crisp dismissal.
/// - Micro-scale (0.985 -> 1.0) coupled with soft opacity fade.
/// - Secondary dimming of background route to eliminate visual clutter.
class OwlPageRoute<T> extends PageRouteBuilder<T> {
  OwlPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.transitionDuration = const Duration(milliseconds: 220),
    super.reverseTransitionDuration = const Duration(milliseconds: 180),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final scaleAnimation = Tween<double>(
              begin: 0.985,
              end: 1.0,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation);

            final secondaryFade = Tween<double>(
              begin: 1.0,
              end: 0.85,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: secondaryFade,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}

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

/// Tactical OLED placeholder view rendered for routes under development.
///
/// Provides visual navigation chips enabling interactive verification of
/// page transitions across all defined routes.
class TacticalRoutePlaceholder extends StatelessWidget {
  const TacticalRoutePlaceholder({
    super.key,
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isError = false,
  });

  final String routeName;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.textPrimary,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          title,
          style: TypographyTokens.headline.copyWith(color: colors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: OwlBadge(
                label: isError ? 'ERROR' : 'TACTICAL',
                variant: isError
                    ? OwlBadgeVariant.danger
                    : OwlBadgeVariant.cyan,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: SpacingTokens.screenInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OwlGlassCard(
                customBorderColor: isError
                    ? colors.alertDanger
                    : colors.borderGlassStrong,
                isHighlighted: !isError,
                padding: SpacingTokens.cardInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isError
                                ? (isDark
                                    ? ColorPrimitives.glassRed25
                                    : const Color(0xFFFFE4E6))
                                : (isDark
                                    ? ColorPrimitives.glassCyan25
                                    : const Color(0xFFE0F2FE)),
                            borderRadius: RadiusTokens.borderSm,
                          ),
                          child: Icon(
                            icon,
                            color: isError
                                ? colors.alertDanger
                                : colors.accentCyan,
                            size: 22,
                          ),
                        ),
                        SpacingTokens.gapH12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TypographyTokens.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TypographyTokens.bodySmall.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OwlStatusDot(
                          role: isError
                              ? OwlStatusDotRole.danger
                              : OwlStatusDotRole.synced,
                          isPulsing: false,
                        ),
                      ],
                    ),
                    SpacingTokens.gapV16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorPrimitives.oledBlack
                            : const Color(0xFFF1F5F9),
                        borderRadius: RadiusTokens.hudChip,
                        border: Border.all(
                          color: colors.borderGlass,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.terminal,
                            size: 14,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            routeName,
                            style: TypographyTokens.displayTimerSmall.copyWith(
                              fontSize: 12,
                              color: colors.accentCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SpacingTokens.gapV16,
              Text(
                'QUICK ROUTE SWITCHER',
                style: TypographyTokens.tacticalLabel.copyWith(
                  color: colors.textMuted,
                ),
              ),
              SpacingTokens.gapV8,
              Expanded(
                child: ListView(
                  children: [
                    _buildRouteTile(
                      context,
                      label: 'Design System Showcase',
                      route: AppRoutes.showcase,
                      icon: Icons.palette_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Tactical Dashboard',
                      route: AppRoutes.dashboard,
                      icon: Icons.dashboard_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Game Profiles (Wild Rift / MLBB)',
                      route: AppRoutes.gameProfiles,
                      icon: Icons.sports_esports_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'HUD Settings',
                      route: AppRoutes.settings,
                      icon: Icons.tune_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'API Keys Configuration',
                      route: AppRoutes.apiKeys,
                      icon: Icons.key_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Overlay HUD Settings',
                      route: AppRoutes.overlaySettings,
                      icon: Icons.layers_outlined,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTile(
    BuildContext context, {
    required String label,
    required String route,
    required IconData icon,
    required OwlColors colors,
  }) {
    final isCurrent = routeName == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: OwlGlassCard(
        customBorderColor: isCurrent
            ? colors.accentCyan
            : colors.borderGlass,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: isCurrent
            ? null
            : () => Navigator.of(context).pushNamed(route),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isCurrent
                  ? colors.accentCyan
                  : colors.textSecondary,
            ),
            SpacingTokens.gapH12,
            Expanded(
              child: Text(
                label,
                style: TypographyTokens.bodyMedium.copyWith(
                  color: isCurrent
                      ? colors.accentCyan
                      : colors.textPrimary,
                  fontWeight:
                      isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isCurrent)
              const OwlBadge(
                label: 'ACTIVE',
                variant: OwlBadgeVariant.cyan,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
