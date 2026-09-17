// language: Dart, file: settings_assistant_section.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/common/settings_tile_components.dart';
import 'package:owl_design/owl_design.dart';

class SettingsAssistantSection extends StatelessWidget {
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;

  const SettingsAssistantSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
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
          title: 'Tactical Assistant & AI Engine',
          description:
              'Tune your in-match coach intelligence, player role specialization, and real-time vision parsing sensitivity.',
        ),
        const SizedBox(height: 16),

        // Card 1: Core Coaching Controls
        SettingsCard(
          children: [
            SettingsRow(
              title: 'Assistant Mode',
              subtitle:
                  'Choose between live battlefield HUD assistance or post-match replay coaching.',
              trailing: OemSegmentedChips<String>(
                options: const ['off', 'postMatch', 'live'],
                selected: settings.assistantMode,
                labelBuilder: (m) => switch (m) {
                  'postMatch' => 'Post-Match',
                  'off' => 'Off',
                  _ => 'Live Match',
                },
                onSelected: notifier.setAssistantMode,
              ),
            ),
            SettingsRow(
              title: 'Coaching Level',
              subtitle:
                  'Adjusts tactical callout depth for beginner basics or advanced objective wave control.',
              trailing: OemSegmentedChips<String>(
                options: const ['beginner', 'intermediate', 'advanced'],
                selected: settings.coachingLevel,
                labelBuilder: (c) => switch (c) {
                  'beginner' => 'Beginner',
                  'advanced' => 'Advanced',
                  _ => 'Intermediate',
                },
                onSelected: notifier.setCoachingLevel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Role Specialization',
                          style: TypographyTokens.settingsRowTitleOf(context)
                              .copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Keep on Default Auto so the AI detects your role dynamically, or swipe to manually lock a position.',
                          style: TypographyTokens.settingsRowDescOf(context)
                              .copyWith(
                            fontSize: 10.5,
                            color: colors.textPrimary.withValues(alpha: 0.53),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settings.preferredRole == 'auto'
                              ? '✓ Auto-detects Smite / Retribution / Roaming boots from match data.'
                              : '• Fixed role override: ${settings.preferredRole.toUpperCase()} (Manual lock).',
                          style: TypographyTokens.tacticalBadgeOf(context)
                              .copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            color: colors.keyInputText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: OemSegmentedChips<String>(
                        options: const [
                          'auto',
                          'jungle',
                          'mid',
                          'roam',
                          'solo',
                          'adc'
                        ],
                        selected: settings.preferredRole,
                        labelBuilder: (r) => switch (r) {
                          'auto' => 'Auto (Default)',
                          'jungle' => 'Jungle',
                          'mid' => 'Mid',
                          'roam' => 'Roam / Sup',
                          'solo' => 'Solo',
                          'adc' => 'ADC',
                          _ => r,
                        },
                        onSelected: notifier.setPreferredRole,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SettingsRow(
              title: 'Warning Sensitivity',
              subtitle:
                  'Early warnings alert on first fog absence; conservative confirms river vision.',
              trailing: OemSegmentedChips<String>(
                options: const ['conservative', 'balanced', 'earlyWarning'],
                selected: settings.warningSensitivity,
                labelBuilder: (s) => switch (s) {
                  'conservative' => 'Conservative',
                  'earlyWarning' => 'Early Warning',
                  _ => 'Balanced',
                },
                onSelected: notifier.setWarningSensitivity,
              ),
            ),
            SettingsRow(
              title: 'Explain Recommendations',
              subtitle:
                  'Show concise 1-line tactical rationale tag with each alert (e.g. "Enemy ult on 45s CD").',
              trailing: MiuiSwitch(
                value: settings.explainRecommendations,
                onChanged: notifier.toggleExplainRecommendations,
              ),
            ),
          ],
        ),

        // Subheader for Individual Feature Toggles
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            'INDIVIDUAL TACTICAL FEATURE TOGGLES',
            style: TypographyTokens.sectionLabelOf(context).copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary.withValues(alpha: 0.45),
              letterSpacing: 0.6,
            ),
          ),
        ),

        // Card 2: Feature Toggles
        SettingsCard(
          children: [
            SettingsRow(
              title: 'Guardian AI Screen Vision',
              subtitle:
                  'Allow Guardian AI to capture transient gameplay frames to visually detect your hero, battle spells, and minimap.',
              trailing: MiuiSwitch(
                value: settings.guardianVisionEnabled,
                onChanged: notifier.toggleGuardianVisionEnabled,
              ),
            ),
            SettingsRow(
              title: 'Missing-Enemy Warnings',
              subtitle:
                  'Alert when enemy mid or jungler disappears from vision for >3s.',
              trailing: MiuiSwitch(
                value: settings.missingEnemyAlerts,
                onChanged: notifier.toggleMissingEnemyAlerts,
              ),
            ),
            SettingsRow(
              title: 'Overextension & Gank Risk Radar',
              subtitle:
                  'Tactical pulse when pushing past enemy river without ward vision.',
              trailing: MiuiSwitch(
                value: settings.overextensionRadar,
                onChanged: notifier.toggleOverextensionRadar,
              ),
            ),
            SettingsRow(
              title: 'Objective Rings & Smite Timers',
              subtitle:
                  'Countdown timer indicators for Dragon, Baron, Turtle, and Lord spawns.',
              trailing: MiuiSwitch(
                value: settings.objectiveTimers,
                onChanged: notifier.toggleObjectiveTimers,
              ),
            ),
            SettingsRow(
              title: 'Lane Wave Management Advice',
              subtitle:
                  'Smart tips to freeze, slow push, or crash waves based on recall state.',
              trailing: MiuiSwitch(
                value: settings.laneWaveAdvice,
                onChanged: notifier.toggleLaneWaveAdvice,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
