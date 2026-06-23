import 'package:get/get.dart';

class FormFieldModel {
  final String key;
  final String hint;
  final String type; // number or string or dropdown
  final List<String>? data;
  final bool? required;

  final value = ''.obs;

  FormFieldModel({
    required this.key,
    required this.hint,
    required this.type,
    this.data,
    this.required
});

  static FormFieldModel fromJson(Map<String, dynamic> data) {
    return FormFieldModel(
      key: data['key'] as String,
      hint: data['hint'] as String,
      type: data['type'] as String,
      data: data['data'] != null ? List<String>.from(data['data']) : null,
      required: data['required'] == true
    );
  }
}