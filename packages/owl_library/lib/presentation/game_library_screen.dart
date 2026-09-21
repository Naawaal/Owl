import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owl_core/owl_core.dart';
import '../providers/game_provider.dart';
import 'game_card.dart';
import 'game_detail_screen.dart';

class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({super.key});

  @override
  State<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends State<GameLibraryScreen> {
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Installed, 2: Not Installed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameProvider = context.watch<GameProvider>();

    List<Game> filteredGames = gameProvider.games;
    if (_selectedFilterIndex == 1) {
      filteredGames = gameProvider.installedGames;
    } else if (_selectedFilterIndex == 2) {
      filteredGames = gameProvider.notInstalledGames;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredGames = filteredGames
          .where((g) =>
              g.name.toLowerCase().contains(query) ||
              g.category.toLowerCase().contains(query) ||
              g.packageName.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: 'Search games or categories...',
              leading: const Icon(Icons.search),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    ]
                  : null,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor:
                  WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('All (${gameProvider.games.length})'),
                  selected: _selectedFilterIndex == 0,
                  onSelected: (val) => setState(() => _selectedFilterIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Installed (${gameProvider.installedGames.length})'),
                  selected: _selectedFilterIndex == 1,
                  onSelected: (val) => setState(() => _selectedFilterIndex = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(
                      'Not Installed (${gameProvider.notInstalledGames.length})'),
                  selected: _selectedFilterIndex == 2,
                  onSelected: (val) => setState(() => _selectedFilterIndex = 2),
                ),
              ],
            ),
          ),

          Expanded(
            child: gameProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredGames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_esports_outlined,
                                size: 54, color: theme.colorScheme.outline),
                            const SizedBox(height: 12),
                            Text(
                              'No Games Found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search or filter criteria.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => gameProvider.loadGames(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 6, bottom: 20),
                          itemCount: filteredGames.length,
                          itemBuilder: (ctx, index) {
                            final game = filteredGames[index];
                            final pluginCount =
                                gameProvider.getPluginCount(game.id);

                            return GameCard(
                              game: game,
                              pluginCount: pluginCount,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GameDetailScreen(game: game),
                                  ),
                                );
                              },
                              onToggleInstalled: () {
                                gameProvider.toggleMockInstalled(game.id);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
