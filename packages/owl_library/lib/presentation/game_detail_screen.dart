import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_mod_studio/owl_mod_studio.dart';
import 'package:owl_skins/owl_skins.dart';
import '../providers/game_provider.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PluginProvider>().loadPluginsForGame(widget.game.id);
      context.read<SkinProvider>().loadSkinPacksForGame(widget.game.id);
    });
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'train':
        return Icons.train_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'sports_baseball':
        return Icons.sports_baseball_rounded;
      case 'cake':
        return Icons.cake_rounded;
      case 'circle':
        return Icons.adjust_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  Future<void> _handlePlay(Game currentGame) async {
    final pluginProvider = context.read<PluginProvider>();
    final launcherService = context.read<LauncherService>();
    final enabledPlugins = pluginProvider.getEnabledPlugins(currentGame.id);

    setState(() {
      _isLaunching = true;
    });

    // Attempt launch
    final result = await launcherService.launchGame(
      currentGame.packageName,
      gameId: currentGame.id,
      enabledPlugins: enabledPlugins,
    );

    if (!mounted) return;

    setState(() {
      _isLaunching = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Launched ${currentGame.name} with ${enabledPlugins.length} active plugins.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // Failed launch surfaces error per spec & keeps user on screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.errorMessage ?? 'Launch failed. Package cannot be opened.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _onTogglePlugin(
      Game currentGame, GamePlugin plugin, bool value) async {
    final pluginProvider = context.read<PluginProvider>();
    final result = await pluginProvider.togglePlugin(currentGame, plugin, value);

    if (!mounted) return;

    if (!result.success) {
      // Version mismatch blocked per spec!
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: Icon(Icons.warning_amber_rounded,
              color: Colors.amber.shade800, size: 36),
          title: const Text('Incompatible Plugin Version'),
          content: Text(result.errorMessage ?? 'Version mismatch error.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameProvider = context.watch<GameProvider>();
    final pluginProvider = context.watch<PluginProvider>();
    final skinProvider = context.watch<SkinProvider>();

    // Resolve freshest game state
    final currentGame = gameProvider.games.firstWhere(
      (g) => g.id == widget.game.id,
      orElse: () => widget.game,
    );

    final plugins = pluginProvider.getPluginsForGame(currentGame.id);
    final enabledCount = pluginProvider.getEnabledPlugins(currentGame.id).length;
    final appliedSkin = skinProvider.getAppliedSkinPack(currentGame.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentGame.name),
        actions: [
          IconButton(
            tooltip: currentGame.isInstalled
                ? 'Simulate Uninstalled'
                : 'Simulate Installed',
            icon: Icon(
              currentGame.isInstalled
                  ? Icons.check_circle_outline
                  : Icons.download_for_offline_outlined,
            ),
            onPressed: () async {
              await gameProvider.toggleMockInstalled(currentGame.id);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: currentGame.isInstalled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            onPressed: _isLaunching ? null : () => _handlePlay(currentGame),
            icon: _isLaunching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    currentGame.isInstalled
                        ? Icons.play_arrow_rounded
                        : Icons.download_rounded,
                    size: 26,
                  ),
            label: Text(
              _isLaunching
                  ? 'Launching Game...'
                  : currentGame.isInstalled
                      ? 'Play with $enabledCount Plugins'
                      : 'Not Installed (Tap for Guide)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _resolveIcon(currentGame.icon),
                  size: 38,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentGame.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentGame.packageName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: currentGame.isInstalled
                                ? Colors.green.withOpacity(0.12)
                                : Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentGame.isInstalled
                                ? 'Installed (v${currentGame.installedVersion ?? currentGame.minVersion})'
                                : 'Not Installed',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentGame.isInstalled
                                  ? Colors.green.shade700
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Min: ${currentGame.minVersion}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            currentGame.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Skin Manager shortcut card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => SkinManagerScreen(game: currentGame),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skin & Config Manager',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appliedSkin != null
                                ? 'Active: ${appliedSkin.name} (v${appliedSkin.version})'
                                : 'Default game configs active (Tap to customize)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Plugins Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Plugins (${plugins.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$enabledCount Enabled',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (pluginProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (plugins.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.extension_off_outlined,
                        size: 36, color: theme.colorScheme.outline),
                    const SizedBox(height: 8),
                    const Text('No plugins available for this game yet.'),
                  ],
                ),
              ),
            )
          else
            ...plugins.map((plugin) {
              final isCompatible = plugin.isCompatibleWith(
                currentGame.installedVersion ?? currentGame.minVersion,
              );

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: plugin.isEnabled
                        ? theme.colorScheme.primary.withOpacity(0.4)
                        : theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          plugin.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (!isCompatible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Mismatch',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(plugin.description),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              plugin.category,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          Text(
                            'v${plugin.version}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  value: plugin.isEnabled,
                  onChanged: (val) => _onTogglePlugin(currentGame, plugin, val),
                ),
              );
            }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
