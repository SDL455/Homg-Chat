import 'dart:async';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import '../chat_controller.dart' as app;

/// Adapter that bridges the app's ChatController with flutter_chat_core's ChatController
class ChatControllerAdapter extends ChatController {
  final app.ChatController _appController;
  final String _chatId;
  final StreamController<ChatOperation> _operationsController =
      StreamController<ChatOperation>.broadcast();

  List<Message> _messages = [];
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  ChatControllerAdapter({
    required app.ChatController appController,
    required String chatId,
    required String currentUserId,
  })  : _appController = appController,
        _chatId = chatId {
    _initializeStream();
  }

  void _initializeStream() {
    _subscription = _appController.streamChat(_chatId).listen((dataList) {
      final newMessages = dataList.map(_convertToMessage).toList();

      // Emit operations based on differences
      if (_messages.isEmpty && newMessages.isNotEmpty) {
        _operationsController.add(ChatOperation.insertAll(newMessages, 0));
      } else if (newMessages.length != _messages.length) {
        // Simple approach: reset all messages
        _operationsController.add(ChatOperation.set(newMessages));
      }

      _messages = newMessages;
    });
  }

  Message _convertToMessage(Map<String, dynamic> data) {
    final id = data['id'] ?? '';
    final senderId = data['senderId'] ?? '';
    final timestamp = data['timestamp'] as int?;
    final text = data['text'] ?? '';
    final imageUrl = data['imageUrl'];

    final createdAt = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.now();

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return Message.image(
        id: id,
        authorId: senderId,
        createdAt: createdAt,
        source: imageUrl.toString(),
        width: 200,
        height: 200,
      );
    } else {
      return Message.text(
        id: id,
        authorId: senderId,
        createdAt: createdAt,
        text: text,
      );
    }
  }

  @override
  Future<void> insertMessage(Message message, {int? index}) async {
    // Not implemented - app handles message insertion through repository
    _messages.add(message);
    _operationsController
        .add(ChatOperation.insert(message, _messages.length - 1));
  }

  @override
  Future<void> insertAllMessages(List<Message> messages, {int? index}) async {
    // Not implemented - app handles message insertion through repository
    _messages.addAll(messages);
    _operationsController.add(ChatOperation.insertAll(messages, index ?? 0));
  }

  @override
  Future<void> updateMessage(Message oldMessage, Message newMessage) async {
    // Not implemented - app handles updates through repository
    final index = _messages.indexWhere((m) => m.id == oldMessage.id);
    if (index != -1) {
      _messages[index] = newMessage;
      _operationsController
          .add(ChatOperation.update(oldMessage, newMessage, index));
    }
  }

  @override
  Future<void> removeMessage(Message message) async {
    // Not implemented - app handles removal through repository
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages.removeAt(index);
      _operationsController.add(ChatOperation.remove(message, index));
    }
  }

  @override
  Future<void> setMessages(List<Message> messages) async {
    _messages = messages;
    _operationsController.add(ChatOperation.set(messages));
  }

  @override
  List<Message> get messages => List.unmodifiable(_messages);

  @override
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  @override
  void dispose() {
    _subscription?.cancel();
    _operationsController.close();
  }
}
