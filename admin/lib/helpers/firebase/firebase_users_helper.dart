import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/helpers/firebase/push_notifications_helper.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';
import 'dart:convert';

import 'package:string_similarity/string_similarity.dart';


class FirebaseUsersHelper {
  static const String userTableName = 'users';
  static const String notificationTableName = 'notifications';

  static final _db = FirebaseFirestore.instance;
  static final _usersDB = _db.collection(userTableName);

  static CollectionReference get ref => _usersDB;

  static Future<DashboardCard> getStats() async {
    int totalUsers = 0;
    int todayUsers = 0;
    double totalPoints = 0;
    try {
      final totalResponse = await _usersDB.aggregate(count(), sum('maPoints'), sum('vcPoints'), sum('mwPoints'), sum('hpPoints')).get();
      totalUsers = totalResponse.count ?? 0;

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      totalPoints = [ 'maPoints', 'vcPoints', 'mwPoints', 'hpPoints' ].fold(0.0, (previousValue, element) => previousValue + (totalResponse.getSum(element) ?? 0.0));
      final todayResponse = await _usersDB.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight)).count().get();
      todayUsers = todayResponse.count ?? 0;
    } catch (_) {}
    final subMetrics = [
      'Total: ${NumberFormat('#,##0').format(totalUsers)}',
      'Total Points: ${NumberFormat('#,##0').format(totalPoints)}'
    ];
    return DashboardCard(label: 'Users', icon: Icons.group, color: Colors.pink, subMetrics: subMetrics, conclusion: todayUsers == 0 ? '0% Users Today' : '${totalUsers > 0 ? '+' : ''}${NumberFormat('#,##0').format(todayUsers)} Users Today', conclusionColor: todayUsers <= 0 ? Colors.red : Colors.green,);
  }


  static Future<List<Map<String, dynamic>>> search(String term, [int limit = 10]) async {
    final List<Map<String, dynamic>> results = [];
    final String query = term.toLowerCase().trim();

    DocumentSnapshot? lastDocument;
    int scannedCount = 0;
    const int batchSize = 50; // Larger batches are faster for network requests

    while (results.length < limit && scannedCount < 500) {
      var queryRef = _usersDB.orderBy('createdAt').limit(batchSize);

      if (lastDocument != null) {
        queryRef = queryRef.startAfterDocument(lastDocument);
      }

      final snapshot = await queryRef.get();
      if (snapshot.docs.isEmpty) break;

      lastDocument = snapshot.docs.last;
      scannedCount += snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Extract fields
        final String firstName = (data['firstName'] ?? '').toString().toLowerCase();
        final String lastName  = (data['lastName'] ?? '').toString().toLowerCase();
        final String phone     = (data['phone'] ?? '').toString().toLowerCase();
        final String shopName  = (data['shopName'] ?? '').toString().toLowerCase();
        final String district  = (data['district'] ?? '').toString().toLowerCase();

        // Combine searchable text for a comprehensive match
        final String combined = "$firstName $lastName $phone $shopName $district";

        if (combined.contains(query)) {
          // Calculate similarity score (0.0 to 1.0)
          double score = StringSimilarity.compareTwoStrings(combined, query);

          results.add({
            ...data,
            'uid': doc.id,
            '_score': score, // Store score for sorting
          });
        }
      }

      if (snapshot.docs.length < batchSize) break;
    }

    // Sort by similarity score descending
    results.sort((a, b) => b['_score'].compareTo(a['_score']));

    return results.take(limit).toList();
  }

  static Future<void> addPoints(String uid, String? token, String productName, String shopName, String quantity, int points) async {
    String pointType = {
      'marutti aluminiums': 'maPoints',
      'vinlam concepts': 'vcPoints',
      'mwholesales': 'mwPoints',
      'hardware palace': 'hpPoints',
    }[shopName.toLowerCase()] ?? '';

    await _usersDB.doc(uid).update({
      pointType: FieldValue.increment(points),
    });

    String title = 'Points Added';
    String body = 'You have received +$points points on purchase of $quantity $productName from $shopName.';

    await _db.collection(notificationTableName).add({
      'receiver': uid,
      'sender': FirebaseAuth.instance.currentUser?.uid ?? 'admin',
      'title': title,
      'body': body,
      'createdAt': Timestamp.now()
    });

    if (token != null && token.isNotEmpty) {
      await PushNotificationsHelper.sendNotification(title: title, body: body, token: token);
    }
  }
}