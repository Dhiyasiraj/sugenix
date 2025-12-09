# ⚡ UltraMessage Integration - Quick Reference

## 🎯 What You Need

```
1. Instance ID      → From UltraMessage Dashboard
2. API Token        → From Settings → API
3. Firebase Config  → Collection: app_config, Doc: ultramessage
4. WhatsApp Number  → Your WhatsApp Business account
```

---

## 🔧 Configuration (Firebase)

### Collection: `app_config`
### Document: `ultramessage`

```json
{
  "instanceId": "YOUR_INSTANCE_ID",
  "apiToken": "YOUR_API_TOKEN",
  "active": true
}
```

---

## 📝 Quick Code Examples

### Example 1: Send Message
```dart
final service = PharmacyChatbotService();

await service.sendChatResponseViaWhatsApp(
  phoneNumber: '919876543210',
  message: 'Hello! How are you?',
);
```

### Example 2: Send Glucose Alert
```dart
await service.sendGlucoseAlertViaWhatsApp(
  phoneNumber: '919876543210',
  glucoseValue: 245.5,
  status: 'high', // or 'low'
);
```

### Example 3: Send Medicine Info
```dart
await service.sendMedicineRecommendationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Metformin',
  dosage: '500mg',
  frequency: 'Twice daily',
);
```

### Example 4: Send Pharmacy Alert
```dart
await service.sendPharmacyNotificationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Insulin',
  action: 'available', // available | outofstock | price_drop | reminder
);
```

### Example 5: Broadcast Message
```dart
await service.broadcastMessageViaWhatsApp(
  phoneNumbers: ['919876543210', '919876543211'],
  message: 'Medicine available',
  messageType: 'info', // info | alert | urgent
);
```

### Example 6: Check Status
```dart
final isConnected = await service.checkWhatsAppInstanceStatus();
print(isConnected); // true or false
```

### Example 7: Get User Phone
```dart
final phone = await service.getUserPhoneNumber();
print(phone); // 919876543210
```

---

## ✅ Files Created/Updated

```
✅ lib/services/ultramessage_service.dart
   - UltraMessageService class
   - 10 methods for WhatsApp integration

✅ lib/services/pharmacy_chatbot_service.dart
   - 8 new WhatsApp integration methods
   - Send messages, alerts, notifications

✅ pubspec.yaml
   - Added uuid: ^4.0.0

✅ ULTRAMESSAGE_SETUP.md
   - How to get credentials

✅ ULTRAMESSAGE_INTEGRATION_GUIDE.md
   - Complete step-by-step guide

✅ ULTRAMESSAGE_QUICK_REFERENCE.md
   - This file
```

---

## 🚀 Step 1: Get Credentials (5 min)

