import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppSnackBar {
  static void success(String message) {
    _show('Success', message, Color(0xFF27AE60));
  }

  static void error(String message) {
    _show('Error', message, Color(0xFFD72638));
  }

  static void _show(String title, String message, Color color) {
    try {
      showTopSnackBar(
          Overlay.of(Get.overlayContext!),
          Card(
            color: color,
            child: Padding(
              padding: EdgeInsets.all(17.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontFamily: 'InstrumentSans',
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
          padding: EdgeInsets.all(8.w)
      );
    } catch (_) {}
  }
}