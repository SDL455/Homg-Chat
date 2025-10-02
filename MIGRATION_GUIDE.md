# ຄູ່ມືການອັບເດດລະບົບການສົນທະນາ (Migration Guide)

## ການປ່ຽນແປງທີ່ສຳຄັນ

ການອັບເດດນີ້ປັບປຸງວິທີການດຶງຂໍ້ມູນການສົນທະນາເພື່ອໃຫ້ສະແດງທຸກການສົນທະນາຢ່າງຖືກຕ້ອງ.

### ການປ່ຽນແປງໃນໂຄງສ້າງຂໍ້ມູນ

**ກ່ອນ:**

```json
{
  "chats": {
    "uid1_uid2": {
      "lastMessage": "ສະບາຍດີ",
      "updatedAt": 1234567890,
      "createdAt": 1234567890
    }
  }
}
```

**ຫຼັງ:**

```json
{
  "chats": {
    "uid1_uid2": {
      "participants": ["uid1", "uid2"],
      "lastMessage": "ສະບາຍດີ",
      "updatedAt": 1234567890,
      "createdAt": 1234567890
    }
  }
}
```

### ການປ່ຽນແປງໃນ Code

1. **HomeController** (`lib/modules/home/home_controller.dart`)

   - ປ່ຽນການ query ຈາກການໃຊ້ document ID ເປັນການໃຊ້ `arrayContains` ກັບ field `participants`
   - ເພີ່ມການສ້າງ `participants` array ເມື່ອສ້າງການສົນທະນາໃໝ່

2. **ChatRepositoryFirebase** (`lib/repositories/chat/chat_repository_firebase.dart`)

   - ອັບເດດ chat document ໃຫ້ລວມ `participants` field ທຸກຄັ້ງທີ່ສົ່ງຂໍ້ຄວາມ

3. **Firestore Rules** (`firestore.rules`)

   - ອັບເດດກົດຄວາມປອດໄພເພື່ອກວດສອບວ່າຜູ້ໃຊ້ແມ່ນຜູ້ເຂົ້າຮ່ວມໃນການສົນທະນາ

4. **Firestore Indexes** (`firestore.indexes.json`)

   - ສ້າງ composite index ສຳລັບການ query `participants` + `updatedAt`

5. **Cloud Functions** (`functions/index.js`)
   - ເພີ່ມ migration function ເພື່ອອັບເດດ chat documents ທີ່ມີຢູ່ແລ້ວ

## ຂັ້ນຕອນການ Deploy

### 1. Deploy Firestore Rules ແລະ Indexes

```bash
# Deploy rules
firebase deploy --only firestore:rules

# Deploy indexes (ອາດໃຊ້ເວລາ 5-10 ນາທີ)
firebase deploy --only firestore:indexes
```

### 2. Deploy Cloud Functions

```bash
# ເຂົ້າໄປໃນໂຟລ໌ເດີ functions
cd functions

# ຕິດຕັ້ງ dependencies ຖ້າຍັງບໍ່ທັນ
npm install

# Deploy functions
cd ..
firebase deploy --only functions
```

### 3. ເຮັດ Migration ຂໍ້ມູນທີ່ມີຢູ່ແລ້ວ

ຫຼັງຈາກ deploy functions ສຳເລັດແລ້ວ, ເຮັດ migration ດ້ວຍການເອີ້ນ migration function:

```bash
# ຫາ URL ຂອງ function
firebase functions:list

# ເອີ້ນ migration function (ປ່ຽນ PROJECT_ID ເປັນ project ID ຂອງທ່ານ)
curl https://us-central1-PROJECT_ID.cloudfunctions.net/migrateChatsAddParticipants
```

ຫຼື ເປີດ URL ນີ້ໃນ browser:

```
https://us-central1-PROJECT_ID.cloudfunctions.net/migrateChatsAddParticipants
```

ທ່ານຈະເຫັນຜົນລັບແບບນີ້:

