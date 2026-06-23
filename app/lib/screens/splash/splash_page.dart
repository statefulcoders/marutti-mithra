import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/resources/marutti_logos.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';

import '../../configs/design/marutti_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRootContainer(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Image.asset(
                      MaruttiLogos.splash,
                      width: 100.w,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade100.withAlpha(10),
                                Colors.grey.shade100,
                                Colors.grey.shade100.withAlpha(10),
                              ]
                          )
                      ),
                      child: Text(
                        'top_shops'.tr,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      children: Constants.shops.map((shop) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          )
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                shop.logo,
                                width: 150.w,
                                height: 65.w,
                              ),
                              // SizedBox(height: 10),
                              // Text(shop.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                              // Text('${'open'.tr} 9 AM - 9 PM', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )).toList()
                    ),
                    SizedBox(height: 30),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('continue'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
