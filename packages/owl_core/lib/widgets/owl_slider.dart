import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/owl_theme_extension.dart';

/// Minimal low-profile tactile slider matching the titanium design system.
class OwlSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double)? valueFormatter;

  const OwlSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.valueFormatter,
  });

  @override
  State<OwlSlider> createState() => _OwlSliderState();
}

class _OwlSliderState extends State<OwlSlider> {
  static const double _trackHeight = 6.0;
  static const double _thumbRadius = 9.0;

  void _updateValueFromPosition(double localX, double totalWidth) {
    if (widget.onChanged == null || totalWidth <= 0) return;

    final clampedX = localX.clamp(0.0, totalWidth);
    final ratio = clampedX / totalWidth;
    var newValue = widget.min + (widget.max - widget.min) * ratio;

    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      newValue = ((newValue - widget.min) / step).round() * step + widget.min;
    }

    newValue = newValue.clamp(widget.min, widget.max);
    if ((newValue - widget.value).abs() > 0.001) {
      HapticFeedback.selectionClick();
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);
    final isEnabled = widget.onChanged != null;

    final double range = widget.max - widget.min;
    final double fraction = range > 0 ? ((widget.value - widget.min) / range).clamp(0.0, 1.0) : 0.0;

    final String displayValue = widget.valueFormatter != null
        ? widget.valueFormatter!(widget.value)
        : widget.value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.valueFormatter != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: AppTypography.titleMedium.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              Text(
                displayValue,
                style: AppTypography.monoMetric.copyWith(
                  color: isEnabled ? AppColors.primaryAccent : tokens.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final thumbPosition = trackWidth * fraction;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                _updateValueFromPosition(details.localPosition.dx, trackWidth);
              },
              onTapDown: (details) {
                _updateValueFromPosition(details.localPosition.dx, trackWidth);
              },
              child: SizedBox(
                height: 32,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Inactive track
                    Container(
                      height: _trackHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                        border: Border.all(
                          color: tokens.borderSubtle,
                          width: 1,
                        ),
                      ),
                    ),
                    // Active track fill
                    Container(
                      height: _trackHeight,
                      width: thumbPosition,
                      decoration: BoxDecoration(
                        gradient: isEnabled
                            ? AppColors.primaryGradient
                            : null,
                        color: isEnabled ? null : tokens.surfaceHover,
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                        boxShadow: isEnabled
                            ? [
                                BoxShadow(
                                  color: tokens.accentGlow,
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: (thumbPosition - _thumbRadius).clamp(0.0, trackWidth - (_thumbRadius * 2)),
                      child: Container(
                        width: _thumbRadius * 2,
                        height: _thumbRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEnabled ? Colors.white : tokens.textTertiary,
                          border: Border.all(
                            color: AppColors.primaryAccent,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
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
          },
        ),
      ],
    );
  }
}
