import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/resources/marutti_icons.dart';

import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find();
    
    return Scaffold(
      backgroundColor:Colors.grey.shade100,
      appBar: AppBar(
        title: Text('settings'.tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white
              ),
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _settingTile(controller, 'your_profile'.tr, MaruttiIcons.user, controller.onProfileTap),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  _settingTile(controller, 'language'.tr, MaruttiIcons.language, () => controller.onLanguageTap(context)),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  _settingTile(controller, 'account_delete'.tr, MaruttiIcons.delete, controller.onDeleteAccount),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  _settingTile(controller, 'privacy_policy'.tr, MaruttiIcons.privacy, controller.onPrivacyTap),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  _settingTile(controller, 'terms_of_services'.tr, MaruttiIcons.terms, controller.onTermsTap),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  _settingTile(controller, 'support'.tr, MaruttiIcons.support, controller.onSupportTap),
                  // Divider(color: Colors.grey.shade300, thickness: 1),
                  // _settingTile(controller, 'about_us'.tr, MaruttiIcons.aboutUs, controller.onAboutTap),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.w),
                child: ElevatedButton.icon(
                  onPressed: controller.logout,
                  icon: Icon(Icons.login, color: Colors.white, size: 26.sp),
                  label: Text('logout'.tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE54447),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 28.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget _settingTile(SettingsController controller, String title, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(14.0.w),
        child: Row(
          children: [
            _icon(iconPath),
            SizedBox(width: 12.w),
            Expanded(child: Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, size: 17.sp),
          ],
        ),
      ),
    );
  }

  Widget _icon(String asset) {
    return Image.asset(asset, width: 22.w, height: 22.w);
  }
}
