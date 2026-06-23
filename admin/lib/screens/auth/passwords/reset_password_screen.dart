import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/screens/auth/passwords/reset_password_controller.dart';

import '../../../comlate/data/resources/comlate_logos.dart';
import '../../../comlate/widgets/comlate_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resetPasswordController = Get.put(ResetPasswordController());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[850] : Colors.white;

    return ComlateRootContainer(
      child: Scaffold(
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            padding: EdgeInsets.all(32.w),
            constraints: BoxConstraints(maxWidth: 600, minWidth: min(Get.width, 600)),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() => AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: resetPasswordController.isSuccess.value
                  ? _createSuccessWidget(context)
                  : _createForm(context, resetPasswordController),
            )),
          ),
        ),
      ),
    );
  }

  Widget _createForm(BuildContext context, ResetPasswordController controller) {
    return Column(
      key: ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _createLogo(),
        _createInstruction(context),
        ..._createEmailField(context, controller),
        SizedBox(height: 32.h),
        _createActionButton(context, controller),
      ],
    );
  }

  Widget _createSuccessWidget(BuildContext context) {
    return Column(
      key: ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
        SizedBox(height: 16.h),
        Text(
          'Reset Link Sent!',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Please check your email for instructions.',
          style: TextStyle(fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _createLogo() {
    return Center(
      child: Image.asset(
        ComlateLogos.loginLogo,
        height: 100,
        width: 200,
        fit: BoxFit.contain,
        color: Get.isDarkMode ? null : null,
      ),
    );
  }
  
  Widget _createInstruction(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withAlpha(20) : Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.blue[700]! : Colors.blue[100]!,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 32.w),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.blue[300] : Theme.of(context).primaryColor,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: SelectableText(
              'Enter your email address and we will send you instructions to reset your password.',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _createEmailField(BuildContext context, ResetPasswordController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      SelectableText(
        'Email',
        style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 15.sp
        ),
      ),
      SizedBox(height: 8.h),
      ComlateTextField(
        controller: controller.emailController,
        hint: 'Enter your email address',
        prefixIconOptional: Icons.email_outlined,
      )
    ];
  }

  Widget _createActionButton(BuildContext context, ResetPasswordController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton.icon(
        onPressed: controller.isLoading.value ? null : controller.reset,
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          backgroundColor: isDark ? Colors.blue[700] : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: controller.isLoading.value ? SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ) : null,
        label: controller.isLoading.value ? SizedBox() : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send),
            const SizedBox(width: 8),
            Text(
              'Send Resend Link',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
