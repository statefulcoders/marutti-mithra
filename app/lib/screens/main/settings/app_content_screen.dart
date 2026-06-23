import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/configs/local/constants.dart';

import '../../../widgets/app_root_container.dart';
import 'app_content_controller.dart';


class AppContentScreen extends StatelessWidget {
  const AppContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppContentController controller = Get.find();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String title = controller.type == Constants.privacyPolicy ? 'privacy_policy'.tr : 'terms_of_services'.tr;

    return AppRootContainer(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(title),
          leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
        ),
        body: SafeArea(
          child: Obx(() => controller.isLoading.value ? Center(
            child: CircularProgressIndicator(
              color: Get.isDarkMode ? Theme.of(context).colorScheme.primary : MaruttiColors.primaryColor,
            ),
          ) : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 20.h),
            child: Obx(
                  () => Html(
                data: controller.currentContent.value,
                style: {
                  "h1": Style(
                    fontSize: FontSize(25.sp),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  "h2": Style(
                    fontSize: FontSize(19.sp),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  "p": Style(
                    fontSize: FontSize(17.sp),
                    color: colorScheme.onSurface.withAlpha(200),
                  ),
                  "li": Style(
                    fontSize: FontSize(17.sp),
                    color: colorScheme.onSurface.withAlpha(200),
                  ),
                  "a": Style(
                    fontSize: FontSize(17.sp),
                    color: Get.isDarkMode
                        ? colorScheme.primary
                        : MaruttiColors.primaryColor,
                    textDecoration: TextDecoration.underline,
                  ),
                },
                onLinkTap: (url, _, __) {
                  if (url != null) {
                    // Add logic to launch URL (e.g., using url_launcher)
                    
                  }
                },
              ),
            ),
          )),
        ),
      ),
    );
  }
}