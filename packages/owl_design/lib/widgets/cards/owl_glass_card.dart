// language: Dart, file: owl_glass_card.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Glassmorphism variant for [OwlGlassCard].
enum OwlGlassVariant {
  /// Standard HUD glass with balanced 75% dark translucency.
  standard,

  /// Dense glass with 85% opacity for high-contrast overlays.
  dense,

  /// Subtle glass with 65% opacity for transparent background HUD visibility.
  subtle,
}

/// A bespoke cyber-tactical glassmorphic container engineered for MOBA gaming overlays.
/// Features:
/// - Real-time background blur via [BackdropFilter] (sigma: 10.0).
/// - 1px subtle gradient border sheen with optional neon cyan glowing state.
/// - Optional [onTap] micro-feedback scaling to `0.985` over 160ms `easeOutCubic`.
/// - Built strictly from Flutter primitives with anti-aliased clipping.
class OwlGlassCard extends StatefulWidget {
  const OwlGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.variant = OwlGlassVariant.standard,
    this.isHighlighted = false,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.customBorderColor,
    this.enableHaptics = true,
  });

  /// The widget content inside the card.
  final Widget child;

  /// Optional tap handler. If provided, the card gives responsive micro-scale feedback.
  final VoidCallback? onTap;

  /// Glass transparency density.
  final OwlGlassVariant variant;

  /// Whether the card is highlighted (illuminates neon cyan border and ambient glow).
  final bool isHighlighted;

  /// Corner radius geometry. Defaults to [RadiusTokens.borderMd] (12px).
  final BorderRadius? borderRadius;

  /// Inner padding. Defaults to [SpacingTokens.cardInsets] (16px).
  final EdgeInsetsGeometry? padding;

  /// Outer margin surrounding the card.
  final EdgeInsetsGeometry? margin;

  /// Optional fixed width.
  final double? width;

  /// Optional fixed height.
  final double? height;

  /// Optional override for the card's border color.
  final Color? customBorderColor;

  /// Whether to fire light tactile haptic feedback on tap down.
  final bool enableHaptics;

  @override
  State<OwlGlassCard> createState() => _OwlGlassCardState();
}

class _OwlGlassCardState extends State<OwlGlassCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isInteractive => widget.onTap != null;

  void _handleTapDown(TapDownDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!_isInteractive) return;
    widget.onTap?.call();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    if (!_isInteractive) return;
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (!_isInteractive) return;
    setState(() {
      _isHovered = false;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? RadiusTokens.borderMd;
    final effectivePadding = widget.padding ?? SpacingTokens.cardInsets;

    final colors = ColorTokens.of(context);

    final (bgColor, filter) = switch (widget.variant) {
      OwlGlassVariant.standard => (
          colors.surfaceGlass,
          ElevationTokens.glassFilter,
        ),
      OwlGlassVariant.dense => (
          colors.surfaceGlassDense,
          ElevationTokens.glassFilterDense,
        ),
      OwlGlassVariant.subtle => (
          colors.surfaceGlassSubtle,
          ElevationTokens.glassFilterSubtle,
        ),
    };

    final borderColor = widget.customBorderColor ??
        (widget.isHighlighted
            ? colors.accentCyan
            : (_isHovered
                ? colors.borderGlassStrong
                : colors.borderGlass));

    final shadows = widget.isHighlighted
        ? [
            ElevationTokens.subtleBorder,
            ElevationTokens.glowCyanSubtle,
          ]
        : (_isHovered
            ? [
                ElevationTokens.subtleBorder,
                BoxShadow(
                  color: colors.isDark
                      ? const Color(0x33000000)
                      : const Color(0x140F172A),
                  blurRadius: 16.0,
                  offset: const Offset(0, 6),
                ),
              ]
            : (colors.isDark
                ? ElevationTokens.glassCardShadows
                : const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ]));

    Widget cardBody = ClipRRect(
      borderRadius: effectiveRadius,
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: filter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: borderColor,
              width: widget.isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: shadows,
          ),
          child: widget.child,
        ),
      ),
    );

    if (_isInteractive) {
      cardBody = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: cardBody,
          ),
        ),
      );
    }

    if (widget.margin != null) {
      cardBody = Padding(padding: widget.margin!, child: cardBody);
    }

    return cardBody;
  }
}
