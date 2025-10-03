import 'package:flutter/material.dart';
import 'package:flutter_chat_app_playable/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../repositories/auth/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repo);
  final IAuthRepository _repo;
  RxnString uid = RxnString();
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Initialize authentication and check for existing login
  Future<void> _initializeAuth() async {
    try {
      final currentUserId = await _repo.currentUserId();
      uid.value = currentUserId;
    } catch (e) {
      print('Auth initialization error: $e');
      uid.value = null;
    } finally {
      isInitialized.value = true;
    }
  }

  /// Check authentication status (called from splash screen)
  Future<void> checkAuthStatus() async {
    if (!isInitialized.value) {
      await _initializeAuth();
    }

    if (uid.value != null && uid.value!.isNotEmpty) {
      // User is logged in, navigate to home
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      // User is not logged in, navigate to login
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _repo.register(email, password, name);
      uid.value = await _repo.currentUserId();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      // Handle registration error
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _repo.login(email, password);
      uid.value = await _repo.currentUserId();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      // Handle login error
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
      uid.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      // Handle logout error
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => uid.value != null && uid.value!.isNotEmpty;
}
