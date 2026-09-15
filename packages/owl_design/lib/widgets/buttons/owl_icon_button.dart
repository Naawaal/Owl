// language: Dart, file: owl_icon_button.dart, target: Flutter / Owl MOBA HUD
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Geometry shapes for [OwlIconButton].
enum OwlIconButtonShape {
  /// Rounded squircle corners adhering to [RadiusTokens.sm] or [RadiusTokens.md].
  squircle,

  /// Full circular tactical button.
  circle,
}

/// Sizing scale for [OwlIconButton].
enum OwlIconButtonSize {
  /// Compact icon button (32x32 px, icon size 16px).
  sm,

  /// Standard HUD icon button (40x40 px, icon size 20px).
  md,

  /// Large tactical action button (48x48 px, icon size 24px).
  lg,
}

/// Visual style variants for [OwlIconButton].
enum OwlIconButtonVariant {
  /// Neon cyan border with translucent glass fill.
  primary,

  /// Elevated dark surface with subtle border.
  secondary,

  /// Ghostly transparent button with hover sheen.
  ghost,

  /// Crimson red emergency action button.
  danger,
}

/// Tactical square/squircle or circular icon button with Emil Kowalski interaction polish:
/// - 160ms `easeOutCubic` responsive micro-scale (`0.95`) on press.
/// - Active glow state with neon cyan bloom.
/// - Haptic feedback on tap down.
/// - Custom miniaturized canvas spinner for loading state.
class OwlIconButton extends StatefulWidget {
  const OwlIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = OwlIconButtonVariant.secondary,
    this.size = OwlIconButtonSize.md,
    this.shape = OwlIconButtonShape.squircle,
    this.isActive = false,
    this.isLoading = false,
    this.enableHaptics = true,
    this.tooltip,
  });

  /// The icon or graphic to render inside the button.
  final Widget icon;

  /// Callback executed when the icon button is tapped. Disabled if null.
  final VoidCallback? onPressed;

  /// Visual styling theme variant.
  final OwlIconButtonVariant variant;

  /// Sizing metric.
  final OwlIconButtonSize size;

  /// Shape geometry: squircle or circular.
  final OwlIconButtonShape shape;

  /// Whether the button is in an active/toggled state (illuminates glowing border).
  final bool isActive;

  /// Whether the button is in a busy loading state.
  final bool isLoading;

  /// Whether to fire light haptic feedback on tap down.
  final bool enableHaptics;

  /// Optional accessibility tooltip label.
  final String? tooltip;

  @override
  State<OwlIconButton> createState() => _OwlIconButtonState();
}

class _OwlIconButtonState extends State<OwlIconButton> {
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
    final (dimension, iconDimension, radius) = switch (widget.size) {
      OwlIconButtonSize.sm => (
          32.0,
          16.0,
          widget.shape == OwlIconButtonShape.circle
              ? RadiusTokens.borderPill
              : RadiusTokens.borderSm,
        ),
      OwlIconButtonSize.md => (
          40.0,
          20.0,
          widget.shape == OwlIconButtonShape.circle
              ? RadiusTokens.borderPill
              : RadiusTokens.borderMd,
        ),
      OwlIconButtonSize.lg => (
          48.0,
          24.0,
          widget.shape == OwlIconButtonShape.circle
              ? RadiusTokens.borderPill
              : RadiusTokens.borderLg,
        ),
    };

    final colors = _resolveColors(context);

