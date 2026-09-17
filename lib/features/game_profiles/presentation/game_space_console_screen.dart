// language: Dart, file: game_space_console_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/screen_capture_channel.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/add_games_modal.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/game_profiles/presentation/widgets/game_space_main_stage.dart';
import 'package:owl/features/game_profiles/presentation/widgets/game_space_top_status_bar.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// 1:1 Authentic Xiaomi Game Turbo Game Space Console Screen.
///
/// Features:
/// - Dynamic game discovery across installed Android packages (no hardcoding)
/// - Top Bar: Battery, CPU, FPS, Add Game (+), Settings Gear
/// - Left Sidebar: Gamebox with real game icons and quick game switcher
/// - Center Stage: Dynamic cinematic hero showcase with real game details
/// - Right Wing: Signature Play action banner launching native game package
/// - Bottom Tab: Beveled trapezoid GPU settings tab linked to active game
///
/// In-game Gaming tools live only in the system overlay over the real game —
/// not as a Console preview HUD.
class GameSpaceConsoleScreen extends ConsumerWidget {
  const GameSpaceConsoleScreen({super.key});

  void _openAppSettings(BuildContext context) {
    HapticHelper.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AppSettingsTwoPaneScreen()),
    );
  }

  void _openGpuSettings(BuildContext context, InstalledGame? activeGame) {
    HapticHelper.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GpuSettingsTwoPaneScreen(
          gameTitle: activeGame?.name ?? 'Game',
        ),
      ),
    );
  }

  void _openAddGames(BuildContext context) {
    HapticHelper.lightImpact();
    AddGamesModal.show(context);
  }

  Future<bool> _showOverlayPermissionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) {
            final dialogColors = ColorTokens.of(ctx);
            return AlertDialog(
              backgroundColor: dialogColors.dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: dialogColors.borderGlassStrong),
              ),
              title: Row(
                children: [
                  Text(
                    '⚡',
                    style: TypographyTokens.dialogTitleOf(ctx).copyWith(
                      fontSize: 18,
                      color: ColorSemantics.turboBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Display Over Apps',
                    style: TypographyTokens.dialogTitleOf(ctx),
                  ),
                ],
              ),
              content: Text(
                'To display Gaming tools over your game, Owl needs "Display over other apps" permission.',
                style: TypographyTokens.dialogBodyOf(ctx),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Not now',
                    style: TypographyTokens.dialogActionOf(ctx).copyWith(
                      color: dialogColors.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSemantics.turboBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(gameDiscoveryServiceProvider)
                        .requestOverlayPermission();
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    'Grant Permission',
                    style: TypographyTokens.dialogAction.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _launchGameMatch(
    BuildContext context,
    WidgetRef ref,
    InstalledGame? activeGame,
  ) async {
    HapticHelper.heavyImpact();
    if (activeGame == null) return;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final discoveryService = ref.read(gameDiscoveryServiceProvider);
      final hasPerm = await discoveryService.hasOverlayPermission();
      if (!hasPerm && context.mounted) {
        final granted = await _showOverlayPermissionDialog(context, ref);
        if (!granted) return;
      }
      final settings = ref.read(gameTurboSettingsProvider);
      if (settings.guardianVisionEnabled) {
        final hasCapture =
            await const ScreenCaptureChannel().hasCapturePermission();
        if (!hasCapture) {
          await const ScreenCaptureChannel().requestCapturePermission();
        }
      }
    }

    await ref.read(installedGamesProvider.notifier).launchActiveGame();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owlColors = ColorTokens.of(context);

    return Scaffold(
      backgroundColor: owlColors.consoleBase,
      body: Stack(
        children: [
          const Positioned.fill(child: OwlAtmosphericBackground()),
          SafeArea(
            child: Column(
              children: [
                GameSpaceTopStatusBar(
                  onLeadingAction: () => _openAddGames(context),
                  onSettingsTap: () => _openAppSettings(context),
                  leadingIcon: Icons.add,
                ),
                GameSpaceMainStage(
                  onOpenAddGames: () => _openAddGames(context),
                  onPlay: (game) => _launchGameMatch(context, ref, game),
                  onOpenGpuSettings: (game) => _openGpuSettings(context, game),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
