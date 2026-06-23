import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/widgets/firebase_table/comlate_firebase_table_controller.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_notifications_helper.dart';
import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';
import '../../../helpers/firebase/firebase_dynamic_fields_helper.dart';
import '../../../helpers/firebase/push_notifications_helper.dart';

class NotificationsController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Category', keys: ['category']),
    ComlateFirebaseTableColumn(label: 'Title', keys: ['title']),
    ComlateFirebaseTableColumn(label: 'Body', keys: ['body']),
    ComlateFirebaseTableColumn(label: 'Sent At', keys: ['createdAt']),
  ];

  final config = Rxn<List<DataUpdateFieldInfo>>();

  @override
  void onInit() {
    _initialize();
    super.onInit();
  }

  Future<void> _initialize() async {
    try {
      final response = await FirebaseDynamicFieldsHelper.ref.get();
      final data = response.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      final categories = [
        'All Users',
        ...List<String>.from(data.where((element) => element['key'] == 'buyerCategory').firstOrNull?['data'] ?? []),
      ];
      config.value = [
        DataUpdateFieldInfo(key: 'title', expectedType: 'text', hint: "Enter title", min: 1, max: 100, required: true),
        DataUpdateFieldInfo(key: 'body', expectedType: 'text', hint: "Enter message", min: 1, max: 500, required: true),
        DataUpdateFieldInfo(key: 'category', expectedType: 'dropdown', hint: "Category", options: categories, required: true),
        DataUpdateFieldInfo(key: 'createdAt', expectedType: 'date', hint: "Sent time", editable: false),
      ];
    } catch (error) {
      config.value = [];
    }
  }

  Future<void> sendNotification() async {
    try {
      final updatedData = await DataUpdaterDialog.show(
        data: { 'category': 'All Users' },
        fieldInfo: config.value!.where((element) => element.key != 'createdAt').toList(),
        editable: true,
        customLabel: "Send Notification",
      );
      if (updatedData is Map<String, dynamic> && updatedData.isNotEmpty) {
        await FirebaseNotificationsHelper.ref.doc().set({
          ...updatedData,
          'sentBy': 'admin',
          'createdAt': DateTime.now()
        });
        final category = updatedData['category'] == 'All Users' ? null : updatedData['category'];
        await PushNotificationsHelper.sendNotificationByCategory(title: updatedData['title'], body: updatedData['body'], category: category);
        Get.find<ComlateFirebaseTableController>(tag: 'Notifications').getInitialPage();
      }
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Creation Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }
}