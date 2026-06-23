import 'package:firebase_auth/firebase_auth.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_keys.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_sub_admin_helper.dart';

class FirebaseUserHelper {
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static Future<bool> isAdmin() async {
    final response = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
    return response?.claims?[ComlateKeys.admin] ?? false;
  }

  static Future<User> loginAsAdmin(String email, String password) async {
    final response = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    if (!await isAdmin()) {
      throw Exception('You are not an admin');
    }
    return response.user!;
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<Map<String, dynamic>?> getAdminInformation() async {
    try {
      final reference = await FirebaseSubAdminHelper.ref.doc(FirebaseAuth.instance.currentUser!.uid).get();
      return reference.data() as Map<String, dynamic>;
    } catch (error) {
      return null;
    }
  }
}