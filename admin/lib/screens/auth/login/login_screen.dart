import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_backgrounds.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_logos.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_text_field.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Slightly longer duration for smoother end
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(
      begin: 1.1, // More subtle initial zoom
      end: 1.0, // Normal scale
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Cubic curve for slower end
      ),
    );

    // Start animation immediately
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());

    return ComlateRootContainer(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() => Stack(
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _createBackground(context)
                );
              },
            ),
            if (!loginController.isLoading.value) Center(child: _createLoginCard(context, loginController)),
            if (loginController.isLoading.value) Center(child: CircularProgressIndicator()),
          ],
        ))
      ),
    );
  }

  Widget _createBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage(ComlateBackgrounds.login),
          fit: BoxFit.cover,
          opacity: 0.9
        )
      )
    );
  }

  Widget _createLoginCard(BuildContext context, LoginController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[850] : Colors.white;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      padding: EdgeInsets.all(32.w),
      constraints: BoxConstraints(maxWidth: 410, minWidth: min(Get.width, 410)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _createLogo(),
          SizedBox(height: 20.h),
          ..._createFieldHint(context, label: 'Email', field: ComlateTextField(
            controller: controller.emailController,
            hint: 'Enter your email address',
            prefixIconOptional: Icons.email_outlined,
            autoFillHints: [AutofillHints.username],
          )),
          SizedBox(height: 20.h),
          ..._createFieldHint(context, label: 'Password', field: Obx(() => ComlateTextField(
            controller: controller.passwordController,
            hint: 'Enter your password',
            prefixIconOptional: Icons.lock_outline,
            obscureText: controller.isPasswordObscured.value,
            onVisibilityTap: controller.isPasswordObscuredToggle,
            autoFillHints: [AutofillHints.password],
          ))),
          SizedBox(height: 16.h),
          _createPasswordOptions(context, controller),
          SizedBox(height: 32.h),
          _createActionButton(context, controller),
        ],
      ),
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

  List<Widget> _createFieldHint(BuildContext context, { required String label, required Widget field }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      SelectableText(
        label,
        style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 15.sp
        ),
      ),
      SizedBox(height: 8.h),
      field
    ];
  }

  Widget _createPasswordOptions(BuildContext context, LoginController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Obx(() => SizedBox(
          height: 24.w,
          width: 24.w,
          child: Checkbox(
            value: controller.isSavingPassword.value,
            onChanged: controller.toggleSavingPassword,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        )
        ),
        SizedBox(width: 8.w),
        Text(
          'Save Password',
          style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14.sp
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: controller.reset,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.blue[300] : Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            'Forgot password?',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp
            ),
          ),
        ),
      ],
    );
  }

  Widget _createActionButton(BuildContext context, LoginController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => SizedBox(
        width: double.infinity,
        height: 55.h,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.blue[700] : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
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
              Icon(Icons.login),
              const SizedBox(width: 8),
              Text(
                'Sign In',
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
