import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ComlateDisplayType {
  phone,
  tablet,
  desktop,
}

class ComlateDisplayUtils {
  static const Map<ComlateDisplayType, Size> _defaultDesignSizes = {
    ComlateDisplayType.phone: Size(430, 932), // e.g., iPhone 13
    ComlateDisplayType.tablet: Size(810, 1080), // e.g., iPad Mini
    ComlateDisplayType.desktop: Size(1440, 900), // e.g., Common desktop
  };

  static ComlateDisplayType getDeviceType(BuildContext context) {
    try {
      final size = MediaQuery.of(context).size;
      final aspectRatio = size.width / size.height;

      if (aspectRatio <= 0.56) {
        return ComlateDisplayType.phone;
      } else if (aspectRatio <= 1 && aspectRatio > 0.56) {
        return ComlateDisplayType.tablet;
      } else {
        return ComlateDisplayType.desktop;
      }
    } catch (e) {
      return ComlateDisplayType.phone;
    }
  }

  static Size getDisplaySizeForPlatform(BuildContext context) {
    try {
      final deviceType = getDeviceType(context);
      final designSize = _defaultDesignSizes[deviceType] ?? _defaultDesignSizes[ComlateDisplayType.phone]!;
      return designSize;
    } catch (e) {
      return _defaultDesignSizes[ComlateDisplayType.phone]!;
    }
  }

  static double getSidePadding(BuildContext context, [double? defaultPadding]) {
    final type = getDeviceType(context);
    switch (type) {
      case ComlateDisplayType.desktop:
        return 120.w;
      case ComlateDisplayType.tablet:
        return 60.w;
      case ComlateDisplayType.phone:
      return defaultPadding ?? 12.w;
    }
  }
}