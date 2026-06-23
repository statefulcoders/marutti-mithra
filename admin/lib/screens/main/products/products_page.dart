
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';
import 'package:marutti_mitra_admin/screens/main/products/products_controller.dart';

import '../../../comlate/dialogs/data_updater_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class ProductsPage extends StatelessWidget {
  final String label;

  final bool addProduct;
  final bool updateProduct;
  final bool deleteProduct;
  final bool exportData;

  const ProductsPage({super.key, required this.label, required this.addProduct, required this.updateProduct, required this.deleteProduct, required this.exportData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => controller.shopNames.value == null ? Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: CircularProgressIndicator(),
        )
      ) : ComlateFirebaseTable(
        sortBy: 'shop',
        columns: controller.columns,
        dataSource: FirebaseProductsHelper.ref,
        identifier: label,
        enableDeletion: deleteProduct,
        enableDetails: true,
        enableExport: exportData,
        enableEditing: updateProduct,
        enableAction: addProduct,
        updateConfig: [
          DataUpdateFieldInfo(key: 'name', hint: 'Product Name', expectedType: 'text', min: 1, max: 255, required: true),
          DataUpdateFieldInfo(key: 'points', hint: 'Product Price', expectedType: 'integer', min: 1, max: 10, required: true),
          DataUpdateFieldInfo(key: 'shop', hint: 'Shop Name', expectedType: 'dropdown', options: controller.shopNames.value ?? [], required: true),
        ]
      )),
    );
  }
}
