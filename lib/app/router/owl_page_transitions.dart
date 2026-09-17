// language: Dart, file: owl_page_transitions.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';

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
