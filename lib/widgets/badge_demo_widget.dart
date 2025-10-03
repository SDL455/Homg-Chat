import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/badge_service.dart';
import '../services/badge_debug_service.dart';

/// Demo widget to test app badge functionality
class BadgeDemoWidget extends StatelessWidget {
  const BadgeDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Badge Demo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Test app badge functionality:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await BadgeService.incrementBadge();
                    Get.snackbar(
                      'Badge Updated',
                      'Badge count: ${BadgeService.getCurrentBadgeCount()}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('+1'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BadgeService.setBadgeCount(5);
                    Get.snackbar(
                      'Badge Set',
                      'Badge count set to 5',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Set to 5'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BadgeService.clearBadge();
                    Get.snackbar(
                      'Badge Cleared',
                      'Badge count cleared',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BadgeService.updateBadgeFromUnreadMessages();
                    Get.snackbar(
                      'Badge Updated',
                      'Badge updated from unread messages',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Update from DB'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false,
                    );

                    final debugInfo = await BadgeDebugService.debugBadge();
                    Get.back(); // Close loading dialog

                    Get.dialog(
                      AlertDialog(
                        title: const Text('Badge Debug Info'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Platform Supported: ${debugInfo['platform_supported']}'),
                              Text(
                                  'Saved Count: ${debugInfo['saved_badge_count']}'),
                              Text('Platform: ${debugInfo['platform_name']}'),
                              if (debugInfo['error'] != null)
                                Text('Error: ${debugInfo['error']}',
                                    style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Debug'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BadgeDebugService.testBadgeValues();
                    Get.snackbar(
                      'Badge Test',
                      'Testing different badge values...',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Test Values'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BadgeDebugService.forceResetBadge();
                    Get.snackbar(
                      'Badge Reset',
                      'Badge forcefully reset',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Force Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: BadgeService.isSupported(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Badge Support: ${snapshot.data! ? "✅ Supported" : "❌ Not Supported"}',
                    style: TextStyle(
                      color: snapshot.data! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const Text('Checking badge support...');
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Current Badge Count: ${BadgeService.getCurrentBadgeCount()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
