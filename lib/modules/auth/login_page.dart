import 'package:flutter/material.dart';
import 'package:flutter_chat_app_playable/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: passC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () => auth.login(emailC.text, passC.text),
                child: const Text('Login')),
            TextButton(
                onPressed: () => Get.offNamed(AppRoutes.REGISTER),
                child: const Text('Don\'t have an account? Register'))
          ],
        ),
      ),
    );
  }
}
