import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/comlate/overlays/app_snackbar.dart';
import 'package:marutti_mitra_admin/comlate/widgets/firebase_table/comlate_firebase_table_controller.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_reward_types_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_rewards_helper.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';

class RewardsController extends GetxController {
  final String label;

  final columns = [
    ComlateFirebaseTableColumn(label: 'Name', keys: ['name']),
    ComlateFirebaseTableColumn(label: 'Total', keys: ['total'], transformer: (data) {
      try {
        final item = data['types'] as Map<String, dynamic>;
        return item.values.map((e) => int.tryParse(e?.toString() ?? '') ?? 0).fold(0, (a, b) => a + b).toString();
      } catch (error) {
        return 0.toString();
      }
    }),
    ComlateFirebaseTableColumn(label: 'Distributed', keys: ['distributed'], transformer: (data) => (int.tryParse(data['distributed']?.toString() ?? '') ?? 0).toString()),
    ComlateFirebaseTableColumn(label: 'CreatedAt', keys: ['createdAt']),
  ];

  final fields = Rxn<List<DataUpdateFieldInfo>>();

   RewardsController({ required this.label});

  @override
  void onInit() {
    _initialise();
    super.onInit();
  }

  Future<void> _initialise() async {
    try {
      final response = await FirebaseRewardTypesHelper.getCouponTypes();
      final types = response.map((e) => e['name']?.toString() ?? 'Unknown').toSet().toList();
      fields.value = [
        DataUpdateFieldInfo(key: 'name', hint: 'Coupon Name', expectedType: 'text', min: 1, max: 255, required: true),
        DataUpdateFieldInfo(key: 'duration', hint: 'Duration (In Days)', expectedType: 'integer', min: 1, max: 365, required: true),
        DataUpdateFieldInfo(key: 'types', hint: 'Coupon Types', expectedType: 'object', keyOptions: types, nestedValueType: 'integer', min: 1, max: 255, required: true),
      ];
    } catch (error) {
      fields.value = [
        DataUpdateFieldInfo(key: 'name', hint: 'Coupon Name', expectedType: 'text', min: 1, max: 255, required: true),
        DataUpdateFieldInfo(key: 'duration', hint: 'Duration (In Days)', expectedType: 'integer', min: 1, max: 365, required: true),
        DataUpdateFieldInfo(key: 'types', hint: 'Coupon Types', expectedType: 'object', keyOptions: ['No Reward'], nestedValueType: 'integer', min: 1, max: 255, required: true),
      ];
    }
  }

  Future<void> createCoupons() async {
    await _initialise();
    final result = await DataUpdaterDialog.show(
      data: {},
      editable: true,
      customLabel: "Create Coupons",
      fieldInfo: fields.value ?? [],
    );

    if (result == null) return;

    try {
      await FirebaseRewardsHelper.createCoupons(data: {...result, "createdAt": Timestamp.now()});
      Get.find<ComlateFirebaseTableController>(tag: label).getInitialPage();
    } catch (error) {
      AppSnackBar.error('$error');
    }
  }
}