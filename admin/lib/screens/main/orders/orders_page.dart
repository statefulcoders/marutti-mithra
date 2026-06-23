import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/screens/main/conversations/conversation_screen.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_page.dart';

import '../messages/messages_controller.dart';

class OrdersPage extends StatelessWidget {
  final String label = 'Orders';
  
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessagesController(conversationType: label.toLowerCase()), tag: label.toLowerCase());
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
    final messagePage = isDesktop ? Column(
      children: [
        _createFilters(controller),
        Expanded(child: MessagesPage(controller: controller))
      ],
    ) : MessagesPage(controller: controller);

    return isDesktop ? Row(
      children: [
        Expanded(child: messagePage),
        SizedBox(width: 4.w),
        if (isDesktop) Expanded(child: _createConversationPage(context, controller, true)),
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

  Widget _createFilters(MessagesController controller) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.onlyOrderLevels.length,
        itemBuilder: (context, index) => _createFilter(controller, controller.onlyOrderLevels[index]),
        separatorBuilder: (context, index) => SizedBox(width: 4.w)
      ),
    );
  }

  Widget _createFilter(MessagesController controller, String status) {
    return Obx(() => FilterChip(
      label: Text(status.capitalizeFirst!),
      selected: controller.shopFilter.value == status,
      onSelected: (selected) => controller.filterLeads(status),
      backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
      selectedColor: Get.isDarkMode ? Colors.grey[700] : Colors.grey[300],
      labelStyle: TextStyle(
        color: controller.shopFilter.value == status
            ? Get.isDarkMode ? Colors.white : Colors.black87
            : Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
      ),
      side: BorderSide(
        color: controller.shopFilter.value == status
            ? Get.isDarkMode ? Colors.grey[600]! : Colors.grey[400]!
            : Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      ),
    ));
  }
}
