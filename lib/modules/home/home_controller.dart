import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_controller.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // List of all registered users
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

  // List of user's conversations
  final RxList<Map<String, dynamic>> conversations =
      <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingChats = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  /// Load all conversations for current user
  Future<void> loadConversations() async {
    try {
      isLoadingChats.value = true;
      final currentUserId = Get.find<AuthController>().uid.value;
      if (currentUserId == null) return;

      print('🔍 Loading conversations for user: $currentUserId');

      // Query all chats where the user is a participant
      final chatsSnapshot = await _db
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('updatedAt', descending: true)
          .get();

      print('📊 Found ${chatsSnapshot.docs.length} chats');

      final allChats = <Map<String, dynamic>>[];

      for (var doc in chatsSnapshot.docs) {
        final chatId = doc.id;
        final data = doc.data();

        // Extract other user's ID
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );

        if (otherUserId.isEmpty) continue;

        // Get other user's info
        final userDoc = await _db.collection('users').doc(otherUserId).get();
        final userData = userDoc.data() ?? {};

        allChats.add({
          'chatId': chatId,
          'otherUserId': otherUserId,
          'otherUserName': userData['name'] ?? 'Unknown',
          'otherUserEmail': userData['email'] ?? '',
          'lastMessage': data['lastMessage'] ?? 'ຍັງບໍ່ມີຂໍ້ຄວາມ',
          'updatedAt': data['updatedAt'] ?? 0,
        });
      }

      conversations.value = allChats;
      print('✅ Loaded ${allChats.length} conversations');
    } catch (e) {
      print('❌ Error loading conversations: $e');
      Get.snackbar(
        'ເກີດຂໍ້ຜິດພາດ',
        'ບໍ່ສາມາດໂຫຼດລາຍການສົນທະນາໄດ້: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingChats.value = false;
    }
  }

  /// Load all registered users
  Future<void> loadAllUsers() async {
    try {
      isLoadingUsers.value = true;
      final currentUserId = Get.find<AuthController>().uid.value;

      print('🔍 Loading users from Firebase...');
      print('Current user ID: $currentUserId');

      final usersSnapshot = await _db.collection('users').get();
      print('📊 Total users found: ${usersSnapshot.docs.length}');

      final users = usersSnapshot.docs
          .map((doc) {
            final data = doc.data();
            print('👤 User: ${data['name']} (${data['uid']})');
            return data;
          })
          .where((user) => user['uid'] != currentUserId) // Exclude current user
          .toList();

      print('✅ Users after filtering: ${users.length}');

      // Sort by name
      users.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      allUsers.value = users;

      if (users.isEmpty) {
        Get.snackbar(
          'ແຈ້ງເຕືອນ',
          'ບໍ່ມີຜູ້ໃຊ້ອື່ນໃນລະບົບ. ລອງສ້າງບັນຊີໃໝ່ເພື່ອທົດສອບ.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error loading users: $e');
      Get.snackbar(
        'ເກີດຂໍ້ຜິດພາດ',
        'ບໍ່ສາມາດໂຫຼດລາຍຊື່ຜູ້ໃຊ້ໄດ້: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Create chat ID from two user IDs (consistent ordering)
  String createChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  /// Start a new chat with a user
  Future<void> startChat(String otherUserId) async {
    try {
      final currentUserId = Get.find<AuthController>().uid.value;
      if (currentUserId == null) return;

      final chatId = createChatId(currentUserId, otherUserId);

      print('🚀 Starting chat with ID: $chatId');

      // Create chat document if it doesn't exist
      await _db.collection('chats').doc(chatId).set({
        'participants': [currentUserId, otherUserId],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': '',
      }, SetOptions(merge: true));

      // Navigate to chat
      Get.back(); // Close the users dialog
      Get.toNamed(AppRoutes.CHAT, arguments: {'chatId': chatId});

      // Reload conversations
      loadConversations();
    } catch (e) {
      print('❌ Error starting chat: $e');
      Get.snackbar(
        'ເກີດຂໍ້ຜິດພາດ',
        'ບໍ່ສາມາດເລີ່ມການສົນທະນາໄດ້: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    }
  }
}
