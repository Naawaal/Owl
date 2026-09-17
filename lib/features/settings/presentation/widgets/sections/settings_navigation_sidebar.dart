// language: Dart, file: settings_navigation_sidebar.dart, target: Flutter / Owl MOBA Companion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

class SettingsTopBar extends ConsumerWidget {
  const SettingsTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final providerLabel = switch (settings.activeAiProvider) {
      'openai' => 'OpenAI',
      'claude' => 'Claude',
      'deepseek' || 'openrouter' => 'DeepSeek',
      'sambanova' => 'SambaNova',
      'xkiro' => 'xKiro',
      'groq' => 'Groq',
      _ => 'Gemini',
    };
    final modelShort = settings.activeModel.split('/').last;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.textPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Header Title + Active Engine Subtitle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TypographyTokens.dialogTitleOf(context).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$providerLabel • $modelShort',
                style: TypographyTokens.settingsRowDescOf(context).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: colors.textPrimary.withValues(alpha: 0.54),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Live Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.isLight
                  ? colors.turboBlue.withValues(alpha: 0.08)
                  : ColorPrimitives.selectBlue12,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.turboBlue.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.turboCyan,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.turboCyan.withValues(alpha: 0.53),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onEnd: () {},
                ),
                const SizedBox(width: 6),
                Text(
                  'CLOUD API READY',
                  style: TypographyTokens.tacticalBadgeOf(context).copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: colors.keyInputText,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsCategorySidebar extends StatelessWidget {
  final AppSettingCategory selectedCategory;
  final ValueChanged<AppSettingCategory> onSelectCategory;

  const SettingsCategorySidebar({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Container(
      width: 220,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        children: [
          ...AppSettingCategory.values.map((cat) {
            final isSelected = cat == selectedCategory;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    HapticHelper.selectionClick();
                    onSelectCategory(cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (colors.isLight
                              ? colors.turboBlue.withValues(alpha: 0.12)
                              : ColorPrimitives.selectBlue12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? colors.turboBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected
                              ? colors.turboCyan
                              : colors.textPrimary.withValues(alpha: 0.54),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.label,
                            style: TypographyTokens.titleSmallOf(context).copyWith(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colors.textPrimary
                                  : colors.textPrimary.withValues(alpha: 0.54),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
