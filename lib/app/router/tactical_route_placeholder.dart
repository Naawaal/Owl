// language: Dart, file: tactical_route_placeholder.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:owl/app/router/app_routes.dart';
import 'package:owl_design/owl_design.dart';

/// Tactical OLED placeholder view rendered for routes under development.
///
/// Provides visual navigation chips enabling interactive verification of
/// page transitions across all defined routes.
class TacticalRoutePlaceholder extends StatelessWidget {
  const TacticalRoutePlaceholder({
    super.key,
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isError = false,
  });

  final String routeName;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.textPrimary,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          title,
          style: TypographyTokens.headline.copyWith(color: colors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: OwlBadge(
                label: isError ? 'ERROR' : 'TACTICAL',
                variant: isError
                    ? OwlBadgeVariant.danger
                    : OwlBadgeVariant.cyan,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: SpacingTokens.screenInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OwlGlassCard(
                customBorderColor: isError
                    ? colors.alertDanger
                    : colors.borderGlassStrong,
                isHighlighted: !isError,
                padding: SpacingTokens.cardInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isError
                                ? (isDark
                                    ? ColorPrimitives.glassRed25
                                    : colors.telemetryCritical
                                        .withValues(alpha: 0.12))
                                : (isDark
                                    ? ColorPrimitives.glassCyan25
                                    : colors.accentCyan
                                        .withValues(alpha: 0.12)),
                            borderRadius: RadiusTokens.borderSm,
                          ),
                          child: Icon(
                            icon,
                            color: isError
                                ? colors.alertDanger
                                : colors.accentCyan,
                            size: 22,
                          ),
                        ),
                        SpacingTokens.gapH12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TypographyTokens.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TypographyTokens.bodySmall.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OwlStatusDot(
                          role: isError
                              ? OwlStatusDotRole.danger
                              : OwlStatusDotRole.synced,
                          isPulsing: false,
                        ),
                      ],
                    ),
                    SpacingTokens.gapV16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorPrimitives.oledBlack
                            : colors.surfaceElevated,
                        borderRadius: RadiusTokens.hudChip,
                        border: Border.all(
                          color: colors.borderGlass,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.terminal,
                            size: 14,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            routeName,
                            style: TypographyTokens.displayTimerSmall.copyWith(
                              fontSize: 12,
                              color: colors.accentCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SpacingTokens.gapV16,
              Text(
                'QUICK ROUTE SWITCHER',
                style: TypographyTokens.tacticalLabel.copyWith(
                  color: colors.textMuted,
                ),
              ),
              SpacingTokens.gapV8,
              Expanded(
                child: ListView(
                  children: [
                    _buildRouteTile(
                      context,
                      label: 'Design System Showcase',
                      route: AppRoutes.showcase,
                      icon: Icons.palette_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Tactical Dashboard',
                      route: AppRoutes.dashboard,
                      icon: Icons.dashboard_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Game Profiles (Wild Rift / MLBB)',
                      route: AppRoutes.gameProfiles,
                      icon: Icons.sports_esports_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'HUD Settings',
                      route: AppRoutes.settings,
                      icon: Icons.tune_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'API Keys Configuration',
                      route: AppRoutes.apiKeys,
                      icon: Icons.key_outlined,
                      colors: colors,
                    ),
                    _buildRouteTile(
                      context,
                      label: 'Overlay HUD Settings',
                      route: AppRoutes.overlaySettings,
                      icon: Icons.layers_outlined,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTile(
    BuildContext context, {
    required String label,
    required String route,
    required IconData icon,
    required OwlColors colors,
  }) {
    final isCurrent = routeName == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: OwlGlassCard(
        customBorderColor: isCurrent ? colors.accentCyan : colors.borderGlass,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: isCurrent ? null : () => Navigator.of(context).pushNamed(route),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isCurrent ? colors.accentCyan : colors.textSecondary,
            ),
            SpacingTokens.gapH12,
            Expanded(
              child: Text(
                label,
                style: TypographyTokens.bodyMedium.copyWith(
                  color: isCurrent ? colors.accentCyan : colors.textPrimary,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isCurrent)
              const OwlBadge(
                label: 'ACTIVE',
                variant: OwlBadgeVariant.cyan,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
