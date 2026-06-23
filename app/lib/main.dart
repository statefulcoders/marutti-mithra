import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/marutti_mitra_app.dart';
import 'package:maruttimitra/utils/extra_fields_helper.dart';
import 'package:maruttimitra/utils/notifications/firebase_notification_service.dart';
import 'package:maruttimitra/utils/notifications/local_notification_service.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(LocalNotificationService());
  await Get.put(FirebaseNotificationService()).initialize();

  await Future.wait([
    MaruttiSettingsMemory.initialize(),
    MaruttiSessionMemory.initialize(),
  ]);

  if (MaruttiSessionMemory.isLoggedIn) {
    UserTableHelper.initialize();
    ExtraFieldsHelper.initialize();
  }

  runApp(const MaruttiMitraApp());
}
