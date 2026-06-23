import 'package:get/get.dart';
import 'package:maruttimitra/screens/main/home/home_controller.dart';
import 'package:maruttimitra/screens/main/points/points_controller.dart';
import 'package:maruttimitra/screens/main/settings/profile_controller.dart';
import 'package:maruttimitra/screens/main/settings/settings_controller.dart';
import 'package:maruttimitra/screens/main/support/support_controller.dart';
import 'package:maruttimitra/screens/main/rewards/rewards_controller.dart';

import '../../screens/main/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PointsController());
    Get.lazyPut(() => SupportController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => RewardsController());
  }
}