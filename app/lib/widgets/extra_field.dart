import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/models/remote/form_field_model.dart';

import 'custom_input_field.dart';

class ExtraField extends StatefulWidget {
  final FormFieldModel field;
  final Rx<Map<String, dynamic>> valuesGallery;
  final Function(MapEntry<String, String> data)? onSubmitted;

  const ExtraField({super.key, required this.field, required this.valuesGallery, this.onSubmitted});

  @override
  State<ExtraField> createState() => _ExtraFieldState();
}

class _ExtraFieldState extends State<ExtraField> {
  bool get isTextField => widget.field.type == 'text' || widget.field.type == 'number';
  late final TextEditingController? _controller = isTextField ? TextEditingController() : null;
  TextEditingController get controller => _controller!;

  final value = RxnString();
  late final values = RxList<String>(widget.field.data ?? []);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processData(widget.valuesGallery.value);
      ever(widget.valuesGallery, (callback) {
        _processData(callback);
      });
    });

    _controller?.addListener(() => widget.onSubmitted?.call(MapEntry(widget.field.key, controller.text.trim())));
    super.initState();
  }

  void _processData(Map<String, dynamic> data) {
    String? existingValue = data[widget.field.key];
    if (widget.field.type == 'dropdown' && existingValue != null && values.contains(existingValue)) {
      value.value = existingValue;
      widget.onSubmitted?.call(MapEntry(widget.field.key, existingValue));
    } else if (isTextField) {
      controller.text = existingValue ?? '';
      widget.onSubmitted?.call(MapEntry(widget.field.key, existingValue ?? ''));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isTextField) {
      return CustomInputField(
        controller: controller,
        hint: widget.field.hint,
        textCapitalization: TextCapitalization.words,
        maxLength: 500,
        inputType: widget.field.type == 'number' ? TextInputType.number : TextInputType.text,
      );
    }

    return Obx(() => DropdownButtonFormField(
      value: value.value,
      items: values.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500)),
      )).toList(),
      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.black),
      onChanged: (item) {
        value.value = item!;
        widget.onSubmitted?.call(MapEntry(widget.field.key, item));
      },
      decoration: InputDecoration(
        hintText: widget.field.hint,
        hintStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
        labelStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    ));
  }
}
