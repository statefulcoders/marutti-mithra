import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_logos.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesPage extends StatelessWidget {
  final MessagesController controller;

  const MessagesPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => controller.getConversations());
    
    return ComlateRootContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          final conversations = controller.conversations.value;

          if (conversations == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  'No Messages'
                )
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) => _createMessageTile(context, index, controller)
          );
        })
      )
    );
  }

  Widget _createMessageTile(BuildContext context, int index, MessagesController controller) {
    final data = controller.conversations.value![index];

    final textStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500
    );

    final isPhone = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.phone;
    final updatedAt = data['updatedAt']?.toDate() ?? DateTime.now();
    final updatedAtStr = isPhone ? timeago.format(updatedAt) : DateFormat('hh:mm a, dd MMM yy').format(updatedAt);
    final unreadCounts = int.tryParse(data['unreads']?.toString() ?? '0') ?? 0;
    final unreadCountsStr = unreadCounts > 9 ? '9+' : unreadCounts.toString();

    final content = data['lastContent'];


    return Obx(() {
      final isOpen = controller.openConversation.value?['id'] != data['id'];

      return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              side: BorderSide(width: isOpen ? 0 : 1, color: AppConfig.primaryColor.withAlpha(200))
          ),
          clipBehavior: Clip.hardEdge,
          color: Get.isDarkMode ? Colors.black38 : Colors.white,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          elevation: 0,
          child: InkWell(
            onTap: () => controller.openAt(context, index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                children: [
                  _createDummyProfilePhoto(),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['username'] ?? 'Deleted User',
                                style: textStyle,
                              ),
                            ),
                            Text(updatedAtStr, style: textStyle.copyWith(color: Colors.grey.shade400, fontSize: 12.sp))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (content == '<image>' && data['audioFile'] != null) ? 'Image File' : (content == '<audio>' && data['audioFile'] != null) ? 'Audio File' : content ?? 'None',
                                style: textStyle.copyWith(fontSize: 13.sp, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unreadCounts > 0) Badge(label: Text(unreadCountsStr), backgroundColor: AppConfig.primaryColor, textColor: Colors.white)
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
      );
    });
  }

  Widget _createDummyProfilePhoto() {
    return CircleAvatar(
      radius: 26.r,
      backgroundImage: AssetImage(ComlateLogos.manager)
    );
  }
}
