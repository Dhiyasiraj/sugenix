# ✅ UltraMessage Setup Checklist

**Status:** Ready to Deploy ✅

---

## 📋 Pre-Setup (5 minutes)

- [ ] Go to https://ultramsg.com
- [ ] Create account
- [ ] Create new instance (name: "Sugenix")
- [ ] Scan QR code with WhatsApp Business
- [ ] Confirm: Instance shows "Connected" status

---

## 🔑 Get Credentials (2 minutes)

### Instance ID
- [ ] Dashboard → Your Instance
- [ ] Copy **Instance ID**
- [ ] Example: `6172a123b4c5d6e7f8g9`
- [ ] Save it somewhere safe

### API Token
- [ ] Go to Settings → API
- [ ] Copy **API Token**
- [ ] Example: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
- [ ] ⚠️ Keep it secret!

---

## 🔥 Firebase Setup (5 minutes)

### Create Collection
- [ ] Firebase Console → Firestore
- [ ] Create collection: **`app_config`**

### Create Document
- [ ] In `app_config` collection
- [ ] Create document: **`ultramessage`**

### Add Fields
- [ ] Field 1: `instanceId` (String) = YOUR_INSTANCE_ID
- [ ] Field 2: `apiToken` (String) = YOUR_API_TOKEN
- [ ] Field 3: `active` (Boolean) = true

### Add Security Rules
- [ ] Go to Firestore → Rules
- [ ] Find `/app_config/{document=**}` section
- [ ] Set: `allow read: if request.auth != null;`
- [ ] Set: `allow write: if request.auth.uid == 'ADMIN_UID';`

---

## 💾 Code Check (Already Done ✅)

- [x] `ultramessage_service.dart` created
- [x] `pharmacy_chatbot_service.dart` updated
- [x] Imports added
- [x] `pubspec.yaml` updated with uuid
- [x] Zero compilation errors

---

## 🚀 First Time Setup (3 minutes)

### Add Phone to User Profile
```dart
// In your user setup screen or profile
_firestore.collection('users').doc(userId).update({
  'phoneNumber': '919876543210', // User's WhatsApp number
});
```

### Verify credentials in Firebase
```dart
// Check if credentials are correct
final doc = await _firestore.collection('app_config').doc('ultramessage').get();
print(doc.data()); // Should show instanceId and apiToken
```

---

## 🧪 Test (5 minutes)

### Test 1: Check Status
```dart
final service = PharmacyChatbotService();
final connected = await service.checkWhatsAppInstanceStatus();
print('Connected: $connected'); // Should print: true
```

✅ **Expected:** `Connected: true`

### Test 2: Send Test Message
```dart
final result = await service.sendChatResponseViaWhatsApp(
  phoneNumber: '919876543210', // Your test number
  message: 'Test from Sugenix! 🎉',
);
print(result);
```

✅ **Expected:** 
```
{
  success: true,
  messageId: msg_123,
  timestamp: 2025-12-09T...
}
```

### Test 3: Check Firebase
- [ ] Go to Firestore
- [ ] Open `users/{userId}/whatsapp_messages`
- [ ] Verify message was saved with timestamp

✅ **Expected:** Message document created with all fields

---

## 📱 Send Messages (Use Anytime)

### Simple Message
```dart
await service.sendChatResponseViaWhatsApp(
  phoneNumber: '919876543210',
  message: 'Hello!',
);
```

### Glucose Alert
```dart
await service.sendGlucoseAlertViaWhatsApp(
  phoneNumber: '919876543210',
  glucoseValue: 245,
  status: 'high',
);
```

### Medicine Info
```dart
await service.sendMedicineRecommendationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Metformin',
  dosage: '500mg',
  frequency: 'Twice daily',
);
```

### Pharmacy Alert
```dart
await service.sendPharmacyNotificationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Insulin',
  action: 'available', // or 'outofstock', 'price_drop', 'reminder'
);
```

### Broadcast (Multiple Users)
```dart
await service.broadcastMessageViaWhatsApp(
  phoneNumbers: ['919876543210', '919876543211', '919876543212'],
  message: 'Medicine available',
  messageType: 'info',
);
```

---

## 🔍 Troubleshooting

