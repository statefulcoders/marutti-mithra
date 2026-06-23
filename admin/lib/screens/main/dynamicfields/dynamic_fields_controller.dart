import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_dynamic_fields_helper.dart';

import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';

class DynamicFieldsController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'key', keys: ['key']),
    ComlateFirebaseTableColumn(label: 'Hint', keys: ['hint']),
    ComlateFirebaseTableColumn(label: 'Type', keys: ['type']),
  ];
}