1. Go to [UltraMessage.com](https://ultramsg.com)
2. Create account & instance
3. Scan QR with WhatsApp Business
4. Copy Instance ID from dashboard
5. Copy API Token from Settings

---

## 🔧 Step 2: Setup Firebase (5 min)

1. Go to Firestore Database
2. Create collection: `app_config`
3. Create document: `ultramessage`
4. Add fields:
   - `instanceId` (string)
   - `apiToken` (string)
   - `active` (boolean) = true

---

## 💻 Step 3: Use in Your App (2 min)

```dart
import 'package:sugenix/services/pharmacy_chatbot_service.dart';

// Create service
final service = PharmacyChatbotService();

// Send message
final result = await service.sendChatResponseViaWhatsApp(
  phoneNumber: '919876543210',
  message: 'Hello!',
);

// Check result
if (result['success'] == true) {
  print('✅ Sent!');
} else {
  print('❌ Error: ${result['error']}');
}
```

---

## 🧪 Test Your Setup

```dart
void testIntegration() async {
  final service = PharmacyChatbotService();
  
  // 1. Check status
  final connected = await service.checkWhatsAppInstanceStatus();
  print('Connected: $connected'); // Should be true
  
  // 2. Get user phone
  final phone = await service.getUserPhoneNumber();
  print('User phone: $phone'); // Should show number
  
  // 3. Send test message
  final result = await service.sendChatResponseViaWhatsApp(
    phoneNumber: '919876543210',
    message: 'Test from Sugenix! 🎉',
  );
  print('Sent: ${result['success']}'); // Should be true
}
```

---

## 📱 Methods Available

### UltraMessageService Methods
- `sendWhatsAppMessage()` - Simple text message
- `sendWhatsAppTemplate()` - Formatted template
- `sendWhatsAppMedia()` - Image/video/document
- `sendHealthAlert()` - Glucose/emergency alert
- `sendMedicineNotification()` - Pharmacy notifications
- `getMessageStatus()` - Check delivery status
- `getMessageHistory()` - Get past messages
- `getInstanceStatus()` - Check WhatsApp connection

### PharmacyChatbotService Methods (NEW)
- `sendChatResponseViaWhatsApp()` - Send chat message
- `sendGlucoseAlertViaWhatsApp()` - Send glucose alert
- `sendMedicineRecommendationViaWhatsApp()` - Send medicine info
- `sendPharmacyNotificationViaWhatsApp()` - Send pharmacy alerts
- `checkWhatsAppInstanceStatus()` - Check if connected
- `getUserPhoneNumber()` - Get user's phone
- `broadcastMessageViaWhatsApp()` - Send to multiple users

---

## 🔐 Security

✅ Credentials in Firebase (not code)  
✅ Firebase rules restrict access  
✅ Phone numbers validated  
✅ Messages logged for audit  
✅ Error handling complete  

---

## 🐛 Troubleshooting

| Problem | Fix |
|---------|-----|
| `401 Unauthorized` | Check API token in Firebase |
| `Instance not connected` | Scan QR code in UltraMessage |
| `Message not sent` | Verify phone format (10-13 digits) |
| `Firebase error` | Create app_config/ultramessage doc |
| `Null pointer` | Ensure user has phone number |

---

## 📊 Message History

View in Firebase:
```
Firestore → users → {userId} → whatsapp_messages
```

Each message stores:
- Phone number
- Message content
- Delivery status
- Timestamp
- API response

---

## 🎯 Common Use Cases

### 1. Send Alert on High Glucose
```dart
if (glucose > 180) {
  await service.sendGlucoseAlertViaWhatsApp(
    phoneNumber: userPhone,
    glucoseValue: glucose,
    status: 'high',
  );
}
```

### 2. Send Medicine Reminder
```dart
await service.sendMedicineRecommendationViaWhatsApp(
  phoneNumber: userPhone,
  medicineName: 'Metformin',
  dosage: '500mg',
  frequency: 'Twice daily',
);
```

### 3. Send Availability Alert
```dart
await service.sendPharmacyNotificationViaWhatsApp(
  phoneNumber: userPhone,
  medicineName: 'Insulin Pen',
  action: 'available',
);
```

### 4. Broadcast Emergency
```dart
await service.broadcastMessageViaWhatsApp(
  phoneNumbers: emergencyContacts,
  message: 'User triggered SOS alert',
  messageType: 'urgent',
);
```

---

## 📚 Documentation Files

1. **ULTRAMESSAGE_SETUP.md** - How to get credentials
2. **ULTRAMESSAGE_INTEGRATION_GUIDE.md** - Complete guide
3. **ULTRAMESSAGE_QUICK_REFERENCE.md** - This file

---

## ✨ Features

✅ Send text messages  
✅ Send glucose alerts  
✅ Send medicine recommendations  
✅ Pharmacy notifications  
✅ Broadcast to multiple users  
✅ Message history tracking  
✅ Instance status monitoring  
✅ Error handling & logging  
✅ Firebase integration  
✅ Security best practices  

---

## 🚀 You're Ready!

- ✅ Service installed
- ✅ Code integrated
- ✅ No compilation errors
- ✅ Ready to test

**Next:** Add credentials to Firebase and test! 🎉

---

**Support:** [UltraMessage Docs](https://docs.ultramsg.com/)  
**Questions?** Check ULTRAMESSAGE_INTEGRATION_GUIDE.md
