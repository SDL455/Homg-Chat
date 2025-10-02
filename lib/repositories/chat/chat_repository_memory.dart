import 'dart:async';
import 'chat_repository.dart';

class ChatRepositoryMemory implements IChatRepository {
  final Map<String, List<Map<String, dynamic>>> _store = {};
  final Map<String, StreamController<List<Map<String, dynamic>>>> _controllers =
      {};

  @override
  Stream<List<Map<String, dynamic>>> messagesStream(String chatId) {
    _controllers.putIfAbsent(chatId, () => StreamController.broadcast());
    _store.putIfAbsent(chatId, () => []);
    Future.microtask(
        () => _controllers[chatId]!.add(List.from(_store[chatId]!.reversed)));
    return _controllers[chatId]!.stream;
  }

  @override
  Future<void> sendText(String chatId, String senderId, String text) async {
    final msg = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'senderId': senderId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _store.putIfAbsent(chatId, () => []);
    _store[chatId]!.add(msg);
    _controllers[chatId]?.add(List.from(_store[chatId]!.reversed));
    await Future.delayed(const Duration(milliseconds: 600));
    final reply = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'senderId': 'echo-bot',
      'text': 'Echo: $text',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _store[chatId]!.add(reply);
    _controllers[chatId]?.add(List.from(_store[chatId]!.reversed));
  }

  @override
  Future<void> sendImage(String chatId, String senderId) async {
    final msg = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'senderId': senderId,
      'imageUrl': 'memory://placeholder',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _store.putIfAbsent(chatId, () => []);
    _store[chatId]!.add(msg);
    _controllers[chatId]?.add(List.from(_store[chatId]!.reversed));
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    // For memory implementation, we don't need to track read status
    // This is just a stub to satisfy the interface
    await Future.delayed(Duration.zero);
  }
}
