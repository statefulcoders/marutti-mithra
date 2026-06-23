import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';

import '../../models/remote/user_model.dart';
import '../../overlays/app_snackbar.dart';
import '../../utils/extra_fields_helper.dart';
import '../../utils/settings/marutti_session_memory.dart';
import '../../utils/user_table_helper.dart';

class AddressDetailsController extends GetxController {
  final isLoading = false.obs;

  final stateController = TextEditingController();
  final districtController = TextEditingController();
  final pinCodeController = TextEditingController();
  final streetAddressController = TextEditingController();

  final extraFieldsValues = <String, dynamic>{}; // To collect updated values
  final extraFieldValues = Rx<Map<String, dynamic>>({}); // From user data
  final extraFields = ExtraFieldsHelper.extraFields; // Custom fields from admin

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final user = UserModel(
        firstName: '',  lastName: '', phone: MaruttiSessionMemory.phoneNumber ?? '',
        streetAddress: streetAddressController.text.trim(),
        pinCode: pinCodeController.text.trim(),
        district: districtController.text.trim(),
        state: stateController.text.trim(),
        extraFields: extraFieldsValues,
        createdAt: null
      );

      if (user.state?.isNotEmpty != true ||
          user.district?.isNotEmpty != true ||
          user.pinCode?.isNotEmpty != true ||
          user.streetAddress?.isNotEmpty != true
      ) {
        AppSnackBar.error('fill_all_fields'.tr);
        return;
      }

      final requiredButEmpty = extraFields.where((e) {
        if (e.required != true) return false;
        final value = user.extraFields[e.key]?.toString().trim() ?? '';
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
      final shopName = user.extraFields['shopName']?.toString();
      final city = user.extraFields['city']?.toString();

      if (shopName != null && city != null) {
        final exists = await UserTableHelper.checkShopNameExists(shopName, city);
        if (exists) {
          AppSnackBar.error("shop_exists_in_city".tr);
          return;
        }
      }

      await UserTableHelper.setUser(user);
      Get.offAllNamed(MaruttiRoutes.main);
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    stateController.dispose();
    districtController.dispose();
    pinCodeController.dispose();
    streetAddressController.dispose();
    super.dispose();
  }

  onExtraFieldSubmitted(MapEntry<String, String> data) {
    extraFieldsValues[data.key] = data.value;
  }
}