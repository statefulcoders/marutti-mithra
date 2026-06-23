import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final Timestamp createdAt;
  final Timestamp distributedAt;
  final Timestamp expiresAt;
  final String couponType;
  final String status;
  final String rewardName;
  final String uid;
  final String id; // Document ID
  final String? image;
  final String? description;

  RewardModel({
    required this.createdAt,
    required this.distributedAt,
    required this.expiresAt,
    required this.couponType,
    required this.status,
    required this.rewardName,
    required this.uid,
    required this.id,
    this.image,
    this.description,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      createdAt: data['createdAt'] as Timestamp,
      distributedAt: data['distributedAt'] as Timestamp,
      expiresAt: data['expiresAt'] as Timestamp,
      couponType: data['couponType'] as String? ?? '',
      status: data['status'] as String? ?? 'assigned',
      rewardName: data['rewardName'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      id: doc.id,
      image: data['image'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'distributedAt': distributedAt,
      'expiresAt': expiresAt,
      'couponType': couponType,
      'status': status,
      'rewardName': rewardName,
      'uid': uid,
      'image': image,
      'description': description,
    };
  }
}
