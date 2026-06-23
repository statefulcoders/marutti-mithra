import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/confirmation_dialog.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';
import 'package:marutti_mitra_admin/screens/main/admins/sub_admins_page.dart';
import 'package:marutti_mitra_admin/screens/main/catalogues/catalogues_page.dart';
import 'package:marutti_mitra_admin/screens/main/coupon_distribution/reward_users_page.dart';
import 'package:marutti_mitra_admin/screens/main/feedbacks/feedbacks_page.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_page.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_page.dart';
import 'package:marutti_mitra_admin/screens/main/dynamicfields/dynamic_fields_page.dart';
import 'package:marutti_mitra_admin/screens/main/notifications/notifications_page.dart';
import 'package:marutti_mitra_admin/screens/main/orders/orders_page.dart';
import 'package:marutti_mitra_admin/screens/main/products/products_page.dart';
import 'package:marutti_mitra_admin/screens/main/reward_types/reward_types_page.dart';
import 'package:marutti_mitra_admin/screens/main/rewards/rewards_page.dart';
import 'package:marutti_mitra_admin/screens/main/users/users_page.dart';
import 'package:marutti_mitra_admin/screens/main/videos/videos_page.dart';
import 'package:marutti_mitra_admin/screens/settings/settings_page.dart';

import '../../../helpers/firebase/firebase_user_helper.dart';
import '../../comlate/dialogs/data_updater_dialog.dart';
import '../../comlate/widgets/responsive_navigation_rail.dart';
import '../../helpers/firebase/firebase_sub_admin_helper.dart';

class MainController extends GetxController {
  final selectedRailIndex = 0.obs;

  final navigationItems = Rx<List<ResponsiveNavigationRailItem>>([ResponsiveNavigationRailItem(title: 'Dashboard', icon: Icons.dashboard)]);

  late final pages = Rx<List<Widget>>([DashboardPage()]);

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    final adminData = await FirebaseUserHelper.getAdminInformation();

    final isSuperAdmin = adminData == null;
    final exportData = isSuperAdmin || adminData[FirebaseSubAdminHelper.permExportData] == true;

