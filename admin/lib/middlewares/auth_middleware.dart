import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_user_helper.dart';
import 'package:marutti_mitra_admin/routes/admin_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!FirebaseUserHelper.isLoggedIn) {
      if (route?.startsWith(AdminRoutes.login) == true) return null;
      return const RouteSettings(name: AdminRoutes.login);
    } else {
      return null;
    }
  }
}