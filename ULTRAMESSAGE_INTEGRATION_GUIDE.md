# 📱 UltraMessage WhatsApp Integration Guide

## 🎯 Complete Step-by-Step Process

---

## **STEP 1: Get UltraMessage Account & Credentials**

### 1.1 Sign Up for UltraMessage
- Go to [UltraMessage.com](https://ultramsg.com)
- Click "Get Started" or "Sign Up"
- Create account (use email)
- Verify email

### 1.2 Create Instance
- Dashboard → Click "Create Instance"
- Choose a name (e.g., "Sugenix-Diabetes-Bot")
- Confirm

### 1.3 Connect WhatsApp Business Account
- Dashboard → Your Instance
- Scan QR code with WhatsApp Business (not personal)
- Confirm in WhatsApp
- Wait for "Connected" status

### 1.4 Get Instance ID
- Dashboard → Your Instance
- Copy **Instance ID** from overview
- Format: Usually alphanumeric string

### 1.5 Get API Token
- Settings → API
- Copy **API Token**
- Keep it secret! ⚠️

---

## **STEP 2: Configure Firebase**

### 2.1 Create Firestore Collection
1. Firebase Console → Firestore Database
2. Create collection: `app_config`
3. Create document: `ultramessage`

### 2.2 Add Fields to Document

| Field | Type | Value |
|-------|------|-------|
| `instanceId` | String | YOUR_INSTANCE_ID |
| `apiToken` | String | YOUR_API_TOKEN |
| `active` | Boolean | true |
| `createdAt` | Timestamp | Auto |

### 2.3 Add Firestore Rules

Go to Firestore → Rules → Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // App config - read by all auth users
    match /app_config/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == 'YOUR_ADMIN_UID';
    }
    
    // WhatsApp messages - user private
    match /users/{userId}/whatsapp_messages/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Pharmacy chats
    match /users/{userId}/pharmacy_chats/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## **STEP 3: Install in Your App**

### 3.1 Update pubspec.yaml ✅ (ALREADY DONE)
```yaml
dependencies:
  http: ^1.1.0
  uuid: ^4.0.0
```

### 3.2 Files Created ✅ (ALREADY DONE)
- `lib/services/ultramessage_service.dart` - Main service
- `lib/services/pharmacy_chatbot_service.dart` - Updated with WhatsApp integration
- `ULTRAMESSAGE_SETUP.md` - Setup guide

---

## **STEP 4: Use in Your Code**

### 4.1 Import Service
```dart
import 'package:sugenix/services/pharmacy_chatbot_service.dart';
import 'package:sugenix/services/ultramessage_service.dart';
```

### 4.2 Basic Usage Examples

#### **Send Simple Message**
```dart
final service = PharmacyChatbotService();

final result = await service.sendChatResponseViaWhatsApp(
  phoneNumber: '919876543210',
  message: 'Hello! Your glucose reading is being checked.',
);

if (result['success'] == true) {
  print('Message sent! ID: ${result['messageId']}');
} else {
  print('Error: ${result['error']}');
}
```

#### **Send Glucose Alert**
```dart
final result = await service.sendGlucoseAlertViaWhatsApp(
  phoneNumber: '919876543210',
  glucoseValue: 245.5,
  status: 'high', // or 'low'
);

print(result);
```

#### **Send Medicine Recommendation**
```dart
final result = await service.sendMedicineRecommendationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Metformin',
  dosage: '500mg',
  frequency: 'Twice daily',
);

print(result);
```

#### **Send Pharmacy Notification**
```dart
// Medicine available
await service.sendPharmacyNotificationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Insulin Pen',
  action: 'available', // available, outofstock, price_drop, reminder
);

// Price drop
await service.sendPharmacyNotificationViaWhatsApp(
  phoneNumber: '919876543210',
  medicineName: 'Metformin',
  action: 'price_drop',
);
```

#### **Check WhatsApp Status**
```dart
final isConnected = await service.checkWhatsAppInstanceStatus();

if (isConnected) {
  print('✅ WhatsApp is connected and ready!');
} else {
  print('❌ WhatsApp not connected. Scan QR code.');
}
```

