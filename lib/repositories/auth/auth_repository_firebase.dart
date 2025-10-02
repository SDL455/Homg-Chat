import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_repository.dart';

class AuthRepositoryFirebase implements IAuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  @override
  Future<String?> currentUserId() async => _auth.currentUser?.uid;
  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    // Save FCM token after login
    await _saveFCMToken();
  }

  Future<void> _saveFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final uid = _auth.currentUser?.uid;
      if (token != null && uid != null) {
        await _db.collection('users').doc(uid).update({'fcmToken': token});
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  @override
  Future<void> logout() async {
    // Delete FCM token before logout
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db
            .collection('users')
            .doc(uid)
            .update({'fcmToken': FieldValue.delete()});
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
    await _auth.signOut();
  }

  @override
  Future<void> register(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user!.uid;

    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'fcmToken': token,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }
}
