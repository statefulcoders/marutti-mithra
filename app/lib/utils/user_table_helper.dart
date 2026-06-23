import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:maruttimitra/dialogs/confirmation_dialog.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/message_table_helper.dart';
import 'package:maruttimitra/utils/notifications/firebase_notification_service.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

class UserTableHelper {
  static const String userTableName = 'users';

  static final _db = FirebaseFirestore.instance;
  static final _usersDB = _db.collection(userTableName);

  static final Rxn<UserModel> user = Rxn();
  static StreamSubscription? userStream;

  static void initialize() {
    userStream = _usersDB.doc(MaruttiSessionMemory.uid).snapshots().listen((event) async {
      if (event.data() != null) {
        try {
          user.value = UserModel.fromJson(event.data() as Map<String, dynamic>);

          final firebaseToken = await Get.find<FirebaseNotificationService>().generateToken();
          if (firebaseToken != null && user.value?.firebaseToken != firebaseToken) {
            await _usersDB.doc(MaruttiSessionMemory.uid).update({
              'firebaseToken': firebaseToken
            });
          }
        } catch (error) {
          print("Getting user -> ${error}");
          user.value = null;
        }
      } else {
        user.value = null;
      }
    });
  }

  static Future<void> setUser(UserModel user) async {
    final extraData = user.extraFields;
    final data = {
      ...Map<String, dynamic>.fromEntries(user.toJson().entries.where((element) => element.value != null)),
      ...extraData
    };
    if (MaruttiSessionMemory.basicInfoSubmitted) {
      await _usersDB.doc(MaruttiSessionMemory.uid).update(data);
      if (!MaruttiSessionMemory.addressInfoSubmitted) {
        await MaruttiSessionMemory.setAddressInfoSubmitted();
      }
    } else {
      await _usersDB.doc(MaruttiSessionMemory.uid).set(data);
      await MaruttiSessionMemory.setBasicInfoSubmitted();
    }
  }

  static Future<void> deleteUser() async {
    try {
      await Future.wait([
        MessageTableHelper.deleteAllChats(),
        _usersDB.doc(MaruttiSessionMemory.uid).delete()
      ]);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }

      await MaruttiSessionMemory.logout();
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> checkShopNameExists(String shopName, String city) async {
    try {
      final normalizedShopName = shopName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      final normalizedCity = city.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

      DocumentSnapshot? lastDoc;
      bool hasMore = true;
      const int batchSize = 100;

      while (hasMore) {
        // Fetch in batches to avoid OOM and improve performance with short-circuiting
        Query query = _usersDB.orderBy(FieldPath.documentId).limit(batchSize);
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        // Update cursor for next batch
        lastDoc = snapshot.docs.last;
        // If we got fewer docs than batchSize, we reached the end
        if (snapshot.docs.length < batchSize) {
          hasMore = false;
        }

        for (final doc in snapshot.docs) {
          // Skip current user if already exists
          if (doc.id == MaruttiSessionMemory.uid) continue;

          final data = doc.data() as Map<String, dynamic>;

            final existingCity = data['city']?.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
            final existingShopName = data['shopName']?.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

            if (existingCity == normalizedCity && existingShopName == normalizedShopName) {
              return true; // Found duplicate, return immediately
            }
        }
      }

      return false;
    } catch (e) {
      print("Error checking shop name: $e");
      return true;
    }
  }

  static void dispose() {
    userStream?.cancel();
  }
}