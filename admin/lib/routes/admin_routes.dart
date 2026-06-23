import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marutti_mitra_admin/middlewares/auth_middleware.dart';
import 'package:marutti_mitra_admin/screens/auth/login/login_screen.dart';
import 'package:marutti_mitra_admin/screens/auth/passwords/reset_password_screen.dart';

import '../screens/main/main_screen.dart';

class AdminRoutes {
  static const main = '/';
  static const login = '/login';
  static const reset = '/reset';

  static final pages = <GetPage>[
    GetPage(name: main, middlewares: [AuthMiddleware()], page: () => const MainScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: reset, page: () => const ResetPasswordScreen()),
  ];

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: main,
        builder: (BuildContext context, GoRouterState state) {
          return const MainScreen();
        },
      ),
      GoRoute(
        path: login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: reset,
        builder: (BuildContext context, GoRouterState state) {
          return const ResetPasswordScreen();
        },
      ),
    ],
  );
}