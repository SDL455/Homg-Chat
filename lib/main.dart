import 'package:flutter/material.dart';
import 'package:flutter_chat_app_playable/firebase_options.dart';
import 'package:get/get.dart';
import 'core/config/app_config.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'modules/auth/auth_controller.dart';
import 'repositories/auth/auth_repo_factory.dart';
import 'services/fcm_service.dart';
import 'services/badge_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _initFirebaseIfNeeded() async {
  if (useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize FCM for background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize FCM service
    await FCMService.initialize();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseIfNeeded();

  // Initialize badge service
  await BadgeService.initialize();

  Get.put(AuthController(AuthRepoFactory.build()), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hmong Chat',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}
