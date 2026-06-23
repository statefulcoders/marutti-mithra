import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/confirmation_dialog.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/comlate/overlays/app_snackbar.dart';
import 'package:marutti_mitra_admin/comlate/widgets/firebase_table/comlate_firebase_table_controller.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_dynamic_fields_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/push_notifications_helper.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';
import 'package:http/http.dart' as http;

class UsersController extends GetxController {
  static final pointKeys = ['mwPoints', 'vcPoints', 'maPoints', 'hpPoints'];

  final columns = [
    ComlateFirebaseTableColumn(label: 'Shop', keys: ['shopName']),
    // ComlateFirebaseTableColumn(label: 'Name', keys: ['firstName', 'lastName']),
    ComlateFirebaseTableColumn(label: 'City', keys: ['district']),
    ComlateFirebaseTableColumn(label: 'Phone', keys: ['phone']),
    ComlateFirebaseTableColumn(label: 'Type', keys: ['buyerCategory']),
    ComlateFirebaseTableColumn(
        label: 'Points',
        keys: pointKeys,
        transformer: (p0) {
          return pointKeys
              .map((key) => int.tryParse(p0[key]?.toString() ?? '0') ?? 0)
              .fold(0, (previousValue, element) => previousValue + element)
              .toString();
        }
    ),
  ];

  final products = Rx<List<Map<String, dynamic>>>([]);
  final points = Rx<Map<String, List<String>>>({});

  final userSearchController = TextEditingController();
  final quantityController = TextEditingController();
  final productSearchController = TextEditingController();

  final selectedUser = <String, dynamic>{}.obs;
  final selectedShop = RxnString();
  final selectedProduct = RxnString();

  final extraFields = Rxn<List<Map<String, dynamic>>>();
  final fieldOrder = Rx<List<String>>([]);

  final String label;
  UsersController({required this.label});

  @override
  void onInit() {
    getPoints();
    _initialize();
    super.onInit();
  }

  Future<void> _initialize() async {
    try {
      final response = await FirebaseDynamicFieldsHelper.ref.get();
      extraFields.value = response.docs.map((e) => e.data() as Map<String, dynamic>).toList();

      final orderDoc = await FirebaseFirestore.instance.collection('field_orders').doc('users').get();
      if (orderDoc.exists) {
        fieldOrder.value = List<String>.from(orderDoc.data()?['order'] ?? []);
      }
    } catch (error) {
      extraFields.value = [];
      debugPrint("Initialization error: $error");
    }
  }

  // --- Field Management & Reordering ---

