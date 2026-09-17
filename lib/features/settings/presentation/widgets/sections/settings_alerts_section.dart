import 'package:flutter/material.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/common/settings_tile_components.dart';
import 'package:owl_design/owl_design.dart';

class SettingsAlertsSection extends StatelessWidget {
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;
  final VoidCallback onTriggerTestCallout;

  const SettingsAlertsSection({
    super.key,
    required this.settings,
    required this.notifier,
    required this.onTriggerTestCallout,
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
          title: 'Voice Callouts & Haptic Alerts',
          description:
              'Manage speech synthesis callouts, non-intrusive priority filtering, and tactile feedback.',
        ),
        const SizedBox(height: 16),
        SettingsCard(
          children: [
            // Master Voice Alerts
            SettingsRow(
              title: 'Spoken Voice Alerts (TTS)',
              subtitle:
                  'Synthesized voice callouts for critical tactical combat events.',
              trailing: MiuiSwitch(
                value: settings.voiceAlertsEnabled,
                onChanged: notifier.toggleVoiceAlerts,
              ),
            ),

            // Priority Filter
            SettingsRow(
              title: 'Voice Alert Priority',
              subtitle:
                  'Critical-only limits speech to urgent ganks while keeping macro advice visual.',
              trailing: OemSegmentedChips<String>(
                options: const ['criticalOnly', 'important', 'allAlerts'],
                selected: settings.alertPriority,
                labelBuilder: (p) => switch (p) {
                  'important' => 'Important',
                  'allAlerts' => 'All Alerts',
                  _ => 'Critical Only',
                },
                onSelected: notifier.setAlertPriority,
              ),
            ),

            // Speech Cooldown Buffer Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speech Cooldown Buffer',
                          style: TypographyTokens.settingsRowTitleOf(context)
                              .copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Minimum cooldown pause between spoken callouts to prevent audio clutter.',
                          style: TypographyTokens.settingsRowDescOf(context)
                              .copyWith(
                            fontSize: 10.5,
                            color: colors.textPrimary.withValues(alpha: 0.53),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${settings.speechCooldownSeconds}s',
                    style: TypographyTokens.tacticalValue.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.keyInputText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ColorTokens.turboBlue,
                        inactiveTrackColor:
                            colors.textPrimary.withValues(alpha: 0.2),
                        thumbColor: colors.textPrimary,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: settings.speechCooldownSeconds.toDouble(),
                        min: 3,
                        max: 20,
                        divisions: 17,
                        onChanged: (v) =>
                            notifier.setSpeechCooldownSeconds(v.round()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Audio Ducking Safety
            SettingsRow(
              title: 'Avoid Interrupting Game Audio',
              subtitle:
                  'Maintains game footstep and skill cues without system volume ducking.',
              trailing: MiuiSwitch(
                value: settings.avoidInterruptingGameAudio,
                onChanged: notifier.toggleAvoidInterruptingGameAudio,
              ),
            ),

            // Haptics
            SettingsRow(
              title: 'Haptic Vibration Pulse',
              subtitle:
                  'Double tactile feedback on objective steal thresholds and ambush alerts.',
              trailing: MiuiSwitch(
                value: settings.hapticsEnabled,
                onChanged: notifier.toggleHaptics,
              ),
            ),

            // Test Alert Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Voice & Haptic Alert',
                          style: TypographyTokens.settingsRowTitleOf(context)
                              .copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Simulate a live tactical callout banner and test vibration pulse.',
                          style: TypographyTokens.settingsRowDescOf(context)
                              .copyWith(
                            fontSize: 10.5,
                            color: colors.textPrimary.withValues(alpha: 0.53),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.play, size: 12),
                    label: Text(
                      'Play Test',
                      style: TypographyTokens.buttonTextOf(context)
                          .copyWith(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          ColorTokens.turboBlue.withValues(alpha: 0.14),
                      foregroundColor: colors.turboCyan,
                      side: BorderSide(
                        color: ColorTokens.turboBlue.withValues(alpha: 0.33),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTriggerTestCallout,
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
