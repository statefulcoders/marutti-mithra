import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';
import 'package:marutti_mitra_admin/screens/main/conversations/conversation_screen.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_controller.dart';

class MessagesController extends GetxController {
  final String conversationType;
  final shopFilter = RxnString();

  final conversations = Rxn<List<Map<String, dynamic>>>();
  final openConversation = Rxn<Map<String, dynamic>>();

  StreamSubscription? conversationSubscription;
  final db = FirebaseFirestore.instance;
  final ordersLimit = 0.obs;

  MessagesController({ required this.conversationType });

  List<String> onlyOrderLevels = ['Marutti Aluminiums', 'MWholesales', 'Vinlam Concepts', 'Hardware Palace'];
  List<String> levels = ['feedbacks', 'orders', 'Marutti Aluminiums', 'MWholesales', 'Vinlam Concepts', 'Hardware Palace'];
  int get level => levels.indexOf(shopFilter.value ?? conversationType.toLowerCase());

  Query _createReference() {
    Query query = db.collection('messages');

    int lvl = level;
    query = query.where('level', isGreaterThanOrEqualTo: lvl);

    print('Building query for lvl: $lvl');

    return query.orderBy('updatedAt', descending: true).limit(ordersLimit.value);
  }

  Future<void> openAt(BuildContext context, int index) async {
    final data = conversations.value![index];
    await Future.wait([
      db.collection('messages').doc(data['uid']).update({ levels[level]: { 'lastContent': data['lastContent'], 'unreads': 0 } }),
      if (level > 0) db.collection('messages').doc(data['uid']).update({ levels[1]: { 'lastContent': data['lastContent'], 'unreads': 0 } })
    ]);
    try {
      Get.find<DashboardController>().initialize();
    } catch (_) {}
    openConversation.value = {
      ...data,
      'shop_filter': shopFilter.value
    };

    final isDesktop = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.desktop;
    if (!isDesktop) {
      Get.to(ConversationScreen(label: conversationType, isDesktop: false, userData: openConversation.value!));
    }
  }

  Future<void> getConversations() async {
    conversationSubscription?.cancel();
    ordersLimit.value += 15;
    conversationSubscription = _createReference().snapshots().listen(_processAndAnnotate);
  }

  Future<void> _processAndAnnotate(QuerySnapshot<dynamic> event) async {
    try {
      final newList = await Future.wait(event.docs.map(_annotate));
      conversations.value = newList;
    } catch (error) {
      conversations.value = [];
    }
  }

  Future<Map<String, dynamic>> _annotate(QueryDocumentSnapshot<dynamic> item) async {
    final id = item.id;
    final conv = item.data();
    Map<String, dynamic>? userData;

    try {
      final oldData = conversations.value?.where((element) => element['id'] == id).firstOrNull;
      if (oldData == null) {
        final response = await db.collection('users').doc(item.reference.id).get();
        userData = {
          'uid': item.reference.id,
          'username': '${response.data()?['firstName']} ${response.data()?['lastName']}',
          'firebaseToken': response.data()?['firebaseToken'] ?? ''
        };
      } else {
        userData = {
          'uid': oldData['uid'],
          'username': oldData['username'],
          'firebaseToken': oldData['firebaseToken']
        };
      }
    } catch (_) {}

    return { ...conv, ...?userData, 'id': id, ...?conv[levels[level]] };
  }

  @override
  void dispose() {
    conversationSubscription?.cancel();
    super.dispose();
  }

  void filterLeads(String status) {
    if (shopFilter.value == status) {
      shopFilter.value = null;
    } else {
      shopFilter.value = status;
    }
    openConversation.value = null;
    getConversations();
  }
}