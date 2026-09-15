// language: Dart, file: owl_button.dart, target: Flutter / Owl MOBA HUD
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Visual style variants for [OwlButton].
enum OwlButtonVariant {
  /// Neon cyan border with deep translucent glass fill and cyan bloom glow.
  primary,

  /// Muted elevated dark slate fill with subtle translucent border.
  secondary,

  /// Crimson red border, glass red fill, and urgent neon warning glow.
  danger,

  /// Transparent background with subtle sheen on hover/press.
  ghost,
}

/// Sizing scale for [OwlButton].
enum OwlButtonSize {
  /// Compact button (height: 32px, text: 12sp, icon: 14px).
  sm,

  /// Standard button (height: 42px, text: 14sp, icon: 16px).
  md,

  /// Prominent button (height: 50px, text: 16sp, icon: 18px).
  lg,
}

/// A bespoke cyber-tactical button engineered with Emil Kowalski's interaction principles:
/// - 160ms `easeOutCubic` responsive micro-scale (`0.97`) on press.
/// - Tactile haptic feedback on touch down.
/// - Sleek custom-painted miniature spinner for loading states.
/// - Strict adherence to Owl 3-tier design tokens. Zero Material dependencies.
class OwlButton extends StatefulWidget {
  const OwlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = OwlButtonVariant.primary,
    this.size = OwlButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.enableHaptics = true,
  });

  /// The button's text label.
  final String label;

  /// Callback fired when the button is clicked. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Visual styling theme variant.
  final OwlButtonVariant variant;

  /// Size metric for the button.
  final OwlButtonSize size;

  /// Optional icon or widget rendered before the label.
  final Widget? leadingIcon;

  /// Optional icon or widget rendered after the label.
  final Widget? trailingIcon;

  /// Whether the button is currently in an asynchronous loading state.
  final bool isLoading;

  /// Whether the button expands to fill all available horizontal space.
  final bool isFullWidth;

  /// Whether to fire light tactile haptic feedback on tap down.
  final bool enableHaptics;

  @override
  State<OwlButton> createState() => _OwlButtonState();
}

