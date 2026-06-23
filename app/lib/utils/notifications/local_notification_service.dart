import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/overlays/app_snackbar.dart';

import 'notification_config.dart';
import 'notification_events.dart';

class LocalNotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse
    );

    // Create a notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConfig.notificationChannelId,
      NotificationConfig.notificationChannelName,
      description: NotificationConfig.notificationChannelDescription,
      importance: Importance.max,
    );

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // Request iOS notification permissions
    await _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _isInitialized = true;
  }

  // Reusable function to show a local notification
  Future<void> showLocalNotification({
    String? messageId,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final uniqueId = messageId != null
        ? messageId.hashCode
        : DateTime.now().microsecondsSinceEpoch.hashCode;
    if (!_isInitialized) {
      await init();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      NotificationConfig.notificationChannelId,
      NotificationConfig.notificationChannelName,
      channelDescription: NotificationConfig.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      uniqueId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  // Test method to send a sample notification
  Future<void> testNotification() async {
    try {
      await showLocalNotification(
        messageId: 'hello',
        title: 'Test Notification',
        body: 'This is a test notification from NotificationService.',
        payload: {'route': '/resume-builder'},
      );
    } catch (error) {
      AppSnackBar.error(error.toString());
    }
  }
}