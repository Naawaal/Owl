// language: Dart, file: toolbox_voice_changer_sheet.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/overlay/data/voice_changer_service.dart';
import 'package:owl_design/owl_design.dart';

/// Modal bottom sheet displaying tactical voice presets for real-time DSP modulation.
class ToolboxVoiceChangerSheet extends ConsumerWidget {
  const ToolboxVoiceChangerSheet({super.key});

  /// Displays the voice changer preset modal bottom sheet.
  static Future<void> show(BuildContext context) {
    final colors = ColorTokens.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const ToolboxVoiceChangerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final voiceNotifier = ref.read(voiceChangerProvider.notifier);
    final voiceState = ref.watch(voiceChangerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TACTICAL VOICE PRESETS',
                  style: TypographyTokens.tacticalBadgeOf(context).copyWith(
                    fontSize: 11,
                    color: colors.turboBlueLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...kTacticalVoicePresets.map((preset) {
              final isSelected = preset.id == voiceState.activePresetId;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      isSelected ? colors.turboBlueLight : colors.textMuted,
                ),
                title: Text(
                  preset.name,
                  style: TypographyTokens.bodySmallOf(context).copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.normal,
                    color: colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  preset.description,
                  style: TypographyTokens.bodySmallOf(context).copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                onTap: () {
                  voiceNotifier.setPreset(preset.id);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
