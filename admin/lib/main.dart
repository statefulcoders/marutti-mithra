import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_web/just_audio_web.dart';
import 'package:marutti_mitra_admin/comlate/comlate_app.dart';
import 'package:marutti_mitra_admin/firebase_options.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';
import 'package:marutti_mitra_admin/utils/settings/secure_memory.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SecureMemory.initialize(),
  ]);

  if (kIsWeb) {
    JustAudioPlugin.registerWith(webPluginRegistrar);

    // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  final app = await ComlateApp.instance(initialRoute: AdminRoutes.main, pages: AdminRoutes.pages);
  runApp(app);
}