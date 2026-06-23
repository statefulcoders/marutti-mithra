import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../data/configs/app_config.dart';

class ComlateTextField extends StatelessWidget {
  final bool innerHint;
  final String? label;
  final String? hint;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization capitalization;
  final TextStyle? style;
  final String? error;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final Color? fillColor;

  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIconOptional;

  final bool? obscureText;
  final VoidCallback? onVisibilityTap;
  final double? borderRadius;
  final Color? textColorParam;
  final double? textSize;
  final Color? hintColorParam;
  final Color? borderColorParam;
  final Color? focusedBorderColorParam;
  final Color? iconColorParam;
  final bool? isFilled;
  final List<String>? autoFillHints;

  const ComlateTextField({
    super.key,
    this.label,
    this.hint,
    this.innerHint = false,
    this.enabled = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.capitalization = TextCapitalization.none,
    this.style,
    this.error,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.fillColor = Colors.transparent,
    this.inputFormatters,
    this.prefixIconOptional,
    this.obscureText,
    this.onVisibilityTap,
    this.borderRadius,
    this.textColorParam,
    this.textSize,
    this.hintColorParam,
    this.borderColorParam,
    this.focusedBorderColorParam,
    this.iconColorParam,
    this.isFilled,
    this.autoFillHints,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = textColorParam ?? (isDark ? Colors.white : Colors.black);
    final hintColor = hintColorParam ?? (isDark ? Colors.grey[500] : Colors.grey[500]);
    final borderColor = borderColorParam ?? (isDark ? Colors.grey[700]! : Colors.grey[300]!);
    final focusedBorderColor = focusedBorderColorParam ?? (isDark ? Colors.blue[300]! : Theme.of(context).primaryColor);
    final iconColor = iconColorParam ?? (isDark ? Colors.grey[400] : Colors.grey[600]);
    final fillClr = fillColor ?? (isDark ? Colors.grey[800] : Colors.grey[50]);
    final textStyle = style ?? TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: textSize ?? 15.sp,
      color: textColor,
    );

    final textField = Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: TextField(
        controller: controller,
        style: textStyle,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textCapitalization: capitalization,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        obscureText: obscureText ?? false,
        autofillHints: autoFillHints,
        decoration: InputDecoration(
            hintText: hint,
            labelText: innerHint ? hint : null,
            hintStyle: textStyle.copyWith(
                color: hintColor
            ),
            labelStyle: textStyle.copyWith(
                color: hintColor
            ),
            prefixIcon: prefixIconOptional != null ? Icon(
              prefixIconOptional,
              color: iconColor,
            ) : null,
            suffixIcon: obscureText != null ? IconButton(
              icon: Icon(
                obscureText == true ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: enabled ? onVisibilityTap : null,
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.radius.r),
              borderSide: BorderSide(color: focusedBorderColor.withAlpha(100), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor, width: 1.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.radius.r),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1.2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            filled: isFilled ?? true,
            counterText: "", // Hides the counter for maxLength
            errorText: error,
            fillColor: fillClr
        ),
      ),
    );

    if (label == null) {
      return textField;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        textField,
      ],
    );
  }
}