#### **Get User's Phone Number**
```dart
final phoneNumber = await service.getUserPhoneNumber();

if (phoneNumber != null) {
  print('User phone: $phoneNumber');
  
  // Send message to user
  await service.sendChatResponseViaWhatsApp(
    phoneNumber: phoneNumber,
    message: 'Hello user!',
  );
}
```

#### **Broadcast to Multiple Users**
```dart
final result = await service.broadcastMessageViaWhatsApp(
  phoneNumbers: [
    '919876543210',
    '919876543211',
    '919876543212',
  ],
  message: 'Medicine Metformin is now available',
  messageType: 'info', // info, alert, urgent
);

print('Success: ${result['successCount']}');
print('Failed: ${result['failureCount']}');
```

### 4.3 Full Example: Send Alert on High Glucose

```dart
Future<void> handleHighGlucose(double glucoseValue, String phoneNumber) async {
  final service = PharmacyChatbotService();
  
  // 1. Send alert via WhatsApp
  final alertResult = await service.sendGlucoseAlertViaWhatsApp(
    phoneNumber: phoneNumber,
    glucoseValue: glucoseValue,
    status: 'high',
  );
  
  if (alertResult['success'] != true) {
    print('Alert failed: ${alertResult['error']}');
    return;
  }
  
  // 2. Get medicine recommendations
  final recommendations = await service.getDiabeticMedicineRecommendations();
  
  // 3. Send recommendations via WhatsApp
  await service.sendChatResponseViaWhatsApp(
    phoneNumber: phoneNumber,
    message: recommendations,
  );
  
  // 4. Check WhatsApp status
  final isConnected = await service.checkWhatsAppInstanceStatus();
  print('WhatsApp Connected: $isConnected');
}
```

---

## **STEP 5: Integration in Different Screens**

### 5.1 In Pharmacy Chatbot Screen

```dart
// In pharmacy_chatbot_screen.dart

import 'package:sugenix/services/pharmacy_chatbot_service.dart';

// Send response via WhatsApp after chat
Future<void> _sendViaWhatsApp(String message) async {
  final service = PharmacyChatbotService();
  
  final userPhone = await service.getUserPhoneNumber();
  
  if (userPhone != null) {
    final result = await service.sendChatResponseViaWhatsApp(
      phoneNumber: userPhone,
      message: message,
    );
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Sent via WhatsApp!')),
      );
    }
  }
}
```

### 5.2 In Glucose Monitor Screen

```dart
// When glucose reading is high/low
void _checkGlucoseLevel(double value) async {
  final service = PharmacyChatbotService();
  final userPhone = await service.getUserPhoneNumber();
  
  if (value > 180) {
    // High glucose
    await service.sendGlucoseAlertViaWhatsApp(
      phoneNumber: userPhone!,
      glucoseValue: value,
      status: 'high',
    );
  } else if (value < 70) {
    // Low glucose
    await service.sendGlucoseAlertViaWhatsApp(
      phoneNumber: userPhone!,
      glucoseValue: value,
      status: 'low',
    );
  }
}
```

### 5.3 In Emergency/SOS Screen

```dart
// lib/screens/sos_alert_screen.dart
import 'package:sugenix/services/pharmacy_chatbot_service.dart';

Future<void> triggerEmergency() async {
  final service = PharmacyChatbotService();
  final userPhone = await service.getUserPhoneNumber();
  
  if (userPhone != null) {
    await service.sendChatResponseViaWhatsApp(
      phoneNumber: userPhone,
      message: '🆘 EMERGENCY ALERT\n\nYou triggered SOS alert.\nEmergency contacts notified.\nHelp on the way!',
    );
  }
}
```

---

## **STEP 6: Test Everything**

### 6.1 Test Message Sending
```dart
void testWhatsAppIntegration() async {
  final service = PharmacyChatbotService();
  
  print('1. Checking instance status...');
  final connected = await service.checkWhatsAppInstanceStatus();
  print('Connected: $connected');
  
  print('\n2. Sending test message...');
  final result = await service.sendChatResponseViaWhatsApp(
    phoneNumber: '919876543210', // Your test number
    message: 'Test message from Sugenix 🎉',
  );
  print('Result: $result');
  
  print('\n3. Checking user phone...');
  final phone = await service.getUserPhoneNumber();
  print('User phone: $phone');
}

// Call in main or initState
testWhatsAppIntegration();
```

