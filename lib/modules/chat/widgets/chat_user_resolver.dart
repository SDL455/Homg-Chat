import 'package:flutter_chat_core/flutter_chat_core.dart';

/// Simple user resolver for the chat UI
class ChatUserResolver {
  static Future<User?> resolveUser(UserID userId) async {
    return User(
      id: userId,
      name: _getUserName(userId),
      imageSource: null,
    );
  }

  static String _getUserName(UserID userId) {
    if (userId == 'demoUser') {
      return 'You';
    } else if (userId.startsWith('user_')) {
      return 'User ${userId.substring(5)}';
    }
    return userId.length > 10 ? userId.substring(0, 10) : userId;
  }
}
