import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_fonts.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeConfig {
  static ThemeData generateTheme(BuildContext context, bool isDarkTheme) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConfig.primaryColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    );

    bool isPhone = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.phone;
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: colorScheme.brightness,
      primaryColor: AppConfig.primaryColor,
      scaffoldBackgroundColor: isDarkTheme ? colorScheme.primaryContainer : AppConfig.primaryColor.withAlpha(40),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: ComlateFonts.poppins,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontFamily: ComlateFonts.poppins, color: colorScheme.onSurface),
        displayMedium: TextStyle(fontSize: 28.sp, fontFamily: ComlateFonts.poppins, color: colorScheme.onSurface),
        bodyLarge: TextStyle(fontSize: 18.sp, fontFamily: ComlateFonts.poppins, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontSize: 16.sp, fontFamily: ComlateFonts.poppins, color: colorScheme.onSurface),
        bodySmall: TextStyle(fontSize: 14.sp, fontFamily: ComlateFonts.poppins, color: colorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16.sp, fontFamily: ComlateFonts.poppins, fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(vertical: isPhone ? 15.h : 20.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(fontSize: 16.sp, fontFamily: ComlateFonts.poppins, fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(vertical: isPhone ? 15.h : 20.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      ),
      cardColor: colorScheme.surface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    );
  }
}