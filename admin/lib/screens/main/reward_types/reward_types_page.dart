
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_reward_types_helper.dart';
import 'package:marutti_mitra_admin/screens/main/products/products_controller.dart';
import 'package:marutti_mitra_admin/screens/main/reward_types/reward_types_controller.dart';
import 'package:marutti_mitra_admin/screens/main/rewards/rewards_controller.dart';

import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class RewardTypesPage extends StatelessWidget {
  final String label;

  final bool createCouponType;
  final bool deleteCouponType;
  final bool exportData;

  const RewardTypesPage({super.key, required this.label, required this.createCouponType, required this.deleteCouponType, required this.exportData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardTypesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ComlateFirebaseTable(
        columns: controller.columns,
        dataSource: FirebaseRewardTypesHelper.ref,
        identifier: label,
        enableDeletion: deleteCouponType,
        enableDetails: true,
        enableExport: exportData,
        enableAction: createCouponType,
        updateConfig: [
          DataUpdateFieldInfo(key: 'name', hint: 'Coupon Name', expectedType: 'text', min: 1, max: 255, required: true),
          DataUpdateFieldInfo(key: 'description', hint: 'Coupon Description', expectedType: 'text', min: 1, max: 512, required: true),
          DataUpdateFieldInfo(key: 'image', hint: 'Coupon Image', expectedType: 'file', min: 1, max: 1, options: ['png'], required: false),
        ]
      ),
    );
  }
}
