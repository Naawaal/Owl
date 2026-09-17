import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/overlay/presentation/widgets/overlay_edge_handle.dart';
import 'package:owl/features/overlay/presentation/widgets/tactical_hud_game_stage.dart';
import 'package:owl/features/overlay/presentation/widgets/tactical_hud_top_bar.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// In-Game HUD companion matching Game Space Console, with an authentic
/// floating TURBO edge handle that opens the Game Turbo toolbox.
class TacticalBattlefieldHud extends ConsumerStatefulWidget {
  const TacticalBattlefieldHud({
    super.key,
    this.activeGame,
    this.autoOpenToolbox = false,
  });

  final InstalledGame? activeGame;
  final bool autoOpenToolbox;

  @override
  ConsumerState<TacticalBattlefieldHud> createState() =>
      _TacticalBattlefieldHudState();
}

class _TacticalBattlefieldHudState extends ConsumerState<TacticalBattlefieldHud>
    with SingleTickerProviderStateMixin {
  bool _isToolboxOpen = false;
  DateTime? _sessionStart;

  int get _matchElapsedSeconds => _sessionStart == null
      ? 0
      : DateTime.now().difference(_sessionStart!).inSeconds;

  late final AnimationController _toolboxController;
  late final Animation<double> _toolboxScaleAnimation;
  late final Animation<double> _toolboxFadeAnimation;
  late final Animation<Offset> _toolboxSlideAnimation;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();

    _toolboxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 160),
    );

    if (widget.autoOpenToolbox) {
      _isToolboxOpen = true;
      _toolboxController.value = 1.0;
    }

    final curved = CurvedAnimation(
      parent: _toolboxController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _toolboxScaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(curved);
    _toolboxFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _toolboxSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.06),
      end: Offset.zero,
    ).animate(curved);
  }

  @override
  void dispose() {
    _toolboxController.dispose();
    super.dispose();
  }

  void _toggleToolbox([bool? forceState]) {
    final next = forceState ?? !_isToolboxOpen;
    if (next == _isToolboxOpen) return;
    HapticHelper.mediumImpact();
    setState(() => _isToolboxOpen = next);
    if (next) {
      _toolboxController.forward();
    } else {
      _toolboxController.reverse();
    }
  }

  void _openGpuSettings(InstalledGame? game) {
    HapticHelper.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GpuSettingsTwoPaneScreen(
          gameTitle: game?.name ?? widget.activeGame?.name ?? 'Game',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final (shortcutEdgePosition, inGameShortcuts) = ref.watch(
      gameTurboSettingsProvider.select(
        (s) => (s.shortcutEdgePosition, s.inGameShortcuts),
      ),
    );
    final activeGame = widget.activeGame ??
        ref.watch(
          installedGamesProvider.select(
            (s) => s.activeGame ?? s.games.where((g) => g.isInGameSpace).firstOrNull,
          ),
        );

    double? handleTop = 140;
    double? handleLeft = 0;
    double? handleRight;
    double? toolboxTop = 60;
    double? toolboxLeft = 8;
    double? toolboxRight;

    if (shortcutEdgePosition == 'Left Edge') {
      handleTop = 140;
      handleLeft = 0;
      toolboxTop = 60;
      toolboxLeft = 8;
    } else if (shortcutEdgePosition == 'Top-Right') {
      handleTop = 10;
      handleLeft = null;
      handleRight = 200;
      toolboxTop = 12;
      toolboxLeft = null;
      toolboxRight = 180;
    }

    final isRight = handleRight != null;

    return Scaffold(
      backgroundColor: colors.consoleBase,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: OwlAtmosphericBackground()),
          SafeArea(
            child: Column(
              children: [
                TacticalHudTopBar(
                  game: activeGame,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Center(
                    child: TacticalHudGameStage(
                      game: activeGame,
                      onOpenToolbox: () => _toggleToolbox(true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isToolboxOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleToolbox(false),
                child: Container(color: ColorPrimitives.scrimBlack25),
              ),
            ),
          if (inGameShortcuts)
            Positioned(
              top: handleTop,
              left: handleLeft,
              right: handleRight,
              child: AnimatedOpacity(
                opacity: _isToolboxOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 160),
                child: IgnorePointer(
                  ignoring: _isToolboxOpen,
                  child: OverlayEdgeHandle(
                    game: activeGame,
                    onTap: () => _toggleToolbox(true),
                  ),
                ),
              ),
            ),
          Positioned(
            top: toolboxTop,
            left: toolboxLeft,
            right: toolboxRight,
            child: AnimatedBuilder(
              animation: _toolboxController,
              builder: (context, child) {
                if (_toolboxController.isDismissed && !_isToolboxOpen) {
                  return const SizedBox.shrink();
                }
                return SlideTransition(
                  position: _toolboxSlideAnimation,
                  child: ScaleTransition(
                    scale: _toolboxScaleAnimation,
                    alignment:
                        isRight ? Alignment.topRight : Alignment.topLeft,
                    child: FadeTransition(
                      opacity: _toolboxFadeAnimation,
                      child: GameturboFloatingToolbox(
                        gameTitle:
                            activeGame?.name ?? 'Game',
                        targetFps: activeGame?.targetFps ?? 120,
                        matchElapsedSeconds: _matchElapsedSeconds,
                        onClose: () => _toggleToolbox(false),
                        onOpenGpuSettings: () => _openGpuSettings(activeGame),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
