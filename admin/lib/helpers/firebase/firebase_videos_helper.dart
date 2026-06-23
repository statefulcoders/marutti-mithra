import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseVideosHelper {
  static const String videosTableName = 'videos';

  static final _db = FirebaseFirestore.instance;
  static final _videosDB = _db.collection(videosTableName);

  static CollectionReference get ref => _videosDB;

  static Future<DashboardCard> getStats() async {
    int totalCatalogues = 0;
    try {
      final totalResponse = await _videosDB.count().get();
      totalCatalogues = totalResponse.count ?? 0;
    } catch (_) {}
    final subMetrics = [
      'Total: ${NumberFormat('#,##0').format(totalCatalogues)}'
    ];
    return DashboardCard(label: 'Videos', icon: Icons.video_library_outlined, color: Colors.green, subMetrics: subMetrics, conclusion: 'Just Updated', conclusionColor: Colors.green);
  }
}