import 'package:get/get.dart';
import 'package:marutti_mitra_admin/helpers/firebase/push_notifications_helper.dart';
import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';

class CataloguesController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Name', keys: ['name']),
    ComlateFirebaseTableColumn(label: 'Url', keys: ['url']),
  ];

  Future<void> newCatalogueAdded(Map<String, dynamic> data) async {
    try {
      final name = data['name'];
      await PushNotificationsHelper.sendNotificationByCategory(title: 'New Catalogue Available', body: 'You might want to read new catalogue - $name');
    } catch (error) {
      ConfirmationDialog.confirm(error.toString());
    }
  }
}