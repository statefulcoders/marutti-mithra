import 'dart:ui';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../../configs/local/constants.dart';
import '../../models/local/app_language_model.dart';

class MaruttiSettingsMemory {
  static final allLanguages = [
    AppLanguageModel(
      name: 'English',
      localName: 'English',
      code: 'en',
      countryCode: 'US',
    ),
    AppLanguageModel(
      name: 'Hindi',
      localName: 'हिन्दी',
      code: 'hi',
      countryCode: 'IN',
    ),
    AppLanguageModel(
      name: 'Telugu',
      localName: 'తెలుగు',
      code: 'te',
      countryCode: 'IN',
    ),
  ];

  static Future<void> initialize() async {
    await GetStorage.init();
  }

  static bool get isLanguageSet {
    return GetStorage().hasData(Constants.keyLanguageCode);
  }

  static String get firm => GetStorage().read(Constants.keyFirm) ?? 'MWholesales';

  static void saveFirmChoice(String firm) async {
    await GetStorage().write(Constants.keyFirm, firm);
  }

  static void noteLoggedInTime() async {
    await GetStorage().write(Constants.keyLoggedInTime, DateTime.now().millisecondsSinceEpoch);
  }

  static DateTime get loggedInTime => DateTime.fromMillisecondsSinceEpoch(GetStorage().read(Constants.keyLoggedInTime) ?? 0);

  static void setLanguage(AppLanguageModel language) {
    GetStorage().write(Constants.keyLanguageCode, language.code);
    Get.updateLocale(Locale(language.code, language.countryCode));
  }

  static AppLanguageModel get currentLanguage => allLanguages.singleWhere((l) => l.code == GetStorage().read(Constants.keyLanguageCode), orElse: () => allLanguages.first);
}