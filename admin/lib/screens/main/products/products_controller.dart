import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';

class ProductsController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Name', keys: ['name']),
    ComlateFirebaseTableColumn(label: 'Shop', keys: ['shop']),
    ComlateFirebaseTableColumn(label: 'Points', keys: ['points']),
  ];

  final shopNames = Rxn<List<String>>();

  @override
  void onInit() {
    _initialise();
    super.onInit();
  }

  Future<void> _initialise() async {
    try {
      final response = await FirebaseProductsHelper.getProducts();
      final shops = response.map((e) => e['shop']?.toString() ?? 'Unknown').toSet().toList();
      shopNames.value = shops;
    } catch (error) {
      shopNames.value = [];
    }
  }
}