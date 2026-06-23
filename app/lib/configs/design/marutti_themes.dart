import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/marutti_fonts.dart';
import 'marutti_colors.dart';

class MaruttiThemes {
  static ThemeData light(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MaruttiColors.primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: colorScheme.brightness,
      primaryColor: MaruttiColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface, // Matches main background
        elevation: 0, // Optional: Removes shadow for a modern look
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20.sp, // Responsive font size
          fontWeight: FontWeight.w600,
          fontFamily: MaruttiFonts.sofiaSansSemiCondensed,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, color: colorScheme.onSurface),
        displayMedium: TextStyle(fontSize: 28.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, color: colorScheme.onSurface),
        bodyLarge: TextStyle(fontSize: 18.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontSize: 16.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, color: colorScheme.onSurface),
        bodySmall: TextStyle(fontSize: 14.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, color: colorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MaruttiColors.primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, fontWeight: FontWeight.w400),
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(fontSize: 16.sp, fontFamily: MaruttiFonts.sofiaSansSemiCondensed, fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
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
