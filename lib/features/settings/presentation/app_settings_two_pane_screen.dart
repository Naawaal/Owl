// language: Dart, file: app_settings_two_pane_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Xiaomi HyperOS Game Turbo Two-Pane Global App Settings Screen.
///
/// Implements a categorized two-column landscape view:
/// - Left Sidebar: Category navigation (General, Performance, DND, AI Core)
/// - Right Pane: Setting rows with title, description, and [MiuiSwitch] controls.
class AppSettingsTwoPaneScreen extends StatefulWidget {
  const AppSettingsTwoPaneScreen({super.key});

  @override
  State<AppSettingsTwoPaneScreen> createState() => _AppSettingsTwoPaneScreenState();
}

enum AppSettingCategory {
  general('General settings'),
  performance('Performance mode'),
  dnd('Game DND'),
  guardianAi('Guardian AI Core');

  const AppSettingCategory(this.label);
  final String label;
}

class _AppSettingsTwoPaneScreenState extends State<AppSettingsTwoPaneScreen> {
  AppSettingCategory _selectedCategory = AppSettingCategory.general;

  // General Settings State
  bool _gameTurboMaster = true;
  bool _inGameShortcuts = true;
  String _shortcutEdge = 'Left';

  // Performance Settings State
  bool _perfOptimization = true;
  bool _wifiBoost = true;
  bool _touchBoost = true;
  bool _audioEnhance = false;

  // DND Settings State
  bool _restrictFloating = true;
  bool _silenceCalls = true;
  bool _lockGestures = false;

  // Guardian AI Settings State
  bool _guardianEngine = true;
  bool _tacticalVoice = true;
  bool _missingRadar = true;

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
          const Text(
            'Game Turbo Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x1A007AFF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ColorSemantics.turboBlue.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'HYPEROS 6.0',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: ColorSemantics.turboBlueLight,
                letterSpacing: 0.5,
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
        children: AppSettingCategory.values.map((cat) {
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
      case AppSettingCategory.general:
        return _buildGeneralSettings();
      case AppSettingCategory.performance:
        return _buildPerformanceSettings();
      case AppSettingCategory.dnd:
        return _buildDndSettings();
      case AppSettingCategory.guardianAi:
        return _buildGuardianAiSettings();
    }
  }

  Widget _buildGeneralSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Game Turbo Master Engine',
          subtitle: 'Improve game experience with hardware-level optimization and background cooling.',
          control: MiuiSwitch(
            value: _gameTurboMaster,
            onChanged: (val) => setState(() => _gameTurboMaster = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'In-Game Floating Shortcuts',
          subtitle: 'Swipe from the edge of the screen to open the Game Turbo floating toolbox.',
          control: MiuiSwitch(
            value: _inGameShortcuts,
            onChanged: (val) => setState(() => _inGameShortcuts = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Shortcut Edge Position',
          subtitle: 'Choose which side of the screen displays the floating trigger handle.',
          control: OemSegmentedChips<String>(
            options: const ['Left', 'Right'],
            selected: _shortcutEdge,
            onSelected: (val) => setState(() => _shortcutEdge = val),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Performance Optimization',
          subtitle: 'Automatically adjust clock frequencies to maintain stable frame rates.',
          control: MiuiSwitch(
            value: _perfOptimization,
            onChanged: (val) => setState(() => _perfOptimization = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Wi-Fi Speed Boost',
          subtitle: 'Reduce latency by 10-20ms via low-latency dual-band Wi-Fi routing.',
          control: MiuiSwitch(
            value: _wifiBoost,
            onChanged: (val) => setState(() => _wifiBoost = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Touch Response Acceleration',
          subtitle: 'Prioritize screen touch events to achieve instant skill actuation.',
          control: MiuiSwitch(
            value: _touchBoost,
            onChanged: (val) => setState(() => _touchBoost = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Spatial Audio Enhancement',
          subtitle: 'Amplify footsteps and ambush audio cues during live match combat.',
          control: MiuiSwitch(
            value: _audioEnhance,
            onChanged: (val) => setState(() => _audioEnhance = val),
          ),
        ),
      ],
    );
  }

  Widget _buildDndSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Restrict Floating Notifications',
          subtitle: 'Block banners, heads-up notifications, and floating app popups during combat.',
          control: MiuiSwitch(
            value: _restrictFloating,
            onChanged: (val) => setState(() => _restrictFloating = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Silence Incoming Calls',
          subtitle: 'Mute phone ringtones while gaming and auto-reject unknown calls.',
          control: MiuiSwitch(
            value: _silenceCalls,
            onChanged: (val) => setState(() => _silenceCalls = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Lock System Navigation Gestures',
          subtitle: 'Require double-swipe to exit full-screen to prevent accidental home trigger.',
          control: MiuiSwitch(
            value: _lockGestures,
            onChanged: (val) => setState(() => _lockGestures = val),
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianAiSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Guardian Tactical AI Engine',
          subtitle: 'Run local on-device tactical analysis for dragon timers and gank alerts.',
          control: MiuiSwitch(
            value: _guardianEngine,
            onChanged: (val) => setState(() => _guardianEngine = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Tactical Voice Co-Pilot Prompts',
          subtitle: 'Deliver spoken earphone alerts when major enemies burn ultimates or flash.',
          control: MiuiSwitch(
            value: _tacticalVoice,
            onChanged: (val) => setState(() => _tacticalVoice = val),
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Enemy Rotation & Missing Radar',
          subtitle: 'Display radar pulse on minimap when enemy mid/jungler disappears from sight.',
          control: MiuiSwitch(
            value: _missingRadar,
            onChanged: (val) => setState(() => _missingRadar = val),
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
