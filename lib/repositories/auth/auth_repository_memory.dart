import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';

class AuthRepositoryMemory implements IAuthRepository {
  static const String _userKey = 'logged_in_user';
  static const String _userDataKey = 'user_data';

  @override
  Future<String?> currentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);
      if (userData != null) {
        final data = jsonDecode(userData);
        return data['uid'];
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'uid': email,
        'email': email,
        'name': email.split('@')[0], // Use email prefix as name
        'loginTime': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setBool(_userKey, true);
    } catch (e) {
      print('Error saving login data: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing login data: $e');
      rethrow;
    }
  }

  @override
  Future<void> register(String email, String password, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'uid': email,
        'email': email,
        'name': name,
        'registerTime': DateTime.now().millisecondsSinceEpoch,
        'loginTime': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setBool(_userKey, true);
    } catch (e) {
      print('Error saving registration data: $e');
      rethrow;
    }
  }

  /// Get user data for display purposes
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Check if user is logged in (for quick check)
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_userKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}
