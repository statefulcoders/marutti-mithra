import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';

import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/utils/inputs/input_validators.dart';

class ResetPasswordController extends GetxController {
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final isSuccess = false.obs;

  Future<void> reset() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      String? validation = InputValidators.validate(emailController.text.trim(), InputType.email);
      if (validation != null) {
        throw Exception(validation);
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      isSuccess.value = true;
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Reset Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
      isSuccess.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

}