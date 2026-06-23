import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/utils/settings/intent_utils.dart';

import '../../../comlate/dialogs/confirmation_dialog.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table_column.dart';
import '../../../helpers/firebase/push_notifications_helper.dart';

class VideosController extends GetxController {
  final columns = [
    ComlateFirebaseTableColumn(label: 'Thumbnail', keys: ['url'], transformer: (p0) => p0 == null ? 'None' : getYoutubeThumbnail(p0['url']?.toString() ?? '')),
    ComlateFirebaseTableColumn(label: 'Url', keys: ['url']),
  ];

  static String getYoutubeThumbnail(String youtubeLink) {
    final uri = Uri.tryParse(youtubeLink);
    if (uri == null) return 'None';

    String? videoId;

    // Handle different YouTube URL formats
    if (uri.host.contains('youtu.be')) {
      videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    } else if (uri.host.contains('youtube.com')) {
      videoId = uri.queryParameters['v'];
    }

    if (videoId == null || videoId.isEmpty) return '';

    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  Future<void> addVideo() async {
  }

  viewLink(DocumentSnapshot<dynamic> data) {
    IntentUtils.launchInBrowser((data.data() as Map<String, dynamic>)['url']?.toString() ?? '');
  }

  Future<void> onNewVideoAdded(Map<String, dynamic> data) async {
    try {
      await PushNotificationsHelper.sendNotificationByCategory(title: 'Marutti Mitra', body: 'New video available, click to watch!');
    } catch (error) {
      ConfirmationDialog.confirm(error.toString());
    }
  }
}