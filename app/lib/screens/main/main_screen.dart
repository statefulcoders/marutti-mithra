import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/resources/marutti_logos.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/screens/main/home/home_page.dart';
import 'package:maruttimitra/screens/main/points/points_page.dart';
import 'package:maruttimitra/screens/main/settings/settings_page.dart';
import 'package:maruttimitra/screens/main/rewards/rewards_page.dart';
import 'package:maruttimitra/screens/main/support/support_page.dart';
import 'package:maruttimitra/utils/notifications/firebase_notification_service.dart';
import 'package:upgrader/upgrader.dart';

import '../../../configs/design/marutti_colors.dart';
import '../../../resources/marutti_icons.dart';
import '../../../widgets/app_root_container.dart';
import 'main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.toNamed(MaruttiRoutes.splash)?.then((value) => Get.find<FirebaseNotificationService>().requestPermission());
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    final _upgrader = Upgrader(
      // debugDisplayAlways: true,
      // debugLogging: true,
      durationUntilAlertAgain: Duration(seconds: 10),
    );

    final screens = [
      HomePage(),
      PointsPage(),
      RewardsPage(),
      SettingsPage(),
    ];

    return AppRootContainer(
      child: UpgradeAlert(
        upgrader: _upgrader,
        showLater: false,
        showIgnore: false,
        child: Scaffold(
          body: SafeArea(child: Obx(() => screens[controller.tabIndex.value])),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent, // No splash color
              highlightColor: Colors.transparent, // No highlight
            ),
            child: Obx(() => BottomNavigationBar(
              items: _createNavItems(context),
              elevation: 0,
              selectedItemColor: Theme.of(context).colorScheme.onSurface,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withAlpha(200),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 15.sp,
              unselectedFontSize: 15.sp,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500
              ),
              currentIndex: controller.tabIndex.value,
              onTap: (index) => controller.tabIndex.value = index,
            )),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _createNavItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
          label: 'home'.tr,
          backgroundColor: MaruttiColors.primaryColor,
          icon: _createNavIcon(MaruttiIcons.home),
          activeIcon: _createNavIcon(MaruttiIcons.homeFilled, true)
      ),
      BottomNavigationBarItem(
          label: 'points'.tr,
          backgroundColor: MaruttiColors.primaryColor,
          icon: _createNavIcon(MaruttiIcons.points),
          activeIcon: _createNavIcon(MaruttiIcons.pointsFilled, true)
      ),
      BottomNavigationBarItem(
          label: 'rewards'.tr,
          backgroundColor: MaruttiColors.primaryColor,
          icon: Icon(Icons.emoji_events_outlined, size: 24.w),
          activeIcon: Icon(Icons.emoji_events, size: 24.w)
      ),
      BottomNavigationBarItem(
          label: 'settings'.tr,
          backgroundColor: MaruttiColors.primaryColor,
          icon: _createNavIcon(MaruttiIcons.settings),
          activeIcon: _createNavIcon(MaruttiIcons.settingsFilled, true)
      ),
    ];
  }

  Widget _createNavIcon(String image, [bool isActive = false]) {
    return Image.asset(
      image,
      height: 24.w,
      width: 24.w,
    );
  }
}
