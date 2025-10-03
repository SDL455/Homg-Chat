import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  static const String _badgeCountKey = 'badge_count';
  static int _currentBadgeCount = 0;

  /// Initialize the badge service
  static Future<void> initialize() async {
    try {
      print('🚀 Initializing Badge Service...');

      // Check if badges are supported on this platform
      bool isSupported = await AppBadgePlus.isSupported();
      print('📱 Badge support status: $isSupported');

      if (!isSupported) {
        print('❌ App badges are not supported on this platform');
        return;
      }

      // Load saved badge count
      await _loadBadgeCount();
      print('📊 Loaded badge count from storage: $_currentBadgeCount');

      // Set initial badge count
      await setBadgeCount(_currentBadgeCount);
      print('✅ Badge service initialized with count: $_currentBadgeCount');

      // Listen for auth state changes to reset badge when user logs out
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          print('👤 User logged out, clearing badge');
          clearBadge();
        }
      });
    } catch (e) {
      print('❌ Error initializing badge service: $e');
    }
  }

  /// Load badge count from shared preferences
  static Future<void> _loadBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentBadgeCount = prefs.getInt(_badgeCountKey) ?? 0;
    } catch (e) {
      print('Error loading badge count: $e');
      _currentBadgeCount = 0;
    }
  }

  /// Save badge count to shared preferences
  static Future<void> _saveBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeCountKey, _currentBadgeCount);
    } catch (e) {
      print('Error saving badge count: $e');
    }
  }

  /// Set the app badge count
  static Future<void> setBadgeCount(int count) async {
    try {
      print('🔢 Setting badge count to: $count');

      bool isSupported = await AppBadgePlus.isSupported();
      print('📱 Badge support check: $isSupported');

      if (!isSupported) {
        print('❌ App badges are not supported on this platform');
        return;
      }

      _currentBadgeCount = count.clamp(0, 999); // Limit to reasonable range
      print('📊 Badge count clamped to: $_currentBadgeCount');

      // Try to update badge
      await AppBadgePlus.updateBadge(_currentBadgeCount);
      print('✅ Badge update API called successfully');

      await _saveBadgeCount();
      print('💾 Badge count saved to storage');

      print('🎯 Badge count set to: $_currentBadgeCount');
    } catch (e) {
      print('❌ Error setting badge count: $e');
      print('❌ Error details: ${e.toString()}');
    }
  }

  /// Increment the badge count
  static Future<void> incrementBadge([int amount = 1]) async {
    await setBadgeCount(_currentBadgeCount + amount);
  }

  /// Decrement the badge count
  static Future<void> decrementBadge([int amount = 1]) async {
    await setBadgeCount(_currentBadgeCount - amount);
  }

  /// Clear the badge (set to 0)
  static Future<void> clearBadge() async {
    await setBadgeCount(0);
  }

  /// Get current badge count
  static int getCurrentBadgeCount() {
    return _currentBadgeCount;
  }

  /// Update badge count based on unread messages
  static Future<void> updateBadgeFromUnreadMessages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Query all conversations for unread messages
      final conversations = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: user.uid)
          .get();

      int totalUnreadCount = 0;

      for (var doc in conversations.docs) {
        final data = doc.data();
        final lastMessage = data['lastMessage'] as Map<String, dynamic>?;

        if (lastMessage != null) {
          final senderId = lastMessage['senderId'] as String?;
          final isRead = lastMessage['isRead'] as bool? ?? false;

          // If message is not from current user and not read, increment count
          if (senderId != user.uid && !isRead) {
            totalUnreadCount++;
          }
        }
      }

      await setBadgeCount(totalUnreadCount);
      print('Badge updated with $totalUnreadCount unread messages');
    } catch (e) {
      print('Error updating badge from unread messages: $e');
    }
  }

  /// Mark all messages as read and clear badge
  static Future<void> markAllAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get all conversations
      final conversations = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: user.uid)
          .get();

      // Update all conversations to mark last message as read
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in conversations.docs) {
        final data = doc.data();
        final lastMessage = data['lastMessage'] as Map<String, dynamic>?;

        if (lastMessage != null) {
          final senderId = lastMessage['senderId'] as String?;

          // Only mark as read if message is not from current user
          if (senderId != user.uid) {
            batch.update(doc.reference, {
              'lastMessage.isRead': true,
            });
          }
        }
      }

      await batch.commit();
      await clearBadge();
      print('All messages marked as read, badge cleared');
    } catch (e) {
      print('Error marking all messages as read: $e');
    }
  }

  /// Mark specific conversation as read
  static Future<void> markConversationAsRead(String conversationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final lastMessage = data['lastMessage'] as Map<String, dynamic>?;

      if (lastMessage != null) {
        final senderId = lastMessage['senderId'] as String?;

        // Only mark as read if message is not from current user
        if (senderId != user.uid) {
          await docRef.update({
            'lastMessage.isRead': true,
          });

          // Update badge count after marking conversation as read
          await updateBadgeFromUnreadMessages();
        }
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  /// Check if app badges are supported
  static Future<bool> isSupported() async {
    try {
      return await AppBadgePlus.isSupported();
    } catch (e) {
      print('Error checking badge support: $e');
      return false;
    }
  }
}
