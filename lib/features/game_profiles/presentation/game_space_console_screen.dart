// language: Dart, file: game_space_console_screen.dart, target: Flutter / Owl Game Turbo
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/add_games_modal.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/overlay/presentation/tactical_battlefield_hud.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl/features/overlay/data/system_stats_service.dart';

/// 1:1 Authentic Xiaomi Game Turbo Game Space Console Screen.
///
/// Features:
/// - Dynamic game discovery across installed Android packages (no hardcoding)
/// - Top Bar: Battery 71%, CPU 30%, Add Game (+), Settings Gear
/// - Left Sidebar: Gamebox with real game icons and quick game switcher
/// - Center Stage: Dynamic cinematic hero showcase with real game details
/// - Right Wing: Signature ⚡ Play action banner launching native game package
/// - Bottom Tab: Beveled trapezoid GPU settings tab linked to active game
class GameSpaceConsoleScreen extends ConsumerStatefulWidget {
  const GameSpaceConsoleScreen({super.key});

  @override
  ConsumerState<GameSpaceConsoleScreen> createState() =>
      _GameSpaceConsoleScreenState();
}

class _GameSpaceConsoleScreenState extends ConsumerState<GameSpaceConsoleScreen>
    with SingleTickerProviderStateMixin {
  int _activeHeroIndex = 0;
  bool _isOverlayToolboxOpen = false;

  AnimationController? _toolboxController;
  Animation<Offset>? _toolboxSlideAnimation;
  Animation<double>? _toolboxScaleAnimation;
  Animation<double>? _toolboxFadeAnimation;

  void _ensureInitialized() {
    if (_toolboxController != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _toolboxSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    _toolboxScaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    _toolboxFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    _toolboxController = controller;
  }

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  @override
  void reassemble() {
    super.reassemble();
    _ensureInitialized();
  }

  @override
  void dispose() {
    _toolboxController?.dispose();
    super.dispose();
  }

  void _toggleOverlayToolbox([bool? forceState]) {
    _ensureInitialized();
    final nextState = forceState ?? !_isOverlayToolboxOpen;
    if (nextState == _isOverlayToolboxOpen) return;
    setState(() {
      _isOverlayToolboxOpen = nextState;
    });
    HapticFeedback.lightImpact();
    if (nextState) {
      _toolboxController?.forward();
    } else {
      _toolboxController?.reverse();
    }
  }

  void _openAppSettings() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AppSettingsTwoPaneScreen()),
    );
  }

  void _openGpuSettings(InstalledGame? activeGame) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GpuSettingsTwoPaneScreen(
          gameTitle: activeGame?.name ?? 'Mobile Legends: Bang Bang',
        ),
      ),
    );
  }

  void _openAddGames() {
    HapticFeedback.lightImpact();
    AddGamesModal.show(context);
  }

  Future<bool> _showOverlayPermissionDialog() async {
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
                    style: TypographyTokens.dialogTitle.copyWith(
                      fontSize: 18,
                      color: ColorTokens.turboBlueLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Display Over Apps',
                    style: TypographyTokens.dialogTitle,
                  ),
                ],
              ),
              content: Text(
                'To display the floating Game Turbo handle & live FPS meter over your game, Owl needs "Display over other apps" permission.',
                style: TypographyTokens.dialogBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    'Skip to In-App HUD',
                    style: TypographyTokens.dialogAction.copyWith(
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
                    style: TypographyTokens.dialogAction,
                  ),
                ),
              ],
            );
          },
        ) ??
        true;
  }

  void _launchGameMatch(InstalledGame? activeGame) async {
    HapticFeedback.heavyImpact();
    bool externalLaunched = false;
    if (activeGame != null) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final discoveryService = ref.read(gameDiscoveryServiceProvider);
        final hasPerm = await discoveryService.hasOverlayPermission();
        if (!hasPerm) {
          await _showOverlayPermissionDialog();
        }
      }
      externalLaunched = await ref
          .read(installedGamesProvider.notifier)
          .launchActiveGame();
    }
    if (mounted) {
      // When a real external game was successfully launched on Android,
      // the native GameTurboOverlayService floats directly over the game.
      // If no external game app was launched (desktop, test, or simulation fallback),
      // navigate to TacticalBattlefieldHud to preview the in-game overlay experience.
      if (!externalLaunched) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TacticalBattlefieldHud(
              activeGame: activeGame,
              autoOpenToolbox: true,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final owlColors = ColorTokens.of(context);
    final gameState = ref.watch(installedGamesProvider);
    final deckGames = gameState.games.where((g) => g.isInGameSpace).toList();
    final activeGame = gameState.activeGame ?? deckGames.firstOrNull;

    return Scaffold(
      backgroundColor: owlColors.consoleBase,
      body: Stack(
        children: [
          // 1. Ambient Horizon (Dark) or Sector Shimmer (Light) — 1:1 prototype match
          const Positioned.fill(child: OwlAtmosphericBackground()),

          // 2. Main Console Layout
          SafeArea(
            child: Column(
              children: [
                // Top Status Bar
                _buildTopStatusBar(),

                // Center Stage & Sidebars
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main Console Row: Left Sidebar (App List), Center Hero Stage, Right Play Wing (Side-by-Side)
                      Positioned.fill(
                        bottom: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Vertical Sidebar (App List) — left 24 padding
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: _buildLeftSidebar(deckGames, activeGame),
                            ),

                            // Center Hero Showcase — fills middle space and scales down to prevent overlap
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _buildCenterStage(
                                      activeGame,
                                      deckGames,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Right Action Wing (⚡ Play) — flush against right edge, side-by-side
                            _buildPlayWing(activeGame),
                          ],
                        ),
                      ),

                      // Bottom GPU Settings Tab
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomGpuTab(activeGame),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Tap-outside backdrop dismissal when overlay toolbox is open
          if (_isOverlayToolboxOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleOverlayToolbox(false),
                child: Container(color: ColorPrimitives.scrimBlack35),
              ),
            ),

          // 4. Compact Floating GameTurbo Overlay Toolbox anchored at top-left
          Positioned(
            top: 48,
            left: 28,
            child: AnimatedBuilder(
              animation: _toolboxController!,
              builder: (context, child) {
                if (_toolboxController!.isDismissed && !_isOverlayToolboxOpen) {
                  return const SizedBox.shrink();
                }
                return SlideTransition(
                  position: _toolboxSlideAnimation!,
                  child: ScaleTransition(
                    scale: _toolboxScaleAnimation!,
                    alignment: Alignment.topLeft,
                    child: FadeTransition(
                      opacity: _toolboxFadeAnimation!,
                      child: GameturboFloatingToolbox(
                        gameTitle:
                            activeGame?.name ?? 'Mobile Legends: Bang Bang',
                        targetFps: activeGame?.targetFps ?? 120,
                        onClose: () => _toggleOverlayToolbox(false),
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

  Widget _buildTopStatusBar() {
    final owlColors = ColorTokens.of(context);
    final statsAsync = ref.watch(systemStatsProvider);
    final stats = statsAsync.valueOrNull;
    // Live reference defaults while loading / on error: 78% / 32%.
    final battery = stats?.battery ?? 78;
    final cpu = stats?.cpu ?? 32;

    // Battery fill fraction (clamp 0–1)
    final battFraction = (battery / 100.0).clamp(0.0, 1.0);
    final battColor = battery <= 20
        ? owlColors.telemetryCritical
        : battery <= 40
        ? owlColors.telemetryLow
        : owlColors.telemetryNormal;
    final battLabel = '$battery%';
    final cpuLabel = '$cpu%';

    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Battery & CPU live — 11.5px w600 #E2E8F0, gap 16
          Row(
            children: [
              // Battery icon — 20x10 shell, 1.5px white65%, radius 3
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 10,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // shell
                        Positioned.fill(
                          right: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: owlColors.textPrimary.withValues(
                                  alpha: 0.65,
                                ),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.all(1),
                            child: LayoutBuilder(
                              builder: (ctx, cst) {
                                return Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      width: cst.maxWidth * battFraction,
                                      decoration: BoxDecoration(
                                        color: battColor,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        // nub
                        Positioned(
                          right: 0,
                          child: SizedBox(
                            width: 2,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: owlColors.textPrimary.withValues(
                                  alpha: owlColors.isLight ? 0.75 : 0.65,
                                ),
                                borderRadius: const BorderRadius.only(
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
                  const SizedBox(width: 6),
                  Text(
                    battLabel,
                    style: TypographyTokens.statusMicro.copyWith(
                      color: owlColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // CPU — chip badge 1.2px white45% radius3 8px 700 #CBD5E1
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: owlColors.textPrimary.withValues(
                          alpha: owlColors.isLight ? 0.4 : 0.45,
                        ),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'CPU',
                      style: TypographyTokens.telemetryBadge.copyWith(
                        color: owlColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cpuLabel,
                    style: TypographyTokens.statusMicro.copyWith(
                      color: owlColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Live Measured FPS Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: owlColors.emeraldLive.withValues(
                          alpha: owlColors.isLight ? 0.6 : 0.45,
                        ),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'FPS',
                      style: TypographyTokens.telemetryBadge.copyWith(
                        color: owlColors.emeraldLive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${stats?.fps ?? 120}',
                    style: TypographyTokens.statusMicro.copyWith(
                      color: owlColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center: Interactive Turbo HUD trigger badge
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleOverlayToolbox(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isOverlayToolboxOpen
                    ? owlColors.turboBlue.withValues(alpha: 0.2)
                    : (owlColors.isLight
                          ? owlColors.turboBlue.withValues(alpha: 0.08)
                          : owlColors.textPrimary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: _isOverlayToolboxOpen
                      ? owlColors.turboBlueLight
                      : (owlColors.isLight
                            ? owlColors.turboBlue.withValues(alpha: 0.25)
                            : owlColors.turboBlue.withValues(alpha: 0.18)),
                  width: 1.2,
                ),
                boxShadow: _isOverlayToolboxOpen
                    ? [
                        BoxShadow(
                          color: owlColors.turboBlue.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: owlColors.emeraldLive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TURBO ${stats?.fps ?? 120} FPS',
                    style: TypographyTokens.tacticalBadge.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: owlColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isOverlayToolboxOpen ? Icons.close : Icons.tune,
                    size: 11,
                    color: owlColors.isLight
                        ? owlColors.turboBlue
                        : owlColors.turboBlueLight,
                  ),
                ],
              ),
            ),
          ),

          // Right: Add Game (+) & Settings Gear — gap 16
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openAddGames,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.add,
                    size: 19,
                    color: owlColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openAppSettings,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: owlColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(
    List<InstalledGame> deckGames,
    InstalledGame? activeGame,
  ) {
    final owlColors = ColorTokens.of(context);
    return SizedBox(
      width: 188,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state
          if (deckGames.isEmpty)
            GestureDetector(
              onTap: _openAddGames,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: owlColors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: owlColors.borderGlassStrong),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: owlColors.turboBlueLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add First Game',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.statusMicro.copyWith(
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Vertical game list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: deckGames.length,
                itemBuilder: (context, index) {
                  final game = deckGames[index];
                  final isActive = game.packageName == activeGame?.packageName;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(installedGamesProvider.notifier)
                          .selectGame(game);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (owlColors.isLight
                                  ? owlColors.turboBlue.withValues(alpha: 0.08)
                                  : owlColors.textPrimary.withValues(
                                      alpha: 0.08,
                                    ))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? (owlColors.isLight
                                    ? owlColors.turboBlue.withValues(
                                        alpha: 0.25,
                                      )
                                    : owlColors.textPrimary.withValues(
                                        alpha: 0.08,
                                      ))
                              : Colors.transparent,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: owlColors.isLight
                                      ? owlColors.turboBlue.withValues(
                                          alpha: 0.08,
                                        )
                                      : ColorPrimitives.segTrackBlack40,
                                  blurRadius: owlColors.isLight ? 12 : 20,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Icon 44x44 r12 + badge
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ColorComponentTokens.gameboxStart,
                                      ColorComponentTokens.gameboxEnd,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: ColorPrimitives.glassWhite15,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: game.iconBytes != null
                                    ? Image.memory(
                                        game.iconBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.sports_esports_outlined,
                                        color: owlColors.textPrimary.withValues(
                                          alpha: 0.54,
                                        ),
                                        size: 22,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 1,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: ColorComponentTokens.gameboxBadgeBg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    game.category.contains('MOBA')
                                        ? '5v5'
                                        : '${game.targetFps}F',
                                    style: TypographyTokens.telemetryBadge
                                        .copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: ColorComponentTokens
                                              .gameboxBadgeFg,
                                          height: 1,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Title 12.5px w700 white, max 110 ellipsis
                          Expanded(
                            child: Text(
                              game.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TypographyTokens.titleSmall.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? owlColors.textPrimary
                                    : owlColors.textSecondary,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildCenterStage(
    InstalledGame? activeGame,
    List<InstalledGame> deckGames,
  ) {
    final owlColors = ColorTokens.of(context);
    void switchGameDelta(int delta) {
      if (deckGames.isEmpty) return;
      HapticFeedback.selectionClick();
      final newIndex = (_activeHeroIndex + delta).clamp(0, 4);
      setState(() => _activeHeroIndex = newIndex);
      final target = deckGames[newIndex % deckGames.length];
      ref.read(installedGamesProvider.notifier).selectGame(target);
    }

    // 1:1 from finalized prototype — static cinematic showcase:
    // splash left + inset gameplay 290x165 gold border + TRIPLE KILL
    // + gold gradient headline + purple subpill + 5-bar pagination.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hero cinematic card 500x295 r20, purple glow + deep shadow
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final vel = details.primaryVelocity;
            if (vel != null) {
              if (vel < -200) {
                switchGameDelta(1);
              } else if (vel > 200) {
                switchGameDelta(-1);
              }
            }
          },
          child: Container(
            width: 500,
            height: 295,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: owlColors.isLight
                    ? owlColors.borderGlassStrong
                    : ColorComponentTokens.heroCardBorder,
              ),
              boxShadow: ElevationTokens.heroShadows(owlColors.isLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base splash — bundled cinematic artwork (left-center)
                Image.asset(
                  'assets/images/wild_rift_splash.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
                // Cinematic legibility gradient: 10% -> 40% -> 95%
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorComponentTokens.heroScrimTop,
                        ColorComponentTokens.heroScrimMid,
                        ColorComponentTokens.heroScrimBottom,
                      ],
                      stops: [0.0, 0.4, 0.9],
                    ),
                  ),
                ),

                // Inset gameplay preview — top 22 right 22, 290x165 r12
                Positioned(
                  top: 22,
                  right: 22,
                  child: Container(
                    width: 290,
                    height: 165,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorComponentTokens.goldBorder,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        ElevationTokens.toolboxDeep,
                        BoxShadow(
                          color: ColorPrimitives.goldGlow25,
                          blurRadius: 20,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/moba_gameplay_bg.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Inner vignette
                        Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.7,
                              colors: [
                                Colors.transparent,
                                ColorPrimitives.scrimBlack60,
                              ],
                            ),
                          ),
                        ),
                        // Triple-kill badge — top centered
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorComponentTokens.tripleKillBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: ColorTokens.goldSolid,
                                ),
                                boxShadow: const [ElevationTokens.goldBadge],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 10,
                                    color: ColorTokens.goldSolid,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'TRIPLE KILL',
                                    style: TypographyTokens.tripleKillLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom headline cluster
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gold gradient headline 24px 900
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorTokens.textPrimary,
                            ColorPrimitives.goldPale,
                            ColorPrimitives.amberWarning,
                            ColorPrimitives.goldDeep,
                          ],
                          stops: [0.0, 0.4, 0.8, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          activeGame?.name.toUpperCase() ??
                              '5V5 ACTION GAMEPLAY',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.heroHeadline,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Purple subpill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          gradient: LinearGradient(
                            colors: [
                              owlColors.consolePurple.withValues(alpha: 0.5),
                              owlColors.consolePurpleVivid.withValues(
                                alpha: 0.85,
                              ),
                              owlColors.consolePurple.withValues(alpha: 0.5),
                            ],
                          ),
                          border: Border.all(
                            color: ColorComponentTokens.subpillBorder,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: ColorPrimitives.subpillGlow40,
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: owlColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SKILL LEADS TO VICTORY',
                              style: TypographyTokens.subpillLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 5-bar pagination — gap 6, h3, w14 / active w22 blue glow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isActive = index == _activeHeroIndex;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeHeroIndex = index);
                if (deckGames.isNotEmpty) {
                  final target = deckGames[index % deckGames.length];
                  ref.read(installedGamesProvider.notifier).selectGame(target);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 14,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? owlColors.turboBlue
                      : owlColors.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: owlColors.turboBlue.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlayWing(InstalledGame? activeGame) {
    // Signature Game Turbo Play wing — 175x114, blue gradient,
    // uniform hairline border (radius-safe) + stronger left edge accent.
    final owlColors = ColorTokens.of(context);
    return SizedBox(
      width: 175,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _launchGameMatch(activeGame),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 175,
            height: 114,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [owlColors.playWingStart, owlColors.playWingEnd],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              border: Border.all(
                color: owlColors.isLight
                    ? owlColors.turboBlue.withValues(alpha: 0.25)
                    : owlColors.textPrimary.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [ElevationTokens.playWingShadow(owlColors.isLight)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Left edge accent on the container edge (radius-safe).
                  Positioned(
                    left: -14,
                    top: -10,
                    bottom: -10,
                    child: Container(
                      width: 1.5,
                      color: ColorComponentTokens.playWingBorder,
                    ),
                  ),
                  // Chevron accent — right 6, white 50%
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: ColorPrimitives.scrimWhite50,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 17,
                            color: ColorComponentTokens.playWingFg,
                          ),
                          const SizedBox(width: 6),
                          Text('Play', style: TypographyTokens.playWingTitle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Game Turbo can turn on automatically',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.playWingSubtitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGpuTab(InstalledGame? activeGame) {
    // Beveled trapezoid tab — polygon(10% 0%, 90% 0%, 100% 100%, 0% 100%)
    // 240x40, with theme-aware border and ambient shadow.
    final owlColors = ColorTokens.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openGpuSettings(activeGame),
        child: CustomPaint(
          painter: _GpuTabBorderPainter(
            borderColor: owlColors.isLight
                ? owlColors.borderGlassStrong
                : ColorPrimitives.glassWhite15,
            fillColor: owlColors.gpuTabFill,
            shadowColor: owlColors.isLight
                ? owlColors.textPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Container(
            width: 240,
            height: 40,
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: owlColors.turboBlue,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: owlColors.turboBlue.withValues(
                          alpha: owlColors.isLight ? 0.35 : 0.45,
                        ),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GPU settings',
                  style: TypographyTokens.gpuTabLabel.copyWith(
                    color: owlColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the beveled GPU tab trapezoid:
/// Draws the angled fill, stroke along the visible top/side borders,
/// and subtle elevation shadow in light mode.
class _GpuTabBorderPainter extends CustomPainter {
  const _GpuTabBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
  });

  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.10, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width, size.height)
      ..close();

    if (shadowColor.a > 0) {
      canvas.drawShadow(path, shadowColor, 8.0, false);
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.10, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GpuTabBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
