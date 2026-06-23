import 'package:marutti_mitra_admin/comlate/data/configs/theme_config.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/comlate/utils/settings/comlate_settings_memory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';

import 'data/configs/app_config.dart';

class ComlateApp extends StatefulWidget {

  static Future<ComlateApp> instance({ Key? key, required String initialRoute, required List<GetPage> pages }) async {
    await ComlateSettingsMemory.initialize();

    return ComlateApp(key: key, initialRoute: initialRoute, pages: pages);
  }

  final String initialRoute;
  final List<GetPage> pages;

  const ComlateApp({super.key, required this.initialRoute, required this.pages});

  @override
  State<ComlateApp> createState() => _ComlateAppState();
}

class _ComlateAppState extends State<ComlateApp> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _initialize();
  }

  Future<void> _initialize() async {
    await ComlateSettingsMemory.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final language = ComlateSettingsMemory.currentLanguage;

    return ScreenUtilInit(
      designSize: ComlateDisplayUtils.getDisplaySizeForPlatform(context),
      minTextAdapt: true, // Ensures text scales properly
      splitScreenMode: true, // Adapts to tablets/foldable screens
      builder: (context, child) {
        return GetMaterialApp(
            title: AppConfig.appName,
            theme: ThemeConfig.generateTheme(context, false),
            darkTheme: ThemeConfig.generateTheme(context, true),
            themeMode: ComlateSettingsMemory.currentThemeMode,
            locale: Locale(language.code, language.countryCode),
            fallbackLocale: Locale('en', 'US'),
            debugShowCheckedModeBanner: false,
            defaultTransition: ComlateDisplayUtils.getDeviceType(context) != ComlateDisplayType.desktop ? Transition.cupertino : Transition.noTransition,
            initialRoute: AdminRoutes.main,
            getPages: widget.pages
        );
      },
    );
  }
}
