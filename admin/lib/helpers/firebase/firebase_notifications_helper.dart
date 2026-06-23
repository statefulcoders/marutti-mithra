import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseNotificationsHelper {
  static const String notificationsTableName = 'notifications';

  static final _db = FirebaseFirestore.instance;
  static final _notificationsDB = _db.collection(notificationsTableName);

  static CollectionReference get ref => _notificationsDB;
  static Query get query => _notificationsDB.where('sentBy', isEqualTo: 'admin');

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final docs = await _notificationsDB.get();
    return docs.docs.map((e) => e.data()).toList();
  }
}