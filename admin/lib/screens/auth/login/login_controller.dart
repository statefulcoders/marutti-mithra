import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/confirmation_dialog.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';

import '../../../comlate/utils/inputs/input_validators.dart';
import '../../../helpers/firebase/firebase_user_helper.dart';
import '../../../utils/settings/secure_memory.dart';

class LoginController extends GetxController {
  late final emailController = TextEditingController(text: SecureMemory.getSavedEmail());
  late final passwordController = TextEditingController(text: SecureMemory.getSavedPassword());

  final isPasswordObscured = true.obs;
  final isLoading = false.obs;
  final isSavingPassword = false.obs;

  @override
  void onInit() {
    isSavingPassword.value = SecureMemory.getSavedEmail() != null && SecureMemory.getSavedPassword() != null;
    super.onInit();
  }

  void isPasswordObscuredToggle() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  Future<void> login() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        throw Exception('Already logged in');
      }
      String? validation = InputValidators.validateMany({
        emailController.text.trim(): InputType.email,
        passwordController.text.trim(): InputType.password
      });
      if (validation != null) {
        throw Exception(validation);
      }
      await FirebaseUserHelper.loginAsAdmin(emailController.text.trim(), passwordController.text.trim());
      if (isSavingPassword.value) {
        await SecureMemory.saveEmailPassword(emailController.text.trim(), passwordController.text.trim());
      }
      await Get.offAllNamed(AdminRoutes.main);
    } catch (err) {
      await ConfirmationDialog.confirm(
        err is FirebaseException ? err.message ?? err.toString() : err.toString(),
        title: 'Login Failed',
        color: Colors.red,
        icon: Icons.error_outline_outlined
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSavingPassword(bool? value) {
    isSavingPassword.value = value ?? false;
  }

  void reset() {
    Get.toNamed(AdminRoutes.reset);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}