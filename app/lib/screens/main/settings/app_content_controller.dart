import 'package:get/get.dart';
import 'package:maruttimitra/configs/local/constants.dart';

import '../../../utils/assets_utils.dart';

class AppContentController extends GetxController {
  final String type = Get.parameters[Constants.keyType]?.toString() ?? Constants.termsOfService;

  // Reactive variables
  final isLoading = false.obs;
  RxString currentContent = ''.obs;

  Future<void> setContentType(String type) async {
    if (type == Constants.termsOfService) {
      currentContent.value = await AssetsUtils.loadText("assets/other/terms_of_service.html");
    } else {
      currentContent.value = await AssetsUtils.loadText("assets/other/privacy_policy.html");
    }
  }

  Future<void> fetchContent(String type) async {
    isLoading.value = true;
    setContentType(type);
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchContent(type);
  }
}