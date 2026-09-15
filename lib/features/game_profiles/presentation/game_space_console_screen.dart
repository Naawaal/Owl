// language: Dart, file: game_space_console_screen.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/add_games_modal.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/overlay/presentation/tactical_battlefield_hud.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';
import 'package:owl_design/owl_design.dart';

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

class _GameSpaceConsoleScreenState
    extends ConsumerState<GameSpaceConsoleScreen> {
  int _activeHeroIndex = 0;

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

  void _launchGameMatch(InstalledGame? activeGame) async {
    HapticFeedback.heavyImpact();
    if (activeGame != null) {
      await ref.read(installedGamesProvider.notifier).launchActiveGame();
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TacticalBattlefieldHud(
            activeGame: activeGame,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(installedGamesProvider);
    final deckGames =
        gameState.games.where((g) => g.isInGameSpace).toList();
    final activeGame = gameState.activeGame ?? deckGames.firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          // 1. Ambient Horizon Radial Gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.0),
                  radius: 0.9,
                  colors: [
                    Color(0x2E8B2BE2),
                    Color(0x0D140A28),
                    Color(0xFF06070B),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Console Layout
          SafeArea(
            child: Column(
              children: [
                // Top Status Bar
                _buildTopStatusBar(),

                // Center Stage & Sidebars
                Expanded(
                  child: Stack(
                    children: [
                      // Left Vertical Sidebar (Gamebox & Game Pill)
                      Positioned(
                        left: 24,
                        top: 0,
                        bottom: 40,
                        child: _buildLeftSidebar(deckGames, activeGame),
                      ),

                      // Center Hero Showcase
                      Positioned(
                        left: 240,
                        right: 175,
                        top: 8,
                        bottom: 40,
                        child: _buildCenterStage(activeGame),
                      ),

                      // Right Action Wing (⚡ Play)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: _buildPlayWing(activeGame),
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
        ],
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Battery 71% & CPU 30%
          Row(
            children: [
              // Battery
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xB3FFFFFF), width: 1.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorSemantics.turboBlue,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      width: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '71%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // CPU
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x33007AFF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorSemantics.turboBlue.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'CPU',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: ColorSemantics.turboBlueLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '30%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Add Game (+) & Settings Gear
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Color(0xE6FFFFFF)),
                tooltip: 'Add Game to Game Space',
                onPressed: _openAddGames,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    size: 19, color: Color(0xE6FFFFFF)),
                tooltip: 'Game Turbo Settings',
                onPressed: _openAppSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(
      List<InstalledGame> deckGames, InstalledGame? activeGame) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gamebox Header Node
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x664F46E5), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.sports_esports_outlined,
                    size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Gamebox (${deckGames.length})',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Empty state or game selector
          if (deckGames.isEmpty)
            GestureDetector(
              onTap: _openAddGames,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0x33FFFFFF), style: BorderStyle.solid),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 16, color: ColorSemantics.turboBlueLight),
                    SizedBox(width: 8),
                    Text(
                      'Add First Game',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Active Game Pill
            if (activeGame != null)
              Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: ColorSemantics.turboBlue.withValues(alpha: 0.45)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 16),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic Avatar with Corner Badge
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: activeGame.iconBytes != null
                              ? Image.memory(
                                  activeGame.iconBytes!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAB308),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4)),
                            ),
                            child: Text(
                              activeGame.category.contains('MOBA')
                                  ? '5v5'
                                  : '${activeGame.targetFps}F',
                              style: const TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activeGame.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Inactive game chips in deck for quick switching
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: deckGames
                    .where((g) => g.packageName != activeGame?.packageName)
                    .take(4)
                    .map((game) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(installedGamesProvider.notifier)
                            .selectGame(game);
                      },
                      child: Tooltip(
                        message: game.name,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: const Color(0x14FFFFFF),
                            border: Border.all(
                                color: const Color(0x22FFFFFF), width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: game.iconBytes != null
                              ? Image.memory(
                                  game.iconBytes!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.sports_esports_outlined,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCenterStage(InstalledGame? activeGame) {
    final title = activeGame?.name ?? 'Mobile Legends: Bang Bang';
    final category = activeGame?.category ?? '5v5 MOBA';
    final targetFps = activeGame?.targetFps ?? 120;

    return Column(
      children: [
        // Main Cinematic Hero Card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E2235), Color(0xFF0F121C)],
              ),
              border: Border.all(color: const Color(0x22FFFFFF)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xE0000000),
                    blurRadius: 30,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Stack(
              children: [
                // Inset Gameplay / Tactical Preview
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 120,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xD9000000),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFFFD700), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on,
                                    size: 9, color: Color(0xFFFFD700)),
                                const SizedBox(width: 2),
                                Text(
                                  activeGame?.tacticalProfile != null
                                      ? 'AI COACH'
                                      : 'TURBO 2026',
                                  style: const TextStyle(
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 6,
                          right: 6,
                          child: Text(
                            activeGame?.packageName ?? 'Dynamic Package',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0x8AFFFFFF),
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Bottom Headline
                Positioned(
                  left: 18,
                  bottom: 16,
                  right: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${category.toUpperCase()} • $targetFps FPS',
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: ColorSemantics.turboBlueLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 5-bar Pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isActive = index == _activeHeroIndex;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeHeroIndex = index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 3.5,
                decoration: BoxDecoration(
                  color: isActive
                      ? ColorSemantics.turboBlue
                      : const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                ColorSemantics.turboBlue.withValues(alpha: 0.6),
                            blurRadius: 6,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchGameMatch(activeGame),
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              ColorSemantics.turboBlue.withValues(alpha: 0.0),
              ColorSemantics.turboBlue.withValues(alpha: 0.25),
              ColorSemantics.turboBlue.withValues(alpha: 0.6),
            ],
          ),
          border: const Border(
            left: BorderSide(color: Color(0x33007AFF), width: 1.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '⚡ Play',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right,
                    size: 18, color: ColorSemantics.turboBlueLight),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Game Turbo turns on automatically for ${activeGame != null ? activeGame.name.split(':').first : 'Game'}',
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8.5,
                color: Color(0x8AFFFFFF),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomGpuTab(InstalledGame? activeGame) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openGpuSettings(activeGame),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xCC111624),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            border: Border.all(color: const Color(0x24FFFFFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 2.5,
                decoration: BoxDecoration(
                  color: ColorSemantics.turboBlue,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ColorSemantics.turboBlue.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'GPU settings',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
