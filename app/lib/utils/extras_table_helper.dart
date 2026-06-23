import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:maruttimitra/models/remote/catalogue_model.dart';
import 'package:maruttimitra/models/remote/form_field_model.dart';
import 'package:maruttimitra/models/remote/support_details_model.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

class ExtrasTableHelper {
  static const String extraTableDB = 'extras';
  static const String supportTableDB = 'support';
  static const String cataloguesTableDB = 'catalogues';
  static const String videosTableDB = 'videos';

  static final _db = FirebaseFirestore.instance;
  static final _extraDB = _db.collection(extraTableDB);
  static final _supportDB = _extraDB.doc(supportTableDB);
  static final _catalogueDB = _db.collection(cataloguesTableDB);
  static final _videoDB = _db.collection(videosTableDB);

  static Future<SupportDetailsModel> getSupportDetails() async {
    final snapshot = await _supportDB.get();
    return SupportDetailsModel.fromJson(snapshot.data()!);
  }

  static Future<List<String>> getVideos() async {
    final snapshots = await _videoDB.get();
    return snapshots.docs.map((e) => e['url'].toString()).toList();
  }

  static Future<List<CatalogueModel>> getCatalogues() async {
    final snapshots = await _catalogueDB.get();
    return snapshots.docs.map((e) => CatalogueModel.fromJson(e.data())).toList();
  }
}