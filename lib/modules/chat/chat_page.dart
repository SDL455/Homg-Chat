import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as ui;
import 'package:flutter_chat_core/flutter_chat_core.dart';

import 'chat_controller.dart' as app;
import 'widgets/chat_controller_adapter.dart';
import 'widgets/chat_user_resolver.dart';
import 'widgets/chat_theme_widget.dart';
import 'widgets/custom_composer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final app.ChatController c = Get.put(app.ChatController());
  late ChatControllerAdapter _chatController;
  late String chatId;
  String? focusMessageId;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    // Get arguments from navigation
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      chatId = args['chatId'] ?? 'demoChat';
      focusMessageId = args['focusMessageId'];
    } else {
      chatId = 'demoChat';
    }

    // Initialize current user
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'demoUser';

    // Create adapter
    _chatController = ChatControllerAdapter(
      appController: c,
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _handleMessageSend(String text) {
    if (text.trim().isEmpty) return;
    c.sendText(chatId, currentUserId, text.trim());
  }

  void _handleAttachmentTap() {
    c.sendImage(chatId, currentUserId);
  }

  void _handleMessageTap(
    BuildContext context,
    Message message, {
    int index = 0,
    TapUpDetails? details,
  }) {
    // Handle message tap - could show details, etc.
  }

  void _handleMessageLongPress(
    BuildContext context,
    Message message, {
    int index = 0,
    LongPressStartDetails? details,
  }) {
    // Handle long press - could show options menu
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show chat options
            },
          ),
        ],
      ),
      body: ui.Chat(
        currentUserId: currentUserId,
        resolveUser: ChatUserResolver.resolveUser,
        chatController: _chatController,
        theme: ChatThemeWidget.lightTheme(),
        onMessageSend: _handleMessageSend,
        onMessageTap: _handleMessageTap,
        onMessageLongPress: _handleMessageLongPress,
        onAttachmentTap: _handleAttachmentTap,
        builders: Builders(
          composerBuilder: (context) => const CustomComposer(),
          textMessageBuilder: (
            context,
            message,
            index, {
            required bool isSentByMe,
            MessageGroupStatus? groupStatus,
          }) {
            // Custom builder for focused messages
            if (message.id == focusMessageId) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: ui.SimpleTextMessage(message: message, index: index),
              );
            }
            return ui.SimpleTextMessage(message: message, index: index);
          },
          imageMessageBuilder: (
            context,
            message,
            index, {
            required bool isSentByMe,
            MessageGroupStatus? groupStatus,
          }) {
            // Custom builder for image messages
            final isHighlighted = message.id == focusMessageId;

            return Container(
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: Colors.amber.shade100,
                      border: Border.all(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              padding: isHighlighted ? const EdgeInsets.all(12) : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.source,
                  width: message.width?.toDouble() ?? 200,
                  height: message.height?.toDouble() ?? 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
