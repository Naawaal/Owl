// language: Dart, file: gpu_settings_content_pane.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

class GpuSettingsContentPane extends StatelessWidget {
  final GpuSettingCategory category;
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;

  const GpuSettingsContentPane({
    super.key,
    required this.category,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case GpuSettingCategory.graphics:
        return _buildGraphicsSettings(context);
      case GpuSettingCategory.display:
        return _buildDisplaySettings(context);
      case GpuSettingCategory.touch:
        return _buildTouchSettings(context);
      case GpuSettingCategory.tacticalAi:
        return _buildTacticalAiSettings(context);
    }
  }

  Widget _buildGraphicsSettings(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _buildSettingRow(
          context: context,
          title: 'Target Frame Rate Cap',
          subtitle:
              'Enforce hardware GPU VSync refresh rate threshold for maximum fluid motion.',
          control: OemSegmentedChips<String>(
            options: const ['60', '90', '120', 'Max'],
            selected: settings.gpuFpsTarget,
            onSelected: notifier.setGpuFpsTarget,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Render Resolution Scale',
          subtitle:
              'Render internal 3D scene at native or upscaled OLED panel resolution.',
          control: OemSegmentedChips<String>(
            options: const ['720p', '1080p', '2K'],
            selected: settings.gpuResolution,
            onSelected: notifier.setGpuResolution,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Multi-Sample Anti-Aliasing (MSAA)',
          subtitle:
              'Smooth out polygon jagged edges on champion models and map terrain.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '2X', '4X'],
            selected: settings.gpuMsaa,
            onSelected: notifier.setGpuMsaa,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Anisotropic Texture Filtering',
          subtitle:
              'Sharpen distant ground textures, lane markers, and river beds at oblique angles.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '4X', '8X', '16X'],
            selected: settings.gpuAniso,
            onSelected: notifier.setGpuAniso,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _buildSettingRow(
          context: context,
          title: 'Color Grading Profile',
          subtitle:
              'Apply hardware post-processing shaders for tactical combat clarity.',
          control: OemSegmentedChips<String>(
            options: const ['Original', 'Vibrant HDR', 'Bush Contrast'],
            selected: settings.gpuColorStyle,
            onSelected: notifier.setGpuColorStyle,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Dynamic Shadow & Bush Contrast',
          subtitle:
              'Boost luminance in neutral jungle brushes to spot ambushes instantly.',
          control: MiuiSwitch(
            value: settings.gpuDynamicContrast,
            onChanged: notifier.toggleGpuDynamicContrast,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Horizon Sunlight Brightness Boost',
          subtitle:
              'Keep panel backlight stable during intense outdoor sunlight gaming.',
          control: MiuiSwitch(
            value: settings.gpuHorizonBrightness,
            onChanged: notifier.toggleGpuHorizonBrightness,
          ),
        ),
      ],
    );
  }

  Widget _buildTouchSettings(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _buildSettingRow(
          context: context,
          title: 'Touch Response Sampling Rate',
          subtitle:
              'Ultra-fast touch polling rate for instantaneous skill shot actuation.',
          control: OemSegmentedChips<String>(
            options: const ['240Hz', '480Hz', '720Hz Ultra'],
            selected: settings.gpuTouchSampling,
            onSelected: notifier.setGpuTouchSampling,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Aiming & Skill Shot Precision',
          subtitle:
              'Fine-tune micro-drag touch sensitivity for skill indicator reticles.',
          control: OemSegmentedChips<String>(
            options: const ['Default', 'Balanced', 'Extreme'],
            selected: settings.gpuSkillPrecision,
            onSelected: notifier.setGpuSkillPrecision,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Edge Mistouch Rejection Area',
          subtitle:
              'Ignore accidental palm contact along phone bezels during clutch teamfights.',
          control: OemSegmentedChips<String>(
            options: const ['Small', 'Medium', 'Large'],
            selected: settings.gpuMistouchRejection,
            onSelected: notifier.setGpuMistouchRejection,
          ),
        ),
      ],
    );
  }

  Widget _buildTacticalAiSettings(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _buildSettingRow(
          context: context,
          title: 'Minimap Threat Radar',
          subtitle:
              'Auto-highlight enemy jungler and mid laner gank trajectories with missing timers.',
          control: MiuiSwitch(
            value: settings.gpuThreatRadar,
            onChanged: notifier.toggleGpuThreatRadar,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Turtle & Lord Spawn Countdown Rings',
          subtitle:
              'Circular countdown rings in top-right showing objective respawn windows.',
          control: MiuiSwitch(
            value: settings.gpuObjectiveRings,
            onChanged: notifier.toggleGpuObjectiveRings,
          ),
        ),
        _buildDivider(context),
        _buildSettingRow(
          context: context,
          title: 'Retribution / Smite Execution Threshold',
          subtitle:
              'Overlay exact true-damage health bar threshold mark on epic monsters.',
          control: MiuiSwitch(
            value: settings.gpuSmiteThreshold,
            onChanged: notifier.toggleGpuSmiteThreshold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget control,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TypographyTokens.settingsRowDescOf(context).copyWith(
                    fontSize: 10,
                    color: ColorTokens.of(context)
                        .textPrimary
                        .withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: ColorTokens.of(context).textPrimary.withValues(alpha: 0.08),
    );
  }
}
