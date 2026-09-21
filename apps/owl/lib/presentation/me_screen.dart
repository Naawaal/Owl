import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_library/owl_library.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // User Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lulubox Gamer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Local Sandbox Profile',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${gameProvider.installedGames.length} Active Games',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const LegalNoticeBanner(),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'TOOLBOX CONTROLS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Reset Mock Data & Library'),
            subtitle: const Text('Reloads catalog.json baseline'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              await gameProvider.loadGames();
              messenger.showSnackBar(
                const SnackBar(content: Text('Catalog refreshed.')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear All Mock Preferences'),
            subtitle: const Text('Resets local test overrides'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences reset.')),
              );
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'ABOUT & LEGAL',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Version'),
            trailing: Text('0.1.0+1 (MVP Greenfield)'),
          ),

          const ListTile(
            leading: Icon(Icons.gavel_outlined),
            title: Text('Zero-Cheat Compliance'),
            subtitle: Text('No memory tampering, no binary injection'),
          ),

          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Storage Sandbox'),
            subtitle: Text('Isolated local user configurations'),
          ),
        ],
      ),
    );
  }
}
