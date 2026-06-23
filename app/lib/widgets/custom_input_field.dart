
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInputField extends StatelessWidget {
  final IconData? icon;
  final Widget? prefix;
  final String hint;
  final TextEditingController? controller;
  final TextInputType inputType;
  final int? maxLength;
  final bool isEnabled;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const CustomInputField({
    super.key,
    this.icon,
    this.prefix,
    required this.hint,
    this.controller,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.textInputAction,
    this.isEnabled = true,
    this.textCapitalization = TextCapitalization.none
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      controller: controller,
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      keyboardAppearance: Brightness.light,
      textInputAction: textInputAction,
      enabled: isEnabled,
      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: prefix ?? (icon == null ? null : Icon(icon, color: Colors.black54, size: 22.sp)),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.grey),
        labelStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );
  }
}
