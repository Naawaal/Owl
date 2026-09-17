// language: Dart, file: settings_performance_section.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/coach_service.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/common/settings_tile_components.dart';
import 'package:owl_design/owl_design.dart';

class SettingsPerformanceSection extends ConsumerWidget {
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;

  const SettingsPerformanceSection({
    super.key,
    required this.settings,
    required this.notifier,
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
          title: 'Hardware Footprint & Adaptive Throttling',
          description:
              'Scale tactical engine resource consumption and configure emergency thermal safeguards.',
        ),
        const SizedBox(height: 16),
        SettingsCard(
          children: [
            // Workload Profile
            SettingsRow(
              title: 'Companion Workload Profile',
              subtitle:
                  'Controls assistant frame sampling frequency and battery efficiency.',
              trailing: OemSegmentedChips<String>(
                options: const ['saver', 'balanced', 'high'],
                selected: settings.performanceMode,
                labelBuilder: (p) => switch (p) {
                  'saver' => 'Battery Saver (1 FPS)',
                  'high' => 'High (12 FPS)',
                  _ => 'Balanced (5 FPS)',
                },
                onSelected: notifier.setPerformanceMode,
              ),
            ),

            // Adaptive Workload
            SettingsRow(
              title: 'Adaptive Workload Throttling',
              subtitle:
                  'Automatically reduce frame sampling during base recalls and passive farming.',
              trailing: MiuiSwitch(
                value: settings.adaptiveWorkload,
                onChanged: notifier.toggleAdaptiveWorkload,
              ),
            ),

            // Thermal Protection
            SettingsRow(
              title: 'Thermal Stress Protection',
              subtitle:
                  'Step down analysis frequency if battery temperature exceeds 41°C.',
              trailing: MiuiSwitch(
                value: settings.thermalProtection,
                onChanged: notifier.toggleThermalProtection,
              ),
            ),

            // In-game Latency HUD
            SettingsRow(
              title: 'Show In-Game Latency HUD',
              subtitle:
                  'Display live inference latency (ms) beside the in-game floating handle.',
              trailing: MiuiSwitch(
                value: settings.showInGameLatencyHud,
                onChanged: notifier.toggleShowInGameLatencyHud,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Telemetry Diagnostics Box
        Builder(
          builder: (context) {
            final coachAsync = ref.watch(coachServiceProvider);
            final lastLatency =
                ref.read(coachServiceProvider.notifier).lastLatencyMs;
            final stats = ref.watch(systemStatsProvider).valueOrNull;

            final latencyLabel = lastLatency != null
                ? '$lastLatency ms'
                : (coachAsync.isLoading ? 'Pinging…' : 'Ready');

            final thermalTemp = stats?.temperatureCelsius != null
                ? stats!.temperatureCelsius!.toStringAsFixed(1)
                : null;
            final ramMb = stats?.ramUsedMb;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SettingsTelemetryColumn(
                    label: 'Cloud Latency',
                    value: latencyLabel,
                    color: colors.turboCyan,
                  ),
                  SettingsTelemetryColumn(
                    label: 'Sampling Rate',
                    value: settings.performanceMode == 'high'
                        ? '12.0 FPS'
                        : settings.performanceMode == 'saver'
                            ? '1.0 FPS'
                            : '5.0 FPS',
                    color: colors.emeraldLive,
                  ),
                  SettingsTelemetryColumn(
                    label: 'Thermal State',
                    value: thermalTemp != null ? '$thermalTemp°C' : '--',
                    color: colors.emeraldLive,
                  ),
                  SettingsTelemetryColumn(
                    label: 'RAM Footprint',
                    value: ramMb != null ? '$ramMb MB' : '--',
                    color: colors.textPrimary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
