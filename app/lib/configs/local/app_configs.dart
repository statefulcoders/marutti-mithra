import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  static const appName = 'Marutti Mitra';
  static const appVersionCode = 1;
  static String get platformType => kIsWeb ? 'web' : Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'other';

  static const defaultCountryCode = '+91';
  static const resendDuration = 120;
  static const phoneLength = 10;
  static const otpLength = 6;

  static const nameLength = 50;
  static const emailLength = 255;
  static const streetAddressLength = 100;
  static const pinCodeLength = 6;

  static final recordingDuration = Duration(minutes: 5);

  static final imageSizeLimitInMB = 8.round();
}