```json
{
  "success": true,
  "message": "Migration completed successfully",
  "updated": 10,
  "skipped": 0,
  "total": 10
}
```

### 4. ທົດສອບ App

```bash
# ເຮັດ Flutter clean ແລະ rebuild
flutter clean
flutter pub get
flutter run
```

## ການກວດສອບຫຼັງ Deploy

1. ເປີດ Firebase Console → Firestore Database
2. ກວດເບິ່ງ collection `chats`
3. ຢືນຢັນວ່າທຸກ documents ມີ field `participants` ແລ້ວ
4. ກວດເບິ່ງ Indexes ວ່າ status ເປັນ "Enabled" (ອາດໃຊ້ເວລາຫຼາຍນາທີ)

## ການແກ້ໄຂບັນຫາທົ່ວໄປ

### ບັນຫາ: "FAILED_PRECONDITION: The query requires an index"

**ວິທີແກ້:**

1. ກວດເບິ່ງວ່າ `firestore.indexes.json` ໄດ້ຖືກ deploy ແລ້ວ
2. ລໍຖ້າໃຫ້ index ສ້າງສຳເລັດ (5-10 ນາທີ)
3. ກວດເບິ່ງສະຖານະໃນ Firebase Console → Firestore → Indexes

### ບັນຫາ: "PERMISSION_DENIED: Missing or insufficient permissions"

**ວິທີແກ້:**

1. ກວດເບິ່ງວ່າ Firestore Rules ໄດ້ຖືກ deploy ແລ້ວ
2. ກວດເບິ່ງວ່າຜູ້ໃຊ້ໄດ້ login ແລ້ວ
3. ກວດເບິ່ງວ່າ chat documents ມີ `participants` field

### ບັນຫາ: ບໍ່ເຫັນການສົນທະນາໃນໜ້າ Home

**ວິທີແກ້:**

1. ກວດເບິ່ງ console logs ໃນ app (ຈະມີ debug messages)
2. ຢືນຢັນວ່າ migration function ໄດ້ຖືກເຮັດແລ້ວ
3. ລອງສົ່ງຂໍ້ຄວາມໃໝ່ໃນການສົນທະນາທີ່ມີຢູ່ແລ້ວ (ຈະອັບເດດ participants ອັດຕະໂນມັດ)
4. ລອງສ້າງການສົນທະນາໃໝ່ເພື່ອທົດສອບ

## ຂໍ້ສັງເກດສຳຄັນ

- ການສົ່ງຂໍ້ຄວາມໃນການສົນທະນາທີ່ມີຢູ່ແລ້ວຈະອັບເດດ `participants` field ອັດຕະໂນມັດ
- ການສ້າງການສົນທະນາໃໝ່ຈະມີ `participants` field ຕັ້ງແຕ່ເລີ່ມຕົ້ນ
- Firestore rules ຮອງຮັບທັງ `participants` field ແລະ chatId format ເກົ່າ

## ການຍົກເລີກການປ່ຽນແປງ (Rollback)

ຖ້າເກີດບັນຫາ, ທ່ານສາມາດ rollback ໄດ້ດ້ວຍການ:

1. Revert code changes ໃນ Git:

```bash
git revert HEAD
```

2. Deploy ກົດເກົ່າກັບຄືນ:

```bash
firebase deploy --only firestore:rules
```

## ສະຫຼຸບການປ່ຽນແປງ

✅ ການດຶງຂໍ້ມູນການສົນທະນາເຮັດວຽກໄດ້ຖືກຕ້ອງກວ່າເກົ່າ
✅ ປະສິດທິພາບການ query ດີຂຶ້ນດ້ວຍ composite index
✅ ຄວາມປອດໄພດີຂຶ້ນດ້ວຍການກວດສອບ participants
✅ ມີ migration function ສຳລັບອັບເດດຂໍ້ມູນເກົ່າ
✅ ຮອງຮັບທັງຂໍ້ມູນໃໝ່ແລະເກົ່າໃນຊ່ວງການປ່ຽນແປງ
