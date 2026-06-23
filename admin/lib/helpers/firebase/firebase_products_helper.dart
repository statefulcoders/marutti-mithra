import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseProductsHelper {
  static const String productsTableName = 'products';

  static final _db = FirebaseFirestore.instance;
  static final _productsDB = _db.collection(productsTableName);

  static CollectionReference get ref => _productsDB;

  static Future<DashboardCard> getStats() async {
    int totalProducts = 0;
    try {
      final totalResponse = await _productsDB.count().get();
      totalProducts = totalResponse.count ?? 0;
    } catch (_) {}
    final subMetrics = [
      'Total: ${NumberFormat('#,##0').format(totalProducts)}'
    ];
    return DashboardCard(label: 'Products', icon: Icons.production_quantity_limits, color: Colors.teal, subMetrics: subMetrics, conclusion: 'Just Updated', conclusionColor: Colors.green);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final docs = await _productsDB.get();
    return docs.docs.map((e) => e.data()).toList();
  }
}