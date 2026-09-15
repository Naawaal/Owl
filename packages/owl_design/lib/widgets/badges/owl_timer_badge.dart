import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Urgency tier for objective and respawn timers.
enum OwlTimerUrgency {
  /// More than 30 seconds remaining. Serene emerald/cyan steady glow.
  normal,

  /// Between 11 and 30 seconds remaining. Amber warning with gentle breathing pulse.
  warning,

  /// 10 seconds or fewer remaining. Crimson red critical alert with rapid heartbeat pulse.
  urgent,

  /// Timer reached 0 or expired. Ready/Spawned state.
  spawned,
}

/// Sizing scale for [OwlTimerBadge].
enum OwlTimerBadgeSize {
  /// Compact badge for in-game HUD strips (height 26px, timer 13sp).
  sm,

  /// Standard badge for tactical overview and drawer (height 32px, timer 15sp).
  md,

  /// Prominent badge for large objective countdowns (height 40px, timer 18sp).
  lg,
}

/// A bespoke cyber-tactical countdown timer badge engineered with:
/// - Tabular figures & monospaced digits (`FontFeature.tabularFigures()`, `slashedZero()`)
///   ensuring zero horizontal jitter or vibration during live countdown.
/// - Dynamic 3-stage urgency state machine:
///   * Normal (> 30s): Emerald / cyan steady status.
///   * Warning (<= 30s): Amber glow with gentle breathing animation.
///   * Urgent (<= 10s): Crimson red glow with rapid heartbeat pulse.
/// - Zero Material dependencies.
class OwlTimerBadge extends StatefulWidget {
  const OwlTimerBadge({
    super.key,
    required this.remainingSeconds,
    this.label,
    this.size = OwlTimerBadgeSize.md,
    this.icon,
    this.isPaused = false,
  });

  /// Seconds remaining in the objective/cooldown timer.
  final int remainingSeconds;

  /// Optional objective identifier (e.g. "DRAGON", "BARON", "FLASH").
  final String? label;

  /// Sizing scale.
  final OwlTimerBadgeSize size;

  /// Optional leading icon or skill graphic.
  final Widget? icon;

  /// Whether the timer is currently paused.
  final bool isPaused;

  @override
  State<OwlTimerBadge> createState() => _OwlTimerBadgeState();
}

