import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/owl_theme_extension.dart';

/// Tactile toggle switch matching the Minimal Titanium & Slate prototype styling.
class OwlSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enableHaptics;

  const OwlSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enableHaptics = true,
  });

  static const double _trackWidth = 46.0;
  static const double _trackHeight = 26.0;
  static const double _thumbSize = 20.0;
  static const double _thumbPadding = 3.0;

  void _handleTap() {
    if (onChanged == null) return;
    if (enableHaptics) {
      HapticFeedback.lightImpact();
    }
    onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);
    final isEnabled = onChanged != null;

    final Color trackColor = value
        ? (isEnabled ? AppColors.primaryAccent : AppColors.primaryAccent.withValues(alpha: 0.5))
        : (isEnabled ? tokens.surfaceElevated : tokens.surfaceHover);

    final Color thumbColor = value
        ? Colors.white
        : (isEnabled ? tokens.textSecondary : tokens.textTertiary);

    return GestureDetector(
      onTap: isEnabled ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: _trackWidth,
        height: _trackHeight,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: value ? AppColors.borderHighlight : tokens.borderSubtle,
            width: 1,
          ),
          boxShadow: value && isEnabled
              ? [
                  BoxShadow(
                    color: tokens.accentGlow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              left: value
                  ? (_trackWidth - _thumbSize - _thumbPadding)
                  : _thumbPadding,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thumbColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
