import 'dart:ui';

import 'package:marutti_mitra_admin/comlate/data/models/comlate_language_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/resources/comlate_keys.dart';

class ComlateSettingsMemory {
  static final allLanguages = [
    ComlateLanguageModel(name: 'English', localName: 'English', code: 'en', countryCode: 'US'),
  ];

  static Future<void> initialize() async {
    await GetStorage.init();
  }

  static void setThemeMode(ThemeMode mode) {
    GetStorage().write(ComlateKeys.themeMode, mode.index);
    Get.changeThemeMode(mode);
  }

  static ThemeMode get currentThemeMode {
    final index = GetStorage().read(ComlateKeys.themeMode);
    if (index == null) return ThemeMode.system;
    return ThemeMode.values[index];
  }

  static bool get isLanguageSet {
    return GetStorage().hasData(ComlateKeys.languageCode);
  }

  static void setLanguage(ComlateLanguageModel language) {
    GetStorage().write(ComlateKeys.languageCode, language.code);
    Get.updateLocale(Locale(language.code, language.countryCode));
  }

  static ComlateLanguageModel get currentLanguage => allLanguages.singleWhere((l) => l.code == GetStorage().read(ComlateKeys.languageCode), orElse: () => allLanguages.first);
}