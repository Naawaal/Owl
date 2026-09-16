// language: Dart, file: tactical_battlefield_hud.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';


import 'package:owl/features/overlay/data/system_stats_service.dart';


/// In-Game HUD & Companion View matching the Game Space Console design system 1:1.
///
/// Shares the exact visual language of [GameSpaceConsoleScreen]:
/// - Atmospheric ambient horizon (deep #07090F with purple & blue radial glows)
/// - Top Status Bar with real-time battery shell, CPU chip badge, and `< Game Space` return navigation
/// - Cinematic hero game showcase with active game artwork, target FPS badge, and status
/// - Slim draggable/pinned floating handle ("⚡ TURBO 120 FPS") with emerald pulsing dot
/// - Compact, streamlined [GameturboFloatingToolbox] overlay with tap-outside dismissal
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
    with TickerProviderStateMixin {
  bool _isToolboxOpen = false;

  late final AnimationController _toolboxController;
  late final Animation<double> _toolboxScaleAnimation;
  late final Animation<double> _toolboxFadeAnimation;
  late final Animation<Offset> _toolboxSlideAnimation;

  // Pulsing dot animation for the edge handle
  late final AnimationController _dotPulseController;
  late final Animation<double> _dotPulseAnimation;

  @override
  void initState() {
    super.initState();

    _toolboxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );

    // Pulsing dot
    _dotPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _dotPulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _dotPulseController, curve: Curves.easeInOut),
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

    _toolboxScaleAnimation =
        Tween<double>(begin: 0.94, end: 1.0).animate(curved);
    _toolboxFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _toolboxSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.04),
      end: Offset.zero,
    ).animate(curved);
  }

  @override
  void dispose() {
    _toolboxController.dispose();
    _dotPulseController.dispose();
    super.dispose();
  }

  void _toggleToolbox(bool open) {
    HapticFeedback.mediumImpact();
    setState(() => _isToolboxOpen = open);
    if (open) {
      _toolboxController.forward();
    } else {
      _toolboxController.reverse();
    }
  }

  void _openGpuSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GpuSettingsTwoPaneScreen(
          gameTitle: widget.activeGame?.name ?? 'Mobile Legends: Bang Bang',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final game = widget.activeGame;

    // Dynamic edge handle and toolbox positioning from settings.shortcutEdgePosition
    double? handleTop = 10;
    double? handleLeft = 140;
    double? handleRight;

    double? toolboxTop = 12;
    double? toolboxLeft = 140;
    double? toolboxRight;

    if (settings.shortcutEdgePosition == 'Left Edge') {
      handleTop = 140;
      handleLeft = 0;
      toolboxTop = 60;
      toolboxLeft = 8;
    } else if (settings.shortcutEdgePosition == 'Top-Right') {
      handleTop = 10;
      handleLeft = null;
      handleRight = 200;
      toolboxTop = 12;
      toolboxLeft = null;
      toolboxRight = 180;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Ambient Horizon (1:1 with GameSpaceConsoleScreen)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF090B12),
                    Color(0xFF06070B),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.0),
                  radius: 0.85,
                  colors: [
                    Color(0x2E8B2BE2),
                    Color(0x0D140A28),
                    Color(0x0006070B),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -120,
            top: 0,
            bottom: 0,
            width: 420,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: [
                    const Color(0xFF006EFF).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main In-Game Companion Stage
          SafeArea(
            child: Column(
              children: [
                // Top Status Bar (Matching Console UI)
                _buildTopStatusBar(game),

                // Center Game Hero Showcase
                Expanded(
                  child: Center(
                    child: _buildCenterGameStage(game, settings),
                  ),
                ),
              ],
            ),
          ),

          // 3. Tap-outside dismissal backdrop when toolbox is open
          if (_isToolboxOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleToolbox(false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
            ),

          // 4. Slim Floating Edge Handle
          if (settings.inGameShortcuts)
            Positioned(
              top: handleTop,
              left: handleLeft,
              right: handleRight,
              child: AnimatedOpacity(
                opacity: _isToolboxOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 160),
                child: IgnorePointer(
                  ignoring: _isToolboxOpen,
                  child: _buildEdgeHandle(game),
                ),
              ),
            ),

          // 5. Streamlined Compact GameturboFloatingToolbox
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
                    alignment: Alignment.topLeft,
                    child: FadeTransition(
                      opacity: _toolboxFadeAnimation,
                      child: GameturboFloatingToolbox(
                        gameTitle: game?.name ?? 'Mobile Legends: Bang Bang',
                        targetFps: game?.targetFps ?? 120,
                        onClose: () => _toggleToolbox(false),
                        onOpenGpuSettings: _openGpuSettings,
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

  Widget _buildTopStatusBar(InstalledGame? game) {
    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;
    final battery = stats?.battery ?? 78;
    final cpu = stats?.cpu ?? 32;
    final battFraction = (battery / 100.0).clamp(0.0, 1.0);
    final battColor = battery <= 20
        ? const Color(0xFFE63946)
        : battery <= 40
            ? const Color(0xFFEAB308)
            : ColorSemantics.turboBlue;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Return to Game Space Console button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x26FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.chevronLeft, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text(
                    'Game Space',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center: Game Title & Target Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game?.name ?? 'Game In-Session',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x2E007AFF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ColorSemantics.turboBlue),
                ),
                child: Text(
                  '${game?.targetFps ?? 120} FPS Max',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: ColorSemantics.turboBlueLight,
                  ),
                ),
              ),
            ],
          ),

          // Right: Live Battery & CPU
          Row(
            children: [
              // Battery Shell — live fill
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 10,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned.fill(
                          right: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xA6FFFFFF), width: 1.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.all(1),
                            child: LayoutBuilder(builder: (ctx, cst) {
                              return Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: cst.maxWidth * battFraction,
                                    decoration: BoxDecoration(
                                      color: battColor,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          child: SizedBox(
                            width: 2,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xA6FFFFFF),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(1),
                                  bottomRight: Radius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$battery%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // CPU chip badge — live
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                          color: const Color(0x73FFFFFF), width: 1.2),
                    ),
                    child: const Text(
                      'CPU',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$cpu%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterGameStage(
      InstalledGame? game, GameTurboSettings settings) {
    return Container(
      width: 520,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2EFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xD9000000),
            blurRadius: 50,
            offset: Offset(0, 20),
          ),
          BoxShadow(
            color: Color(0x407C3AED),
            blurRadius: 35,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base Artwork
          if (game?.iconBytes != null)
            Image.memory(
              game!.iconBytes!,
              fit: BoxFit.cover,
            )
          else
            Image.asset(
              'assets/images/wild_rift_splash.jpg',
              fit: BoxFit.cover,
            ),

          // Deep gradient darkening layer for contrast
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000),
                  Color(0x660A0514),
                  Color(0xF207080E),
                ],
                stops: [0.0, 0.45, 0.95],
              ),
            ),
          ),

          // Overlay Guide Info Banner at bottom of card
          Positioned(
            bottom: 18,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '⚡',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              game?.name ?? 'Game Space Live Match',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${game?.category ?? 'Gaming Engine'} · Game Turbo Active',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggleToolbox(true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF0055B8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: ColorSemantics.turboBlue.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.sliders, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        const Text(
                          'Open Turbo HUD',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeHandle(InstalledGame? game) {
    final stats = ref.watch(systemStatsProvider).valueOrNull;
    final liveFps = stats?.fps ?? (game?.targetFps ?? 120);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleToolbox(true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xE00D121B),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: const Color(0x4D3B82F6), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing emerald dot
            ScaleTransition(
              scale: _dotPulseAnimation,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF30D158),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF30D158), blurRadius: 8),
                  ],
                ),
                child: SizedBox(width: 6, height: 6),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '⚡',
              style: TextStyle(
                fontSize: 10,
                color: ColorSemantics.turboBlueLight,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'TURBO $liveFps FPS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
                fontFamily: TypographyTokens.monoFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
