// language: Dart, file: gpu_settings_two_pane_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Xiaomi Game Turbo Two-Pane Selected Game GPU Settings Screen.
///
/// Configures hardware graphics, touch sampling, and per-game tactical AI modules
/// for the selected game title. All options persist in the global GPU profile
/// of [GameTurboSettingsNotifier] and survive app restarts.
class GpuSettingsTwoPaneScreen extends ConsumerStatefulWidget {
  const GpuSettingsTwoPaneScreen({
    super.key,
    this.gameTitle = 'Mobile Legends: Bang Bang',
  });

  final String gameTitle;

  @override
  ConsumerState<GpuSettingsTwoPaneScreen> createState() =>
      _GpuSettingsTwoPaneScreenState();
}

enum GpuSettingCategory {
  graphics('Graphic Quality'),
  display('Display & Colors'),
  touch('Touch Controls'),
  tacticalAi('Tactical AI Modules');

  const GpuSettingCategory(this.label);
  final String label;
}

class _GpuSettingsTwoPaneScreenState
    extends ConsumerState<GpuSettingsTwoPaneScreen> {
  GpuSettingCategory _selectedCategory = GpuSettingCategory.graphics;

  void _resetDefaults() {
    HapticFeedback.mediumImpact();
    ref.read(gameTurboSettingsProvider.notifier).resetGpuSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.consoleBase,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: OwlAtmosphericBackground()),
          SafeArea(
            left: false,
            right: false,
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context),

                // Two-Pane Content
                Expanded(
                child: Row(
                  children: [
                    // Left Category Sidebar
                    _buildCategorySidebar(),

                    // Vertical Separator
                    Container(
                      width: 1,
                      color: colors.textPrimary.withValues(alpha: 0.08),
                    ),

                    // Right Content Pane
                    Expanded(child: _buildContentPane()),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceCard.withValues(alpha: 0.92)
            : colors.settingsPanel.withValues(alpha: 0.75),
        border: Border(
          bottom: BorderSide(
            color: colors.isLight
                ? colors.borderGlass.withValues(alpha: 1.0)
                : colors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 16, color: colors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Text(
            'GPU settings — ${widget.gameTitle}',
            style: TypographyTokens.titleSmallOf(context).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetDefaults,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Reset Default',
              style: TypographyTokens.statusMicroOf(context).copyWith(
                fontWeight: FontWeight.w700,
                color: colors.turboBlueLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    final colors = ColorTokens.of(context);
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceElevated.withValues(alpha: 0.85)
            : colors.settingsCard.withValues(alpha: 0.6),
        border: Border(
          right: BorderSide(
            color: colors.isLight
                ? colors.borderGlass.withValues(alpha: 0.8)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: GpuSettingCategory.values.map((cat) {
          final isSelected = cat == _selectedCategory;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? (colors.isLight
                        ? colors.turboBlue.withValues(alpha: 0.12)
                        : ColorPrimitives.selectBlue12)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? colors.turboBlue : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                cat.label,
                style: TypographyTokens.titleSmallOf(context).copyWith(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colors.textPrimary
                      : colors.textPrimary.withValues(alpha: 0.54),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentPane() {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);
    switch (_selectedCategory) {
      case GpuSettingCategory.graphics:
        return _buildGraphicsSettings(settings, notifier);
      case GpuSettingCategory.display:
        return _buildDisplaySettings(settings, notifier);
      case GpuSettingCategory.touch:
        return _buildTouchSettings(settings, notifier);
      case GpuSettingCategory.tacticalAi:
        return _buildTacticalAiSettings(settings, notifier);
    }
  }

  Widget _buildGraphicsSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
      children: [
        _buildSettingRow(
          title: 'Target Frame Rate Cap',
          subtitle: 'Enforce hardware GPU VSync refresh rate threshold for maximum fluid motion.',
          control: OemSegmentedChips<String>(
            options: const ['60', '90', '120', 'Max'],
            selected: settings.gpuFpsTarget,
            onSelected: notifier.setGpuFpsTarget,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Render Resolution Scale',
          subtitle: 'Render internal 3D scene at native or upscaled OLED panel resolution.',
          control: OemSegmentedChips<String>(
            options: const ['720p', '1080p', '2K'],
            selected: settings.gpuResolution,
            onSelected: notifier.setGpuResolution,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Multi-Sample Anti-Aliasing (MSAA)',
          subtitle: 'Smooth out polygon jagged edges on champion models and map terrain.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '2X', '4X'],
            selected: settings.gpuMsaa,
            onSelected: notifier.setGpuMsaa,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Anisotropic Texture Filtering',
          subtitle: 'Sharpen distant ground textures, lane markers, and river beds at oblique angles.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '4X', '8X', '16X'],
            selected: settings.gpuAniso,
            onSelected: notifier.setGpuAniso,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
      children: [
        _buildSettingRow(
          title: 'Color Grading Profile',
          subtitle: 'Apply hardware post-processing shaders for tactical combat clarity.',
          control: OemSegmentedChips<String>(
            options: const ['Original', 'Vibrant HDR', 'Bush Contrast'],
            selected: settings.gpuColorStyle,
            onSelected: notifier.setGpuColorStyle,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Dynamic Shadow & Bush Contrast',
          subtitle: 'Boost luminance in neutral jungle brushes to spot ambushes instantly.',
          control: MiuiSwitch(
            value: settings.gpuDynamicContrast,
            onChanged: notifier.toggleGpuDynamicContrast,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Horizon Sunlight Brightness Boost',
          subtitle: 'Keep panel backlight stable during intense outdoor sunlight gaming.',
          control: MiuiSwitch(
            value: settings.gpuHorizonBrightness,
            onChanged: notifier.toggleGpuHorizonBrightness,
          ),
        ),
      ],
    );
  }

  Widget _buildTouchSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
      children: [
        _buildSettingRow(
          title: 'Touch Response Sampling Rate',
          subtitle: 'Ultra-fast touch polling rate for instantaneous skill shot actuation.',
          control: OemSegmentedChips<String>(
            options: const ['240Hz', '480Hz', '720Hz Ultra'],
            selected: settings.gpuTouchSampling,
            onSelected: notifier.setGpuTouchSampling,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Aiming & Skill Shot Precision',
          subtitle: 'Fine-tune micro-drag touch sensitivity for skill indicator reticles.',
          control: OemSegmentedChips<String>(
            options: const ['Default', 'Balanced', 'Extreme'],
            selected: settings.gpuSkillPrecision,
            onSelected: notifier.setGpuSkillPrecision,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Edge Mistouch Rejection Area',
          subtitle: 'Ignore accidental palm contact along phone bezels during clutch teamfights.',
          control: OemSegmentedChips<String>(
            options: const ['Small', 'Medium', 'Large'],
            selected: settings.gpuMistouchRejection,
            onSelected: notifier.setGpuMistouchRejection,
          ),
        ),
      ],
    );
  }

  Widget _buildTacticalAiSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
      children: [
        _buildSettingRow(
          title: 'Minimap Threat Radar',
          subtitle: 'Auto-highlight enemy jungler and mid laner gank trajectories with missing timers.',
          control: MiuiSwitch(
            value: settings.gpuThreatRadar,
            onChanged: notifier.toggleGpuThreatRadar,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Turtle & Lord Spawn Countdown Rings',
          subtitle: 'Circular countdown rings in top-right showing objective respawn windows.',
          control: MiuiSwitch(
            value: settings.gpuObjectiveRings,
            onChanged: notifier.toggleGpuObjectiveRings,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Retribution / Smite Execution Threshold',
          subtitle: 'Overlay exact true-damage health bar threshold mark on epic monsters.',
          control: MiuiSwitch(
            value: settings.gpuSmiteThreshold,
            onChanged: notifier.toggleGpuSmiteThreshold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: ColorTokens.of(context).textPrimary.withValues(alpha: 0.08),
    );
  }
}
