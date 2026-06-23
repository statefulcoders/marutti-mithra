import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'intent_utils_stub.dart';

export 'intent_utils_stub.dart'
  if (dart.library.html) 'intent_utils_web.dart';

class IntentUtils {
  static Future<void> launchCall(String phone) async {
    final Uri url = Uri.parse("tel://+91$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch call');
    }
  }

  static Future<void> launchWhatsApp(String phone) async {
    final Uri directUri = Uri.parse("whatsapp://send?phone=91$phone&text=Hello");
    final Uri fallbackUri = Uri.parse("https://wa.me/91$phone");

    if (await canLaunchUrl(directUri)) {
      await launchUrl(directUri);
    } else if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri);
    } else {
      Get.snackbar('Error', 'Could not launch call');
    }
  }

  static Future<void> launchEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch call');
    }
  }

  static Future<void> launchInBrowser(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch call');
    }
  }
  static void previewPdfBlob(Uint8List bytes) {
    IntentUtilsWeb.previewPdfBlob(bytes);
  }
}