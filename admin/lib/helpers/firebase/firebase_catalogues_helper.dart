import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseCataloguesHelper {
  static const String cataloguesTableName = 'catalogues';

  static final _db = FirebaseFirestore.instance;
  static final _cataloguesDB = _db.collection(cataloguesTableName);

  static CollectionReference get ref => _cataloguesDB;

  static Future<DashboardCard> getStats() async {
    int totalCatalogues = 0;
    try {
      final totalResponse = await _cataloguesDB.count().get();
      totalCatalogues = totalResponse.count ?? 0;
    } catch (_) {}
    final subMetrics = [
      'Total: ${NumberFormat('#,##0').format(totalCatalogues)}'
    ];
    return DashboardCard(label: 'Catalogues', icon: Icons.card_travel_sharp, color: Colors.blue, subMetrics: subMetrics, conclusion: 'Just Updated', conclusionColor: Colors.green);
  }
}