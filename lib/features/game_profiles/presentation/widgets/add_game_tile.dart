// language: Dart, file: add_game_tile.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// App tile in the Add Games dialog featuring icon, package metadata, and toggle switch.
class AddGameTile extends StatelessWidget {
  const AddGameTile({
    super.key,
    required this.app,
    required this.isEnabled,
    required this.onChanged,
  });

  final InstalledGame app;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);

    return Row(
      children: [
        // App Icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: LinearGradient(
              colors: [
                colors.isLight ? colors.surfaceElevated : colors.horizonBottom,
                colors.isLight ? colors.surfaceCard : colors.consoleBase,
              ],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: app.iconBytes != null
              ? Image.memory(
                  app.iconBytes!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.sports_esports_outlined,
                  size: 20,
                  color: colors.textSecondary,
                ),
        ),
        const SizedBox(width: 12),

        // Title & Package
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.titleSmallOf(context).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                app.packageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.bodySmallOf(context).copyWith(
                  fontSize: 10,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // MIUI Switch Toggle
        MiuiSwitch(
          value: isEnabled,
          onChanged: (val) {
            HapticHelper.selectionClick();
            onChanged(val);
          },
        ),
      ],
    );
  }
}
