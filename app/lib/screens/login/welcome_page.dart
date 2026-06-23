import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/local/app_configs.dart';
import 'package:maruttimitra/dialogs/select_language_dialog.dart';
import 'package:maruttimitra/resources/marutti_logos.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRootContainer(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 35.h),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        MaruttiLogos.splash,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.sizeOf(context).width * 0.45,
                      ),
                      Text(
                        AppConfig.appName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)
                      )
                    ],
                  )
              ),
              SelectLanguageDialog(),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.all(14.w).copyWith(top: 0),
                child: ElevatedButton(
                  onPressed: () {
                    MaruttiSettingsMemory.setLanguage(MaruttiSettingsMemory.currentLanguage);
                    Get.offAllNamed(MaruttiRoutes.main);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('continue'.tr, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      )),
                      SizedBox(width: 6.w),
                      Icon(Icons.arrow_forward_ios_outlined, size: 15.sp)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
