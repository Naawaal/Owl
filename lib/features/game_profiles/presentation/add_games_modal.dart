// language: Dart, file: add_games_modal.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/game_profiles/presentation/widgets/add_game_tile.dart';
import 'package:owl_design/owl_design.dart';

/// Autodisposed provider querying all installed device apps.
final deviceInstalledAppsProvider =
    FutureProvider.autoDispose<List<InstalledGame>>((ref) async {
  final service = ref.watch(gameDiscoveryServiceProvider);
  return service.getAllInstalledApps();
});

/// Autodisposed search filter for the Add Games modal.
final addGamesSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Modal dialog allowing users to scan and add any installed device application
/// to the Game Space deck.
class AddGamesModal extends ConsumerWidget {
  const AddGamesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: ColorPrimitives.scrimBlack88,
      builder: (context) => const AddGamesModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final gameState = ref.watch(installedGamesProvider);
    final appsAsync = ref.watch(deviceInstalledAppsProvider);
    final searchQuery = ref.watch(addGamesSearchQueryProvider);

    final inDeckPackages = gameState.games
        .where((g) => g.isInGameSpace)
        .map((g) => g.packageName)
        .toSet();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Container(
        width: 680,
        height: 420,
        decoration: BoxDecoration(
          color: colors.isLight ? colors.surfaceCard : colors.consoleBase,
          borderRadius: RadiusTokens.borderXl,
          border: Border.all(
            color: colors.borderGlassStrong,
            width: 1.2,
          ),
          boxShadow: [
            ElevationTokens.toolboxShadow(colors.isLight),
          ],
        ),
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.turboBlue
                          .withValues(alpha: colors.isLight ? 0.12 : 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_to_photos_outlined,
                      size: 18,
                      color: colors.turboBlueLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Games to Game Space',
                          style: TypographyTokens.dialogTitleOf(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Boost FPS, optimize touch sampling & enable Guardian overlay',
                          style: TypographyTokens.bodySmallOf(context).copyWith(
                            fontSize: 10.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: colors.textPrimary.withValues(alpha: 0.7),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: colors.isLight
                      ? colors.surfaceElevated
                      : colors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.borderGlass),
                ),
                child: TextField(
                  onChanged: (val) =>
                      ref.read(addGamesSearchQueryProvider.notifier).state =
                          val,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search installed games or apps...',
                    hintStyle: TypographyTokens.bodySmallOf(context).copyWith(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            Divider(color: colors.borderGlass, height: 16),

            // App List
            Expanded(
              child: appsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.turboBlue,
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Failed to scan installed apps: $err',
                    style: TypographyTokens.bodySmallOf(context).copyWith(
                      color: colors.telemetryCritical,
                    ),
                  ),
                ),
                data: (allApps) {
                  final filtered = allApps.where((app) {
                    if (searchQuery.isEmpty) return true;
                    final q = searchQuery.toLowerCase();
                    return app.name.toLowerCase().contains(q) ||
                        app.packageName.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching applications found',
                        style:
                            TypographyTokens.bodySmallOf(context).copyWith(
                          color: colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, _) =>
                        Divider(color: colors.borderGlass, height: 8),
                    itemBuilder: (context, index) {
                      final app = filtered[index];
                      final isEnabled =
                          inDeckPackages.contains(app.packageName);

                      return AddGameTile(
                        app: app,
                        isEnabled: isEnabled,
                        onChanged: (val) {
                          ref
                              .read(installedGamesProvider.notifier)
                              .toggleGameInSpace(app, val);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
