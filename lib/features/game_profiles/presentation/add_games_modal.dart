// language: Dart, file: add_games_modal.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Modal dialog allowing users to scan and add any installed device application
/// to the Game Space deck.
class AddGamesModal extends ConsumerStatefulWidget {
  const AddGamesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => const AddGamesModal(),
    );
  }

  @override
  ConsumerState<AddGamesModal> createState() => _AddGamesModalState();
}

class _AddGamesModalState extends ConsumerState<AddGamesModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<InstalledGame> _allApps = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceApplications();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceApplications() async {
    final service = ref.read(gameDiscoveryServiceProvider);
    final apps = await service.getAllInstalledApps();
    if (mounted) {
      setState(() {
        _allApps = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(installedGamesProvider);
    final inDeckPackages = gameState.games
        .where((g) => g.isInGameSpace)
        .map((g) => g.packageName)
        .toSet();

    final filtered = _allApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return app.name.toLowerCase().contains(q) ||
          app.packageName.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Container(
        width: 680,
        height: 420,
        decoration: BoxDecoration(
          color: const Color(0xFF0D111A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33FFFFFF), width: 1.2),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 40, spreadRadius: 10),
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
                      color: ColorSemantics.turboBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_to_photos_outlined,
                      size: 18,
                      color: ColorSemantics.turboBlueLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Add Games to Game Space',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Boost FPS, optimize touch sampling & enable Guardian overlay',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0x8AFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.white70),
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
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 12.5, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search installed games or apps...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0x66FFFFFF)),
                    prefixIcon: Icon(Icons.search, size: 16, color: Color(0x8AFFFFFF)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const Divider(color: Color(0x1AFFFFFF), height: 16),

            // App List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: ColorSemantics.turboBlue,
                      ),
                    )
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching applications found',
                            style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (context, _) =>
                              const Divider(color: Color(0x0FFFFFFF), height: 8),
                          itemBuilder: (context, index) {
                            final app = filtered[index];
                            final isEnabled = inDeckPackages.contains(app.packageName);

                            return Row(
                              children: [
                                // Icon
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1E2638), Color(0xFF2C3E55)],
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: app.iconBytes != null
                                      ? Image.memory(
                                          app.iconBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.sports_esports_outlined,
                                          size: 20,
                                          color: Colors.white70,
                                        ),
                                ),
                                const SizedBox(width: 12),

                                // Title & Package
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        app.packageName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0x66FFFFFF),
                                          fontFamily: TypographyTokens.monoFontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // MIUI Switch Toggle
                                MiuiSwitch(
                                  value: isEnabled,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    ref
                                        .read(installedGamesProvider.notifier)
                                        .toggleGameInSpace(app, val);
                                  },
                                ),
                              ],
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
