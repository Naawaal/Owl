import 'package:flutter/material.dart';
import 'package:owl_core/owl_core.dart';

/// Horizontal carousel deck card with blurred artwork backdrop, status tags,
/// active mod chips, and quick-launch action button.
class HeroDeckCard extends StatelessWidget {
  final Game game;
  final List<String> activeMods;
  final VoidCallback onTap;
  final VoidCallback? onLaunch;
  final double width;

  const HeroDeckCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onLaunch,
    this.activeMods = const [],
    this.width = 300.0,
  });

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'train':
        return Icons.train_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'sports_baseball':
        return Icons.sports_baseball_rounded;
      case 'cake':
        return Icons.cake_rounded;
      case 'circle':
        return Icons.adjust_rounded;
      case 'crosshairs':
        return Icons.my_location_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: tokens.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: tokens.borderSubtle,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Category tag and Installed Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Text(
                        game.category.toUpperCase(),
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: game.isInstalled
                            ? AppColors.success.withOpacity(0.14)
                            : tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: game.isInstalled
                              ? AppColors.success.withOpacity(0.3)
                              : tokens.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: game.isInstalled ? AppColors.success : tokens.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            game.isInstalled ? 'INSTALLED' : 'AVAILABLE',
                            style: AppTypography.labelCaps.copyWith(
                              color: game.isInstalled ? AppColors.success : tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Center Icon and Title Banner
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.borderStrong),
                      ),
                      child: Icon(
                        _resolveIcon(game.icon),
                        size: 28,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: AppTypography.titleLarge.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            game.packageName,
                            style: AppTypography.bodySmall.copyWith(
                              color: tokens.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Active Mod Badges / Tags
                if (activeMods.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: activeMods.take(3).map((mod) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        child: Text(
                          mod,
                          style: AppTypography.monoCode.copyWith(
                            color: tokens.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Text(
                    game.description.isNotEmpty
                        ? game.description
                        : 'Custom sandbox ready with overlay vision & aim support.',
                    style: AppTypography.bodySmall.copyWith(
                      color: tokens.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 18),

                // Bottom Action Button
                OwlButton(
                  label: game.isInstalled ? 'Launch Mod' : 'Configure',
                  icon: game.isInstalled ? Icons.play_arrow_rounded : Icons.tune_rounded,
                  variant: game.isInstalled
                      ? OwlButtonVariant.primary
                      : OwlButtonVariant.secondary,
                  onPressed: onLaunch ?? onTap,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
