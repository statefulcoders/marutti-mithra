import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AssetImageIcon extends StatelessWidget {

  final String path;
  final double? size;
  final Color? color;

  const AssetImageIcon({super.key, required this.path, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(path),
      size: size ?? 20.sp,
      color: color ?? (Get.isDarkMode ? Colors.white : Colors.black),
    );
  }
}
