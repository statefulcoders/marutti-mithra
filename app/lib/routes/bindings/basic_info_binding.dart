import 'package:get/get.dart';
import 'package:maruttimitra/screens/login/basic_info_controller.dart';

class BasicInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BasicInfoController());
  }
}