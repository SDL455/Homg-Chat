import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../../routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passC, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => auth.register(emailC.text, passC.text, nameC.text), child: const Text('Create account')),
            TextButton(onPressed: () => Get.offNamed(AppRoutes.LOGIN), child: const Text('Already have an account? Login'))
          ],
        ),
      ),
    );
  }
}
