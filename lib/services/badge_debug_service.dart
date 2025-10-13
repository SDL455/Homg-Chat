import 'package:flutter/services.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Debug service to help troubleshoot badge issues
class BadgeDebugService {
  /// Comprehensive badge debugging
  static Future<Map<String, dynamic>> debugBadge() async {
    Map<String, dynamic> debugInfo = {};

    try {
      print('🔍 Starting comprehensive badge debug...');

      // 1. Check platform support
      bool isSupported = await AppBadgePlus.isSupported();
      debugInfo['platform_supported'] = isSupported;
      print('📱 Platform support: $isSupported');

      // 2. Check SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedCount = prefs.getInt('badge_count') ?? 0;
        debugInfo['saved_badge_count'] = savedCount;
        print('💾 Saved badge count: $savedCount');
      } catch (e) {
        debugInfo['shared_prefs_error'] = e.toString();
        print('❌ SharedPreferences error: $e');
      }

      // 3. Test badge operations
      if (isSupported) {
        try {
          // Test setting badge to 1
          await AppBadgePlus.updateBadge(1);
          debugInfo['test_badge_set'] = 'success';
          print('✅ Test badge set to 1: success');

          // Wait a moment
          await Future.delayed(const Duration(seconds: 2));

          // Test setting badge to 5
          await AppBadgePlus.updateBadge(5);
          debugInfo['test_badge_update'] = 'success';
          print('✅ Test badge updated to 5: success');
        } catch (e) {
          debugInfo['badge_operation_error'] = e.toString();
          print('❌ Badge operation error: $e');
        }
      }

      // 4. Check platform info
      try {
        const platform = MethodChannel('app_badge_plus');
        final platformName = await platform.invokeMethod('getPlatformName');
        debugInfo['platform_name'] = platformName;
        print('🖥️ Platform: $platformName');
      } catch (e) {
        debugInfo['platform_info_error'] = e.toString();
        print('❌ Platform info error: $e');
      }
    } catch (e) {
      debugInfo['general_error'] = e.toString();
      print('❌ General debug error: $e');
    }

    return debugInfo;
  }

  /// Force clear badge and reset
  static Future<void> forceResetBadge() async {
    try {
      print('🔄 Force resetting badge...');

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('badge_count');
      print('💾 Cleared badge from storage');

      // Set badge to 0
      bool isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        await AppBadgePlus.updateBadge(0);
        print('✅ Badge reset to 0');
      }
    } catch (e) {
      print('❌ Error force resetting badge: $e');
    }
  }

  /// Test badge with different values
  static Future<void> testBadgeValues() async {
    try {
      print('🧪 Testing badge with different values...');

      bool isSupported = await AppBadgePlus.isSupported();
      if (!isSupported) {
        print('❌ Platform not supported, skipping tests');
        return;
      }

      // Test sequence
      List<int> testValues = [1, 5, 10, 99, 0];

      for (int value in testValues) {
        print('🔢 Testing badge value: $value');
        await AppBadgePlus.updateBadge(value);
        await Future.delayed(const Duration(seconds: 2));
      }

      print('✅ Badge testing completed');
    } catch (e) {
      print('❌ Error testing badge values: $e');
    }
  }

  /// Check Android-specific badge requirements
  static Future<Map<String, dynamic>> checkAndroidBadgeSupport() async {
    Map<String, dynamic> androidInfo = {};

    try {
      print('🤖 Checking Android badge support...');

      const platform = MethodChannel('app_badge_plus');

      // Check if running on Android
      final platformName = await platform.invokeMethod('getPlatformName');
      androidInfo['platform'] = platformName;

      if (platformName == 'Android') {
        // Try to get launcher info
        try {
          final launcherInfo = await platform.invokeMethod('getLauncherInfo');
          androidInfo['launcher_info'] = launcherInfo;
          print('Launcher info: $launcherInfo');
        } catch (e) {
          androidInfo['launcher_info_error'] = e.toString();
          print('Could not get launcher info: $e');
        }

        // Check permissions
        try {
          final permissions = await platform.invokeMethod('checkPermissions');
          androidInfo['permissions'] = permissions;
          print('Permissions: $permissions');
        } catch (e) {
          androidInfo['permissions_error'] = e.toString();
          print('Could not check permissions: $e');
        }
      }
    } catch (e) {
      androidInfo['error'] = e.toString();
      print('Error checking Android support: $e');
    }

    return androidInfo;
  }
}
