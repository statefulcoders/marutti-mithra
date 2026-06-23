import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';

class NotificationsController extends GetxController {
  static const notificationsTableName = 'notifications';

  final notifications = Rxn<List<Map<String, dynamic>>>();
  final scrollController = ScrollController();

  int currentPage = 0;
  final int pageSize = 20;
  bool isFetching = false;
  bool hasMore = true;

  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    fetchNotification(isInitialLoad: true);
    FirebaseFirestore.instance.collection(UserTableHelper.userTableName).doc(MaruttiSessionMemory.uid).update({
      'unread': false
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (hasMore) {
          fetchNotification();
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchNotification({bool isInitialLoad = false}) async {
    if (isFetching) return;
    isFetching = true;

    try {
      final newNotifications = await fetchNotificationsFromDatabase(offset: currentPage * pageSize, limit: pageSize);
      if (isInitialLoad) {
        notifications.value = newNotifications;
      } else {
        final current = notifications.value ?? [];
        notifications.value = [...current, ...newNotifications];
      }

      if (newNotifications.length < pageSize) {
        hasMore = false;
      } else {
        currentPage++;
      }
    } finally {
      isFetching = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotificationsFromDatabase({
    required int offset,
    required int limit,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection(notificationsTableName)
        .where('receiver', isEqualTo: MaruttiSessionMemory.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
    }

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}