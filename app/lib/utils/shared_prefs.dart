import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late final SharedPreferences _sharedPreferences;

  static const accessTokenKey = 'prefs:accessToken';
  static const refreshTokenKey = 'prefs:refreshToken';
  static const String userKey = 'prefs:user';

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static T? get<T>(String key, [T? t]) {
    return (_sharedPreferences.get(key) ?? t) as T?;
  }

  static Future<bool> set<T>(String key, T value) {
    if (value is String) {
      return _sharedPreferences.setString(key, value);
    } else if (value is int) {
      return _sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      return _sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return _sharedPreferences.setDouble(key, value);
    } else if (value is List<String>) {
      return _sharedPreferences.setStringList(key, value);
    }
    throw 'Invalid value type';
  }

  static Future<bool> delete(String key) {
    return _sharedPreferences.remove(key);
  }

  static Future<bool> clear() {
    return _sharedPreferences.clear();
  }
}