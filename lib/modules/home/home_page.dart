import 'package:flutter/material.dart';
import 'package:flutter_chat_app_playable/routes/app_pages.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';
import '../../widgets/badge_demo_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ສົນທະນາ'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingChats.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.conversations.isEmpty) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ຍັງບໍ່ມີການສົນທະນາ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ກົດປຸ່ມ + ເພື່ອເລີ່ມສົນທະນາໃໝ່',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Add badge demo widget for testing
                const BadgeDemoWidget(),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadConversations,
          child: Column(
            children: [
              // Add badge demo widget at the top
              const BadgeDemoWidget(),
              // Conversations list
              Expanded(
                child: ListView.builder(
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final chat = controller.conversations[index];
                    final timestamp = chat['updatedAt'] as int;
                    final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final timeStr = _formatTime(dateTime);

                    final unreadCount = chat['unreadCount'] ?? 0;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[700],
                        child: Text(
                          (chat['otherUserName'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        chat['otherUserName'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.CHAT,
                          arguments: {'chatId': chat['chatId']},
                        );
                        // Real-time listener will automatically update unread count
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUsersDialog(context, controller),
        child: const Icon(Icons.message_outlined),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'ມື້ວານນີ້';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ມື້ກ່ອນ';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showUsersDialog(BuildContext context, HomeController controller) {
    // Load users when dialog opens
    controller.loadAllUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'ລາຍຊື່ຜູ້ໃຊ້ທັງໝົດ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingUsers.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.allUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ບໍ່ມີຜູ້ໃຊ້ອື່ນໃນລະບົບ',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ລອງສ້າງບັນຊີໃໝ່ເພື່ອທົດສອບການສົນທະນາ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: controller.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.allUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: Text(
                          (user['name'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: Icon(
                        Icons.message,
                        color: Colors.blue[700],
                      ),
                      onTap: () => controller.startChat(user['uid']),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
