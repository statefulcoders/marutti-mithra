import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/screens/main/dashboard/dashboard_controller.dart';

import '../../../comlate/utils/display/comlate_display_utils.dart';

class DashboardCard {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> subMetrics;
  final String conclusion;
  final Color conclusionColor;
  final String? route;

  const DashboardCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.subMetrics,
    required this.conclusion,
    required this.conclusionColor,
    this.route,
  });
}

class DashboardPage extends StatelessWidget {
  static Color get railGradientStart => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientMid => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientEnd => Get.isDarkMode ? Colors.black54 : Colors.white;

  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final deviceType = ComlateDisplayUtils.getDeviceType(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Obx(() => GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: deviceType == ComlateDisplayType.phone ? 1 : deviceType == ComlateDisplayType.tablet ? 2 : 3,
              childAspectRatio: deviceType == ComlateDisplayType.phone ? 1.2 : deviceType == ComlateDisplayType.tablet ? 1.2 : 1.6,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h
          ),
          children: controller.cards.map((e) => _buildGridCard(context, data: e, onClicked: controller.clickTab)).toList(),
        ))
    );
  }

  Widget _buildGridCard(BuildContext context, { required DashboardCard data, required Function(DashboardCard card) onClicked }) {
    final deviceType = ComlateDisplayUtils.getDeviceType(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 25.h),
            child: GestureDetector(
              onTap: () => onClicked(data),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey, width: 0.1),
                    // color: Colors.black.withAlpha(100),
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
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: deviceType == ComlateDisplayType.phone ? 30.h : 50.h),
                      Text(
                        data.label
                      ),
                      SizedBox(height: 8.h),
                      ...data.subMetrics.map((metric) => Row(
                        children: [
                          Icon(Icons.circle, size: 6.sp, color: Colors.grey[400]),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              metric,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                            ),
                          ),
                        ],
                      )),
                      Spacer(),
                      Divider(color: data.color.withAlpha(100)),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.conclusion,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: data.conclusionColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward, size: 15.sp, color: Colors.grey)
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: data.color
            ),
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(left: 16.w),
            child: Icon(data.icon, color: Colors.white, size: 25.sp)
        )
      ],
    );
  }
}
