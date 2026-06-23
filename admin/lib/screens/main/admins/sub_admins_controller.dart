import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';

import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_controller.dart';
import '../../../helpers/firebase/firebase_sub_admin_helper.dart';

class SubAdminsController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Name', keys: ['name']),
    ComlateFirebaseTableColumn(label: 'Email', keys: ['email']),
    ComlateFirebaseTableColumn(label: 'Created At', keys: ['createdAt']),
  ];

  final updateFields = [
    DataUpdateFieldInfo(key: 'name', hint: 'Sub-Admin Name', expectedType: 'text', min: 1, max: 255, required: true),
    DataUpdateFieldInfo(key: 'email', hint: 'Login username (Email)', expectedType: 'text', min: 1, max: 255, required: true),
    DataUpdateFieldInfo(key: 'createdAt', hint: 'Created At', expectedType: 'date', required: true),
    ...FirebaseSubAdminHelper.allPerms.map((e) => DataUpdateFieldInfo(key: e, hint: e.split('_').map((e) => e.capitalizeFirst ?? e).join(' '), expectedType: 'toggle', required: true))
  ];

  late final createFields = [
    DataUpdateFieldInfo(key: 'name', hint: 'Sub-Admin Name', expectedType: 'text', min: 1, max: 255, required: true),
    DataUpdateFieldInfo(key: 'email', hint: 'Login username (Email)', expectedType: 'text', min: 1, max: 255, required: true),
    DataUpdateFieldInfo(key: 'password', hint: 'Password', expectedType: 'text', min: 6, max: 255, required: true),
    ...FirebaseSubAdminHelper.allPerms.map((e) => DataUpdateFieldInfo(key: e, hint: e.split('_').map((e) => e.capitalizeFirst ?? e).join(' '), expectedType: 'toggle', required: true))
  ];

  Future<void> createAdmin() async {
    try {
      final updatedData = await DataUpdaterDialog.show(
        data: {},
        fieldInfo: createFields,
        editable: true,
        customLabel: "Create Sub-Admin",
      );
      if (updatedData is Map<String, dynamic> && updatedData.isNotEmpty) {
        await FirebaseSubAdminHelper.createSubAdmin({...updatedData,  'createdAt': DateTime.now() });
        await Get.find<ComlateFirebaseTableController>(tag: 'Sub Admins').getInitialPage();
      }
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err
              .toString(),
          title: 'Creation Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }
}