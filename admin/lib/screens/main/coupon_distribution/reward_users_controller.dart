import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/confirmation_dialog.dart';
import 'package:marutti_mitra_admin/comlate/overlays/app_snackbar.dart';
import 'package:marutti_mitra_admin/comlate/widgets/firebase_table/comlate_firebase_table_column.dart';
import 'package:marutti_mitra_admin/comlate/widgets/firebase_table/comlate_firebase_table_controller.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_rewards_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';

class RewardUsersController extends GetxController {
  final String label;

  RewardUsersController({required this.label});

  // Displaying Reward Inventory in the Table
  final columns = [
    ComlateFirebaseTableColumn(label: 'Phone', keys: ['phone']),
    ComlateFirebaseTableColumn(label: 'Shop', keys: ['shopName']),
    ComlateFirebaseTableColumn(label: 'City', keys: ['district']),
    ComlateFirebaseTableColumn(label: 'Reward Name', keys: ['rewardName']),
    ComlateFirebaseTableColumn(label: 'Coupon Type', keys: ['couponType']),
    ComlateFirebaseTableColumn(label: 'Status', keys: ['status']),
    ComlateFirebaseTableColumn(label: 'Distributed At', keys: ['distributedAt']),
  ];

  // --- Distribution Panel Variables ---
  final userSearchController = TextEditingController();
  final rewardSearchController = TextEditingController();
  final quantityController = TextEditingController();

  final selectedUser = <String, dynamic>{}.obs;
  final selectedReward = Rxn<Map<String, dynamic>>();

  final availableRewards = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    _fetchRewardsList();
    super.onInit();
  }

  Future<void> _fetchRewardsList() async {
    try {
      final snapshot = await FirebaseRewardsHelper.ref.get();
      availableRewards.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint("Error fetching rewards: $e");
    }
  }

  Future<void> redeemAll() async {
    try {
      // 1. Critical Confirmation Dialog
      final confirm = await ConfirmationDialog.confirm(
          "WARNING: This will mark EVERY 'scratched' reward in the entire database as 'redeemed'.\n\n(Rewards that are merely 'assigned' will not be affected.)\n\nAre you sure?",
        positiveLabel: "Yes",
          color: Colors.red,
      );

      if (!confirm) return;

      // 2. Show Loader
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // 3. Authentication
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("Not Authenticated");

      // 4. API Call
      final url = Uri.parse('https://us-central1-marutti-mitra-groups.cloudfunctions.net/redeemAllRewardsHttp');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        // No body needed as we process all system docs
      );

      Get.back(); // Close Loader

      // 5. Handle Response
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);

        if (resData['success'] == true) {
          int count = resData['count'] ?? 0;
          if (count > 0) {
            AppSnackBar.success("Success! $count scratched rewards marked as redeemed.");
            Get.find<ComlateFirebaseTableController>(tag: label).getInitialPage();
          } else {
            AppSnackBar.error("No scratched rewards found in the system.");
          }
        } else {
          AppSnackBar.error(resData['error'] ?? "Unknown Error");
        }
      } else {
        final resData = jsonDecode(response.body);
        AppSnackBar.error(resData['error'] ?? "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.error("Error: $e");
    }
  }

  // --- Search Logic ---
  Future<List<Map<String, dynamic>>> findUser(String search) async {
    return await FirebaseUsersHelper.search(search.trim().toLowerCase(), 4);
  }

  void selectUser(Map<String, dynamic> user) {
    userSearchController.text = user['shopName']?.toString() ?? '${user['firstName']} ${user['lastName']}';
    selectedUser.value = user;
  }

  Future<List<Map<String, dynamic>>> findReward(String search) async {
    await _fetchRewardsList();
    if (search.isEmpty) return availableRewards;
    return availableRewards.where((r) =>
        (r['name'] ?? '').toString().toLowerCase().contains(search.toLowerCase())
    ).toList();
  }

  void selectReward(Map<String, dynamic> reward) {
    rewardSearchController.text = reward['name'] ?? '';
    selectedReward.value = reward;
  }

  Map<String, int> getRewardStats(Map<String, dynamic> rewardData) {
    int total = 0;
    try {
      if (rewardData['types'] != null && rewardData['types'] is Map) {
        final types = rewardData['types'] as Map<String, dynamic>;
        total = types.values.map((e) => int.tryParse(e?.toString() ?? '0') ?? 0).fold(0, (prev, element) => prev + element);
      }
    } catch (e) { total = 0; }
    int distributed = int.tryParse(rewardData['distributed']?.toString() ?? '0') ?? 0;
    return {'total': total, 'distributed': distributed};
  }

  // --- Distribute Action ---
  Future<void> distributeReward() async {
    try {
      if (selectedUser.isEmpty || selectedReward.value == null || quantityController.text.trim().isEmpty) {
        AppSnackBar.error("Please fill all fields");
        return;
      }

      int qty = int.tryParse(quantityController.text.trim()) ?? 1;
      if (qty < 1) {
        AppSnackBar.error("Quantity must be at least 1");
        return;
      }

      final confirm = await ConfirmationDialog.confirm(
          "Give ${qty}x '${selectedReward.value?['name']}' to ${userSearchController.text}?",
          color: AppConfig.primaryColor
      );

      if (!confirm) return;

      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("Not Authenticated");

      // Replace with your Project URL
      final url = Uri.parse('https://us-central1-marutti-mitra-groups.cloudfunctions.net/distributeRewardsHttp');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "uid": selectedUser['uid'] ?? selectedUser['id'],
          "rewardId": selectedReward.value!['id'],
          "quantity": qty,
        }),
      );

      Get.back(); // Close Loader

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          AppSnackBar.success("Rewards distributed successfully!");

          // Clear Inputs
          selectedUser.clear();
          selectedReward.value = null;
          userSearchController.clear();
          rewardSearchController.clear();
          quantityController.clear();

          // Refresh Data
          await _fetchRewardsList();
          Get.find<ComlateFirebaseTableController>(tag: label).getInitialPage();
        } else {
          AppSnackBar.error(resData['error'] ?? "Unknown Error");
        }
      } else {
        final resData = jsonDecode(response.body);
        AppSnackBar.error(resData['error'] ?? "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if(Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.error("Error: $e");
    }
  }

  @override
  void onClose() {
    userSearchController.dispose();
    rewardSearchController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}