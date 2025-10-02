# Firebase Chat App - Notification Features Documentation

## ການປັບປຸງທີ່ດຳເນີນການ (Improvements Made)

### 1. 🔔 ລະບົບແຈ້ງເຕືອນທີ່ສົມບູນແບບ (Complete Notification System)

#### Cloud Functions (Backend Server)
ໄຟລ໌: `functions/index.js`

**ຄຸນສົມບັດ (Features):**
- ✅ ສົ່ງການແຈ້ງເຕືອນອັດຕະໂນມັດເມື່ອມີຂໍ້ຄວາມໃໝ່
- ✅ ສະແດງຊື່ຜູ້ສົ່ງແທນ "New Message"
- ✅ ຮອງຮັບທັງຂໍ້ຄວາມແລະຮູບພາບ
- ✅ ມີລະບົບ priority ສູງສໍາລັບ Android ແລະ iOS
- ✅ ສົ່ງຂໍ້ມູນ chatId ແລະ messageId ສໍາລັບການນຳທາງ

**ວິທີເຮັດວຽກ:**
```javascript
// ດຶງຂໍ້ມູນຜູ້ສົ່ງ
const senderDoc = await db.collection('users').doc(senderId).get();
const senderName = senderDoc.exists ? senderDoc.data()?.name : 'Someone';

// ກຳນົດເນື້ອໃນການແຈ້ງເຕືອນ
let body;
if (imageUrl) {
  body = '📷 Sent an image';
} else if (text) {
  body = text;
}
```

### 2. 📱 FCM Service - ການຈັດການການແຈ້ງເຕືອນທຸກສະຖານະ

ໄຟລ໌: `lib/services/fcm_service.dart`

**ຄຸນສົມບັດ (Features):**
- ✅ ຮັບການແຈ້ງເຕືອນໃນທຸກສະຖານະ:
  - **Foreground** (ແອັບເປີດຢູ່)
  - **Background** (ແອັບຢູ່ພື້ນຫຼັງ)
  - **Terminated** (ແອັບປິດແລ້ວ)
- ✅ ກົດການແຈ້ງເຕືອນເພື່ອເຂົ້າໄປຫາຂໍ້ຄວາມນັ້ນໂດຍອັດຕະໂນມັດ
- ✅ ປັບແຕ່ງສຽງການແຈ້ງເຕືອນໄດ້
- ✅ ສ້າງ notification channel ສໍາລັບ Android

**ການເຮັດວຽກຂອງການນຳທາງ:**
```dart
// ຈັບການກົດການແຈ້ງເຕືອນ
static void _onNotificationTapped(NotificationResponse response) {
  final parts = response.payload!.split('|');
  final chatId = parts[0];
  final messageId = parts[1];
  _navigateToChat(chatId, messageId);
}

// ນຳທາງໄປຫາຫນ້າແຊັດພ້ອມເລື່ອນໄປຫາຂໍ້ຄວາມ
static void _navigateToChat(String chatId, String? messageId) {
  Get.toNamed(
    AppRoutes.CHAT,
    arguments: {
      'chatId': chatId,
      'focusMessageId': messageId,
    },
  );
}
```

### 3. 💬 ຫນ້າແຊັດທີ່ປັບປຸງແລ້ວ (Improved Chat Page)

ໄຟລ໌: `lib/modules/chat/chat_page.dart`

**ຄຸນສົມບັດ (Features):**
- ✅ ສະແດງຮູບພາບໃນການສົນທະນາ
- ✅ UI ທີ່ສວຍງາມແບບ Material Design 3
- ✅ ຂໍ້ຄວາມຖືກຈັດລຽງຕາມຜູ້ສົ່ງ (ຂວາ/ຊ້າຍ)
- ✅ ເລື່ອນໄປຫາຂໍ້ຄວາມອັດຕະໂນມັດເມື່ອກົດການແຈ້ງເຕືອນ
- ✅ ສະແດງເວລາທີ່ສົ່ງຂໍ້ຄວາມ
- ✅ ໄຮໄລທ໌ຂໍ້ຄວາມທີ່ຖືກກົດຈາກການແຈ້ງເຕືອນ (ສີເຫຼືອງ)

**ຕົວຢ່າງການສະແດງຮູບພາບ:**
```dart
if (isImage)
  ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      m['imageUrl'],
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    ),
  )
```

### 4. ⚙️ ຫນ້າການຕັ້ງຄ່າ (Settings Page)

ໄຟລ໌: `lib/modules/settings/settings_page.dart`

**ຄຸນສົມບັດ (Features):**

#### ການແຈ້ງເຕືອນ (Notifications)
- ✅ ເປີດ/ປິດການແຈ້ງເຕືອນ
- ✅ ເລືອກສຽງແຈ້ງເຕືອນ:
  - Default (ສຽງມາດຕະຖານ)
  - Ding
  - Chime
  - Bell

#### ຮູບລັກສະນະ (Appearance)
- ✅ ເລືອກຮູບແບບສີ (Theme):
  - System Default (ຕາມລະບົບ)
  - Light (ສະຫວ່າງ)
  - Dark (ມືດ)

#### ບັນຊີ (Account)
- ✅ ອອກຈາກລະບົບ (Logout)

**ຕົວຢ່າງການປ່ຽນ Theme:**
```dart
Get.changeThemeMode(mode);  // ປ່ຽນ theme ທັນທີ
```

### 5. 📷 ການສົ່ງຮູບພາບ (Image Messaging)

ໄຟລ໌: `lib/repositories/chat/chat_repository_firebase.dart`

