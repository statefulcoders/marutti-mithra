import 'package:firebase_auth/firebase_auth.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';

import '../extra_fields_helper.dart';
import '../shared_prefs.dart';

class MaruttiSessionMemory {

  static const registrationLevelBasic = 'basic-level';
  static const registrationLevelAddress = 'address-level';

  static final _auth = FirebaseAuth.instance;

  static Future<void> initialize() {
    return SharedPrefs.init();
  }

  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get phoneNumber => _auth.currentUser?.phoneNumber;
  static String? get uid => _auth.currentUser?.uid;

  static Future<void> setBasicInfoSubmitted() {
    return _auth.currentUser?.updateDisplayName(registrationLevelBasic) ?? Future.value();
  }

  static Future<void> setAddressInfoSubmitted() {
    return _auth.currentUser?.updateDisplayName(registrationLevelAddress) ?? Future.value();
  }

  static bool get basicInfoSubmitted => _auth.currentUser?.displayName == registrationLevelBasic || addressInfoSubmitted;
  static bool get addressInfoSubmitted => _auth.currentUser?.displayName == registrationLevelAddress;

  static Future<void> logout() async {
    UserTableHelper.dispose();
    ExtraFieldsHelper.dispose();
    await _auth.signOut();
  }
}