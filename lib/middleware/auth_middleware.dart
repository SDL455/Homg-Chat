import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/auth_controller.dart';
import '../routes/app_routes.dart';

/// Middleware to protect routes that require authentication
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // Allow splash screen to load
    if (route == AppRoutes.SPLASH) {
      return null;
    }

    // Allow login and register pages
    if (route == AppRoutes.LOGIN || route == AppRoutes.REGISTER) {
      return null;
    }

    // Check if user is authenticated for protected routes
    if (authController.isLoggedIn) {
      return null; // Allow access to protected routes
    } else {
      return const RouteSettings(name: AppRoutes.LOGIN); // Redirect to login
    }
  }
}

/// Middleware to redirect authenticated users away from login/register
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If user is already logged in, redirect to home
    if (authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.HOME);
    }

    return null; // Allow access to login/register pages
  }
}
