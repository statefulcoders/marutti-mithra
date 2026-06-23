import 'dart:convert';

import '../resources/comlate_keys.dart';

class ComlateLanguageModel {
  final String name;
  final String localName;
  final String code;
  final String countryCode;

  ComlateLanguageModel({
    required this.name,
    required this.localName,
    required this.code,
    required this.countryCode,
  });

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      ComlateKeys.name: name,
      ComlateKeys.localName: localName,
      ComlateKeys.languageCode: code,
      ComlateKeys.countryCode: countryCode,
    };
  }

  factory ComlateLanguageModel.fromJson(Map<String, dynamic> json) {
    return ComlateLanguageModel(
      name: json[ComlateKeys.name] as String,
      localName: json[ComlateKeys.localName] as String,
      code: json[ComlateKeys.languageCode] as String,
      countryCode: json[ComlateKeys.countryCode] as String,
    );
  }
}