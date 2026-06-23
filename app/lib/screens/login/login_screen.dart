import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/screens/login/login_controller.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:maruttimitra/widgets/custom_input_field.dart';
import 'package:pinput/pinput.dart';

import '../../configs/design/marutti_colors.dart';
import '../../configs/local/app_configs.dart';
import '../../resources/marutti_logos.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return AppRootContainer(
      child: Obx(() => Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: controller.isCodeSent.value ? AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(onPressed: controller.discard, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
        ) : null,
        body: PopScope(
          canPop: !controller.isCodeSent.value,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              controller.discard();
            }
          },
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  margin: EdgeInsets.all(16.w),
                  elevation: 0,
                  color: Colors.white,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.2)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Obx(() => Column(
                      children: [
                        if (controller.isCodeSent.value) ..._createVerifyOtpView(),
                        if (!controller.isCodeSent.value) ..._createSendOtpView(),
                        _createActionButton(),
                        SizedBox(height: 26.h),
                      ],
                    )),
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  List<Widget> _createSendOtpView() {
    return [
      SizedBox(height: 26.h),
      Image.asset(
        MaruttiLogos.splash,
        fit: BoxFit.fitWidth,
        width: MediaQuery.sizeOf(context).width * 0.25,
      ),
      Text(
          AppConfig.appName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400)
      ),
      SizedBox(height: 20.h),
      Text(
        'enter_your_phone_number'.tr,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 17.sp),
      ),
      SizedBox(height: 20.h),
      CustomInputField(
        isEnabled: !controller.isLoading.value,
        prefix: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: Text(
            '+91',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 17.sp),
            textAlign: TextAlign.center,
          ),
        ),
        hint: 'phone_number'.tr,
        maxLength: AppConfig.phoneLength,
        inputType: TextInputType.phone,
        controller: controller.phoneController,

      ),
      SizedBox(height: 20.h),
    ];
  }

  List<Widget> _createVerifyOtpView() {
    return [
      SizedBox(height: 26.h),
      Text(
        'otp_sent'.tr,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.sp),
      ),
      SizedBox(height: 8.h),
      Text(
        '+91 ${controller.phoneController.text.trim()}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 17.sp, color: MaruttiColors.primaryColor),
      ),
      SizedBox(height: 20.h),
      _createPinView(),
      SizedBox(height: 20.h),
      Obx(() => Column(
        children: [
          Text(
            controller.canResendCode.value
                ? 'Didn\'t receive the code?'
                : 'Resend code in ${controller.timeLeftInResendStr.value}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
          if (controller.canResendCode.value)
            TextButton(
              onPressed: controller.sendOTP,
              style: TextButton.styleFrom(
                foregroundColor: MaruttiColors.primaryColor,
                textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
              ),
              child: Text('Resend OTP'),
            ),
        ],
      )),
      SizedBox(height: 20.h),
    ];
  }


  _createPinView() {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: TextStyle(fontSize: 20.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: MaruttiColors.primaryColor, width: 1.2),
      borderRadius: BorderRadius.circular(8.r),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Theme.of(context).colorScheme.surface,
      ),
    );

    return Obx(() => Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorText: controller.error.value,
      forceErrorState: controller.error.value != null,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      crossAxisAlignment: CrossAxisAlignment.center,
      controller: controller.pinController,
      enabled: !controller.isLoading.value,
      length: AppConfig.otpLength,
      onChanged: controller.onOtpChanged,
      onCompleted: controller.onOtpChanged,
    ));
  }

  Widget _createActionButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.isCodeSent.value && controller.isValidOTPProvided.value ? controller.verifyOTP : !controller.isCodeSent.value && controller.isValidNumberProvided.value ? controller.sendOTP : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: MaruttiColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 26.w),
      ),
      child: controller.isLoading.value ? SizedBox(
        height: 18.sp,
        width: 18.sp,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ) : Text(controller.isCodeSent.value ? "verify_otp".tr : "send_otp".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
    ));
  }
}
