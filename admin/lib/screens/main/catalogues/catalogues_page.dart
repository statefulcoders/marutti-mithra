
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_catalogues_helper.dart';
import 'package:marutti_mitra_admin/screens/main/catalogues/catalogues_controller.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class CataloguesPage extends StatelessWidget {
  final String label;

  final bool addCatalogue;
  final bool updateCatalogue;
  final bool deleteCatalogue;
  final bool exportData;

  const CataloguesPage({super.key, required this.label, required this.addCatalogue, required this.deleteCatalogue, required this.exportData, required this.updateCatalogue});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CataloguesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComlateFirebaseTable(
            columns: controller.columns,
            dataSource: FirebaseCataloguesHelper.ref,
            onDataAdded: controller.newCatalogueAdded,
            identifier: label,
            enableEditing: updateCatalogue,
            enableAction: addCatalogue,
            enableDetails: true,
            enableExport: exportData,
            enableDeletion: deleteCatalogue,
            updateConfig: [
              DataUpdateFieldInfo(key: 'name', expectedType: 'text', hint: "Catalogue Name", min: 1, max: 255, required: true),
              DataUpdateFieldInfo(key: 'url', expectedType: 'file', hint: "Catalogue link (PDF only)", options: ['pdf'], min: 1, max: 500, required: true),
            ],
          ),
        ],
      ),
    );
  }
}
