import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../overlays/app_snackbar.dart';

class IntentUtils {
  static Future<void> launchCall(String phone) async {
    final Uri url = Uri.parse("tel://+91$phone");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (error) {
      AppSnackBar.error('could_not_launch_call'.tr);
    }
  }

  static Future<void> launchWhatsApp(String phone) async {
    final Uri directUri = Uri.parse("whatsapp://send?phone=91$phone&text=Hello");
    final Uri fallbackUri = Uri.parse("https://wa.me/91$phone");

    try {
      await launchUrl(directUri);
    } catch (error) {
      try {
        await launchUrl(fallbackUri);
      } catch (error) {
        AppSnackBar.error('could_not_launch_whatsapp'.tr);
      }
    }
  }

  static Future<void> launchEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (error) {
      AppSnackBar.error('could_not_launch_email'.tr);
    }
  }

  static Future<void> launchInBrowser(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (error) {
      AppSnackBar.error('could_not_launch_url'.tr);
    }
  }
}