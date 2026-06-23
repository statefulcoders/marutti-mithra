
import 'package:marutti_mitra_admin/comlate/data/models/comlate_language_model.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_keys.dart';
import 'package:marutti_mitra_admin/utils/shared_prefs.dart';

class SecureMemory {
  static final allLanguages = [
    ComlateLanguageModel(
        name: 'English', localName: 'English', code: 'en', countryCode: 'US'),
  ];

  static Future<void> initialize() async {
    await SharedPrefs.init();
  }

  static Future<void> clear() async {
    await SharedPrefs.clear();
  }

  static String? getSavedEmail() {
    return SharedPrefs.get(ComlateKeys.email);
  }

  static String? getSavedPassword() {
    return SharedPrefs.get(ComlateKeys.password);
  }

  static Future<void> saveEmailPassword(String email, String password) async {
    await SharedPrefs.set(ComlateKeys.email, email);
    await SharedPrefs.set(ComlateKeys.password, password);
  }
}