
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_dynamic_fields_helper.dart';
import 'package:marutti_mitra_admin/screens/main/dynamicfields/dynamic_fields_controller.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class DynamicFieldsPage extends StatelessWidget {
  final String label;
  const DynamicFieldsPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DynamicFieldsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ComlateFirebaseTable(
        columns: controller.columns,
        dataSource: FirebaseDynamicFieldsHelper.ref,
        identifier: label,
        enableDeletion: true,
        enableDetails: true,
        enableEditing: true,
        updateConfig: [
          DataUpdateFieldInfo(key: 'key', hint: 'Key (Avoid space or special characters)', expectedType: 'text', min: 1, max: 25, required: true),
          DataUpdateFieldInfo(key: 'hint', hint: 'Hint', expectedType: 'text', min: 1, max: 100, required: true),
          DataUpdateFieldInfo(key: 'type', hint: 'Input Type', expectedType: 'dropdown', options: [ 'text', 'number', 'dropdown' ], required: true),
          DataUpdateFieldInfo(key: 'data', hint: 'Options (Separated by comma)', expectedType: 'list', required: false),
          DataUpdateFieldInfo(key: 'required', hint: 'Required', expectedType: 'toggle', required: true),
        ],
      ),
    );
  }
}