class _OwlButtonState extends State<OwlButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!_isEnabled) return;
    widget.onPressed?.call();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    if (!_isEnabled) return;
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (!_isEnabled) return;
    setState(() {
      _isHovered = false;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final (height, horizontalPadding, verticalPadding, fontSize, iconSize) = switch (widget.size) {
      OwlButtonSize.sm => (32.0, 10.0, 6.0, 12.0, 14.0),
      OwlButtonSize.md => (42.0, 16.0, 10.0, 14.0, 16.0),
      OwlButtonSize.lg => (50.0, 22.0, 14.0, 16.0, 18.0),
    };

    final colors = _resolveColors(context);

    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      opacity: _isEnabled ? 1.0 : 0.45,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: RadiusTokens.button,
          border: Border.all(
            color: colors.borderColor,
            width: 1.0,
          ),
          boxShadow: colors.shadows,
        ),
        child: Row(
          mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.isLoading) ...[
              _OwlButtonSpinner(
                size: iconSize,
                color: colors.textColor,
              ),
              const SizedBox(width: SpacingTokens.xs),
            ] else if (widget.leadingIcon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: colors.textColor,
                  size: iconSize,
                ),
                child: widget.leadingIcon!,
              ),
              const SizedBox(width: SpacingTokens.xs),
            ],
            Flexible(
              fit: widget.isFullWidth ? FlexFit.tight : FlexFit.loose,
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  height: 1.1,
                  color: colors.textColor,
                ),
              ),
            ),
            if (!widget.isLoading && widget.trailingIcon != null) ...[
              const SizedBox(width: SpacingTokens.xs),
              IconTheme(
                data: IconThemeData(
                  color: colors.textColor,
                  size: iconSize,
                ),
                child: widget.trailingIcon!,
              ),
            ],
          ],
        ),
      ),
    );

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: _handleMouseEnter,
      onExit: _handleMouseExit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: widget.isFullWidth ? SizedBox(width: double.infinity, child: content) : content,
        ),
      ),
    );
  }

  _ButtonColorState _resolveColors(BuildContext context) {
    final t = ColorTokens.of(context);
    switch (widget.variant) {
      case OwlButtonVariant.primary:
        final baseBg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassCyan25 : const Color(0xFF0284C7))
            : (_isHovered
                ? (t.isDark ? const Color(0x3300F5D4) : const Color(0xFF0369A1))
                : (t.isDark ? ColorPrimitives.glassCyan15 : t.buttonPrimaryBg));
        final baseBorder = _isPressed
            ? t.accentCyan
            : (_isHovered
                ? (t.isDark ? const Color(0xFF33F7DC) : const Color(0xFF0369A1))
                : t.accentCyan);
        final baseText = t.isDark ? t.accentCyan : const Color(0xFFFFFFFF);
        final shadows = _isPressed
            ? [
                ElevationTokens.subtleBorder,
                t.isDark
                    ? ElevationTokens.glowCyan
                    : const BoxShadow(color: Color(0x330EA5E9), blurRadius: 8, offset: Offset(0, 2)),
              ]
            : (_isHovered
                ? [
                    ElevationTokens.subtleBorder,
                    t.isDark
                        ? ElevationTokens.glowCyanSubtle
                        : const BoxShadow(color: Color(0x1F0EA5E9), blurRadius: 6, offset: Offset(0, 2)),
                  ]
                : [ElevationTokens.subtleBorder]);
        return _ButtonColorState(
          backgroundColor: baseBg,
          borderColor: baseBorder,
          textColor: baseText,
          shadows: shadows,
        );

      case OwlButtonVariant.secondary:
        final baseBg = _isPressed
            ? (t.isDark ? const Color(0xFF222936) : const Color(0xFFE2E8F0))
            : (_isHovered
                ? (t.isDark ? const Color(0xFF1D232E) : const Color(0xFFE2E8F0))
                : t.buttonSecondaryBg);
        final baseBorder = _isPressed
            ? t.borderGlassStrong
            : (_isHovered
                ? (t.isDark ? const Color(0x4DF8FAFC) : const Color(0xFFCBD5E1))
                : t.buttonSecondaryBorder);
        final baseText = _isPressed
            ? t.textPrimary
            : (_isHovered ? t.textPrimary : t.textSecondary);
        return _ButtonColorState(
          backgroundColor: baseBg,
          borderColor: baseBorder,
          textColor: baseText,
          shadows: const [ElevationTokens.subtleBorder],
        );

      case OwlButtonVariant.danger:
        final baseBg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassRed25 : const Color(0xFFBE123C))
            : (_isHovered
                ? (t.isDark ? const Color(0x33FF0055) : const Color(0xFFE11D48))
                : (t.isDark ? ColorPrimitives.glassRed15 : const Color(0xFFFFF1F2)));
        final baseBorder = t.alertDanger;
        final baseText = t.isDark ? t.alertDanger : const Color(0xFFE11D48);
        final shadows = _isPressed
            ? [ElevationTokens.subtleBorder, ElevationTokens.glowDangerIntense]
            : (_isHovered
                ? [ElevationTokens.subtleBorder, ElevationTokens.glowDanger]
                : [ElevationTokens.subtleBorder]);
        return _ButtonColorState(
          backgroundColor: baseBg,
          borderColor: baseBorder,
          textColor: baseText,
          shadows: shadows,
        );

      case OwlButtonVariant.ghost:
        final baseBg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassWhite15 : const Color(0x1A0F172A))
            : (_isHovered
                ? (t.isDark ? ColorPrimitives.glassWhite10 : const Color(0x0D0F172A))
                : const Color(0x00000000));
        final baseBorder = _isPressed
            ? t.borderGlassStrong
            : (_isHovered ? t.borderGlass : const Color(0x00000000));
        final baseText = _isPressed
            ? t.textPrimary
            : (_isHovered ? t.textPrimary : t.textSecondary);
        return _ButtonColorState(
          backgroundColor: baseBg,
          borderColor: baseBorder,
          textColor: baseText,
          shadows: const [],
        );
    }
  }
}

class _ButtonColorState {
  const _ButtonColorState({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.shadows,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final List<BoxShadow> shadows;
}

/// Sleek miniature canvas spinner for tactical HUD buttons.
class _OwlButtonSpinner extends StatefulWidget {
  const _OwlButtonSpinner({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<_OwlButtonSpinner> createState() => _OwlButtonSpinnerState();
}

class _OwlButtonSpinnerState extends State<_OwlButtonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SpinnerPainter(color: widget.color),
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Subtle track arc
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Glowing active sweep arc
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.0,
      1.75 * math.pi,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
