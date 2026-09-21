import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owl_core/owl_core.dart';
import '../providers/skin_provider.dart';

class SkinManagerScreen extends StatefulWidget {
  final Game game;

  const SkinManagerScreen({super.key, required this.game});

  @override
  State<SkinManagerScreen> createState() => _SkinManagerScreenState();
}

class _SkinManagerScreenState extends State<SkinManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkinProvider>().loadSkinPacksForGame(widget.game.id);
    });
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  void _showPreviewDialog(BuildContext context, SkinPack pack) {
    final theme = Theme.of(context);
    final accentColor = _parseHexColor(pack.accentColor);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pack.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pack.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Version: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(pack.version),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Author: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(pack.author),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: pack.previewTags
                    .map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          backgroundColor: accentColor.withOpacity(0.15),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accentColor),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<SkinProvider>().applySkinPack(widget.game.id, pack);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Applied "${pack.name}" (v${pack.version})'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              },
              child: Text(pack.isApplied ? 'Re-Apply' : 'Apply Pack'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearSkin(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Restore Default Config?'),
          content: const Text(
            'This will clear the active skin and visual configuration profile, restoring default game presentation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<SkinProvider>().clearAppliedSkin(widget.game.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No Custom Pack Applied. Defaults restored.'),
                  ),
                );
              },
              child: const Text('Clear & Restore'),
            ),
          ],
        );
      },
    );
  }

  void _showImportGuidance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import User Config Pack',
                style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Place your custom skin or shader config JSON file inside your device\'s Owl/Configs directory or select a local archive to import.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Import scanner ready: Drop .json pack to /sdcard/Owl/Configs'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Select Local Config Archive'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skinProvider = context.watch<SkinProvider>();
    final skinPacks = skinProvider.getSkinPacksForGame(widget.game.id);
    final appliedPack = skinProvider.getAppliedSkinPack(widget.game.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.game.name} Skins'),
        actions: [
          IconButton(
            tooltip: 'Import Custom Pack',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showImportGuidance(context),
          ),
        ],
      ),
      body: skinProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Legal Safe notice
                const LegalNoticeBanner(),

                // Active Applied Status Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appliedPack != null
                        ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: appliedPack != null
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : theme.colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appliedPack != null
                            ? Icons.check_circle_rounded
                            : Icons.palette_outlined,
                        color: appliedPack != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appliedPack != null
                                  ? 'Active Profile: ${appliedPack.name}'
                                  : 'No Custom Pack Applied',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appliedPack != null
                                  ? 'Version ${appliedPack.version} • ${appliedPack.appliedAt != null ? "Applied ${appliedPack.appliedAt!.hour.toString().padLeft(2, '0')}:${appliedPack.appliedAt!.minute.toString().padLeft(2, '0')}" : "Active"}'
                                  : 'Standard default textures and shaders active',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (appliedPack != null)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => _confirmClearSkin(context),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Packs (${skinPacks.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.file_open_outlined, size: 16),
                        label: const Text('Import'),
                        onPressed: () => _showImportGuidance(context),
                      ),
                    ],
                  ),
                ),

                // Empty catalog state
                if (skinPacks.isEmpty)
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Packs for ${widget.game.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Community configs must be imported manually. You can import user-made config profiles (.json/.zip).',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showImportGuidance(context),
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Import Guidance Action'),
                        ),
                      ],
                    ),
                  ),

                // List of skin packs
                ...skinPacks.map((pack) {
                  final accentColor = _parseHexColor(pack.accentColor);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: pack.isApplied
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withOpacity(0.4),
                        width: pack.isApplied ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: accentColor, width: 2),
                                ),
                                child: Icon(
                                  Icons.auto_fix_high_rounded,
                                  size: 18,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pack.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'v${pack.version} by ${pack.author}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (pack.isApplied)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Applied',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pack.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => _showPreviewDialog(context, pack),
                                child: const Text('Preview'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: pack.isApplied
                                      ? Colors.grey.shade700
                                      : accentColor,
                                ),
                                onPressed: () {
                                  context
                                      .read<SkinProvider>()
                                      .applySkinPack(widget.game.id, pack);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Applied "${pack.name}" (v${pack.version})'),
                                      backgroundColor: Colors.green.shade700,
                                    ),
                                  );
                                },
                                child: Text(pack.isApplied ? 'Re-Apply' : 'Apply'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
