import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseDynamicFieldsHelper {
  static const String dynamicFieldsTableName = 'extrafields';

  static final _db = FirebaseFirestore.instance;
  static final _dynamicFieldsDB = _db.collection(dynamicFieldsTableName);

  static CollectionReference get ref => _dynamicFieldsDB;

  static Future<DashboardCard> getStats() async {
    int totalFields = 0;
    try {
      final totalResponse = await _dynamicFieldsDB.count().get();
      totalFields = totalResponse.count ?? 0;
    } catch (_) {}
    final subMetrics = [
      'Total: ${NumberFormat('#,##0').format(totalFields)}'
    ];
    return DashboardCard(label: 'Dynamic Fields', icon: Icons.tune, color: Colors.amber, subMetrics: subMetrics, conclusion: 'Just Updated', conclusionColor: Colors.green);
  }

  static Future<void> createNewField(Map<String, dynamic> data) {
    return _dynamicFieldsDB.add(data);
  }
}