    final deleteUser = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDeleteUser] == true;
    final addPoints = isSuperAdmin || adminData[FirebaseSubAdminHelper.permAddPoints] == true;
    final updateUser = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDeleteUser] == true;

    final accessDynamicFields = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDynamicField] == true;

    final addProduct = isSuperAdmin || adminData[FirebaseSubAdminHelper.permAddProduct] == true;
    final updateProduct = isSuperAdmin || adminData[FirebaseSubAdminHelper.permUpdateProduct] == true;
    final deleteProduct = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDeleteProduct] == true;

    final deleteCatalogue = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDeleteCatalogue] == true;
    final addCatalogue = isSuperAdmin || adminData[FirebaseSubAdminHelper.permCreateCatalogue] == true;
    final updateCatalogue = isSuperAdmin || adminData[FirebaseSubAdminHelper.permUpdateCatalogue] == true;


    final deleteVideos = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDeleteVideo] == true;
    final addVideos = isSuperAdmin || adminData[FirebaseSubAdminHelper.permCreateVideo] == true;
    final updateVideos = isSuperAdmin || adminData[FirebaseSubAdminHelper.permUpdateVideo] == true;

    final accessOrders = isSuperAdmin || adminData[FirebaseSubAdminHelper.permAccessOrders] == true;
    final accessFeedbacks = isSuperAdmin || adminData[FirebaseSubAdminHelper.permAccessFeedbacks] == true;

    final accessNotification = isSuperAdmin || adminData[FirebaseSubAdminHelper.permAccessNotification] == true;

    final manageRewards = isSuperAdmin || adminData[FirebaseSubAdminHelper.permManageRewards] == true;
    final distributeRewards = isSuperAdmin || adminData[FirebaseSubAdminHelper.permDistributeRewards] == true;

    navigationItems.value = [
      ...navigationItems.value,
      if (isSuperAdmin) ResponsiveNavigationRailItem(title: 'Sub Admins', icon: Icons.manage_accounts_rounded),
      ResponsiveNavigationRailItem(title: 'Users', icon: Icons.group),
      ResponsiveNavigationRailItem(title: 'Coupon Types', icon: Icons.gif_box_outlined),
      ResponsiveNavigationRailItem(title: 'Coupons', icon: Icons.airplane_ticket_outlined),
      if (distributeRewards) ResponsiveNavigationRailItem(title: 'Reward Users', icon: Icons.star),
      if (accessDynamicFields) ResponsiveNavigationRailItem(title: 'Dynamic Fields', icon: Icons.tune),
      ResponsiveNavigationRailItem(title: 'Products', icon: Icons.production_quantity_limits),
      ResponsiveNavigationRailItem(title: 'Catalogues', icon: Icons.book),
      ResponsiveNavigationRailItem(title: 'Videos', icon: Icons.video_library),
      if (accessOrders) ResponsiveNavigationRailItem(title: 'Orders', icon: Icons.chat_bubble_outline_rounded),
      if (accessFeedbacks) ResponsiveNavigationRailItem(title: 'Feedbacks', icon: Icons.feedback_outlined),
      if (accessNotification) ResponsiveNavigationRailItem(title: 'Notifications', icon: Icons.notifications_none_rounded),
      ResponsiveNavigationRailItem(title: 'Settings', icon: Icons.settings),
    ];

    pages.value = [
      ...pages.value,
      if (isSuperAdmin) SubAdminsPage(label: 'Sub Admins'),
      UsersPage(label: 'Users', deleteUser: deleteUser, updateUser: updateUser, addPoints: addPoints, exportData: exportData),
      RewardTypesPage(label: 'Coupon Types', deleteCouponType: manageRewards, createCouponType: manageRewards, exportData: exportData),
      RewardsPage(label: 'Coupons', deleteCoupons: manageRewards, createCoupons: manageRewards, exportData: exportData),
      if (distributeRewards) RewardUsersPage(label: 'Reward Users', exportData: exportData),
      if (accessDynamicFields) DynamicFieldsPage(label: 'Dynamic Fields'),
      ProductsPage(label: 'Products', addProduct: addProduct, updateProduct: updateProduct, deleteProduct: deleteProduct, exportData: exportData),
      CataloguesPage(label: 'Catalogues', addCatalogue: addCatalogue, deleteCatalogue: deleteCatalogue, updateCatalogue: updateCatalogue, exportData: exportData),
      VideosPage(label: 'Videos', deleteVideos: deleteVideos, addVideos: addVideos, updateVideos: updateVideos, exportData: exportData),
      if (accessOrders) OrdersPage(),
      if (accessFeedbacks) FeedbacksPage(),
      if (accessNotification) NotificationsPage(label: 'Notifications'),
      SettingsPage()
    ];

  }

  void toggleRailIndex(int index) {
    selectedRailIndex.value = index;
    scrollController.jumpTo(0);
  }

  Future<void> goToSettings() async {
    final adminData = await FirebaseUserHelper.getAdminInformation();
    if (adminData == null || adminData[FirebaseSubAdminHelper.permAccessSupportSettings] == true) {
      selectedRailIndex.value = pages.value.length - 1;
    } else {
      await DataUpdaterDialog.show(
        data: adminData,
        fieldInfo: [
          DataUpdateFieldInfo(key: 'name', hint: 'Sub-Admin Name', expectedType: 'text', min: 1, max: 255, required: true),
          DataUpdateFieldInfo(key: 'email', hint: 'Login username (Email)', expectedType: 'text', min: 1, max: 255, required: true),
          DataUpdateFieldInfo(key: 'createdAt', hint: 'Created At', expectedType: 'date', required: true),
          ...FirebaseSubAdminHelper.allPerms.where((element) => adminData[element] == true).map((e) => DataUpdateFieldInfo(key: e, hint: e.split('_').map((e) => e.capitalizeFirst ?? e).join(' '), expectedType: 'toggle', required: true))
        ],
        editable: false,
        customLabel: "Your Details",
      );
    }
  }

  Future<void> logout() async {
    try {
      final confirm = await ConfirmationDialog.confirm(
          'Are you sure you want to logout?',
          title: 'Logout',
          color: Colors.red,
          icon: Icons.logout
      );

      if (!confirm) return;

      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Already logged out');
      }
      await FirebaseUserHelper.logout();
      await Get.offAllNamed(AdminRoutes.main);
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Logout Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }
}