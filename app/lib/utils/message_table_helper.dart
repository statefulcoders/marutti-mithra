import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/models/remote/form_field_model.dart';
import 'package:maruttimitra/models/remote/message_model.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';

class MessageTableHelper {
  static const String messagesTableName = 'messages';
  static const String categoryOrder = 'order';
  static const String categoryFeedback = 'feedback';
  static const String senderYou = 'you';
  static const String senderAdmin = 'admin';
  static const int messagesLimit = 14;

  static final _db = FirebaseFirestore.instance;
  static CollectionReference get _ordersDB => _db.collection(messagesTableName).doc(MaruttiSessionMemory.uid).collection('orders');
  static CollectionReference get _feedbacksDB => _db.collection(messagesTableName).doc(MaruttiSessionMemory.uid).collection('feedbacks');

  static Stream<QuerySnapshot> getMessagesStream({ required String category }) {
    Query query = category == categoryFeedback ? _feedbacksDB : _ordersDB;
    query = query.orderBy(Constants.keyCreated, descending: true);
    return query.limit(messagesLimit).snapshots();
  }

  static Future<void> addMessage({ required String category, String? content, File? audioFile }) async {
    String? audio;
    CollectionReference reference = category == categoryFeedback ? _feedbacksDB : _ordersDB;
    final ref = reference.doc();
    if (audioFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('audio_messages/${ref.id}.${audioFile.path.split('.').last}');
      await storageRef.putFile(audioFile);
      audio = await storageRef.getDownloadURL();
    }
    final message = MessageModel(id: '', sender: senderYou, content: content, audioFile: audio, createdAt: DateTime.now(), orderFrom: MaruttiSettingsMemory.firm);
    await ref.set(message.toJson());
  }

  static Future<QuerySnapshot> getMessages({ required String category, DocumentSnapshot? startAfter }) async {
    Query query = category == categoryFeedback ? _feedbacksDB : _ordersDB;
    query = query.orderBy(Constants.keyCreated, descending: true);

    if (startAfter != null) {
      query = query.startAtDocument(startAfter);
    }

    return query.limit(messagesLimit).get();
  }

  static Future<void> deleteAllChats() async {
    await Future.wait([
      _deleteRef(_ordersDB),
      _deleteRef(_feedbacksDB),
    ]);
  }

  static Future<void> _deleteRef(CollectionReference ref) async {
    const batchLimit = 500;
    bool hasMore = true;
    QueryDocumentSnapshot? lastDoc;

    while (hasMore) {
      var query = ref.limit(batchLimit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) break;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      lastDoc = snapshot.docs.last;
      hasMore = snapshot.docs.length == batchLimit;
    }
  }

  static Future<int> getTodaySentImagesCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final response1 = await _feedbacksDB
      // .where('audioFile', isNull: false)
          .where('content', isEqualTo: '<image>')
          .where('createdAt', isGreaterThan: startOfDay)
          .count()
          .get();
      final response0 = await _ordersDB
          // .where('audioFile', isNull: false)
          .where('content', isEqualTo: '<image>')
          .where('createdAt', isGreaterThan: startOfDay)
          .count()
          .get();


      return (response0.count ?? 0) + (response1.count ?? 0);
    } catch (error) {
      print(error);
      return 0;
    }
  }
}