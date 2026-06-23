import 'package:flutter/cupertino.dart';
import 'package:maruttimitra/screens/main/support/support_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/dialogs/confirmation_dialog.dart';
import 'package:maruttimitra/dialogs/select_language_dialog.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';

import '../../../utils/user_table_helper.dart';

class SettingsController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    simulateFetch();
  }

  void simulateFetch() async {
    // API CALL
    isLoading.value = false;
  }

  void onLanguageTap(BuildContext context) => SelectLanguageDialog.show(context);
  
  Future<void> onDeleteAccount() async {
    if (MaruttiSettingsMemory.loggedInTime.isBefore(DateTime.now().subtract(const Duration(minutes: 8)))) {
      final login = await ConfirmationDialog.confirm(
        "recent_login_required_message".tr,
        title: "recent_login_required_title".tr,
        color: Colors.red,
        icon: CupertinoIcons.delete,
        negativeLabel: "cancel".tr,
        positiveLabel: "login".tr,
      );

      if (login) {
        await MaruttiSessionMemory.logout();
        if (Get.context != null) {
          Get.offAllNamed(MaruttiRoutes.login);
        }
      }
    } else {
      final delete = await ConfirmationDialog.confirm(
        "deletion_confirmation".tr,
        title: "account_deletion".tr,
        color: Colors.red,
        icon: CupertinoIcons.delete,
        negativeLabel: "cancel".tr,
        positiveLabel: "delete".tr,
      );

      if (delete) {
        await UserTableHelper.deleteUser();
        if (Get.context != null) {
          Get.offAllNamed(MaruttiRoutes.login);
        }
      }
    }
  }

  void onPrivacyTap() => Get.toNamed(MaruttiRoutes.appContent, parameters: { Constants.keyType: Constants.privacyPolicy });
  
  void onTermsTap() => Get.toNamed(MaruttiRoutes.appContent, parameters: { Constants.keyType: Constants.termsOfService });
  
  Future<void> logout() async {
    final confirm = await ConfirmationDialog.confirm(
      "logout_confirmation".tr,
      title: "logout".tr,
      color: Colors.red,
      icon: Icons.logout,
      negativeLabel: "cancel".tr,
      positiveLabel: "logout".tr,
    );

    if (confirm) {
      await MaruttiSessionMemory.logout();
      Get.offAllNamed(MaruttiRoutes.main);
    }
  }

  void onProfileTap() {
    Get.toNamed(MaruttiRoutes.profile);
  }

  void onSupportTap() {
    Get.to(() => const SupportPage());
  }
}