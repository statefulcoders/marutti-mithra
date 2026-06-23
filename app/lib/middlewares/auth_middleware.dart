import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import '../utils/settings/marutti_session_memory.dart';
import '../utils/settings/marutti_settings_memory.dart'; // adjust path as needed

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!MaruttiSettingsMemory.isLanguageSet) {
      if (route?.startsWith(MaruttiRoutes.welcome) == true) return null;
      return const RouteSettings(name: MaruttiRoutes.welcome);
    } else if (!MaruttiSessionMemory.isLoggedIn) {
      if (route?.startsWith(MaruttiRoutes.login) == true) return null;
      return const RouteSettings(name: MaruttiRoutes.login);
    }  else if (!MaruttiSessionMemory.basicInfoSubmitted) {
      if (route?.startsWith(MaruttiRoutes.basicInfo) == true) return null;
      return const RouteSettings(name: MaruttiRoutes.basicInfo);
    }  else if (!MaruttiSessionMemory.addressInfoSubmitted) {
      if (route?.startsWith(MaruttiRoutes.addressDetails) == true) return null;
      return const RouteSettings(name: MaruttiRoutes.addressDetails);
    } else {
      return null;
    }
  }
}