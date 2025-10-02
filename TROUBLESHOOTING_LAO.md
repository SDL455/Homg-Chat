# 🔧 ຄູ່ມືແກ້ໄຂບັນຫາ - User List ບໍ່ສະແດງ

## ບັນຫາ: ເມື່ອກົດ FAB ແລ້ວບໍ່ມີລາຍຊື່ຜູ້ໃຊ້ສະແດງ

### ວິທີກວດສອບ:

## ✅ ຂັ້ນຕອນທີ 1: ກວດເບິ່ງ Console Logs

ເມື່ອກົດປຸ່ມ FAB, ກວດເບິ່ງ console ຄວນເຫັນ:

```
🔍 Loading users from Firebase...
Current user ID: [user-id]
📊 Total users found: X
👤 User: [name] ([uid])
✅ Users after filtering: X
```

### ສິ່ງທີ່ຄວນກວດສອບ:

#### 1. ກວດເບິ່ງວ່າມີຜູ້ໃຊ້ໃນ Firebase Firestore ຫຼືບໍ່

**ວິທີກວດສອບ:**

1. ເປີດ Firebase Console: https://console.firebase.google.com
2. ໄປທີ່ Firestore Database
3. ກວດເບິ່ງ collection `users`
4. ຄວນມີຢ່າງໜ້ອຍ 2 users (ເພາະວ່າລະບົບຈະບໍ່ສະແດງຜູ້ໃຊ້ປັດຈຸບັນ)

**ໂຄງສ້າງຂໍ້ມູນຜູ້ໃຊ້ທີ່ຖືກຕ້ອງ:**

```
users (collection)
  └── [uid] (document)
      ├── uid: "user-id-123"
      ├── email: "user@example.com"
      ├── name: "User Name"
      ├── fcmToken: "..."
      └── createdAt: 1234567890
```

#### 2. ກວດເບິ່ງ Firestore Rules

ໄປທີ່ Firebase Console > Firestore Database > Rules

ຄວນເປັນ:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;  // ✅ ສຳຄັນ!
      allow create, update: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### 3. ກວດເບິ່ງການເຊື່ອມຕໍ່ Firebase

ໃນໄຟລ໌ `lib/core/config/app_config.dart`:

```dart
const bool useFirebase = true;  // ✅ ຕ້ອງເປັນ true
```

#### 4. ທົດສອບສ້າງຜູ້ໃຊ້ໃໝ່

**ວິທີທີ 1: ໃຊ້ແອັບ**

1. Logout ຈາກບັນຊີປັດຈຸບັນ
2. ກົດ Register
3. ສ້າງບັນຊີໃໝ່
4. Login ດ້ວຍບັນຊີເກົ່າ
5. ກົດ FAB - ຄວນເຫັນຜູ້ໃຊ້ໃໝ່

**ວິທີທີ 2: ໃຊ້ Firebase Console**

1. ໄປທີ່ Firestore Database
2. ສ້າງ document ໃໝ່ໃນ collection `users`
3. ເພີ່ມ fields:
   - uid: "test-user-001"
   - name: "ທົດສອບ 1"
   - email: "test1@test.com"
   - createdAt: 1234567890

## 🐛 ຂໍ້ຜິດພາດທີ່ພົບເລື້ອຍ

### Error: "permission-denied"

**ສາເຫດ:** Firestore rules ບໍ່ອະນຸຍາດໃຫ້ອ່ານຂໍ້ມູນ
**ວິທີແກ້:** ແກ້ໄຂ Firestore Rules ຕາມຂັ້ນຕອນທີ 2

### Error: "Firebase not initialized"

**ສາເຫດ:** Firebase ຍັງບໍ່ຖືກເປີດໃຊ້ງານ
**ວິທີແກ້:** ກວດເບິ່ງວ່າມີໄຟລ໌ `google-services.json` (Android) ແລະ `GoogleService-Info.plist` (iOS)

### ບໍ່ມີຜູ້ໃຊ້ສະແດງ (ແຕ່ບໍ່ມີ error)

**ສາເຫດ:** ມີແຕ່ຜູ້ໃຊ້ປັດຈຸບັນຄົນດຽວໃນລະບົບ
**ວິທີແກ້:** ສ້າງບັນຊີໃໝ່ເພີ່ມເຕີມ

## 📱 ວິທີທົດສອບ

### ທົດສອບທີ 1: ລອງ Run ແອັບ

```bash
cd /Users/sdl/Desktop/flutter_chat_app_playable
flutter run
```

### ທົດສອບທີ 2: ກວດເບິ່ງ Console Output

ເວລາກົດ FAB, console ຄວນສະແດງ logs ດັ່ງນີ້:

- 🔍 Loading users from Firebase...
- 📊 Total users found: X
- ✅ Users after filtering: X

### ທົດສອບທີ 3: ກວດເບິ່ງ SnackBar

- ຖ້າບໍ່ມີຜູ້ໃຊ້: ຄວນສະແດງ "ບໍ່ມີຜູ້ໃຊ້ອື່ນໃນລະບົບ"
- ຖ້າມີ error: ຄວນສະແດງ "ເກີດຂໍ້ຜິດພາດ"

## 🎯 ການແກ້ໄຂດ່ວນ

### ແກ້ໄຂທີ 1: ລິເຊັດ Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### ແກ້ໄຂທີ 2: Clear Cache

```bash
flutter clean
flutter pub get
flutter run
```

### ແກ້ໄຂທີ 3: ສ້າງຂໍ້ມູນທົດສອບ

ໃຊ້ Firebase Console ສ້າງຜູ້ໃຊ້ທົດສອບດັ່ງນີ້:

```javascript
// Document ID: test-user-001
{
  "uid": "test-user-001",
  "name": "ຜູ້ໃຊ້ທົດສອບ 1",
  "email": "test1@test.com",
  "createdAt": 1696118400000
}

// Document ID: test-user-002
{
  "uid": "test-user-002",
  "name": "ຜູ້ໃຊ້ທົດສອບ 2",
  "email": "test2@test.com",
  "createdAt": 1696118400000
}
```

## 📞 ຕິດຕໍ່ຊ່ວຍເຫຼືອ

ຖ້າຍັງບໍ່ສາມາດແກ້ໄຂໄດ້:

1. ກວດເບິ່ງ Console logs ທັງໝົດ
2. Copy error message
3. ກວດເບິ່ງ Firestore ວ່າມີຂໍ້ມູນບໍ່
4. Share screenshots ຂອງ Firebase Console

---

ອັບເດດຫຼ້າສຸດ: October 2025
