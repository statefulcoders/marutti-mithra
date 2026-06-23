import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseRewardTypesHelper {
  static const String rewardTypesTableName = 'reward-coupons-types';

  static final _db = FirebaseFirestore.instance;
  static final _couponsTypesDB = _db.collection(rewardTypesTableName);

  static CollectionReference get ref => _couponsTypesDB;

  static Future<List<Map<String, dynamic>>> getCouponTypes() async {
    final docs = await _couponsTypesDB.get();
    return docs.docs.map((e) => e.data()).toList();
  }
}