import 'package:get/get.dart';
import '../modules/auth/splash_page.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/home/home_page.dart';
import '../modules/chat/chat_page.dart';
import '../modules/settings/settings_page.dart';
import '../middleware/auth_middleware.dart';

abstract class AppRoutes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const CHAT = '/chat';
  static const SETTINGS = '/settings';
}

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
