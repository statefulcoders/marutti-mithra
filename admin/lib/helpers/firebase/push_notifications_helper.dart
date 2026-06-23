import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PushNotificationsHelper {
  static Future<http.Response?> callFunction({ required String endpoint, required Map<String, dynamic> arguments }) async {
    try {
      final response = await http.post(
        Uri.parse('https://us-central1-marutti-mitra-groups.cloudfunctions.net/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(arguments),
      );

      if (response.statusCode != 200) {
        debugPrint('Error response from notification endpoint: ${response.statusCode} ${response.body}');
      }
      return response;
    } catch (e) {
      debugPrint('Error sending push notification: $e ${jsonEncode(arguments)}');
    }
    return null;
  }

  static Future<void> sendNotification({ required String title, required String body, required String token }) {
    return callFunction(
        endpoint: 'sendNotification',
        arguments: { 'title': title, 'body': body, 'token': token }
    );
  }

  static Future<void> sendNotificationByCategory({ required String title, required String body, String? category }) {
    return callFunction(
        endpoint: 'sendNotificationByCategory',
        arguments: { 'title': title, 'body': body, 'category': category }
    );
  }
}