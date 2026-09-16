// language: Dart, file: oem_segmented_chips.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Authentic Xiaomi Game Turbo segmented chip selector.
///
/// Features a dark beveled capsule container with smooth active pill highlighting.
class OemSegmentedChips<T> extends StatelessWidget {
  const OemSegmentedChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.labelBuilder,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T item)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.isDark
            ? ColorPrimitives.segTrackBlack40
            : colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderGlass),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == selected;
          final label = labelBuilder != null ? labelBuilder!(option) : option.toString();

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!isSelected) {
                HapticFeedback.selectionClick();
                onSelected(option);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color:
                    isSelected ? colors.turboBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.turboBlue.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TypographyTokens.bodySmallOf(context).copyWith(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : colors.textPrimary.withValues(alpha: 0.6),
                  letterSpacing: -0.1,
                  height: 1.2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
