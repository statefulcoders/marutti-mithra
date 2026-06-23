import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final DateTime? dateOfBirth;

  final String? streetAddress;
  final String? pinCode;

  final String? state;
  final String? district;

  final int maPoints;
  final int mwPoints;
  final int hpPoints;
  final int vcPoints;

  final String? firebaseToken;

  final DateTime? createdAt;

  final Map<String, dynamic> extraFields;

  final bool? unread;

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.dateOfBirth,
    this.streetAddress,
    this.pinCode,
    this.state,
    this.district,
    this.firebaseToken,
    this.maPoints = 0,
    this.mwPoints = 0,
    this.hpPoints = 0,
    this.vcPoints = 0,
    this.createdAt,
    this.extraFields = const {},
    this.unread = false,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth'] == null ? null : json['dateOfBirth'] is DateTime ? DateTime.parse(json['dateOfBirth']) : json['dateOfBirth'] is Timestamp ? json['dateOfBirth'].toDate() : null,
      streetAddress: json['address']?.toString() ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      maPoints: int.tryParse(json['maPoints']?.toString() ?? '0') ?? 0,
      mwPoints: int.tryParse(json['mwPoints']?.toString() ?? '0') ?? 0,
      hpPoints: int.tryParse(json['hpPoints']?.toString() ?? '0') ?? 0,
      vcPoints: int.tryParse(json['vcPoints']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] is String ? DateTime.parse(json['createdAt']) : json['createdAt'] is DateTime ? json['createdAt'] : json['createdAt'] is Timestamp ? json['createdAt'].toDate() : null,
      extraFields: json,
      firebaseToken: json['firebaseToken']?.toString(),
      unread: json['unread'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName.isEmpty ? null : firstName,
      'lastName': lastName.isEmpty ? null : lastName,
      'phone': phone.isEmpty ? null : phone,
      'email': email,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'address': streetAddress,
      'pinCode': pinCode,
      'state': state,
      'district': district,
      'maPoints': maPoints,
      'mwPoints': mwPoints,
      'hpPoints': hpPoints,
      'vcPoints': vcPoints,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'firebaseToken': firebaseToken,
      'unread': unread,
      ...extraFields,
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? streetAddress,
    String? pinCode,
    String? state,
    String? district,
    int? maPoints,
    int? mwPoints,
    int? hpPoints,
    int? vcPoints,
    String? firebaseToken,
    DateTime? createdAt,
    Map<String, dynamic>? extraFields,
    bool? unread,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      streetAddress: streetAddress ?? this.streetAddress,
      pinCode: pinCode ?? this.pinCode,
      state: state ?? this.state,
      district: district ?? this.district,
      maPoints: maPoints ?? this.maPoints,
      mwPoints: mwPoints ?? this.mwPoints,
      hpPoints: hpPoints ?? this.hpPoints,
      vcPoints: vcPoints ?? this.vcPoints,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      createdAt: createdAt ?? this.createdAt,
      extraFields: extraFields ?? this.extraFields,
      unread: unread ?? this.unread,
    );
  }
}