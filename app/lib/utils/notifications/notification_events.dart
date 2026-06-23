import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../configs/local/app_configs.dart';
import 'local_notification_service.dart';

@pragma("vm:entry-point")
Future<void> onBackgroundNotification(RemoteMessage message) async {
  debugPrint('Background Notification: ${message.notification?.toMap()} [${message.data}]');
}

@pragma("vm:entry-point")
Future<void> onForegroundNotification(RemoteMessage message) async {
  debugPrint('Foreground Notification: ${message.notification?.toMap()} [${message.data}]');

  // Show local notification using NotificationService
  if (message.notification != null) {
    try {
      LocalNotificationService notificationService = Get.find<LocalNotificationService>();
      await notificationService.showLocalNotification(
        messageId: message.messageId,
        title: message.notification!.title ?? AppConfig.appName,
        body: message.notification!.body ?? 'You have a new update!',
        payload: message.data
      );
    } catch (error) {
      debugPrint('Error Showing Foreground Notification: $error');
    }
  }
}

@pragma("vm:entry-point")
Future<void> onMessageOpenedApp(RemoteMessage message) async {
  debugPrint('App Opened From Notification: ${message.notification?.toMap()} [${message.data}]');

  // if (message.data.isNotEmpty && message.data['route'] != null && Get.context != null) {
    // await Get.toNamed(message.data['route']);
  // }
}

@pragma("vm:entry-point")
Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
  debugPrint('App Opened From local Notification: ${response.payload}');
}

@pragma("vm:entry-point")
Future<void> onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
  debugPrint('App Opened From local background Notification: ${response.payload}');
}
