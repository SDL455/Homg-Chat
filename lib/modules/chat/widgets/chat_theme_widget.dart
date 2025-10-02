import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

/// Custom chat theme configuration
class ChatThemeWidget {
  static ChatTheme lightTheme() {
    return ChatTheme.light().copyWith(
      colors: ChatTheme.light().colors.copyWith(
            primary: Colors.blue,
            surface: Colors.grey.shade100,
            onSurface: Colors.black87,
          ),
    );
  }

  static ChatTheme darkTheme() {
    return ChatTheme.dark().copyWith(
      colors: ChatTheme.dark().colors.copyWith(
            primary: const Color(0xFF2196F3),
            surface: const Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
    );
  }
}
