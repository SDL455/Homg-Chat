import 'package:get/get.dart';
import '../../repositories/chat/chat_repository.dart';
import '../../repositories/chat/chat_repo_factory.dart';

class ChatController extends GetxController {
  final IChatRepository repo = ChatRepoFactory.build();
  Stream<List<Map<String, dynamic>>> streamChat(String chatId) =>
      repo.messagesStream(chatId);
  Future<void> sendText(String chatId, String senderId, String text) =>
      repo.sendText(chatId, senderId, text);
  Future<void> sendImage(String chatId, String senderId) =>
      repo.sendImage(chatId, senderId);
  Future<void> markAsRead(String chatId, String userId) =>
      repo.markAsRead(chatId, userId);
}
