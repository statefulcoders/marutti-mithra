import 'package:get/get.dart';
import 'package:maruttimitra/models/remote/product_model.dart';

import '../../../utils/products_table_helper.dart';

class PointsController extends GetxController {

  final products = Rxn<Map<String, List<ProductModel>>>();

  @override
  void onInit() {
    getPoints();
    super.onInit();
  }

  Future<void> getPoints() async {
    try {
      final response = await ProductsTableHelper.getProducts();

      final productsMap = <String, List<ProductModel>>{};
      for (final product in response) {
        if (!productsMap.containsKey(product.shop)) {
          productsMap[product.shop] = [];
        }
        productsMap[product.shop]!.add(product);
      }

      products.value = productsMap;
    } catch (error) {
      print("GETTING POINTS: ${error}");
      products.value = {};
    }
  }

}