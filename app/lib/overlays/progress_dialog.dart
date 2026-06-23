import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';

class ProgressDialog {
  static bool _isShowing = false;
  static final RxString _label = RxString('');
  static final GlobalKey<NavigatorState> _dialogNavigatorKey = GlobalKey<NavigatorState>();

  static void show(String message) {
    // Prevent multiple dialogs
    if (_isShowing) return;
    _isShowing = true;
    _label.value = message;

    Get.dialog(
      PopScope(
        canPop: false, // Disable back button
        child: Navigator(
          key: _dialogNavigatorKey, // Assign unique navigator key
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              elevation: 3,
              backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                width: 160.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(MaruttiColors.primaryColor),
                        strokeWidth: 4.w,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Obx(() => Text(
                      _label.value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
    );
  }

  static void dismiss() {
    if (_isShowing) {
      // Use the navigator key to pop the specific dialog
      if (_dialogNavigatorKey.currentState != null &&
          _dialogNavigatorKey.currentState!.canPop()) {
        _dialogNavigatorKey.currentState!.pop();
      }
      // If the dialog is still in the GetX stack, ensure it's removed
      if (Get.isDialogOpen == true) {
        Get.back(closeOverlays: false);
      }
      _isShowing = false;
    }
  }

  static void update(String s) {
    _label.value = s;
  }
}