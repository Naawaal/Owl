// language: Dart, file: gpu_settings_two_pane_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/sections/gpu_settings_content_pane.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Xiaomi Game Turbo Two-Pane Selected Game GPU Settings Screen.
///
/// Configures hardware graphics, touch sampling, and per-game tactical AI modules
/// for the selected game title. All options persist in the global GPU profile
/// of [GameTurboSettingsNotifier] and survive app restarts.
class GpuSettingsTwoPaneScreen extends ConsumerStatefulWidget {
  const GpuSettingsTwoPaneScreen({
    super.key,
    this.gameTitle = 'Game',
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
    HapticHelper.mediumImpact();
    ref.read(gameTurboSettingsProvider.notifier).resetGpuSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);

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
                      Expanded(
                        child: GpuSettingsContentPane(
                          category: _selectedCategory,
                          settings: settings,
                          notifier: notifier,
                        ),
                      ),
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
              HapticHelper.selectionClick();
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
}
