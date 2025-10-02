abstract class IChatRepository {
  Stream<List<Map<String, dynamic>>> messagesStream(String chatId);
  Future<void> sendText(String chatId, String senderId, String text);
  Future<void> sendImage(String chatId, String senderId);
  Future<void> markAsRead(String chatId, String userId);
}
