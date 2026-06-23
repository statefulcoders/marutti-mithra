import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';

import '../../../models/remote/product_model.dart';
import 'points_controller.dart';

class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PointsController>();

    return AppRootContainer(
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Text('points'.tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600)),
          ),
        body: SafeArea(
          child: Obx(() => controller.products.value == null ? Center(
            child: CircularProgressIndicator(color: MaruttiColors.primaryColor),
          ) : controller.products.value!.isEmpty ? Center(
            child: Text('no_data_found'.tr),
          ) : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: controller.products.value!.entries.map((entry) => [
                  ..._createTable(entry.key, entry.value),
                  SizedBox(height: 16.h),
                ]).toList().expand((element) => element).toList()
            ),
          ))
        )
      ),
    );
  }

  List<Widget> _createTable(String shop, List<ProductModel> products) {
    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          gradient: LinearGradient(
            colors: [
              MaruttiColors.primaryColor.withAlpha(20),
              Colors.transparent
            ]
          )
        ),
        child: Text(
          shop,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
      SizedBox(height: 8.h),
      Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade300)
        ),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade200),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        'product_name'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp
                        )
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        'points'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp
                        )
                    ),
                  ),
                ),
              ],
            ),
            ...products.map((product) => TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      product.name,
                      style: TextStyle(
                          fontSize: 17.sp
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      product.points.toString(),
                      style: TextStyle(
                          fontSize: 17.sp
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    ];
  }
}
