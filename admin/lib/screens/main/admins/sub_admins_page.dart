
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/screens/main/admins/sub_admins_controller.dart';
import 'package:marutti_mitra_admin/screens/main/products/products_controller.dart';

import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';
import '../../../helpers/firebase/firebase_sub_admin_helper.dart';

class SubAdminsPage extends StatelessWidget {
  final String label;
  const SubAdminsPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubAdminsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ComlateFirebaseTable(
          sortBy: 'createdAt',
          columns: controller.columns,
          dataSource: FirebaseSubAdminHelper.ref,
          identifier: label,
          enableDeletion: true,
          enableDetails: true,
          enableEditing: true,
          customActionLabel: 'Create Admin',
          onAction: controller.createAdmin,
          updateConfig: controller.updateFields
      )
    );
  }
}
