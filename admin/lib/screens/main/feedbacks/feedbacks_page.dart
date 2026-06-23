import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/screens/main/conversations/conversation_screen.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_controller.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_page.dart';

class FeedbacksPage extends StatelessWidget {
  final String label = 'Feedbacks';
  
  const FeedbacksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessagesController(conversationType: label.toLowerCase()), tag: label);
    final isDesktop = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.desktop;

    return ComlateRootContainer(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: WillPopScope(
            child: _createRow(context, controller, isDesktop),
            onWillPop: () async {
              if (controller.openConversation.value != null) {
                controller.openConversation.value = null;
                return false;
              } else {
                return true;
              }
            },
          )
      ),
    );
  }

  Widget _createRow(BuildContext context, MessagesController controller, bool isDesktop) {
    final messagePage = MessagesPage(controller: controller);
    return isDesktop ? Row(
        children: [
          Expanded(child: messagePage),
          SizedBox(width: 4.w),
          if (isDesktop) Expanded(child: _createConversationPage(context, controller, isDesktop)),
        ]
    ) : Obx(() => controller.openConversation.value == null ? messagePage : _createConversationPage(context, controller, false));
  }

  Widget _createConversationPage(BuildContext context, MessagesController controller, bool isDesktop) {
    return Card(
      color: Colors.black12,
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w).copyWith(top: 0),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: Obx(() => controller.openConversation.value == null ? placeholder() : ConversationScreen(label: label, isDesktop: isDesktop, userData: controller.openConversation.value ?? {})),
    );
  }

  Widget placeholder() {
    return Center(
        child: Text(
          "Select any conversation to start chatting",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        )
    );
  }
}
