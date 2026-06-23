import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_logos.dart';

import '../utils/display/comlate_display_utils.dart';

class ResponsiveNavigationRailItem {
  final String title;
  final IconData icon;

  const ResponsiveNavigationRailItem({required this.title, required this.icon});
}

class ResponsiveNavigationRail extends StatelessWidget {
  static Color get gradientStartColor => Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200;
  static Color get gradientMidColor => Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade500;
  static Color get gradientEndColor => Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200;

  static Color get railGradientStart => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientMid => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientEnd => Get.isDarkMode ? Colors.black54 : Colors.white;

  static Color get foregroundColor => Get.isDarkMode ? Colors.white : Colors.black;

  static const double navigationRailFontSize = 12.8;

  final List<ResponsiveNavigationRailItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  final bool? enableLeading;
  final String? avatarImageUrl;
  final String? avatarLabel;

  final bool? enableTrailing;
  final VoidCallback? onTrailingPressed;

  const ResponsiveNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.enableLeading,
    this.enableTrailing, this.avatarImageUrl, this.avatarLabel, this.onTrailingPressed,
  });

  bool _isPhoneOrTablet(BuildContext context) {
    final deviceType = ComlateDisplayUtils.getDeviceType(context);
    return deviceType == ComlateDisplayType.phone || deviceType == ComlateDisplayType.tablet;
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneOrTablet = _isPhoneOrTablet(context);

    return Container(
      width: isPhoneOrTablet ? 92.w : 240.w,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      margin: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.black, width: 0.1),
          color: Colors.black,
          gradient: LinearGradient(
              colors: [
                railGradientStart,
                railGradientMid,
                railGradientEnd
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enableLeading == true) _createLeading(context) else SizedBox(height: 18.h),
          Expanded(
              child: SizedBox(
            // width: isPhoneOrTablet ? 200.w : isDesktop ? 300.w : 200.w,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => _buildNavigationRailItem(context, items[index], index),
            ),
          )),
          if (enableTrailing == true) _buildTrailingButton(context)
        ],
      ),
    );
  }

  Widget _createLeading(BuildContext context) {
    final isPhoneOrTablet = _isPhoneOrTablet(context);

    return Column(
      children: [
        SizedBox(height: 18.w),
        ClipOval(
          child: SizedBox(
              width: isPhoneOrTablet ? 50.w : 90.w,
              height: isPhoneOrTablet ? 50.w : 90.w,
              child: avatarImageUrl != null && avatarImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarImageUrl!,
                      placeholder: (context, url) => Container(color: Theme.of(context).colorScheme.primaryContainer),
                      errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Image.asset(ComlateLogos.profile)),
                    )
                  : Image.asset(ComlateLogos.loginLogo)),
        ),
        SizedBox(height: 10.w),
        if (!isPhoneOrTablet) ...[
          Text(avatarLabel ?? AppConfig.appName),
          SizedBox(height: 10.w),
        ],
        _buildDivider(),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      height: 1,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        gradientStartColor,
        gradientMidColor,
        gradientEndColor,
      ])),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    final isPhoneOrTablet = _isPhoneOrTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: onTrailingPressed,
          child: isPhoneOrTablet ? Icon(Icons.logout, size: 20.sp) : Text(
                  'Logout',
                  style: TextStyle(fontSize: navigationRailFontSize.sp),
                )
      ),
    );
  }

  Widget _buildNavigationRailItem(BuildContext context, ResponsiveNavigationRailItem item, int index) {
    final isPhoneOrTablet = _isPhoneOrTablet(context);
    bool isSelected = index == selectedIndex;

    return Card(
      elevation: isSelected ? 1 : 0,
      clipBehavior: Clip.hardEdge,
      color: isSelected ? AppConfig.primaryColor : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radius.r)),
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.w),
          child: Row(
            crossAxisAlignment: isPhoneOrTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              SizedBox(width: 10.w),
              Icon(
                item.icon,
                size: 20.sp,
                color: isSelected ? Colors.white : foregroundColor,
              ),
              if (!isPhoneOrTablet) ...[
                SizedBox(width: 10.w),
                Text(
                  item.title,
                  style: TextStyle(
                      fontSize: navigationRailFontSize.sp,
                      fontWeight: FontWeight.w300,
                      color: isSelected ? Colors.white : foregroundColor
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
