
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_rewards_helper.dart';
import 'package:marutti_mitra_admin/screens/main/products/products_controller.dart';
import 'package:marutti_mitra_admin/screens/main/rewards/rewards_controller.dart';

import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class RewardsPage extends StatelessWidget {
  final String label;

  final bool createCoupons;
  final bool deleteCoupons;
  final bool exportData;

  const RewardsPage({super.key, required this.label, required this.createCoupons, required this.deleteCoupons, required this.exportData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardsController(label: label));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => controller.fields.value == null ? Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: CircularProgressIndicator(),
        )
      ) : ComlateFirebaseTable(
        sortBy: 'createdAt',
        columns: controller.columns,
        dataSource: FirebaseRewardsHelper.ref,
        identifier: label,
        enableDeletion: deleteCoupons,
        enableDetails: true,
        customActionLabel: 'Create Coupons',
        onAction: controller.createCoupons,
        enableExport: exportData,
        enableAction: createCoupons,
        updateConfig: controller.fields.value
      )),
    );
  }
}
