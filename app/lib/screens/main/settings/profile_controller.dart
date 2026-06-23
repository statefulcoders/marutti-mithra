import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:maruttimitra/configs/local/app_configs.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/models/remote/form_field_model.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/extra_fields_helper.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

import '../../../overlays/app_snackbar.dart';
import '../../../utils/user_table_helper.dart';

class ProfileController extends GetxController {

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final birthdayCtrl = TextEditingController();

  final stateController = TextEditingController();
  final districtController = TextEditingController();
  final pinCodeController = TextEditingController();
  final streetAddressController = TextEditingController();

  final RxBool initializing = true.obs;
  final RxBool isLoading = false.obs;

  final extraFieldsValues = <String, dynamic>{};
  final extraFieldValues = Rx<Map<String, dynamic>>({});
  final extraFields = ExtraFieldsHelper.extraFields;

  Worker? userWorker;

  @override
  void onInit() {
    _initialize(UserTableHelper.user.value);
    userWorker = ever(UserTableHelper.user, (user) async {
      _initialize(user);
    });

    super.onInit();
  }

  Future<void> _initialize(UserModel? user) async {
    try {
      firstNameCtrl.text = user?.firstName ?? '';
      lastNameCtrl.text = user?.lastName ?? '';
      phoneCtrl.text = user?.phone ?? '';
      emailCtrl.text = user?.email ?? '';
      if (user?.dateOfBirth != null) birthdayCtrl.text = DateFormat('dd/MM/yyyy').format(user!.dateOfBirth!);

      stateController.text = user?.state ?? '';
      districtController.text = user?.district ?? '';
      pinCodeController.text = user?.pinCode ?? '';
      streetAddressController.text = user?.streetAddress ?? '';

      extraFieldValues.value.assignAll(user?.extraFields ?? {});
      extraFieldValues.refresh();
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      initializing.value = false;
    }
  }

  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 8, 28),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdayCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> updateProfile() async {
    if (firstNameCtrl.text.trim().isEmpty) {
      AppSnackBar.error("first_name_required".tr);
      return;
    }
    if (lastNameCtrl.text.trim().isEmpty) {
      AppSnackBar.error("last_name_required".tr);
      return;
    }
    if (phoneCtrl.text.trim().isEmpty || phoneCtrl.text.trim().length < 10) {
      AppSnackBar.error("phone_invalid".tr);
      return;
    }
    if (emailCtrl.text.trim().isNotEmpty && !_isValidEmail(emailCtrl.text.trim())) {
      AppSnackBar.error("email_invalid".tr);
      return;
    }

    if (stateController.text.trim().isEmpty) {
      AppSnackBar.error("state_required".tr);
      return;
    }

    if (districtController.text.trim().isEmpty) {
      AppSnackBar.error("district_required".tr);
      return;
    }


    if (pinCodeController.text.trim().isEmpty || pinCodeController.text.trim().length < AppConfig.pinCodeLength) {
      AppSnackBar.error("pin_required".tr);
      return;
    }

    if (streetAddressController.text.trim().isEmpty) {
      AppSnackBar.error("address_required".tr);
      return;
    }

    final requiredButEmpty = extraFields.where((e) {
      if (e.required != true) return false;
      final value = extraFieldsValues[e.key]?.toString().trim() ?? '';
      switch(e.type) {
        case 'dropdown':
        case 'text':
          return value.isEmpty;
        case 'number':
          return (num.tryParse(value) ?? 0) <= 0;
      }
      return false;
    }).firstOrNull;

    if (requiredButEmpty != null) {
      final spaced = requiredButEmpty.key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
      final snakeCase = spaced.replaceAll('_', ' ');
      final normalisedKey = snakeCase.split(' ').map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
      AppSnackBar.error('$normalisedKey is required');
      return;
    }

    // Validate Unique Shop Name per City
    // Merge existing fields with updates to get the effective values
    final currentUserExtraFields = UserTableHelper.user.value?.extraFields ?? {};
    final effectiveExtraFields = {...currentUserExtraFields, ...extraFieldsValues};
    
    final shopName = effectiveExtraFields['shopName']?.toString();
    final city = effectiveExtraFields['city']?.toString();

    if (shopName != null && city != null) {
      final exists = await UserTableHelper.checkShopNameExists(shopName, city);
      if (exists) {
        AppSnackBar.error("shop_exists_in_city".tr);
        return;
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;

    try {
      UserModel user = UserTableHelper.user.value!.copyWith(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        dateOfBirth: DateFormat('dd/MM/yyyy').tryParse(birthdayCtrl.text.trim()),
        state: stateController.text.trim(),
        district: districtController.text.trim(),
        pinCode: pinCodeController.text.trim(),
        streetAddress: streetAddressController.text.trim(),
        extraFields: extraFieldsValues,
      );
      await UserTableHelper.setUser(user);
      Get.back();
      AppSnackBar.success("profile_updated".tr);
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    userWorker?.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    birthdayCtrl.dispose();
    stateController.dispose();
    districtController.dispose();
    pinCodeController.dispose();
    streetAddressController.dispose();
    super.dispose();
  }

  void onExtraFieldSubmitted(MapEntry<String, String> data) {
    extraFieldsValues[data.key] = data.value;
  }
}