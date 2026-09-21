import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences? _prefs;

  StorageService([this._prefs]);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService has not been initialized with SharedPreferences');
    }
    return _prefs;
  }

  // Plugin state persistence: key = "plugin_toggle_${gameId}_${pluginId}"
  bool isPluginEnabled(String gameId, String pluginId, {bool defaultValue = false}) {
    if (_prefs == null) return defaultValue;
    return prefs.getBool('plugin_toggle_${gameId}_$pluginId') ?? defaultValue;
  }

  Future<void> setPluginEnabled(String gameId, String pluginId, bool enabled) async {
    if (_prefs == null) return;
    await prefs.setBool('plugin_toggle_${gameId}_$pluginId', enabled);
  }

  // Applied skin state persistence
  String? getAppliedSkinPackId(String gameId) {
    if (_prefs == null) return null;
    return prefs.getString('applied_skin_${gameId}_id');
  }

  DateTime? getAppliedSkinTimestamp(String gameId) {
    if (_prefs == null) return null;
    final iso = prefs.getString('applied_skin_${gameId}_timestamp');
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  String? getPreviousAppliedSkinPackId(String gameId) {
    if (_prefs == null) return null;
    return prefs.getString('previous_skin_${gameId}_id');
  }

  Future<void> setAppliedSkinPack(String gameId, String packId) async {
    if (_prefs == null) return;
    final current = getAppliedSkinPackId(gameId);
    if (current != null && current != packId) {
      await prefs.setString('previous_skin_${gameId}_id', current);
    }
    await prefs.setString('applied_skin_${gameId}_id', packId);
    await prefs.setString('applied_skin_${gameId}_timestamp', DateTime.now().toIso8601String());
  }

  Future<void> clearAppliedSkinPack(String gameId) async {
    if (_prefs == null) return;
    final current = getAppliedSkinPackId(gameId);
    if (current != null) {
      await prefs.setString('previous_skin_${gameId}_id', current);
    }
    await prefs.remove('applied_skin_${gameId}_id');
    await prefs.remove('applied_skin_${gameId}_timestamp');
  }

  // Mock installed game override for testing or manual simulation
  bool isMockGameInstalled(String gameId, {bool defaultInstalled = false}) {
    if (_prefs == null) return defaultInstalled;
    return prefs.getBool('mock_installed_$gameId') ?? defaultInstalled;
  }

  Future<void> setMockGameInstalled(String gameId, bool installed) async {
    if (_prefs == null) return;
    await prefs.setBool('mock_installed_$gameId', installed);
  }
}
