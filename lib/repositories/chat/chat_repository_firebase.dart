import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'chat_repository.dart';

class ChatRepositoryFirebase implements IChatRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  @override
  Stream<List<Map<String, dynamic>>> messagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  @override
  Future<void> sendText(String chatId, String senderId, String text) async {
    // Extract receiverId from chatId (format: uid1_uid2)
    final receiverId = _getReceiverId(chatId, senderId);

    final ref =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    await ref.set({
      'id': ref.id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'updatedAt': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  // Helper to get receiverId from chatId
  String _getReceiverId(String chatId, String senderId) {
    final parts = chatId.split('_');
    if (parts.length == 2) {
      return parts[0] == senderId ? parts[1] : parts[0];
    }
    return '';
  }

  @override
  Future<void> sendImage(String chatId, String senderId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final file = File(picked.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    final task = await _storage.ref('uploads/$chatId/$fileName').putFile(file);
    final url = await task.ref.getDownloadURL();

    // Extract receiverId from chatId
    final receiverId = _getReceiverId(chatId, senderId);

    final ref =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    await ref.set({
      'id': ref.id,
      'senderId': senderId,
      'receiverId': receiverId,
      'imageUrl': url,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));

    // Update chat document with lastMessage
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': '📷 Image',
      'updatedAt': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }
}