class _OwlTimerBadgeState extends State<OwlTimerBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  OwlTimerUrgency get _urgency {
    if (widget.remainingSeconds <= 0) return OwlTimerUrgency.spawned;
    if (widget.remainingSeconds <= 10) return OwlTimerUrgency.urgent;
    if (widget.remainingSeconds <= 30) return OwlTimerUrgency.warning;
    return OwlTimerUrgency.normal;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this);
    _configureAnimation(_urgency);
  }

  @override
  void didUpdateWidget(covariant OwlTimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrgency = _resolveUrgency(oldWidget.remainingSeconds);
    final newUrgency = _urgency;

    if (oldUrgency != newUrgency || oldWidget.isPaused != widget.isPaused) {
      _configureAnimation(newUrgency);
    }
  }

  OwlTimerUrgency _resolveUrgency(int seconds) {
    if (seconds <= 0) return OwlTimerUrgency.spawned;
    if (seconds <= 10) return OwlTimerUrgency.urgent;
    if (seconds <= 30) return OwlTimerUrgency.warning;
    return OwlTimerUrgency.normal;
  }

  void _configureAnimation(OwlTimerUrgency urgency) {
    if (widget.isPaused) {
      _pulseController.stop();
      _pulseController.value = 1.0;
      return;
    }

    switch (urgency) {
      case OwlTimerUrgency.urgent:
        // Rapid heartbeat pulse (550ms period)
        _pulseController.duration = const Duration(milliseconds: 550);
        _pulseController.repeat(reverse: true);
        break;
      case OwlTimerUrgency.warning:
        // Gentle breathing pulse (1100ms period)
        _pulseController.duration = const Duration(milliseconds: 1100);
        _pulseController.repeat(reverse: true);
        break;
      case OwlTimerUrgency.normal:
      case OwlTimerUrgency.spawned:
        _pulseController.stop();
        _pulseController.value = 1.0;
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return 'READY';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final urgency = _urgency;
    final timeString = _formatTime(widget.remainingSeconds);

    final (height, horizontalPadding, timerFontSize, labelFontSize, iconSize) =
        switch (widget.size) {
      OwlTimerBadgeSize.sm => (26.0, 8.0, 13.0, 9.0, 13.0),
      OwlTimerBadgeSize.md => (32.0, 12.0, 15.0, 10.0, 15.0),
      OwlTimerBadgeSize.lg => (40.0, 16.0, 18.0, 11.5, 18.0),
    };

    final visualConfig = _resolveVisuals(urgency, context);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseProgress = (urgency == OwlTimerUrgency.urgent ||
                urgency == OwlTimerUrgency.warning)
            ? _pulseController.value
            : 1.0;

        final glowOpacity = (0.2 + (0.5 * pulseProgress)).clamp(0.0, 1.0);
        final borderColor = Color.lerp(
          visualConfig.baseBorderColor,
          visualConfig.highlightBorderColor,
          pulseProgress,
        )!;

        return Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: visualConfig.backgroundColor,
            borderRadius: RadiusTokens.borderPill,
            border: Border.all(
              color: borderColor,
              width: urgency == OwlTimerUrgency.urgent ? 1.5 : 1.0,
            ),
            boxShadow: [
              ElevationTokens.subtleBorder,
              BoxShadow(
                color: visualConfig.glowColor.withValues(alpha: glowOpacity),
                blurRadius: urgency == OwlTimerUrgency.urgent ? 14.0 : 8.0,
                spreadRadius: urgency == OwlTimerUrgency.urgent ? 1.0 : 0.0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: visualConfig.accentColor,
                    size: iconSize,
                  ),
                  child: widget.icon!,
                ),
                const SizedBox(width: SpacingTokens.xs),
              ],
              if (widget.label != null) ...[
                Text(
                  widget.label!.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    height: 1.1,
                    color: visualConfig.labelColor,
                    fontFeatures: const [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
              ],
              Text(
                timeString,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: timerFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  height: 1.1,
                  color: visualConfig.timerColor,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                    FontFeature.slashedZero(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _TimerVisualConfig _resolveVisuals(OwlTimerUrgency urgency, BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (urgency) {
      case OwlTimerUrgency.normal:
        return _TimerVisualConfig(
          backgroundColor: isDark
              ? ColorPrimitives.glassDeepSlate85
              : const Color(0xFFF1F5F9),
          baseBorderColor: isDark
              ? const Color(0x3300F5D4)
              : const Color(0x330EA5E9),
          highlightBorderColor: colors.accentCyan,
          timerColor: colors.accentCyan,
          labelColor: colors.textSecondary,
          accentColor: colors.accentCyan,
          glowColor: isDark
              ? ColorPrimitives.glassCyan25
              : const Color(0x220EA5E9),
        );

      case OwlTimerUrgency.warning:
        return _TimerVisualConfig(
          backgroundColor: isDark
              ? ColorPrimitives.glassDeepSlate85
              : const Color(0xFFFEF3C7),
          baseBorderColor: isDark
              ? const Color(0x66FFB703)
              : const Color(0x80D97706),
          highlightBorderColor: colors.alertWarning,
          timerColor: colors.alertWarning,
          labelColor: isDark
              ? const Color(0xFFFFD166)
              : const Color(0xFFB45309),
          accentColor: colors.alertWarning,
          glowColor: colors.alertWarning,
        );

      case OwlTimerUrgency.urgent:
        return _TimerVisualConfig(
          backgroundColor: isDark
              ? ColorPrimitives.glassRed15
              : const Color(0xFFFFE4E6),
          baseBorderColor: isDark
              ? const Color(0x80FF0055)
              : const Color(0x80E11D48),
          highlightBorderColor: colors.alertDanger,
          timerColor: colors.alertDanger,
          labelColor: isDark
              ? const Color(0xFFFF6699)
              : const Color(0xFFBE123C),
          accentColor: colors.alertDanger,
          glowColor: colors.alertDanger,
        );

      case OwlTimerUrgency.spawned:
        return _TimerVisualConfig(
          backgroundColor: isDark
              ? ColorPrimitives.glassGreen15
              : const Color(0xFFD1FAE5),
          baseBorderColor: colors.alertSuccess,
          highlightBorderColor: isDark
              ? const Color(0xFF33FFAA)
              : const Color(0xFF059669),
          timerColor: colors.alertSuccess,
          labelColor: colors.alertSuccess,
          accentColor: colors.alertSuccess,
          glowColor: colors.alertSuccess,
        );
    }
  }
}

class _TimerVisualConfig {
  const _TimerVisualConfig({
    required this.backgroundColor,
    required this.baseBorderColor,
    required this.highlightBorderColor,
    required this.timerColor,
    required this.labelColor,
    required this.accentColor,
    required this.glowColor,
  });

  final Color backgroundColor;
  final Color baseBorderColor;
  final Color highlightBorderColor;
  final Color timerColor;
  final Color labelColor;
  final Color accentColor;
  final Color glowColor;
}
