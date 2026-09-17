// language: Dart, file: settings_tile_components.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';
import 'package:owl_design/owl_design.dart';

/// Reusable section pane header with title and description.
class SettingsPaneHeader extends StatelessWidget {
  final String title;
  final String description;

  const SettingsPaneHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TypographyTokens.dialogTitleOf(context).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TypographyTokens.settingsRowDescOf(context).copyWith(
            color: colors.textPrimary.withValues(alpha: 0.58),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Reusable container card wrapping a list of setting rows.
class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceCard.withValues(alpha: 0.95)
            : colors.settingsCard.withValues(alpha: 0.8),
        borderRadius: RadiusTokens.card,
        border: Border.all(
          color: colors.borderGlass,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.isLight
                ? colors.textPrimary.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: RadiusTokens.card,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.textPrimary.withValues(alpha: 0.08),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Single interactive setting row with label, subtitle, and trailing control.
class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: RadiusTokens.button,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TypographyTokens.settingsRowTitleOf(context).copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TypographyTokens.settingsRowDescOf(context).copyWith(
                        fontSize: 10.5,
                        color: colors.textPrimary.withValues(alpha: 0.53),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 14),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable telemetry metric column with value and colored accent.
class SettingsTelemetryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const SettingsTelemetryColumn({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TypographyTokens.tacticalBadgeOf(context).copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary.withValues(alpha: 0.45),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TypographyTokens.displayTimerSmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
