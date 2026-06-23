import 'package:get/get.dart';
import 'package:maruttimitra/screens/login/login_controller.dart';

import '../../screens/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}