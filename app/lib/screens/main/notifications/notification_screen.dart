import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/screens/main/notifications/notifications_controller.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return AppRootContainer(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text('notifications'.tr),
          leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
        ),
        body: SafeArea(
          child: Obx(() => controller.notifications.value == null ? Center(
            child: CircularProgressIndicator(),
          ) : controller.notifications.value!.isEmpty ? _createEmptyState() : _createNotificationsList(controller.scrollController, controller.notifications.value!)),
        )
      ),
    );
  }

  Widget _createEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80.sp,
              color: Colors.grey.shade500,
            ),
            SizedBox(height: 20.h),
            Text(
              'no_notifications_yet'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'no_notifications_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createNotificationsList(ScrollController controller, List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: notifications.length,
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.r))
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(1000))
                ),
                alignment: Alignment.center,
                child: Icon(Icons.notifications_none, color: Colors.grey.shade600)
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notifications[index]['title'] ?? 'Notification',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp
                          ),
                        ),
                      ),
                      Text(
                        timeago.format((notifications[index]['createdAt']?.toDate()) ?? DateTime.now()),
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                            fontSize: 13.5.sp
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                      notifications[index]['body'] ?? 'You have an update.',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