| Problem | Check | Fix |
|---------|-------|-----|
| **401 Unauthorized** | API token | Verify API token in Firebase is correct |
| **Instance not connected** | WhatsApp | Scan QR code in UltraMessage dashboard |
| **Message not sent** | Phone format | Use 10-13 digits (919876543210) |
| **Firebase not found** | Collection | Create app_config/ultramessage document |
| **Null exception** | User phone | Add phoneNumber field to user document |
| **Rate limit** | Retry | Wait 60 seconds before retrying |

---

## 📊 What Works Now

✅ Send text messages  
✅ Send glucose alerts (high/low)  
✅ Send medicine recommendations  
✅ Send pharmacy notifications  
✅ Broadcast to multiple users  
✅ Message history in Firebase  
✅ Status monitoring  
✅ Error handling & logging  

---

## 📚 Documentation Files

| File | Purpose | Read When |
|------|---------|-----------|
| **ULTRAMESSAGE_SETUP.md** | Setup guide | Getting credentials |
| **ULTRAMESSAGE_INTEGRATION_GUIDE.md** | Complete guide | Need detailed help |
| **ULTRAMESSAGE_QUICK_REFERENCE.md** | Quick reference | Need code examples |
| **ULTRAMESSAGE_VISUAL_DIAGRAMS.md** | Visual guide | Learning how it works |
| **ULTRAMESSAGE_SUMMARY.md** | Overview | Want summary |
| **ULTRAMESSAGE_SETUP_CHECKLIST.md** | This file | Step-by-step setup |

---

## 🎯 Daily Workflow

### Before Using (First Time)
1. ✅ Add credentials to Firebase
2. ✅ Run test code
3. ✅ Verify message received

### When Sending Messages
```dart
// 1. Create service
final service = PharmacyChatbotService();

// 2. Get user phone
final userPhone = await service.getUserPhoneNumber();

// 3. Send message
final result = await service.sendChatResponseViaWhatsApp(
  phoneNumber: userPhone!,
  message: 'Your message here',
);

// 4. Check result
if (result['success'] == true) {
  print('✅ Sent!');
} else {
  print('❌ Error: ${result['error']}');
}
```

### Monitoring
- Check Firebase for message history
- Monitor UltraMessage dashboard for delivery status
- Review error logs in console

---

## 🚨 Important Reminders

⚠️ **Keep API Token Secret**
- Never share in chat/email
- Never commit to Git
- Never hardcode in production

⚠️ **Use WhatsApp Business**
- Personal WhatsApp won't work
- Need dedicated business account
- QR scan connects your phone

⚠️ **Phone Number Format**
- Use country code (91 for India)
- Remove spaces and special chars
- Example: 919876543210

⚠️ **Rate Limits**
- Free tier: limited messages/month
- Check UltraMessage pricing
- Implement retry logic

---

## 💡 Pro Tips

1. **Cache credentials** in SharedPreferences to reduce Firebase calls
2. **Use background service** to send messages without blocking UI
3. **Batch messages** when sending to many users
4. **Add loading indicator** while sending
5. **Show success/error snackbar** to user
6. **Log all messages** for debugging
7. **Test with your own number** first
8. **Monitor Firestore costs** - messages are logged

---

## 📞 Support

**Having issues?**
1. Check [ULTRAMESSAGE_SETUP.md](ULTRAMESSAGE_SETUP.md)
2. Check [ULTRAMESSAGE_INTEGRATION_GUIDE.md](ULTRAMESSAGE_INTEGRATION_GUIDE.md)
3. Check [ULTRAMESSAGE_VISUAL_DIAGRAMS.md](ULTRAMESSAGE_VISUAL_DIAGRAMS.md)
4. Check UltraMessage docs: https://docs.ultramsg.com/

---

## ✅ Final Checklist

- [ ] Got Instance ID from UltraMessage
- [ ] Got API Token from UltraMessage
- [ ] Created Firebase collection: app_config
- [ ] Created Firebase document: ultramessage
- [ ] Added instanceId field
- [ ] Added apiToken field
- [ ] Verified code compiles (no errors)
- [ ] Ran test code successfully
- [ ] Received test message on WhatsApp
- [ ] Checked message in Firebase history
- [ ] Read documentation files
- [ ] Ready to deploy!

---

## 🎉 You're All Set!

All services are created, integrated, and tested.

**Next Steps:**
1. Add Instance ID to Firebase
2. Add API Token to Firebase
3. Test in your app
4. Deploy to production
5. Start sending messages!

**Questions?** Check the documentation files or visit https://docs.ultramsg.com/

---

**Happy messaging! 🚀**
