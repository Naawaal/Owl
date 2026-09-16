// language: Dart, file: owl_badge.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Semantic color theme variants for [OwlBadge].
enum OwlBadgeVariant {
  /// Tactical cyan tint for active states and objectives.
  cyan,

  /// Electric purple for AI coaching insights and smart tips.
  purple,

  /// Amber warning for impending objective spawns (<= 30s).
  warning,

  /// Crimson danger for urgent threats and missing enemies (<= 10s).
  danger,

  /// Emerald success for secured buffs and ready ultimates.
  success,

  /// Neutral translucent dark slate for metadata tags.
  neutral,
}

/// Sizing scale for [OwlBadge].
enum OwlBadgeSize {
  /// Micro tag (height 20px, text 9.5sp).
  sm,

  /// Standard badge (height 24px, text 11sp).
  md,
}

/// Compact tactical badge/chip with monospaced uppercase lettering,
/// optional indicator dot, and cyber-tactical border sheen. Zero Material dependencies.
class OwlBadge extends StatelessWidget {
  const OwlBadge({
    super.key,
    required this.label,
    this.variant = OwlBadgeVariant.cyan,
    this.size = OwlBadgeSize.md,
    this.showDot = false,
    this.isPulsingDot = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isPill = true,
  });

  /// The badge text label (will be rendered uppercase).
  final String label;

  /// Semantic theme variant determining background, border, and text tint.
  final OwlBadgeVariant variant;

  /// Sizing metric.
  final OwlBadgeSize size;

  /// Whether to show a colored indicator dot preceding the label.
  final bool showDot;

  /// Whether the indicator dot should pulse softly.
  final bool isPulsingDot;

  /// Optional custom leading widget.
  final Widget? leadingIcon;

  /// Optional custom trailing widget.
  final Widget? trailingIcon;

  /// Whether the badge uses full pill geometry ([RadiusTokens.borderPill])
  /// or compact tactical corners ([RadiusTokens.borderXs]).
  final bool isPill;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context);
    final (height, horizontalPadding, verticalPadding, fontSize, dotSize) = switch (size) {
      OwlBadgeSize.sm => (20.0, 7.0, 2.0, 9.5, 5.0),
      OwlBadgeSize.md => (24.0, 10.0, 3.5, 11.0, 6.0),
    };

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: isPill ? RadiusTokens.borderPill : RadiusTokens.borderXs,
        border: Border.all(
          color: colors.borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            _BadgeDot(
              size: dotSize,
              color: colors.accentColor,
              isPulsing: isPulsingDot,
            ),
            const SizedBox(width: SpacingTokens.xxs + 1.0),
          ] else if (leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: colors.accentColor,
                size: fontSize + 2.0,
              ),
              child: leadingIcon!,
            ),
            const SizedBox(width: SpacingTokens.xxs + 1.0),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              height: 1.1,
              color: colors.textColor,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: SpacingTokens.xxs + 1.0),
            IconTheme(
              data: IconThemeData(
                color: colors.accentColor,
                size: fontSize + 2.0,
              ),
              child: trailingIcon!,
            ),
          ],
        ],
      ),
    );
  }

  _BadgeColors _resolveColors(BuildContext context) {
    final t = ColorTokens.of(context);
    switch (variant) {
      case OwlBadgeVariant.cyan:
        return _BadgeColors(
          backgroundColor: t.isDark ? ColorPrimitives.glassCyan15 : const Color(0x1A0EA5E9),
          borderColor: t.accentCyan.withValues(alpha: 0.4),
          textColor: t.accentCyan,
          accentColor: t.accentCyan,
        );
      case OwlBadgeVariant.purple:
        return _BadgeColors(
          backgroundColor: t.isDark ? ColorPrimitives.glassPurple15 : const Color(0x1A7C3AED),
          borderColor: t.accentPurple.withValues(alpha: 0.4),
          textColor: t.isDark ? const Color(0xFFC084FC) : t.accentPurple,
          accentColor: t.accentPurple,
        );
      case OwlBadgeVariant.warning:
        return _BadgeColors(
          backgroundColor: t.isDark ? ColorPrimitives.glassAmber15 : const Color(0x1AD97706),
          borderColor: t.alertWarning.withValues(alpha: 0.4),
          textColor: t.alertWarning,
          accentColor: t.alertWarning,
        );
      case OwlBadgeVariant.danger:
        return _BadgeColors(
          backgroundColor: t.isDark ? ColorPrimitives.glassRed15 : const Color(0x1AE11D48),
          borderColor: t.alertDanger.withValues(alpha: 0.4),
          textColor: t.alertDanger,
          accentColor: t.alertDanger,
        );
      case OwlBadgeVariant.success:
        return _BadgeColors(
          backgroundColor: t.isDark ? ColorPrimitives.glassGreen15 : const Color(0x1A059669),
          borderColor: t.alertSuccess.withValues(alpha: 0.4),
          textColor: t.alertSuccess,
          accentColor: t.alertSuccess,
        );
      case OwlBadgeVariant.neutral:
        return _BadgeColors(
          backgroundColor: t.surfaceElevated,
          borderColor: t.borderGlass,
          textColor: t.textSecondary,
          accentColor: t.textSecondary,
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.accentColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color accentColor;
}

class _BadgeDot extends StatefulWidget {
  const _BadgeDot({
    required this.size,
    required this.color,
    required this.isPulsing,
  });

  final double size;
  final Color color;
  final bool isPulsing;

  @override
  State<_BadgeDot> createState() => _BadgeDotState();
}

class _BadgeDotState extends State<_BadgeDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BadgeDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPulsing) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.4 + (_controller.value * 0.6);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 * _controller.value),
                blurRadius: 4.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
