
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_catalogues_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_notifications_helper.dart';
import 'package:marutti_mitra_admin/screens/main/catalogues/catalogues_controller.dart';
import 'package:marutti_mitra_admin/screens/main/notifications/notifications_controller.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class NotificationsPage extends StatelessWidget {
  final String label;
  const NotificationsPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => controller.config.value == null ? Center(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: CircularProgressIndicator(),
            ),
          ) : ComlateFirebaseTable(
            columns: controller.columns,
            dataSource: FirebaseNotificationsHelper.ref,
            filteredQuery: FirebaseNotificationsHelper.query,
            identifier: label,
            enableEditing: false,
            enableDetails: true,
            enableDeletion: false,
            customActionLabel: 'Send Notification',
            sortBy: 'createdAt',
            onAction: () => controller.sendNotification(),
            updateConfig: controller.config.value,
          )),
        ],
      ),
    );
  }
}
