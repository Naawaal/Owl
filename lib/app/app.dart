import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/app/app_observer.dart';
import 'package:owl/app/router/app_router.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';

/// Root Application Widget for Owl MOBA Companion HUD.
///
/// Integrates:
/// - System-default dual-theme architecture ([AppTheme.lightTheme] and [AppTheme.darkTheme]).
/// - Dynamic [SystemUiOverlayStyle] synchronized with system/active brightness.
/// - Riverpod wiring synchronizing navigation state via [currentRouteProvider]
///   and theme mode via [themeModeProvider].
/// - Centralized routing with [AppRouter] and [AppRoutes].
class OwlApp extends StatelessWidget {
  const OwlApp({
    super.key,
    this.initialRoute = AppRoutes.console,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.withProviderScope = false,
    this.observers,
    this.overrides = const [],
  });

  /// Creates a self-contained [OwlApp] pre-wrapped with [ProviderScope]
  /// and the default [AppObserver].
  const OwlApp.standalone({
    super.key,
    this.initialRoute = AppRoutes.console,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.observers = const [AppObserver()],
    this.overrides = const [],
  }) : withProviderScope = true;

  /// The entry route to display when the app initializes.
  final String initialRoute;

  /// Optional navigator key override. Defaults to [AppRouter.navigatorKey].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Additional navigator observers to register.
  final List<NavigatorObserver> navigatorObservers;

  /// Whether to embed an internal [ProviderScope] with [AppObserver].
  final bool withProviderScope;

  /// Riverpod provider observers when [withProviderScope] is enabled.
  final List<ProviderObserver>? observers;

  /// Provider overrides when [withProviderScope] is enabled.
  final List<Override> overrides;

  /// Dark tactical system UI overlay style matching OLED black HUD.
  static const SystemUiOverlayStyle darkSystemUiOverlayStyle =
      AppTheme.darkSystemUiOverlayStyle;

  /// Modern minimalist light system UI overlay style.
  static const SystemUiOverlayStyle lightSystemUiOverlayStyle =
      AppTheme.lightSystemUiOverlayStyle;

  /// Resolves the appropriate system UI overlay style for [brightness].
  static SystemUiOverlayStyle systemUiOverlayStyleFor(Brightness brightness) =>
      AppTheme.systemUiOverlayStyleFor(brightness);

  @override
  Widget build(BuildContext context) {
    final core = _OwlAppCore(
      initialRoute: initialRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
    );

    if (withProviderScope) {
      return ProviderScope(
        observers: observers ?? const [AppObserver()],
        overrides: overrides,
        child: core,
      );
    }

    return core;
  }
}

class _OwlAppCore extends ConsumerWidget {
  const _OwlAppCore({
    required this.initialRoute,
    required this.navigatorKey,
    required this.navigatorObservers,
  });

  final String initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlayStyle,
      child: MaterialApp(
        title: AppConstants.appFullName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        navigatorKey: navigatorKey ?? AppRouter.navigatorKey,
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
        navigatorObservers: [
          OwlRouteObserver(
            onRouteChanged: (routeName) {
              if (routeName != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(currentRouteProvider.notifier).state = routeName;
                });
              }
            },
          ),
          AppRouter.routeObserver,
          ...navigatorObservers,
        ],
        builder: (context, child) {
          final brightness = Theme.of(context).brightness;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemUiOverlayStyleFor(brightness),
            child: ScrollConfiguration(
              behavior: const OwlScrollBehavior(),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
