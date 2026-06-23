import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/local/app_configs.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';

import '../../dialogs/confirmation_dialog.dart';
import '../../overlays/app_snackbar.dart';
import '../../utils/extra_fields_helper.dart';
import '../../utils/time_date_utils.dart';
import '../../utils/user_table_helper.dart';

class LoginController extends GetxController {
  final _auth = FirebaseAuth.instance;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  final error = RxnString();
  final isLoading = false.obs;

  final isValidNumberProvided = false.obs;
  final isValidOTPProvided = false.obs;
  final isCodeSent = false.obs;
  final canResendCode = false.obs;

  String? verificationId;
  int? resendToken;

  Timer? resendTimer;
  int timeLeftInResend = AppConfig.resendDuration;
  late final timeLeftInResendStr = TimeDateUtils.formatDuration(timeLeftInResend).obs;

  @override
  void onInit() {
    phoneController.addListener(onPhoneChanged);
    super.onInit();
  }


  void _startResendCountdown() {
    resendTimer?.cancel();
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeftInResend == 0) {
        canResendCode.value = true;
        timeLeftInResend = AppConfig.resendDuration;
        timer.cancel();
      } else {
        timeLeftInResend--;
      }
      timeLeftInResendStr.value = TimeDateUtils.formatDuration(timeLeftInResend);
    });
  }


  String cleanedPhoneNumber() => phoneController.text.replaceAll(RegExp(r'\s'), '').trim();

  void onPhoneChanged() {
    String phone = cleanedPhoneNumber();
    isValidNumberProvided.value = phone.length == 10 && GetUtils.isPhoneNumber(phone);
  }

  void onOtpChanged(String value) {
    final otp = value.replaceAll(RegExp('/s'), '').trim();
    isValidOTPProvided.value = otp.length == AppConfig.otpLength;
  }

  Future<void> sendOTP() async {
    String phone = cleanedPhoneNumber();
    if (phone.length != AppConfig.phoneLength || !GetUtils.isPhoneNumber(phone)) {
      AppSnackBar.error('phone_invalid'.tr);
      return;
    }

    isLoading.value = true;
    isCodeSent.value = verificationId != null;
    canResendCode.value = false;
    timeLeftInResend = AppConfig.resendDuration;
    error.value = null;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: '${AppConfig.defaultCountryCode}$phone',
          timeout: const Duration(seconds: AppConfig.resendDuration),
          verificationCompleted: (PhoneAuthCredential credential) {
            onOtpChanged(credential.smsCode??pinController.text.trim());
          },
          verificationFailed: (FirebaseAuthException e) {
            error.value = e.message;
            canResendCode.value = true;
            isLoading.value = false;

            if (!isCodeSent.value) {
              AppSnackBar.error(error.value ?? 'unexpected_error'.tr);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            isLoading.value = false;
            isCodeSent.value = true;
            this.verificationId = verificationId;
            this.resendToken = resendToken;
            _startResendCountdown();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            isLoading.value = false;
            this.verificationId = verificationId;
          },
          forceResendingToken: resendToken
      );
    } catch (error) {
      isLoading.value = false;
      AppSnackBar.error('unexpected_error'.tr);
    }
  }

  Future<void> verifyOTP() async {
    isLoading.value = true;
    final otp = pinController.text.trim();

    if (otp.length != AppConfig.otpLength) {
      AppSnackBar.error('invalid_otp'.tr);
      isLoading.value = false;
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      MaruttiSettingsMemory.noteLoggedInTime();
      UserTableHelper.initialize();
      ExtraFieldsHelper.initialize();
      await Get.offAllNamed(MaruttiRoutes.main);
    } on FirebaseAuthException catch (e) {
      AppSnackBar.error(e.message ?? 'verification_failed'.tr);
    } catch (e) {
      AppSnackBar.error('unexpected_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> discard() async {
    final result = await ConfirmationDialog.confirm(
        'discard_otp_message'.tr,
        title: 'discard_otp_title'.tr
    );
    if (result) {
      canResendCode.value = false;
      timeLeftInResend = AppConfig.resendDuration;
      isCodeSent.value = false;
      isLoading.value = false;
      resendTimer?.cancel();
      pinController.clear();
      error.value = null;
      verificationId = null;
    }
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    phoneController.dispose();
    pinController.dispose();
    super.dispose();
  }
}