    final buttonContent = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      opacity: _isEnabled ? 1.0 : 0.4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: radius,
          border: Border.all(
            color: colors.borderColor,
            width: widget.isActive ? 1.5 : 1.0,
          ),
          boxShadow: colors.shadows,
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? _IconButtonSpinner(size: iconDimension, color: colors.iconColor)
            : IconTheme(
                data: IconThemeData(
                  color: colors.iconColor,
                  size: iconDimension,
                ),
                child: widget.icon,
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
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: buttonContent,
        ),
      ),
    );
  }

  _IconColors _resolveColors(BuildContext context) {
    final t = ColorTokens.of(context);
    if (widget.isActive) {
      return _IconColors(
        backgroundColor: _isPressed
            ? (t.isDark ? ColorPrimitives.glassCyan25 : const Color(0x330EA5E9))
            : (t.isDark ? ColorPrimitives.glassCyan15 : const Color(0x1A0EA5E9)),
        borderColor: t.accentCyan,
        iconColor: t.accentCyan,
        shadows: [
          ElevationTokens.subtleBorder,
          t.isDark ? ElevationTokens.glowCyanSubtle : const BoxShadow(color: Color(0x1F0EA5E9), blurRadius: 6),
        ],
      );
    }

    switch (widget.variant) {
      case OwlIconButtonVariant.primary:
        final bg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassCyan25 : const Color(0xFF0284C7))
            : (_isHovered
                ? (t.isDark ? const Color(0x3300F5D4) : const Color(0xFF0369A1))
                : (t.isDark ? ColorPrimitives.glassCyan15 : t.buttonPrimaryBg));
        final border = _isPressed || _isHovered ? (t.isDark ? const Color(0xFF33F7DC) : const Color(0xFF0369A1)) : t.accentCyan;
        final icon = t.isDark ? t.accentCyan : const Color(0xFFFFFFFF);
        final shadows = _isPressed
            ? [ElevationTokens.subtleBorder, t.isDark ? ElevationTokens.glowCyan : const BoxShadow(color: Color(0x330EA5E9), blurRadius: 8)]
            : (_isHovered ? [ElevationTokens.subtleBorder, t.isDark ? ElevationTokens.glowCyanSubtle : const BoxShadow(color: Color(0x1F0EA5E9), blurRadius: 6)] : const [ElevationTokens.subtleBorder]);
        return _IconColors(
          backgroundColor: bg,
          borderColor: border,
          iconColor: icon,
          shadows: shadows,
        );

      case OwlIconButtonVariant.secondary:
        final bg = _isPressed
            ? (t.isDark ? const Color(0xFF222936) : const Color(0xFFE2E8F0))
            : (_isHovered ? (t.isDark ? const Color(0xFF1D232E) : const Color(0xFFE2E8F0)) : t.buttonSecondaryBg);
        final border = _isPressed
            ? t.borderGlassStrong
            : (_isHovered ? (t.isDark ? const Color(0x4DF8FAFC) : const Color(0xFFCBD5E1)) : t.buttonSecondaryBorder);
        final icon = _isPressed || _isHovered ? t.textPrimary : t.textSecondary;
        return _IconColors(
          backgroundColor: bg,
          borderColor: border,
          iconColor: icon,
          shadows: const [ElevationTokens.subtleBorder],
        );

      case OwlIconButtonVariant.ghost:
        final bg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassWhite15 : const Color(0x1A0F172A))
            : (_isHovered ? (t.isDark ? ColorPrimitives.glassWhite10 : const Color(0x0D0F172A)) : const Color(0x00000000));
        final border = _isPressed
            ? t.borderGlassStrong
            : (_isHovered ? t.borderGlass : const Color(0x00000000));
        final icon = _isPressed || _isHovered ? t.textPrimary : t.textSecondary;
        return _IconColors(
          backgroundColor: bg,
          borderColor: border,
          iconColor: icon,
          shadows: const [],
        );

      case OwlIconButtonVariant.danger:
        final bg = _isPressed
            ? (t.isDark ? ColorPrimitives.glassRed25 : const Color(0xFFBE123C))
            : (_isHovered ? (t.isDark ? const Color(0x33FF0055) : const Color(0xFFE11D48)) : (t.isDark ? ColorPrimitives.glassRed15 : const Color(0xFFFFF1F2)));
        final border = t.alertDanger;
        final icon = t.isDark ? t.alertDanger : const Color(0xFFE11D48);
        final shadows = _isPressed
            ? [ElevationTokens.subtleBorder, ElevationTokens.glowDangerIntense]
            : (_isHovered ? [ElevationTokens.subtleBorder, ElevationTokens.glowDanger] : const [ElevationTokens.subtleBorder]);
        return _IconColors(
          backgroundColor: bg,
          borderColor: border,
          iconColor: icon,
          shadows: shadows,
        );
    }
  }
}

class _IconColors {
  const _IconColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.shadows,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final List<BoxShadow> shadows;
}

class _IconButtonSpinner extends StatefulWidget {
  const _IconButtonSpinner({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<_IconButtonSpinner> createState() => _IconButtonSpinnerState();
}

class _IconButtonSpinnerState extends State<_IconButtonSpinner>
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
            painter: _IconSpinnerPainter(color: widget.color),
          ),
        );
      },
    );
  }
}

class _IconSpinnerPainter extends CustomPainter {
  const _IconSpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

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
  bool shouldRepaint(covariant _IconSpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
