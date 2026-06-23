import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:maruttimitra/models/remote/form_field_model.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

class ExtraFieldsHelper {
  static const String dynamicsTableName = 'extrafields';

  static final _db = FirebaseFirestore.instance;
  static final _extraFieldsDB = _db.collection(dynamicsTableName);

  static final extraFields = RxList<FormFieldModel>();
  static StreamSubscription? userStream;

  static void initialize() {
    userStream = _extraFieldsDB.snapshots().listen((event) {
      try {
        if (event.docs.isNotEmpty) {
          extraFields.value = event.docs.map((e) => FormFieldModel.fromJson(e.data())).toList();
          print("ExtraFields: ${event.docs.map((e) => e.data()).toList()}");
        } else {
          extraFields.value = [];
        }
      } catch (error) {
        print("ExtraFields: $error");
      }
    });
  }

  static void dispose() {
    userStream?.cancel();
  }
}