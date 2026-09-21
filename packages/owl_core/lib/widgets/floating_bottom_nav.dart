import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/owl_theme_extension.dart';

class FloatingNavItem {
  final IconData icon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.label,
  });
}

/// Frosted glass floating pill navigation dock with animated sliding selection indicator.
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<FloatingNavItem> items;
  final double elevation;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    this.elevation = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);
    final count = items.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: tokens.glassNavBg,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: tokens.borderStrong,
                    width: 1,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / count;
                    final clampedIndex = currentIndex.clamp(0, count - 1);

                    return Stack(
                      children: [
                        // Animated sliding pill background for active tab
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left: itemWidth * clampedIndex,
                          top: 0,
                          bottom: 0,
                          width: itemWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: tokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: tokens.borderHighlight,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tokens.accentGlow.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Interactive Tab Items
                        Row(
                          children: List.generate(count, (index) {
                            final item = items[index];
                            final isActive = index == currentIndex;

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (index != currentIndex) {
                                    HapticFeedback.selectionClick();
                                    onIndexChanged(index);
                                  }
                                },
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isActive
                                          ? AppColors.primaryAccent
                                          : tokens.textTertiary,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          item.icon,
                                          size: 18,
                                          color: isActive
                                              ? AppColors.primaryAccent
                                              : tokens.textTertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            color: isActive
                                                ? AppColors.primaryAccent
                                                : tokens.textTertiary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
