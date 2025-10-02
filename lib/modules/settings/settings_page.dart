import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/fcm_service.dart';
import '../../modules/auth/auth_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedSound = 'default';
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedSound = FCMService.notificationSound;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              ListTile(
                title: const Text('Notification Sound'),
                subtitle: Text(
                    _selectedSound == 'default' ? 'Default' : _selectedSound),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSoundPicker(),
              ),
            ],
          ),
          _buildSection(
            title: 'Appearance',
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(),
              ),
            ],
          ),
          _buildSection(
            title: 'Account',
            children: [
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout, color: Colors.red),
                onTap: () async {
                  final authController = Get.find<AuthController>();
                  await authController.logout();
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Debug',
            children: [
              ListTile(
                title: const Text('ກວດສອບຂໍ້ມູນຜູ້ໃຊ້'),
                subtitle: const Text('ກວດເບິ່ງຂໍ້ມູນໃນ Firebase'),
                leading: const Icon(Icons.bug_report, color: Colors.orange),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFirebaseDebugInfo(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Notification Sound',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSoundOption('default', 'Default'),
              _buildSoundOption('ding', 'Ding'),
              _buildSoundOption('chime', 'Chime'),
              _buildSoundOption('bell', 'Bell'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundOption(String value, String label) {
    return ListTile(
      title: Text(label),
      trailing: _selectedSound == value
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() => _selectedSound = value);
        FCMService.notificationSound = value;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification sound set to $label')),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildThemeOption(
                  ThemeMode.system, 'System Default', Icons.phone_android),
              _buildThemeOption(ThemeMode.light, 'Light', Icons.light_mode),
              _buildThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: _themeMode == mode
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() => _themeMode = mode);
        Navigator.pop(context);
        Get.changeThemeMode(mode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Theme set to $label')),
        );
      },
    );
  }

  String _getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showFirebaseDebugInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.uid.value;

      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Get current user data
      DocumentSnapshot? currentUserDoc;
      if (currentUserId != null) {
        currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
      }

      Navigator.pop(context); // Close loading dialog

      // Show results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔍 Firebase Debug Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 Current User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text('UID: ${currentUserId ?? "Not logged in"}'),
                if (currentUserDoc != null && currentUserDoc.exists)
                  Text('Name: ${currentUserDoc.get('name')}'),
                if (currentUserDoc != null && currentUserDoc.exists)
                  Text('Email: ${currentUserDoc.get('email')}'),
                const Divider(height: 24),
                Text(
                  '👥 All Users (${usersSnapshot.docs.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...usersSnapshot.docs.map((doc) {
                  final data = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${data['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '  ${data['email']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '  UID: ${data['uid']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 24),
                Text(
                  '💡 Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  usersSnapshot.docs.length < 2
                      ? '⚠️ ຕ້ອງມີຢ່າງໜ້ອຍ 2 ຜູ້ໃຊ້ເພື່ອສົນທະນາກັນ\nລອງສ້າງບັນຊີໃໝ່ເພີ່ມ!'
                      : '✅ ມີຜູ້ໃຊ້ພຽງພໍສຳລັບການທົດສອບ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ປິດ'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Error'),
          content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
