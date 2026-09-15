// language: Dart, file: miui_switch.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl_design/theme/tokens/color_tokens.dart';

/// Authentic Xiaomi MIUI / HyperOS pill toggle switch.
///
/// Implements a 44x24px smooth rounded capsule with an 18px sliding circular
/// thumb, glowing vibrant blue state when active, and subtle slate when inactive.
class MiuiSwitch extends StatelessWidget {
  const MiuiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const width = 44.0;
    const height = 24.0;
    const thumbSize = 18.0;
    const padding = 3.0;

    final activeColor = ColorSemantics.turboBlue;
    const inactiveColor = Color(0xFF232A38);
    final borderColor = value ? ColorSemantics.turboBlueLight.withValues(alpha: 0.5) : const Color(0x33FFFFFF);

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled && onChanged != null
            ? () {
                HapticFeedback.lightImpact();
                onChanged!(!value);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: value ? activeColor : inactiveColor,
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: value
                ? [
                    BoxShadow(
                      color: ColorSemantics.turboBlue.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: value ? (width - thumbSize - padding - 2.4) : padding,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
