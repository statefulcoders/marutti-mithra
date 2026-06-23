import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../../firebase_options.dart';
import 'local_notification_service.dart';
import 'notification_events.dart';

class FirebaseNotificationService extends GetxService {
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  late final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final LocalNotificationService _notificationService = Get.find<LocalNotificationService>();

  Future<void> initializeFirebaseApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> initialize() async {
    try {
      await initializeFirebaseApp();
      await _notificationService.init(); // Initialize NotificationService

      // Set up FCM listeners
      FirebaseMessaging.onBackgroundMessage(onBackgroundNotification);
      _onMessageSubscription = FirebaseMessaging.onMessage.listen(onForegroundNotification);
      _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

      // Enable iOS foreground notifications
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('Error while initializing firebase notification service: ${await generateToken()}');

    } catch (error) {
      print('Error while initializing firebase notification service: $error');
    }
  }

  Future<void> handleNotificationClick() async {

    // final initialMessage = await fcm.getInitialMessage();
    // if (initialMessage != null) {
    //   onMessageOpenedApp(initialMessage);
    // }

  }

  Future<NotificationSettings> requestPermission() async {
    // Request FCM permissions
    return await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<String?> generateToken() async {
    String? token;
    try {
      token = await fcm.getToken();
    } catch (error) {
      return 'ERROR:$error';
    }
    return token;
  }

  Future<void> logout(String userId) async {
    try {
      await fcm.deleteToken();
    } catch (error) {
      print('Error while logging out from FCM: $error');
    }
  }

  @override
  void onClose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    super.onClose();
  }
}