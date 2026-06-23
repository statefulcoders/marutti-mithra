import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:maruttimitra/resources/marutti_strings.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/extra_fields_helper.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';

import 'configs/design/marutti_themes.dart';
import 'configs/local/app_configs.dart';

class MaruttiMitraApp extends StatefulWidget {
  const MaruttiMitraApp({super.key});

  @override
  State<MaruttiMitraApp> createState() => _MaruttiMitraAppState();
}

class _MaruttiMitraAppState extends State<MaruttiMitraApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    UserTableHelper.dispose();
    ExtraFieldsHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = MaruttiSettingsMemory.currentLanguage;
    final strings = MaruttiStrings();

    return ScreenUtilInit(
      designSize: Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
            title: AppConfig.appName,
            theme: MaruttiThemes.light(context),
            themeMode: ThemeMode.light,
            translations: strings,
            locale: Locale(language.code, language.countryCode),
            fallbackLocale: Locale('en', 'US'),
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.cupertino,
            initialRoute: MaruttiRoutes.main,
            getPages: MaruttiRoutes.routes
        );
      },
    );
  }
}
