// language: Dart, file: toolbox_quick_actions_grid.dart, target: Flutter / Owl Game Turbo
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/dnd_service.dart';
import 'package:owl/features/overlay/data/voice_changer_service.dart';
import 'package:owl/features/overlay/data/wifi_optimizer_service.dart';
import 'package:owl/features/overlay/presentation/widgets/toolbox_voice_changer_sheet.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Quick actions row containing DND, Wi-Fi Boost, AI Guardian, and Voice Changer.
class ToolboxQuickActionsGrid extends ConsumerWidget {
  const ToolboxQuickActionsGrid({
    super.key,
    required this.onAiToggled,
  });

  final Future<void> Function(bool next) onAiToggled;

  Future<void> _toggleVoice(BuildContext context, WidgetRef ref) async {
    final colors = ColorTokens.of(context);
    final ok = await ref.read(voiceChangerProvider.notifier).toggleVoice();
    if (!ok && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            'Microphone permission needed for Voice.',
            style: TypographyTokens.bodySmallOf(context).copyWith(
              color: colors.textPrimary,
            ),
          ),
          backgroundColor: colors.surfaceCard,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final settings = ref.watch(gameTurboSettingsProvider);
    final dndState = ref.watch(dndServiceProvider);
    final dndNotifier = ref.read(dndServiceProvider.notifier);
    final wifiState = ref.watch(wifiOptimizerProvider);
    final wifiNotifier = ref.read(wifiOptimizerProvider.notifier);
    final voiceState = ref.watch(voiceChangerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.xxs - 1,
      ),
      child: Row(
        children: [
          // 1. DND
          Expanded(
            child: ToolboxActionButton(
              icon: LucideIcons.bellOff,
              label: 'DND',
              isActive: dndState.isEnabled,
              activeColor: colors.telemetryCritical,
              onTap: () {
                dndNotifier.toggleDnd().then((success) {
                  if (!success &&
                      context.mounted &&
                      !ref.read(dndServiceProvider).hasPermission) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification Access required for DND.',
                          style: TypographyTokens.bodySmallOf(context).copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        backgroundColor: colors.surfaceCard,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                });
              },
            ),
          ),
          AppSpacing.gapH4,

          // 2. Wi-Fi Speed Boost
          Expanded(
            child: ToolboxActionButton(
              icon: LucideIcons.wifi,
              label: 'Wi-Fi',
              isActive: wifiState.isBoostActive,
              activeColor: colors.turboBlueLight,
              onTap: () => wifiNotifier.toggleWifiBoost(),
            ),
          ),
          AppSpacing.gapH4,

          // 3. AI Assistant
          Expanded(
            child: ToolboxActionButton(
              icon: LucideIcons.bot,
              label: 'AI',
              isActive: settings.guardianTacticalEngine,
              activeColor: colors.turboBlueLight,
              onTap: () => unawaited(
                onAiToggled(!settings.guardianTacticalEngine),
              ),
            ),
          ),
          AppSpacing.gapH4,

          // 4. Voice Changer
          Expanded(
            child: ToolboxActionButton(
              icon: LucideIcons.mic,
              label: 'Voice',
              badge: voiceState.isActive ? voiceState.currentPreset.name : null,
              isActive: voiceState.isActive,
              activeColor: colors.isLight
                  ? colors.turboBlue
                  : ColorTokens.consolePurpleVivid,
              onTap: () => unawaited(_toggleVoice(context, ref)),
              onLongPress: () => ToolboxVoiceChangerSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactical action button used across the in-game floating toolbox.
class ToolboxActionButton extends StatelessWidget {
  const ToolboxActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticHelper.selectionClick();
        onTap();
      },
      onLongPress: onLongPress != null
        ? () {
            HapticHelper.heavyImpact();
            onLongPress!();
          }
        : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.pillPaddingVertical - 1,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: colors.isLight ? 0.12 : 0.18)
              : (colors.isLight
                  ? colors.surfaceCard.withValues(alpha: 0.75)
                  : colors.textPrimary.withValues(alpha: 0.08)),
          borderRadius: RadiusTokens.button,
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: colors.isLight ? 0.40 : 0.70)
                : colors.borderGlass,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.p16 - 2,
              color: isActive
                  ? activeColor
                  : colors.textPrimary.withValues(alpha: 0.6),
            ),
            AppSpacing.gapV4,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.telemetryBadge.copyWith(
                fontSize: 8.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? (colors.isLight ? activeColor : colors.textPrimary)
                    : colors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
            if (badge != null)
              Text(
                badge!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.telemetryBadge.copyWith(
                  fontSize: 7.0,
                  fontWeight: FontWeight.w700,
                  color: colors.isLight ? activeColor : colors.turboBlueLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
