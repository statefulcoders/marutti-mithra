import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_catalogues_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_dynamic_fields_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_videos_helper.dart';
import 'package:marutti_mitra_admin/screens/main/main_controller.dart';

import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../helpers/firebase/firebase_messages_helper.dart';
import 'dashboard_page.dart';

class DashboardController extends GetxController {

  final cards = const [
    DashboardCard(label: 'Users', icon: Icons.supervised_user_circle_sharp, color: Colors.pink, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green),
    DashboardCard(label: 'Dynamic Fields', icon: Icons.text_fields, color: Colors.yellow, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green),
    DashboardCard(label: 'Products', icon: Icons.tune, color: Colors.teal, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green),
    DashboardCard(label: 'Catalogues', icon: Icons.card_travel_sharp, color: Colors.blue, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green),
    DashboardCard(label: 'Videos', icon: Icons.video_library_outlined, color: Colors.green, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green),
    DashboardCard(label: 'Messages', icon: Icons.chat_bubble_outline_rounded, color: Colors.deepPurple, subMetrics: ['Loading...'], conclusion: 'Loading...', conclusionColor: Colors.green)
  ].obs;

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    try {
      final List<DashboardCard> cardData = await Future.wait([
        FirebaseUsersHelper.getStats(),
        FirebaseDynamicFieldsHelper.getStats(),
        FirebaseProductsHelper.getStats(),
        FirebaseCataloguesHelper.getStats(),
        FirebaseVideosHelper.getStats(),
        FirebaseMessagesHelper.getStats(),
      ]);

      cards.assignAll(cardData);
      cards.refresh();
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Login Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }

  void clickTab(DashboardCard card) {
    try {
      final controller = Get.find<MainController>();
      controller.toggleRailIndex(max(0, controller.navigationItems.value.indexWhere((element) => element.title == card.label)));
    } catch (_) {}
  }
}