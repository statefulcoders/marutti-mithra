import 'package:get/get.dart';
import 'package:maruttimitra/screens/main/settings/app_content_controller.dart';

class AppContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppContentController());
  }
}