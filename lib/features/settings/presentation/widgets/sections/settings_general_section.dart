import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/common/settings_tile_components.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';

class SettingsGeneralSection extends ConsumerWidget {
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;
  final VoidCallback onResetDefaults;

  const SettingsGeneralSection({
    super.key,
    required this.settings,
    required this.notifier,
    required this.onResetDefaults,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        22 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const SettingsPaneHeader(
          title: 'General Preferences',
          description:
              'Manage theme mode, launch behavior, interface display localization, and profile factory resets.',
        ),
        const SizedBox(height: 16),
        SettingsCard(
          children: [
            // Theme Mode
            SettingsRow(
              title: 'App Theme',
              subtitle:
                  'Choose system default matching device OS, light mode, or forced dark MOBA theme.',
              trailing: OemSegmentedChips<ThemeMode>(
                options: const [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark,
                ],
                selected: ref.watch(themeModeProvider),
                labelBuilder: (m) => switch (m) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                },
                onSelected: (mode) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(mode),
              ),
            ),

            // Interface Language
            SettingsRow(
              title: 'Interface Display Language',
              subtitle:
                  'Controls on-screen text and settings labels. Assistant voice language remains separate in Alerts tab.',
              trailing: OemSegmentedChips<String>(
                options: const ['en', 'es', 'id', 'tl', 'vi'],
                selected: settings.interfaceLanguage,
                labelBuilder: (l) => switch (l) {
                  'es' => 'Español',
                  'id' => 'Bahasa',
                  'tl' => 'Tagalog',
                  'vi' => 'Tiếng Việt',
                  _ => 'English (US)',
                },
                onSelected: notifier.setInterfaceLanguage,
              ),
            ),

            // Reset All Settings Row
            Container(
              color: colors.alertCrimson.withValues(alpha: 0.03),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reset All Settings',
                          style: TypographyTokens.settingsRowTitleOf(context)
                              .copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colors.telemetryCritical,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Clear all custom role configurations, thresholds, and restore factory defaults.',
                          style: TypographyTokens.settingsRowDescOf(context)
                              .copyWith(
                            fontSize: 10.5,
                            color: colors.textPrimary.withValues(alpha: 0.53),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: Icon(
                      LucideIcons.rotateCcw,
                      size: 13,
                      color: colors.telemetryCritical,
                    ),
                    label: Text(
                      'Reset to Factory Defaults',
                      style: TypographyTokens.dialogActionOf(context).copyWith(
                        fontSize: 11,
                        color: colors.telemetryCritical,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: colors.alertCrimson.withValues(alpha: 0.33),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onResetDefaults,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
