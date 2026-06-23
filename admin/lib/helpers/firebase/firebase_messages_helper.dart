import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseMessagesHelper {
  static const String messagesTableName = 'messages';

  static const String categoryOrder = 'orders';
  static const String categoryFeedback = 'feedbacks';

  static final _db = FirebaseFirestore.instance;
  static final ordersDB = _db.collectionGroup(categoryOrder);
  static final feedbacksDB = _db.collectionGroup(categoryFeedback);

  static Future<DashboardCard> getStats() async {
    int totalOrders = 0;
    int totalFeedbacks = 0;
    int todayMessages = 0;
    try {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final List<AggregateQuerySnapshot> counts = await Future.wait([
        ordersDB.where('sender', isEqualTo: 'you').count().get(),
        feedbacksDB.where('sender', isEqualTo: 'you').count().get(),
        ordersDB.where('sender', isEqualTo: 'you').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight)).count().get(),
        feedbacksDB.where('sender', isEqualTo: 'you').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight)).count().get(),
      ]);
      totalOrders = counts.first.count ?? 0;
      totalFeedbacks = counts[1].count ?? 0;
      todayMessages = ((counts[2].count ?? 0) + (counts.last.count ?? 0));
    } catch (_) {}
    int newOrders = 0;
    int newFeedbacks = 0;
    try {
      final orders = await FirebaseFirestore.instance.collection(messagesTableName).aggregate(sum('orders.unreads')).get();
      newOrders = orders.getSum('orders.unreads')?.toInt() ?? 0;
      final feedbacks = await FirebaseFirestore.instance.collection(messagesTableName).aggregate(sum('feedbacks.unreads')).get();
      newFeedbacks = feedbacks.getSum('feedbacks.unreads')?.toInt() ?? 0;
    } catch (err) {
      print('Getting sum: $err');
    }
    final subMetrics = [
      'Total Orders: ${NumberFormat('#,##0').format(totalOrders)}${newOrders > 0 ? ' ($newOrders unread)' : ''}',
      'Total Feedbacks: ${NumberFormat('#,##0').format(totalFeedbacks)}${newFeedbacks > 0 ? ' ($newFeedbacks unread)' : ''}',
    ];
    String conclusion = '${NumberFormat('#,##0').format(todayMessages)} messages today';
    return DashboardCard(label: 'Messages', icon: Icons.chat_bubble_outline_rounded, color: Colors.deepPurple, subMetrics: subMetrics, conclusion: conclusion, conclusionColor: todayMessages > 0 ? Colors.green : Colors.red);
  }
}