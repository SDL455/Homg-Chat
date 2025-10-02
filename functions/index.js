const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();

exports.sendChatNotification = onDocumentCreated('chats/{chatId}/messages/{messageId}', async (event) => {
  const data = event.data?.data();
  const chatId = event.params.chatId;
  const messageId = event.params.messageId;
  const senderId = data?.senderId;
  const receiverId = data?.receiverId;
  const text = data?.text;
  const imageUrl = data?.imageUrl;
  
  if (!receiverId || !senderId) return null;
  
  const db = getFirestore();
  
  // Get receiver's FCM token
  const receiverDoc = await db.collection('users').doc(receiverId).get();
  const fcmToken = receiverDoc.exists ? receiverDoc.data()?.fcmToken : null;
  
  if (!fcmToken) {
    console.log(`No FCM token for user: ${receiverId}`);
    return null;
  }
  
  // Get sender's name
  const senderDoc = await db.collection('users').doc(senderId).get();
  const senderName = senderDoc.exists ? senderDoc.data()?.name : 'Someone';
  
  // Determine notification body
  let body;
  if (imageUrl) {
    body = '📷 Sent an image';
  } else if (text) {
    body = text;
  } else {
    body = 'Sent a message';
  }
  
  const payload = {
    notification: {
      // title: senderName,
      title: 'ຂໍ້ຄວາມໃໝ່',
      body: body
    },
    data: {
      chatId: chatId,
      messageId: messageId,
      senderId: senderId,
      type: 'chat_message',
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'chat_channel',
        sound: 'default',
        priority: 'high'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1
        }
      }
    }
  };
  
  const messaging = getMessaging();
  
  try {
    const response = await messaging.send({
      token: fcmToken,
      ...payload
    });
    console.log('Notification sent successfully:', response);
    return response;
  } catch (error) {
    console.error('Error sending notification:', error);
    return null;
  }
});
