import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'badge_service.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification sound preference
  static String notificationSound = 'default';

  // Initialize FCM and request permissions
  static Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    }

    // Initialize local notifications for foreground messages
    const androidSettings = AndroidInitializationSettings('@drawable/icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize badge service
    await BadgeService.initialize();

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Notifications',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get and save FCM token
    await _saveFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message clicks
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });

    // Check for notification that opened the app (terminated state)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveFCMToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});

      print('FCM token saved: $token');
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }

  // Handle foreground messages (when app is open)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');

    // Increment badge count for new message
    await BadgeService.incrementBadge();

    // Show local notification with navigation data
    final androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: _getNotificationSound(),
      icon: '@drawable/icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'ຂໍ້ຄວາມໃໝ່',
      message.notification?.body ?? '',
      notificationDetails,
      payload: '${message.data['chatId']}|${message.data['messageId']}',
    );
  }

  // Handle notification tap (when tapped from notification tray)
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final parts = response.payload!.split('|');
      if (parts.length == 2) {
        final chatId = parts[0];
        final messageId = parts[1];
        _navigateToChat(chatId, messageId);

        // Mark conversation as read when notification is tapped
        BadgeService.markConversationAsRead(chatId);
      }
    }
  }

  // Handle notification clicks (from background/terminated)
  static void _handleMessageClick(RemoteMessage message) {
    print('Message clicked: ${message.data}');
    final chatId = message.data['chatId'];
    final messageId = message.data['messageId'];
    if (chatId != null) {
      _navigateToChat(chatId, messageId);

      // Mark conversation as read when notification is clicked
      BadgeService.markConversationAsRead(chatId);
    }
  }

  // Navigate to chat page with optional message focus
  static void _navigateToChat(String chatId, String? messageId) {
    Get.toNamed(
      AppRoutes.CHAT,
      arguments: {
        'chatId': chatId,
        'focusMessageId': messageId,
      },
    );
  }

  // Get notification sound based on user preference
  static RawResourceAndroidNotificationSound? _getNotificationSound() {
    switch (notificationSound) {
      case 'ding':
        return const RawResourceAndroidNotificationSound('ding');
      case 'chime':
        return const RawResourceAndroidNotificationSound('chime');
      case 'bell':
        return const RawResourceAndroidNotificationSound('bell');
      case 'default':
      default:
        return null; // Use system default
    }
  }

  // Delete FCM token on logout
  static Future<void> deleteToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': FieldValue.delete()});
      }
      await FirebaseMessaging.instance.deleteToken();

      // Clear badge on logout
      await BadgeService.clearBadge();
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');

  // Initialize Firebase if not already done
  await Firebase.initializeApp();

  // Increment badge count for background messages
  try {
    await BadgeService.incrementBadge();
  } catch (e) {
    print('Error updating badge in background handler: $e');
  }
}
