
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_videos_helper.dart';
import 'package:marutti_mitra_admin/screens/main/videos/videos_controller.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class VideosPage extends StatelessWidget {
  final String label;

  final bool deleteVideos;
  final bool addVideos;
  final bool updateVideos;
  final bool exportData;

  const VideosPage({super.key, required this.label, required this.deleteVideos, required this.addVideos, required this.updateVideos, required this.exportData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideosController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComlateFirebaseTable(
            columns: controller.columns,
            dataSource: FirebaseVideosHelper.ref,
            onDataAdded: controller.onNewVideoAdded,
            identifier: label,
            enableEditing: updateVideos,
            enableDetails: true,
            enableDeletion: deleteVideos,
            enableExport: exportData,
            enableAction: addVideos,
            updateConfig: [
              DataUpdateFieldInfo(key: 'url', expectedType: 'text', hint: "Video link", min: 1, max: 500, required: true)
            ],
            onView: controller.viewLink,
          ),
        ],
      ),
    );
  }
}
