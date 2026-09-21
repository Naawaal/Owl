import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/owl_theme_extension.dart';

enum OwlButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

/// High-polish tactile button with micro-scale press animation and multiple styling variants.
class OwlButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final OwlButtonVariant variant;
  final IconData? icon;
  final Widget? trailing;
  final bool isLoading;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const OwlButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OwlButtonVariant.primary,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.height = 44,
    this.width,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<OwlButton> createState() => _OwlButtonState();
}

class _OwlButtonState extends State<OwlButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Decoration decoration;
    TextStyle textStyle;

    switch (widget.variant) {
      case OwlButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: isEnabled ? AppColors.primaryGradient : null,
          color: isEnabled ? null : tokens.surfaceHover,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: tokens.accentGlow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );
        textStyle = AppTypography.titleMedium.copyWith(
          color: isEnabled ? Colors.white : tokens.textTertiary,
          fontWeight: FontWeight.w700,
        );
        break;

      case OwlButtonVariant.secondary:
        decoration = BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: tokens.borderSubtle),
        );
        textStyle = AppTypography.titleMedium.copyWith(
          color: isEnabled ? tokens.textPrimary : tokens.textTertiary,
        );
        break;

      case OwlButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: tokens.borderStrong),
        );
        textStyle = AppTypography.titleMedium.copyWith(
          color: isEnabled ? tokens.textPrimary : tokens.textTertiary,
        );
        break;

      case OwlButtonVariant.ghost:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
        textStyle = AppTypography.titleMedium.copyWith(
          color: isEnabled ? tokens.textSecondary : tokens.textTertiary,
        );
        break;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: widget.padding,
          decoration: decoration,
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.variant == OwlButtonVariant.primary
                          ? Colors.white
                          : tokens.textPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 16,
                        color: textStyle.color,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: textStyle,
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
