// language: Dart, file: owl_status_dot.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/widgets.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Semantic preset roles for [OwlStatusDot].
enum OwlStatusDotRole {
  /// AI Live Coach active and observing match telemetry (Electric purple).
  aiLive,

  /// In-game overlay connected & synchronized (Neon cyan).
  synced,

  /// Target MOBA game client detected and anchored (Emerald green).
  gameDetected,

  /// Objective imminent or warning condition (Amber warning).
  warning,

  /// Offline, missing game context, or error (Crimson red).
  danger,
}

/// Breathing speed cadence for the outer pulsing aura.
enum OwlPulseSpeed {
  /// Gentle calm rhythm (2000ms period).
  slow,

  /// Standard operational rhythm (1400ms period).
  normal,

  /// Rapid alert cadence (700ms period).
  fast,
}

/// A bespoke cyber-tactical animated status indicator engineered for MOBA gaming HUDs.
/// Displays a high-contrast glowing core with a smoothly breathing/expanding concentric aura ring.
/// Zero Material dependencies.
class OwlStatusDot extends StatefulWidget {
  const OwlStatusDot({
    super.key,
    this.role = OwlStatusDotRole.synced,
    this.customColor,
    this.coreSize = 8.0,
    this.speed = OwlPulseSpeed.normal,
    this.isPulsing = true,
  });

  /// Semantic role configuring the telemetry color and pulse identity.
  final OwlStatusDotRole role;

  /// Optional override color if not using a predefined role.
  final Color? customColor;

  /// Diameter of the central solid dot in pixels. Defaults to 8.0.
  final double coreSize;

  /// Speed cadence of the breathing pulse.
  final OwlPulseSpeed speed;

  /// Whether the outer concentric aura is actively animating.
  final bool isPulsing;

  @override
  State<OwlStatusDot> createState() => _OwlStatusDotState();
}

class _OwlStatusDotState extends State<OwlStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _resolveDuration(widget.speed),
    );
    if (widget.isPulsing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant OwlStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = _resolveDuration(widget.speed);
    }
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  Duration _resolveDuration(OwlPulseSpeed speed) => switch (speed) {
        OwlPulseSpeed.slow => const Duration(milliseconds: 2000),
        OwlPulseSpeed.normal => const Duration(milliseconds: 1400),
        OwlPulseSpeed.fast => const Duration(milliseconds: 700),
      };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveColor(BuildContext context) {
    if (widget.customColor != null) return widget.customColor!;
    final t = ColorTokens.of(context);
    return switch (widget.role) {
      OwlStatusDotRole.aiLive => t.accentPurple,
      OwlStatusDotRole.synced => t.accentCyan,
      OwlStatusDotRole.gameDetected => t.alertSuccess,
      OwlStatusDotRole.warning => t.alertWarning,
      OwlStatusDotRole.danger => t.alertDanger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);
    final totalContainerSize = widget.coreSize * 2.8;

    if (!widget.isPulsing) {
      return SizedBox(
        width: totalContainerSize,
        height: totalContainerSize,
        child: Center(
          child: Container(
            width: widget.coreSize,
            height: widget.coreSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4.0,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: totalContainerSize,
      height: totalContainerSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final auraScale = 1.0 + (progress * 1.6); // Expands from 1.0 to 2.6
          final auraOpacity = (1.0 - progress).clamp(0.0, 0.7);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Concentric breathing expanding aura ring
              Transform.scale(
                scale: auraScale,
                child: Container(
                  width: widget.coreSize,
                  height: widget.coreSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: auraOpacity),
                      width: 1.2,
                    ),
                    color: color.withValues(alpha: auraOpacity * 0.25),
                  ),
                ),
              ),
              // High-density glowing solid core
              Container(
                width: widget.coreSize,
                height: widget.coreSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 6.0,
                      spreadRadius: 0.8,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
