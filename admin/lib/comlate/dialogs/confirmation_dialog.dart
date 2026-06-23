import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';

class ConfirmationDialog {

  static Future<bool> confirm(String message, {
    String? title,
    String positiveLabel = 'Okay',
    String negativeLabel = 'Cancel',
    Color? color,
    IconData icon = Icons.info_outline_rounded
  }) async {
    final context = Get.context!;
    final primaryColor = Get.isDarkMode ? Theme.of(context).colorScheme.primary : AppConfig.primaryColor;
    return await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        backgroundColor: Get.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          width: 300.w,
          margin: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle using primary color
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      (color ?? primaryColor).withAlpha(50),
                      (color ?? primaryColor).withAlpha(50)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color ?? primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Dialog title
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              // Dialog message
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Get.isDarkMode ? Colors.grey : Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Get.isDarkMode
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                      ),
                      child: Text(
                        negativeLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Get.isDarkMode ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        backgroundColor: color ?? (Get.isDarkMode ? Theme.of(context).colorScheme.primaryContainer : AppConfig.primaryColor),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        positiveLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withAlpha(90),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
    ) == true;
  }
}
