import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/local/constants.dart';

class MessageModel {
  final String id; // excluded in toJson
  final String? content;
  final String? audioFile;
  final String sender;
  final DateTime createdAt;
  final String? orderFrom; // Shop name

  MessageModel({
    required this.id,
    this.content,
    this.audioFile,
    required this.sender,
    required this.createdAt,
    this.orderFrom,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'],
      audioFile: json['audioFile'],
      sender: json[Constants.keySender],
      createdAt: (json[Constants.keyCreated] as Timestamp).toDate(),
      orderFrom: json['orderFrom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'audioFile': audioFile,
      Constants.keySender: sender,
      Constants.keyCreated: Timestamp.fromDate(createdAt),
      'orderFrom': orderFrom,
    };
  }
}