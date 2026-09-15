// language: Dart, file: gpu_settings_two_pane_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Xiaomi Game Turbo Two-Pane Selected Game GPU Settings Screen.
///
/// Configures hardware graphics, touch sampling, and per-game tactical AI modules
/// for the selected game title.
class GpuSettingsTwoPaneScreen extends StatefulWidget {
  const GpuSettingsTwoPaneScreen({
    super.key,
    this.gameTitle = 'Mobile Legends: Bang Bang',
  });

  final String gameTitle;

  @override
  State<GpuSettingsTwoPaneScreen> createState() => _GpuSettingsTwoPaneScreenState();
}

enum GpuSettingCategory {
  graphics('Graphic Quality'),
  display('Display & Colors'),
  touch('Touch Controls'),
  tacticalAi('Tactical AI Modules');

  const GpuSettingCategory(this.label);
  final String label;
}

class _GpuSettingsTwoPaneScreenState extends State<GpuSettingsTwoPaneScreen> {
  GpuSettingCategory _selectedCategory = GpuSettingCategory.graphics;

  // Graphics state
  String _fpsTarget = '120';
  String _resolution = '1080p';
  String _msaa = '4X';
  String _aniso = '8X';

  // Display state
  String _colorStyle = 'Vibrant HDR';
  bool _dynamicContrast = true;
  bool _horizonBrightness = true;

  // Touch state
  String _touchSampling = '720Hz Ultra';
  String _skillPrecision = 'Extreme';
  String _mistouchRejection = 'Medium';

  // Tactical AI state
  bool _threatRadar = true;
  bool _objectiveRings = true;
  bool _smiteThreshold = true;

  void _resetDefaults() {
    HapticFeedback.mediumImpact();
    setState(() {
      _fpsTarget = '120';
      _resolution = '1080p';
      _msaa = '4X';
      _aniso = '8X';
      _colorStyle = 'Vibrant HDR';
      _dynamicContrast = true;
      _horizonBrightness = true;
      _touchSampling = '720Hz Ultra';
      _skillPrecision = 'Extreme';
      _mistouchRejection = 'Medium';
      _threatRadar = true;
      _objectiveRings = true;
      _smiteThreshold = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C13),
      body: SafeArea(
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
                  Container(width: 1, color: const Color(0x14FFFFFF)),

                  // Right Content Pane
                  Expanded(child: _buildContentPane()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0E121A),
        border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Text(
            'GPU settings — ${widget.gameTitle}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
            child: const Text(
              'Reset Default',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: ColorSemantics.turboBlueLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return SizedBox(
      width: 180,
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
                color: isSelected ? const Color(0x1A007AFF) : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? ColorSemantics.turboBlue : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0x8AFFFFFF),
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
    switch (_selectedCategory) {
      case GpuSettingCategory.graphics:
        return _buildGraphicsSettings();
      case GpuSettingCategory.display:
        return _buildDisplaySettings();
      case GpuSettingCategory.touch:
        return _buildTouchSettings();
      case GpuSettingCategory.tacticalAi:
        return _buildTacticalAiSettings();
    }
  }

  Widget _buildGraphicsSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Target Frame Rate Cap',
          subtitle: 'Enforce hardware GPU VSync refresh rate threshold for maximum fluid motion.',
          control: OemSegmentedChips<String>(
            options: const ['60', '90', '120', 'Max'],
            selected: _fpsTarget,
            onSelected: (val) => setState(() => _fpsTarget = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Render Resolution Scale',
          subtitle: 'Render internal 3D scene at native or upscaled OLED panel resolution.',
          control: OemSegmentedChips<String>(
            options: const ['720p', '1080p', '2K'],
            selected: _resolution,
            onSelected: (val) => setState(() => _resolution = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Multi-Sample Anti-Aliasing (MSAA)',
          subtitle: 'Smooth out polygon jagged edges on champion models and map terrain.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '2X', '4X'],
            selected: _msaa,
            onSelected: (val) => setState(() => _msaa = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Anisotropic Texture Filtering',
          subtitle: 'Sharpen distant ground textures, lane markers, and river beds at oblique angles.',
          control: OemSegmentedChips<String>(
            options: const ['Off', '4X', '8X', '16X'],
            selected: _aniso,
            onSelected: (val) => setState(() => _aniso = val),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Color Grading Profile',
          subtitle: 'Apply hardware post-processing shaders for tactical combat clarity.',
          control: OemSegmentedChips<String>(
            options: const ['Original', 'Vibrant HDR', 'Bush Contrast'],
            selected: _colorStyle,
            onSelected: (val) => setState(() => _colorStyle = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Dynamic Shadow & Bush Contrast',
          subtitle: 'Boost luminance in neutral jungle brushes to spot ambushes instantly.',
          control: MiuiSwitch(
            value: _dynamicContrast,
            onChanged: (val) => setState(() => _dynamicContrast = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Horizon Sunlight Brightness Boost',
          subtitle: 'Keep panel backlight stable during intense outdoor sunlight gaming.',
          control: MiuiSwitch(
            value: _horizonBrightness,
            onChanged: (val) => setState(() => _horizonBrightness = val),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Touch Response Sampling Rate',
          subtitle: 'Ultra-fast touch polling rate for instantaneous skill shot actuation.',
          control: OemSegmentedChips<String>(
            options: const ['240Hz', '480Hz', '720Hz Ultra'],
            selected: _touchSampling,
            onSelected: (val) => setState(() => _touchSampling = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Aiming & Skill Shot Precision',
          subtitle: 'Fine-tune micro-drag touch sensitivity for skill indicator reticles.',
          control: OemSegmentedChips<String>(
            options: const ['Default', 'Balanced', 'Extreme'],
            selected: _skillPrecision,
            onSelected: (val) => setState(() => _skillPrecision = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Edge Mistouch Rejection Area',
          subtitle: 'Ignore accidental palm contact along phone bezels during clutch teamfights.',
          control: OemSegmentedChips<String>(
            options: const ['Small', 'Medium', 'Large'],
            selected: _mistouchRejection,
            onSelected: (val) => setState(() => _mistouchRejection = val),
          ),
        ),
      ],
    );
  }

  Widget _buildTacticalAiSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Minimap Threat Radar',
          subtitle: 'Auto-highlight enemy jungler and mid laner gank trajectories with missing timers.',
          control: MiuiSwitch(
            value: _threatRadar,
            onChanged: (val) => setState(() => _threatRadar = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Turtle & Lord Spawn Countdown Rings',
          subtitle: 'Circular countdown rings in top-right showing objective respawn windows.',
          control: MiuiSwitch(
            value: _objectiveRings,
            onChanged: (val) => setState(() => _objectiveRings = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Retribution / Smite Execution Threshold',
          subtitle: 'Overlay exact true-damage health bar threshold mark on epic monsters.',
          control: MiuiSwitch(
            value: _smiteThreshold,
            onChanged: (val) => setState(() => _smiteThreshold = val),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99FFFFFF),
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
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x14FFFFFF),
    );
  }
}
