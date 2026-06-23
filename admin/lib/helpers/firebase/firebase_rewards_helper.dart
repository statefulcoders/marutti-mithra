import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseRewardsHelper {
  static const String couponTableName = 'reward-coupons';

  static final _db = FirebaseFirestore.instance;
  static final _couponsDB = _db.collection(couponTableName);

  static CollectionReference get ref => _couponsDB;

  // static Future<DashboardCard> getStats() async {
  //   int totalProducts = 0;
  //   try {
  //     final totalResponse = await _couponsDB.count().get();
  //     totalProducts = totalResponse.count ?? 0;
  //   } catch (_) {}
  //   final subMetrics = [
  //     'Total: ${NumberFormat('#,##0').format(totalProducts)}'
  //   ];
  //   return DashboardCard(label: 'Products', icon: Icons.production_quantity_limits, color: Colors.teal, subMetrics: subMetrics, conclusion: 'Just Updated', conclusionColor: Colors.green);
  // }

  // static Future<List<Map<String, dynamic>>> getProducts() async {
  //   final docs = await _couponsDB.get();
  //   return docs.docs.map((e) => e.data()).toList();
  // }

static Future<Future<DocumentReference<Map<String, dynamic>>>> createCoupons({ required Map<String, dynamic> data }) async {
  return _couponsDB.add(data);
}
}