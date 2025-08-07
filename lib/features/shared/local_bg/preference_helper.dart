import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  static String token = 'token';
  static String accessToken = 'accessToken';
  static String refreshToken = 'refreshToken';
  static String fcmToken = 'fcmToken';
  static String broker = 'broker';
  static String brokerId = 'brokerId';
  static String isLogin = 'isLogin';
  static String isRegistered = 'isRegistered';
  static String accountTypeId = "accountTypeId";
  static String symbolId = 'SymbolId';
  static String symbolName = 'SymbolName';
  static String symbolAlias = 'symbolAlias';
  static String code = 'code';
  static String darkMode = 'darkMode';
  static String userRoleId = 'userRoleId';
  static String oldSymbolName = 'newSymbolName';
  static String oldSymbolId = 'newSymbolId';
  static String newDetails = 'newDetails';
  static String sort = 'sort';
}

class PreferenceHelper {
  static final PreferenceHelper instance = PreferenceHelper._internal();

  factory PreferenceHelper() {
    return instance;
  }

  PreferenceHelper._internal();

  static SharedPreferences? preferences;

  createSharedPref() {
    SharedPreferences.getInstance().then((pref) {
      PreferenceHelper.preferences = pref;
    });
  }

  setData(String key, dynamic value) {
    if (PreferenceHelper.preferences != null) {
      if (value is String) {
        PreferenceHelper.preferences!.setString(key, value);
      } else if (value is int) {
        PreferenceHelper.preferences!.setInt(key, value);
      } else if (value is double) {
        PreferenceHelper.preferences!.setDouble(key, value);
      } else if (value is bool) {
        PreferenceHelper.preferences!.setBool(key, value);
      } else {
        PreferenceHelper.preferences?.setString(key, value);
      }
    }
  }

  Future<dynamic> getData(String key) async {
    await PreferenceHelper.instance.createSharedPref();
    if (PreferenceHelper.preferences == null) {
      return null;
    } else {
      return PreferenceHelper.preferences!.get(key);
    }
  }

  Future<void> clearData() async {
    if (PreferenceHelper.preferences != null) {
      await SharedPreferences.getInstance().then((value) {
        value.clear();
      });
    }
  }

  Future<void> clearSessionPreferences() async {
    if (PreferenceHelper.preferences != null) {
      await preferences?.remove(Pref.broker);
      await preferences?.remove(Pref.brokerId);
      await preferences?.remove(Pref.isLogin);
      await preferences?.remove(Pref.isRegistered);
      await preferences?.remove(Pref.accountTypeId);
      await preferences?.remove(Pref.symbolId);
      await preferences?.remove(Pref.symbolName);
      await preferences?.remove(Pref.symbolAlias);
      await preferences?.remove(Pref.code);
    }
  }
}
