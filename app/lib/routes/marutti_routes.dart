import 'package:get/get.dart';
import 'package:maruttimitra/middlewares/auth_middleware.dart';
import 'package:maruttimitra/routes/bindings/address_details_binding.dart';
import 'package:maruttimitra/routes/bindings/app_content_binding.dart';
import 'package:maruttimitra/routes/bindings/basic_info_binding.dart';
import 'package:maruttimitra/routes/bindings/login_binding.dart';
import 'package:maruttimitra/routes/bindings/profile_binding.dart';
import 'package:maruttimitra/routes/bindings/support_chat_binding.dart';
import 'package:maruttimitra/screens/login/address_details_screen.dart';
import 'package:maruttimitra/screens/login/basic_info_screen.dart';
import 'package:maruttimitra/screens/login/welcome_page.dart';
import 'package:maruttimitra/screens/main/notifications/notification_screen.dart';
import 'package:maruttimitra/screens/main/settings/profile_screen.dart';
import 'package:maruttimitra/screens/main/settings/app_content_screen.dart';
import 'package:maruttimitra/screens/main/support/support_chat_screen.dart';
import 'package:maruttimitra/screens/splash/splash_page.dart';
import '../screens/login/login_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/main/pdf_viewer/pdf_viewer.dart';
import 'bindings/main_binding.dart';

class MaruttiRoutes {
  static const String splash = '/splash';
  static const String main = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String appContent = '/app-content';
  static const String notifications = '/notifications';
  static const String supportChat = '/support-chat';
  static const String basicInfo = '/basic-info';
  static const String profile = '/profile';
  static const String addressDetails = '/address-details';
  static const String pdfViewer = '/pdf-viewer';

  static List<GetPage> routes = [
    GetPage(
        name: main,
        binding: MainBinding(),
        middlewares: [
          AuthMiddleware()
        ],
        page: () => MainScreen()
    ),
    GetPage(
      name: welcome,
      middlewares: [
        AuthMiddleware()
      ],
      page: () => const WelcomePage(),
    ),
    GetPage(
      name: login,
      binding: LoginBinding(),
      middlewares: [
        AuthMiddleware()
      ],
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: appContent,
      binding: AppContentBinding(),
      page: () => const AppContentScreen(),
    ),
    GetPage(
      name: notifications,
      middlewares: [AuthMiddleware()],
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: supportChat,
      middlewares: [AuthMiddleware()],
      binding: SupportChatBinding(),
      page: () => SupportChatScreen(),
    ),
    GetPage(
      name: basicInfo,
      middlewares: [AuthMiddleware()],
      binding: BasicInfoBinding(),
      page: () => BasicInfoScreen(),
    ),
    GetPage(
      name: addressDetails,
      middlewares: [AuthMiddleware()],
      binding: AddressDetailsBinding(),
      page: () => AddressDetailsScreen(),
    ),
    GetPage(
      name: profile,
      middlewares: [AuthMiddleware()],
      binding: ProfileBinding(),
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: splash,
      middlewares: [AuthMiddleware()],
      page: () => SplashPage(),
    ),
    GetPage(
      name: pdfViewer,
      page: () => PdfViewer(),
    )
  ];
}