**ຄຸນສົມບັດ (Features):**
- ✅ ເລືອກຮູບຈາກ Gallery
- ✅ ບີບອັດຮູບເພື່ອປະຫຍັດພື້ນທີ່ (80% quality)
- ✅ ອັບໂຫຼດໄປ Firebase Storage
- ✅ ອັບເດດ lastMessage ເປັນ "📷 Image"
- ✅ ສົ່ງການແຈ້ງເຕືອນພ້ອມ icon ຮູບພາບ

### 6. 🎨 ລະບົບ Theme (Theme System)

ໄຟລ໌: `lib/main.dart`

**ຄຸນສົມບັດ (Features):**
- ✅ Light Theme - ຮູບແບບສີສະຫວ່າງ
- ✅ Dark Theme - ຮູບແບບສີມືດ
- ✅ Material Design 3
- ✅ ສີຫຼັກ: Indigo

```dart
theme: ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.light,
),
darkTheme: ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.dark,
),
```

## 📋 ການຕິດຕັ້ງ ແລະ ການນຳໃຊ້

### ຂັ້ນຕອນການ Deploy Cloud Functions:

1. ເຂົ້າໄປໃນໂຟລ໌ເດີ functions:
```bash
cd functions
```

2. ຕິດຕັ້ງ dependencies:
```bash
npm install
```

3. Deploy ໄປ Firebase:
```bash
firebase deploy --only functions
```

### ການຕັ້ງຄ່າ Android:

ໄຟລ໌: `android/app/src/main/AndroidManifest.xml`

ຕ້ອງມີການຕັ້ງຄ່າ:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### ການຕັ້ງຄ່າ iOS:

ໄຟລ໌: `ios/Runner/Info.plist`

ຕ້ອງມີການຕັ້ງຄ່າສິດການເຂົ້າເຖິງ notification.

## 🔧 ການແກ້ໄຂບັນຫາທົ່ວໄປ

### ບໍ່ໄດ້ຮັບການແຈ້ງເຕືອນ?

1. ກວດສອບວ່າ FCM token ຖືກບັນທຶກໃນ Firestore:
   - Collection: `users`
   - Field: `fcmToken`

2. ກວດສອບ Cloud Functions logs:
```bash
firebase functions:log
```

3. ກວດສອບວ່າ receiverId ຖືກສົ່ງໃນຂໍ້ຄວາມ:
```dart
await ref.set({
  'senderId': senderId,
  'receiverId': receiverId,  // ຕ້ອງມີ!
  'text': text,
});
```

### ກົດການແຈ້ງເຕືອນແລ້ວບໍ່ເຂົ້າແອັບ?

1. ກວດສອບວ່າມີການ initialize FCM ໃນ `main.dart`:
```dart
await FCMService.initialize();
```

2. ກວດສອບວ່າມີ `getInitialMessage()` ສໍາລັບ terminated state

### ຮູບພາບບໍ່ສະແດງ?

1. ກວດສອບ Firebase Storage Rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /uploads/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

2. ກວດສອບ URL ຂອງຮູບໃນ Firestore

## 📱 ການທົດສອບ

### ທົດສອບການແຈ້ງເຕືອນ:

1. **Foreground**: ເປີດແອັບແລ້ວໃຫ້ຄົນອື່ນສົ່ງຂໍ້ຄວາມ
2. **Background**: ກົດ Home ແລ້ວໃຫ້ຄົນອື່ນສົ່ງຂໍ້ຄວາມ
3. **Terminated**: ປິດແອັບແລ້ວໃຫ້ຄົນອື່ນສົ່ງຂໍ້ຄວາມ

### ທົດສອບການນຳທາງ:

1. ກົດການແຈ້ງເຕືອນ
2. ຄວນເປີດແອັບແລະເຂົ້າໄປຫາແຊັດ
3. ຄວນເລື່ອນໄປຫາຂໍ້ຄວາມນັ້ນ
4. ຂໍ້ຄວາມນັ້ນຄວນມີສີເຫຼືອງ

## 🚀 ຄຸນລັກສະນະທີ່ສຳເລັດແລ້ວ

- ✅ ສົ່ງຂໍ້ຄວາມທັງ text ແລະ image
- ✅ ຮັບ notification ທຸກສະຖານະ (foreground, background, terminated)
- ✅ ກົດ notification ແລ້ວເຂົ້າຫາຂໍ້ຄວາມອັດຕະໂນມັດ
- ✅ ປັບສຽງ notification ໄດ້
- ✅ ປ່ຽນ theme (Light/Dark) ໄດ້
- ✅ ມີ backend server (Cloud Functions) ຄອຍຈັດການ
- ✅ UI ສວຍງາມແບບ Material Design 3
- ✅ ສະແດງຊື່ຜູ້ສົ່ງໃນການແຈ້ງເຕືອນ
- ✅ ສະແດງເວລາທີ່ສົ່ງຂໍ້ຄວາມ
- ✅ Highlight ຂໍ້ຄວາມທີ່ຖືກກົດຈາກການແຈ້ງເຕືອນ

## 📞 ຕິດຕໍ່ສອບຖາມ

ຖ້າມີບັນຫາຫຼືຕ້ອງການຄວາມຊ່ວຍເຫຼືອ, ກະລຸນາກວດສອບ:
1. Firebase Console - Functions logs
2. Firebase Console - Firestore data
3. Flutter logs: `flutter logs`
4. Android logs: `adb logcat`

---

**Version:** 1.0.0  
**Last Updated:** October 1, 2025  
**Language:** Lao (ລາວ) + English