### 6.2 Monitor Message History
```dart
// Get all sent messages
final service = PharmacyChatbotService();
final messages = await UltraMessageService().getMessageHistory();

for (var msg in messages) {
  print('To: ${msg['phoneNumber']}');
  print('Message: ${msg['message']}');
  print('Status: ${msg['status']}');
  print('---');
}
```

---

## **STEP 7: Add to UI (Optional)**

### 7.1 Add WhatsApp Send Button to Chat

```dart
// In pharmacy_chatbot_screen.dart

FloatingActionButton(
  onPressed: () => _sendLatestMessageViaWhatsApp(),
  tooltip: 'Send via WhatsApp',
  child: Icon(Icons.message),
),

Future<void> _sendLatestMessageViaWhatsApp() async {
  if (_messages.isEmpty) return;
  
  final lastMessage = _messages.last;
  final service = PharmacyChatbotService();
  
  final result = await service.sendChatResponseViaWhatsApp(
    phoneNumber: await service.getUserPhoneNumber() ?? '',
    message: lastMessage['content'],
  );
  
  if (result['success'] == true) {
    _showSuccessSnackBar('✅ Sent to WhatsApp');
  } else {
    _showErrorSnackBar('❌ ${result['error']}');
  }
}
```

### 7.2 Add WhatsApp Status Indicator

```dart
// Show WhatsApp connection status in app bar
StreamBuilder<bool>(
  stream: _whatsappStatusStream(),
  builder: (context, snapshot) {
    final connected = snapshot.data ?? false;
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: connected ? Colors.green : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.whatsapp, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              connected ? 'WhatsApp Connected' : 'Offline',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  },
)

Stream<bool> _whatsappStatusStream() async* {
  while (true) {
    final service = PharmacyChatbotService();
    final status = await service.checkWhatsAppInstanceStatus();
    yield status;
    await Future.delayed(Duration(seconds: 30));
  }
}
```

---

## **STEP 8: Troubleshooting**

| Issue | Solution |
|-------|----------|
| **401 Unauthorized** | Check API token in Firebase config |
| **Instance not connected** | Scan QR code in UltraMessage dashboard |
| **Message not sent** | Verify phone number format (10-13 digits) |
| **Firebase not found** | Create `app_config/ultramessage` document |
| **Null exception** | Ensure user has phone number in profile |
| **Rate limit** | Wait 60 seconds before retrying |
| **Service returns null** | Check Firebase rules are correct |

---

## **STEP 9: Security Checklist**

- ✅ API token stored in Firebase (not in code)
- ✅ Firebase rules restrict write access to admin only
- ✅ Phone numbers validated before sending
- ✅ Messages logged to Firebase for audit
- ✅ Rate limiting implemented
- ✅ Error handling comprehensive
- ✅ No hardcoded credentials

---

## **STEP 10: Monitor & Logs**

### View Message History in Firebase
```
Firestore → users → {userId} → whatsapp_messages
```

Each message has:
- `phoneNumber` - Recipient
- `message` - Content sent
- `status` - sent/failed
- `timestamp` - When sent
- `responseData` - API response

---

## **📊 Summary: What You Get**

✅ **Send messages to users** via WhatsApp  
✅ **Glucose alerts** (high/low)  
✅ **Medicine recommendations** with details  
✅ **Pharmacy notifications** (available, price drop)  
✅ **Broadcast messages** to multiple users  
✅ **Message history** in Firebase  
✅ **Instance status** monitoring  
✅ **Error handling** and logging  

---

## **🚀 Next Steps**

1. ✅ Add credentials to Firebase
2. ✅ Run tests in your app
3. ✅ Add WhatsApp buttons to UI
4. ✅ Deploy to production
5. ✅ Monitor message delivery
6. ✅ Get user feedback

**You're all set!** 🎉

For support: [UltraMessage Docs](https://docs.ultramsg.com/)
