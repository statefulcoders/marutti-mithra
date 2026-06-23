import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/overlays/app_snackbar.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';

class BasicInfoController extends GetxController {
  final isLoading = false.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();


  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 8, 28),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final user = UserModel(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phone: MaruttiSessionMemory.phoneNumber ?? '',
          email: emailController.text.trim(),
          createdAt: DateTime.now(),
          dateOfBirth: dobController.text.trim().isNotEmpty ? DateFormat('dd/MM/yyyy').parse(dobController.text.trim()) : null,
      );

      if (user.firstName.isEmpty || user.lastName.isEmpty) {
        AppSnackBar.error('fill_all_fields'.tr);
        return;
      }

      if (user.email?.isNotEmpty == true && !GetUtils.isEmail(emailController.text.trim())) {
        AppSnackBar.error('email_invalid'.tr);
        return;
      }

      await UserTableHelper.setUser(user);
      Get.offAllNamed(MaruttiRoutes.addressDetails);
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.dispose();
  }
}