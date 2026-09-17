// language: Dart, file: game_discovery_service.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owl/features/game_profiles/data/presets/mlbb_preset.dart';
import 'package:owl/features/game_profiles/data/presets/pokemon_unite_preset.dart';
import 'package:owl/features/game_profiles/data/presets/wild_rift_preset.dart';
import 'package:owl/features/game_profiles/domain/models/game_profile.dart';
import 'package:owl/features/game_profiles/domain/models/installed_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for dynamic game discovery, package inspection,
/// and native game launching via Android PackageManager and MethodChannels.
class GameDiscoveryService {
  static const MethodChannel _channel = MethodChannel('com.example.owl/games');

  static const String _keyGameSpaceList = 'owl_gamespace_package_list';
  static const String _keyActivePackage = 'owl_gamespace_active_package';

  final SharedPreferences? _prefs;

  const GameDiscoveryService([this._prefs]);

  /// Query installed games on the host device dynamically.
  Future<List<InstalledGame>> getInstalledGames() async {
    List<InstalledGame> discovered = [];

    // Attempt native Android PackageManager discovery
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final List<dynamic>? nativeResults =
            await _channel.invokeListMethod<dynamic>('getInstalledGames');

        if (nativeResults != null && nativeResults.isNotEmpty) {
          for (final item in nativeResults) {
            if (item is Map) {
              final pkg = item['packageName'] as String? ?? '';
              final name = item['name'] as String? ?? 'Unknown Game';
              final iconBytes = item['iconBytes'] as Uint8List?;
              final isGame = item['isGame'] as bool? ?? true;
              final isSystem = item['isSystem'] as bool? ?? false;

              discovered.add(
                InstalledGame(
                  id: pkg,
                  name: name,
                  packageName: pkg,
                  iconBytes: iconBytes,
                  isGame: isGame,
                  isSystem: isSystem,
                  category: _categorizePackage(pkg, name),
                  targetFps: _inferTargetFps(pkg),
                  tacticalProfile: _matchPresetProfile(pkg, name),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[GameDiscoveryService] Native scan fallback: $e');
      }
    }

    // If native discovery returned 0 games (e.g. running on Windows, macOS, Linux, emulator, or tests)
    // generate dynamic detected game deck so user has instant playable games
    if (discovered.isEmpty) {
      discovered = _getFallbackDiscoveredGames();
    }

    // Apply user preferences for games added to Game Space deck
    final enabledPackages = _prefs?.getStringList(_keyGameSpaceList);
    if (enabledPackages != null && enabledPackages.isNotEmpty) {
      return discovered.map((game) {
        final inDeck = enabledPackages.contains(game.packageName);
        return game.copyWith(isInGameSpace: inDeck);
      }).toList();
    }

    return discovered;
  }

  /// Query ALL launchable applications installed on device for the (+) Add Game picker.
  Future<List<InstalledGame>> getAllInstalledApps() async {
    List<InstalledGame> allApps = [];

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final List<dynamic>? nativeResults =
            await _channel.invokeListMethod<dynamic>('getAllApplications');

        if (nativeResults != null && nativeResults.isNotEmpty) {
          for (final item in nativeResults) {
            if (item is Map) {
              final pkg = item['packageName'] as String? ?? '';
              final name = item['name'] as String? ?? 'Unknown App';
              final iconBytes = item['iconBytes'] as Uint8List?;
              final isGame = item['isGame'] as bool? ?? false;
              final isSystem = item['isSystem'] as bool? ?? false;

              allApps.add(
                InstalledGame(
                  id: pkg,
                  name: name,
                  packageName: pkg,
                  iconBytes: iconBytes,
                  isGame: isGame,
                  isSystem: isSystem,
                  category: _categorizePackage(pkg, name),
                  targetFps: _inferTargetFps(pkg),
                  tacticalProfile: _matchPresetProfile(pkg, name),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[GameDiscoveryService] All apps query fallback: $e');
      }
    }

    if (allApps.isEmpty) {
      allApps = _getFallbackDiscoveredGames();
    }

    return allApps;
  }

  /// Launch the game by package name via Android native launch intent.
  Future<bool> launchGame(
    String packageName, {
    String? gameName,
    int? targetFps,
    String? aiApiKey,
    String? aiProvider,
    String? aiModel,
  }) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final payload = <String, dynamic>{
          'packageName': packageName,
          'gameName': gameName,
          'targetFps': targetFps,
        };
        if (aiApiKey != null && aiApiKey.isNotEmpty) {
          payload['aiApiKey'] = aiApiKey;
        }
        if (aiProvider != null) {
          payload['aiProvider'] = aiProvider;
        }
        if (aiModel != null) {
          payload['aiModel'] = aiModel;
        }
        final bool? success = await _channel.invokeMethod<bool>(
          'launchGame',
          payload,
        );
        return success ?? false;
      } catch (e) {
        debugPrint('[GameDiscoveryService] Failed to launch $packageName: $e');
        return false;
      }
    }

    debugPrint('[GameDiscoveryService] Desktop/Simulation launch: $packageName');
    return false;
  }

  /// Update live AI credentials for the active overlay service.
  Future<bool> setAiCredentials({
    String? apiKey,
    String provider = 'gemini',
    String model = 'gemini-3-flash-preview',
  }) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? success = await _channel.invokeMethod<bool>(
          'setAiCredentials',
          {
            'apiKey': apiKey,
            'provider': provider,
            'model': model,
          },
        );
        return success ?? false;
      } catch (e) {
        debugPrint('[GameDiscoveryService] Failed to set AI credentials: $e');
        return false;
      }
    }
    return false;
  }

