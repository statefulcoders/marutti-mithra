import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/comlate/overlays/app_snackbar.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/push_notifications_helper.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';

class FirebaseSubAdminHelper {
  static const String subAdminTable = 'admins';

  static const String permAddPoints = 'perm_add_points';
  static const String permExportData = 'perm_export_data';
  static const String permEditUser = 'perm_update_user';
  static const String permDeleteUser = 'perm_delete_user';
  static const String permDynamicField = 'perm_create_or_update_dynamic_field';
  static const String permAddProduct = 'perm_create_product';
  static const String permUpdateProduct = 'perm_update_product';
  static const String permDeleteProduct = 'perm_delete_product';
  static const String permCreateCatalogue = 'perm_create_catalogue';
  static const String permUpdateCatalogue = 'perm_update_catalogue';
  static const String permDeleteCatalogue = 'perm_delete_catalogue';
  static const String permCreateVideo = 'perm_create_video';
  static const String permUpdateVideo = 'perm_update_video';
  static const String permDeleteVideo = 'perm_delete_video';
  static const String permAccessOrders = 'perm_access_orders';
  static const String permAccessFeedbacks = 'perm_access_feedbacks';
  static const String permAccessNotification = 'perm_access_notifications';
  static const String permAccessSupportSettings = 'perm_access_support_settings';

  static const String permManageRewards = 'perm_manage_rewards';
  static const String permDistributeRewards = 'perm_distribute_rewards';

  static const List<String> allPerms = [
    permAddPoints,
    permExportData,
    permEditUser,
    permDeleteUser,
    permDynamicField,
    permAddProduct,
    permUpdateProduct,
    permCreateCatalogue,
    permUpdateCatalogue,
    permDeleteCatalogue,
    permCreateVideo,
    permUpdateVideo,
    permDeleteVideo,
    permAccessOrders,
    permAccessFeedbacks,
    permAccessNotification,
    permAccessSupportSettings,
    permManageRewards,
    permDistributeRewards
  ];

  static final _db = FirebaseFirestore.instance;
  static final _subAdminDB = _db.collection(subAdminTable);

  static CollectionReference get ref => _subAdminDB;
  
  static Future<void> createSubAdmin(Map<String, dynamic> data) async {
    try {
      final response = await PushNotificationsHelper.callFunction(endpoint: 'createAdminUser', arguments: {
        'email': data['email']!,
        'password': data.remove('password')
      });
      final jsonResponse = jsonDecode(response?.body ?? '{}') ?? {};
      if (jsonResponse['success'] == true) {
        await _subAdminDB.doc(jsonResponse['uid']).set(data);
      } else {
        throw jsonResponse['error'] ?? 'Something went wrong';
      }
    } catch (error) {
      AppSnackBar.error(error.toString());
    }
  }
}