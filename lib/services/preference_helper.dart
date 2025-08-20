import 'package:shared_preferences/shared_preferences.dart';


class Pref {
  // Singleton pattern
  Pref._privateConstructor();
  static final Pref instance = Pref._privateConstructor();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences instance (call once in app startup)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set String value
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) await init();
    return _prefs!.setString(key, value);
  }

  // Get String value
  String? getString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  // Set bool value
  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    return _prefs!.setBool(key, value);
  }

  // Get bool value
  bool? getBool(String key) {
    if (_prefs == null) return null;
    return _prefs!.getBool(key);
  }

  // Remove a key
  Future<bool> remove(String key) async {
    if (_prefs == null) await init();
    return _prefs!.remove(key);
  }

  // Clear all keys (use carefully!)
  Future<bool> clear() async {
    if (_prefs == null) await init();
    return _prefs!.clear();
  }
}
