# Flutter Chat App (Playable Offline + Switchable Firebase)

This project runs immediately in Offline Demo Mode and can be switched to Firebase Mode later.

## Offline Demo
```
flutter pub get
flutter run
```
- Login/register with any email/password (mock auth).
- Open Chat and send messages (memory store). Echo-bot replies.

## Switch to Firebase
1. Create Firebase project
2. Install & run FlutterFire:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   (Generates `lib/firebase_options.dart` and platform configs)
3. Set `useFirebase = true` in `lib/core/config/app_config.dart`
4. (Optional) Deploy `functions/`
# Homg-Chat
