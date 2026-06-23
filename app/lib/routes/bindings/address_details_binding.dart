import 'package:get/get.dart';
import 'package:maruttimitra/screens/login/address_details_controller.dart';

class AddressDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddressDetailsController());
  }
}