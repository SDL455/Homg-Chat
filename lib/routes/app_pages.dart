import 'package:get/get.dart';
import '../modules/auth/splash_page.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/home/home_page.dart';
import '../modules/chat/chat_page.dart';
import '../modules/settings/settings_page.dart';
import '../middleware/auth_middleware.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const SplashPage(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: '/register',
      page: () => RegisterPage(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/chat',
      page: () => const ChatPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
