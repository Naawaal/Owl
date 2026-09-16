// language: Dart, file: app_settings_two_pane_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Xiaomi HyperOS Game Turbo Two-Pane Global App Settings Screen.
///
/// Implements a categorized two-column landscape view with full logic integration:
/// - Left Sidebar: Category navigation (General, Performance, DND, AI Core)
/// - Right Pane: Setting rows with title, description, [MiuiSwitch], and [OemSegmentedChips].
/// - Real-time persistence and system integration via [gameTurboSettingsProvider].
class AppSettingsTwoPaneScreen extends ConsumerStatefulWidget {
  const AppSettingsTwoPaneScreen({super.key});

  @override
  ConsumerState<AppSettingsTwoPaneScreen> createState() =>
      _AppSettingsTwoPaneScreenState();
}

enum AppSettingCategory {
  general('General settings'),
  performance('Performance mode'),
  dnd('Game DND'),
  guardianAi('Guardian AI Core');

  const AppSettingCategory(this.label);
  final String label;
}

class _AppSettingsTwoPaneScreenState
    extends ConsumerState<AppSettingsTwoPaneScreen> {
  AppSettingCategory _selectedCategory = AppSettingCategory.general;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF090C13),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, notifier),

            // Two-Pane Content
            Expanded(
              child: Row(
                children: [
                  // Left Category Sidebar
                  _buildCategorySidebar(),

                  // Vertical Separator
                  Container(width: 1, color: const Color(0x14FFFFFF)),

                  // Right Content Pane
                  Expanded(child: _buildContentPane(settings, notifier)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, GameTurboSettingsNotifier notifier) {
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
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.white),
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
          TextButton(
            onPressed: notifier.resetToDefaults,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Reset Default',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0x99FFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x1A007AFF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: ColorSemantics.turboBlue.withValues(alpha: 0.3)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0x1A007AFF)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? ColorSemantics.turboBlue
                        : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? Colors.white : const Color(0x8AFFFFFF),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentPane(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    switch (_selectedCategory) {
      case AppSettingCategory.general:
        return _buildGeneralSettings(settings, notifier);
      case AppSettingCategory.performance:
        return _buildPerformanceSettings(settings, notifier);
      case AppSettingCategory.dnd:
        return _buildDndSettings(settings, notifier);
      case AppSettingCategory.guardianAi:
        return _buildGuardianAiSettings(settings, notifier);
    }
  }

  Widget _buildGeneralSettings(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Game Turbo Master Engine',
          subtitle:
              'Improve your gaming experience with hardware-level acceleration and background cooling.',
          control: MiuiSwitch(
            value: settings.gameTurboMaster,
            onChanged: notifier.toggleGameTurboMaster,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'In-Game Floating Shortcuts',
          subtitle:
              'Swipe from the top side edge of the screen to view floating toolbox.',
          control: MiuiSwitch(
            value: settings.inGameShortcuts,
            onChanged: notifier.toggleInGameShortcuts,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Shortcut Edge Position',
          subtitle: 'Choose edge handle anchor on the display.',
          control: OemSegmentedChips<String>(
            options: const ['Top-Left', 'Left Edge', 'Top-Right'],
            selected: settings.shortcutEdgePosition,
            onSelected: notifier.setShortcutEdgePosition,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Content recommendations',
          subtitle: 'Receive gaming-related content recommendations.',
          control: MiuiSwitch(
            value: settings.contentRecommendations,
            onChanged: notifier.toggleContentRecommendations,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Remove added games from Home screen',
          subtitle:
              'Don\'t show the games that were added to the gamebox on the Home screen.',
          control: MiuiSwitch(
            value: settings.hideGamesFromHomeScreen,
            onChanged: notifier.toggleHideGamesFromHomeScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSettings(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Performance Optimization',
          subtitle:
              'Prioritize CPU and GPU allocation to maintain stable frame rates.',
          control: MiuiSwitch(
            value: settings.performanceOptimization,
            onChanged: notifier.togglePerformanceOptimization,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Wi-Fi Speed Boost',
          subtitle:
              'Reduce network delay by switching to fastest available low-latency channel.',
          control: MiuiSwitch(
            value: settings.wifiSpeedBoost,
            onChanged: notifier.toggleWifiSpeedBoost,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Aggressive Memory Cleanup',
          subtitle:
              'Purge non-essential background services before game launch.',
          control: MiuiSwitch(
            value: settings.aggressiveMemoryCleanup,
            onChanged: notifier.toggleAggressiveMemoryCleanup,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Spatial Audio Enhancement',
          subtitle:
              'Amplify footsteps and ambush audio cues during live match combat.',
          control: MiuiSwitch(
            value: settings.spatialAudio,
            onChanged: notifier.toggleSpatialAudio,
          ),
        ),
      ],
    );
  }

  Widget _buildDndSettings(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Restrict floating notifications',
          subtitle: 'Don\'t display floating notifications during match.',
          control: MiuiSwitch(
            value: settings.restrictFloatingNotifications,
            onChanged: notifier.toggleRestrictFloatingNotifications,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Restrict buttons and gestures',
          subtitle:
              'Prevent accidental touches of the notification bar and navigation gestures.',
          control: MiuiSwitch(
            value: settings.restrictButtonsAndGestures,
            onChanged: notifier.toggleRestrictButtonsAndGestures,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Answer calls hands-free',
          subtitle: 'Open speakerphone automatically when answering calls.',
          control: MiuiSwitch(
            value: settings.answerCallsHandsFree,
            onChanged: notifier.toggleAnswerCallsHandsFree,
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianAiSettings(
      GameTurboSettings settings, GameTurboSettingsNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingRow(
          title: 'Guardian Tactical Engine',
          subtitle:
              'Real-time MOBA visual parsing, enemy roam predictions & gank alerts.',
          control: MiuiSwitch(
            value: settings.guardianTacticalEngine,
            onChanged: notifier.toggleGuardianTacticalEngine,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'AI Vision Inference Backend',
          subtitle:
              'Select on-device NPU for ultra-low latency (42ms) or cloud models.',
          control: OemSegmentedChips<String>(
            options: const ['Local NPU', 'Gemini 2.5', 'Claude 3.5'],
            selected: settings.aiInferenceBackend,
            onSelected: notifier.setAiInferenceBackend,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Audio Tactical Callouts',
          subtitle:
              'Voice announcements for missing enemy mid/jungler and dragon spawns.',
          control: MiuiSwitch(
            value: settings.tacticalAudioCallouts,
            onChanged: notifier.toggleTacticalAudioCallouts,
          ),
        ),
        _buildDivider(),
        _buildSettingRow(
          title: 'Enemy Rotation & Missing Radar',
          subtitle:
              'Display radar pulse on minimap when enemy mid/jungler disappears from sight.',
          control: MiuiSwitch(
            value: settings.enemyMissingRadar,
            onChanged: notifier.toggleEnemyMissingRadar,
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
