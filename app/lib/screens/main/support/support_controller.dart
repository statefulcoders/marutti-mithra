import 'package:get/get.dart';
import 'package:maruttimitra/overlays/app_snackbar.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/message_table_helper.dart';

import '../../../configs/local/constants.dart';
import '../../../utils/extras_table_helper.dart';

class SupportController extends GetxController {
  final RxString email = ''.obs;
  final RxMap<String, String> contacts = <String, String>{}.obs;
  final RxString phone = ''.obs;
  final RxString location = ''.obs;
  final RxString hours = ''.obs;
  final RxBool isLoading = true.obs;

  final List<Map<String, String>> faqs = [
    {
      "question": "faq_q1",
      "answer": "faq_a1",
    },
    {
      "question": "faq_q2",
      "answer": "faq_a2",
    },
    {
      "question": "faq_q3",
      "answer": "faq_a3",
    },
    {
      "question": "faq_q4",
      "answer": "faq_a4",
    },
    {
      "question": "faq_q5",
      "answer": "faq_a5",
    },
    {
      "question": "faq_q6",
      "answer": "faq_a6",
    },
    {
      "question": "faq_q7",
      "answer": "faq_a7",
    },
    {
      "question": "faq_q8",
      "answer": "faq_a8",
    },
    {
      "question": "faq_q9",
      "answer": "faq_a9",
    },
    {
      "question": "faq_q10",
      "answer": "faq_a10",
    },
    {
      "question": "faq_q11",
      "answer": "faq_a11",
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadSupportInfo();
  }

  void loadSupportInfo() async {
    try {
      final response = await ExtrasTableHelper.getSupportDetails();
      email.value = response.email;
      phone.value = response.phone;
      location.value = response.location;
      hours.value = response.time;
      contacts.value = response.contacts;
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void placeAnOrder() {
    Get.toNamed(MaruttiRoutes.supportChat, parameters: {
      Constants.keyTitle: 'place_order',
      Constants.keyCategory: MessageTableHelper.categoryOrder
    });
  }

  void feedbackOrComplaint() {
    Get.toNamed(MaruttiRoutes.supportChat, parameters: {
      Constants.keyTitle: 'complaint_or_feedback',
      Constants.keyCategory: MessageTableHelper.categoryFeedback
    });
  }
}