  Future<void> saveOrder(List<DataUpdateFieldInfo> fields) async {
    try {
      final List<String> newOrder = fields.map((f) => f.key).toList();
      await FirebaseFirestore.instance.collection('field_orders').doc('users').set({
        'order': newOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      fieldOrder.value = newOrder;
      AppSnackBar.success("Order saved");
    } catch (e) {
      AppSnackBar.error('Failed to save order: $e');
    }
  }

  List<DataUpdateFieldInfo> getSortedFields() {
    final List<DataUpdateFieldInfo> allFields = [
      const DataUpdateFieldInfo(key: 'firstName', hint: 'Enter First Name', expectedType: 'text', max: 50, min: 1),
      const DataUpdateFieldInfo(key: 'lastName', hint: 'Enter Last Name', expectedType: 'text', max: 50, min: 1),
      const DataUpdateFieldInfo(key: 'phone', hint: 'Enter Phone Number', expectedType: 'text', max: 15, min: 10, required: true),
      const DataUpdateFieldInfo(key: 'email', hint: 'Enter Email', expectedType: 'text', max: 500, min: 1),
      const DataUpdateFieldInfo(key: 'dateOfBirth', hint: 'Birthday', expectedType: 'date'),
      const DataUpdateFieldInfo(key: 'state', hint: 'Enter State', expectedType: 'text', max: 100, min: 1),
      const DataUpdateFieldInfo(key: 'district', hint: 'Enter City', expectedType: 'text', max: 100, min: 1),
      const DataUpdateFieldInfo(key: 'address', hint: 'Enter Street Address', expectedType: 'text', max: 300, min: 1),
      const DataUpdateFieldInfo(key: 'pinCode', hint: 'Enter Pincode', expectedType: 'integer', max: 6, min: 6),
      const DataUpdateFieldInfo(key: 'maPoints', hint: 'MA Points', expectedType: 'integer', max: 10, min: 0),
      const DataUpdateFieldInfo(key: 'mwPoints', hint: 'MW Points', expectedType: 'integer', max: 10, min: 0),
      const DataUpdateFieldInfo(key: 'hpPoints', hint: 'HP Points', expectedType: 'integer', max: 10, min: 0),
      const DataUpdateFieldInfo(key: 'vcPoints', hint: 'VC Points', expectedType: 'integer', max: 10, min: 0),
      ...(extraFields.value ?? []).map((data) {
        return DataUpdateFieldInfo(
            key: data['key'] ?? 'key',
            hint: data['hint'] ?? 'Enter',
            expectedType: data['type'] == 'number' ? 'integer' : data['type'],
            options: List<String>.from(data['data'] ?? []),
            max: 500,
            min: 1,
          required: false
        );
      })
    ];

    if (fieldOrder.value.isEmpty) return allFields;

    allFields.sort((a, b) {
      int indexA = fieldOrder.value.indexOf(a.key);
      int indexB = fieldOrder.value.indexOf(b.key);
      if (indexA == -1 && indexB == -1) return 0;
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    return allFields;
  }

  Future<void> createUser() async {
    final Map<String, dynamic> initialData = {
      'maPoints': 0, 'vcPoints': 0, 'hpPoints': 0, 'mwPoints': 0,
      'buyerCategory': 'Retailer', // Default value
    };

    final result = await DataUpdaterDialog.show(
      data: initialData,
      editable: true,
      customLabel: "Create New User",
      fieldInfo: getSortedFields(),
      onSaveOrder: saveOrder,
    );

    if (result != null) {
      await callCreateUser(result);
    }
  }

  Future<void> callCreateUser(Map<String, dynamic> userData) async {
    try {
      Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false
      );

      // 1. Get the current logged-in admin's ID Token
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (token == null) {
        throw Exception("User not authenticated");
      }

      // 2. Define the HTTP endpoint
      final url = Uri.parse('https://us-central1-marutti-mitra-groups.cloudfunctions.net/createNewUserHttp');

      // 3. Make the POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Passing the custom token
        },
        // 4. Encode Body: Handle DateTime conversion to String
        body: jsonEncode(userData, toEncodable: (nonEncodable) {
          if (nonEncodable is DateTime) {
            return nonEncodable.toIso8601String();
          }
          return nonEncodable;
        }),
      );

      Get.back(); // Close Loading Dialog

      // 5. Handle Response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          AppSnackBar.success("User created successfully!");
          // Refresh table
          Get.find<ComlateFirebaseTableController>(tag: label).getInitialPage();
        } else {
          // Success is false in body
          AppSnackBar.error(responseData['error'] ?? "Unknown error");
        }
      } else {
        // HTTP Error (400, 401, 403, 500, etc.)
        final responseData = jsonDecode(response.body);
        AppSnackBar.error(responseData['error'] ?? "Server Error: ${response.statusCode}");
      }

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Ensure dialog closes
      AppSnackBar.error("Error: $e");
    }
  }

  // --- Existing Logic ---

  void selectUser(Map<String, dynamic> user) {
    userSearchController.text = user['shopName']?.toString() ?? '${user['firstName']} ${user['lastName']}';
    selectedUser.value = user;
  }

  void selectShop(String? shop) {
    selectedProduct.value = null;
    productSearchController.text = '';
    selectedShop.value = shop;
  }

  void selectProduct(String? product) {
    productSearchController.text = product ?? '';
    selectedProduct.value = product;
  }

  Future<List<Map<String, dynamic>>> findUser(String search) async {
    try {
      return await FirebaseUsersHelper.search(search.trim().toLowerCase(), 4).timeout(const Duration(seconds: 10));
    } catch (err) {
      debugPrint('Search error: $err');
      return [];
    }
  }

  Future<List<String>> findProduct(String search) async {
    return points.value[selectedShop.value]?.where((element) => element.toLowerCase().contains(search.trim().toLowerCase())).toList() ?? [];
  }

  Future<void> getPoints() async {
    try {
      products.value = await FirebaseProductsHelper.getProducts();
      points.value = {};
      for (final point in products.value) {
        String shopName = point['shop'] ?? '';
        points.value.putIfAbsent(shopName, () => []).add(point['name'] ?? 'Unknown');
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> providePoints() async {
    try {
      if (selectedUser.isEmpty || selectedShop.value == null || selectedProduct.value == null || quantityController.text.trim().isEmpty) {
        AppSnackBar.error("Please fill all fields");
        return;
      }

      String pVal = products.value.where((p) => p['name'] == selectedProduct.value && p['shop'] == selectedShop.value).firstOrNull?['points']?.toString() ?? '0';
      double qty = double.tryParse(quantityController.text.trim()) ?? 1.0;

      await FirebaseUsersHelper.addPoints(
          selectedUser['uid'] ?? '',
          selectedUser['firebaseToken'],
          selectedProduct.value ?? '',
          selectedShop.value ?? '',
          qty.toString(),
          ((int.tryParse(pVal) ?? 0) * qty).toInt()
      );

      // Reset fields
      selectedShop.value = null;
      selectedProduct.value = null;
      userSearchController.clear();
      productSearchController.clear();
      quantityController.clear();

      await Get.find<ComlateFirebaseTableController>(tag: label).getInitialPage();
      AppSnackBar.success("Points Added");
    } catch (error) {
      ConfirmationDialog.confirm(error.toString());
    }
  }

  Future<void> onPointsChanged(Map<String, dynamic> newData, Map<String, dynamic> oldData) async {
    try {
      bool pointsChanged = pointKeys.any((key) =>
      (double.tryParse(oldData[key]?.toString() ?? '') ?? 0.0) != (double.tryParse(newData[key]?.toString() ?? '') ?? 0.0)
      );

      final firebaseToken = newData['firebaseToken']?.toString() ?? '';

      if (pointsChanged && firebaseToken.isNotEmpty) {
        String title = 'Points Updated';
        String body = 'Your points have updated! Click to see updated points.';

        await FirebaseFirestore.instance.collection(FirebaseUsersHelper.notificationTableName).add({
          'receiver': newData['id'],
          'sender': FirebaseAuth.instance.currentUser?.uid ?? 'admin',
          'title': title,
          'body': body,
          'createdAt': Timestamp.now()
        });
        await PushNotificationsHelper.sendNotification(title: title, body: body, token: firebaseToken);
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    productSearchController.dispose();
    userSearchController.dispose();
    super.onClose();
  }
}