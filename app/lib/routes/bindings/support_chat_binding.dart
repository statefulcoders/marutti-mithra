import 'package:get/get.dart';
import 'package:maruttimitra/screens/main/support/support_chat_controller.dart';

class SupportChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupportChatController());
  }
}