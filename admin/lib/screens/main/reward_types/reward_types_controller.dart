import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_products_helper.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';

class RewardTypesController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Image', keys: ['image'], transformer: (data) => data['image']?.toString() ?? 'None'),
    ComlateFirebaseTableColumn(label: 'Name', keys: ['name']),
    ComlateFirebaseTableColumn(label: 'Description', keys: ['description']),
  ];
}