  /// Check if the Android device has granted SYSTEM_ALERT_WINDOW (Display over other apps).
  Future<bool> hasOverlayPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? granted =
            await _channel.invokeMethod<bool>('hasOverlayPermission');
        return granted ?? false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Request the user to grant Display Over Other Apps in Android system settings.
  Future<bool> requestOverlayPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? success =
            await _channel.invokeMethod<bool>('requestOverlayPermission');
        return success ?? false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Save the user's active game selection.
  Future<void> saveActiveGamePackage(String packageName) async {
    await _prefs?.setString(_keyActivePackage, packageName);
  }

  /// Read the user's saved active game selection.
  String? getActiveGamePackage() {
    return _prefs?.getString(_keyActivePackage);
  }

  /// Toggle or update the list of packages enabled in the Game Space deck.
  Future<void> updateGameSpaceDeck(List<String> packageNames) async {
    await _prefs?.setStringList(_keyGameSpaceList, packageNames);
  }

  // ---------------------------------------------------------------------------
  // INTERNALS & HEURISTICS
  // ---------------------------------------------------------------------------

  static String _categorizePackage(String pkg, String name) {
    final lower = '$pkg $name'.toLowerCase();
    if (lower.contains('moba') ||
        lower.contains('league') ||
        lower.contains('legends') ||
        lower.contains('rift') ||
        lower.contains('unite') ||
        lower.contains('dota') ||
        lower.contains('arena of valor')) {
      return '5v5 MOBA';
    }
    if (lower.contains('pubg') ||
        lower.contains('freefire') ||
        lower.contains('cod') ||
        lower.contains('shooter') ||
        lower.contains('fps')) {
      return 'Battle Royale / FPS';
    }
    if (lower.contains('genshin') ||
        lower.contains('honkai') ||
        lower.contains('rpg')) {
      return 'Open World RPG';
    }
    if (lower.contains('racing') || lower.contains('asphalt')) {
      return 'Racing';
    }
    return 'Action / Gaming';
  }

  static int _inferTargetFps(String pkg) {
    final lower = pkg.toLowerCase();
    if (lower.contains('mobile.legends') ||
        lower.contains('wildrift') ||
        lower.contains('pubg')) {
      return 120;
    }
    return 60;
  }

  static GameProfile? _matchPresetProfile(String pkg, String name) {
    final lower = '$pkg $name'.toLowerCase();
    if (lower.contains('mobile.legends') || lower.contains('mlbb')) {
      return mlbbPreset;
    }
    if (lower.contains('wildrift') || lower.contains('riotgames')) {
      return wildRiftPreset;
    }
    if (lower.contains('pokemon.unite') || lower.contains('unite')) {
      return pokemonUnitePreset;
    }
    return null;
  }

  static List<InstalledGame> _getFallbackDiscoveredGames() {
    return [
      InstalledGame(
        id: 'com.mobile.legends',
        name: 'Mobile Legends: Bang Bang',
        packageName: 'com.mobile.legends',
        category: '5v5 MOBA',
        targetFps: 120,
        tacticalProfile: mlbbPreset,
      ),
      InstalledGame(
        id: 'com.riotgames.league.wildrift',
        name: 'League of Legends: Wild Rift',
        packageName: 'com.riotgames.league.wildrift',
        category: '5v5 MOBA',
        targetFps: 120,
        tacticalProfile: wildRiftPreset,
      ),
      InstalledGame(
        id: 'jp.pokemon.pokemonunite',
        name: 'Pokémon UNITE',
        packageName: 'jp.pokemon.pokemonunite',
        category: 'MOBA Action',
        targetFps: 60,
        tacticalProfile: pokemonUnitePreset,
      ),
      const InstalledGame(
        id: 'com.miHoYo.GenshinImpact',
        name: 'Genshin Impact',
        packageName: 'com.miHoYo.GenshinImpact',
        category: 'Open World RPG',
        targetFps: 60,
      ),
      const InstalledGame(
        id: 'com.tencent.ig',
        name: 'PUBG MOBILE',
        packageName: 'com.tencent.ig',
        category: 'Battle Royale FPS',
        targetFps: 120,
      ),
    ];
  }
}
