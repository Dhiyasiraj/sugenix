# 🔧 UltraMessage Configuration in Firebase

## 1️⃣ Create Firestore Collection: `app_config`

### Document ID: `ultramessage`

Add the following fields:

```json
{
  "instanceId": "YOUR_INSTANCE_ID",
  "apiToken": "YOUR_API_TOKEN",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "active": true
}
```

---

## 2️⃣ How to Get Your Credentials from UltraMessage

### A. Get Instance ID:
1. Go to [UltraMessage Dashboard](https://ultramsg.com/dashboard)
2. Log in or sign up
3. Create a new instance or select existing one
4. Your Instance ID appears in the URL: `https://ultramsg.com/instance/{YOUR_INSTANCE_ID}/`
5. Also visible in dashboard overview

### B. Get API Token:
1. Go to Settings → API
2. Copy your API Token (long alphanumeric string)
3. Keep it private and secure

### C. Connect WhatsApp:
1. Scan QR code with WhatsApp Business
2. Instance status changes to "connected"
3. You're ready to send messages!

---

## 3️⃣ Firestore Security Rules

Add this rule to allow authenticated users to read config:

```javascript
match /app_config/{document=**} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == 'ADMIN_UID';
}

match /users/{userId}/whatsapp_messages/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 4️⃣ Firebase Setup Steps

### Step A: Create Collection
1. Go to Firestore Database
2. Create collection: `app_config`
3. Create document: `ultramessage`

### Step B: Add Fields (Document)

| Field | Type | Value |
|-------|------|-------|
| `instanceId` | String | YOUR_INSTANCE_ID |
| `apiToken` | String | YOUR_API_TOKEN |
| `active` | Boolean | true |

### Step C: Save

Done! Your service will automatically fetch these credentials.

---

## 5️⃣ Alternative: Hardcoded Credentials (Development Only)

In `ultramessage_service.dart`, line 10-11:

```dart
static const String _instanceId = 'YOUR_INSTANCE_ID';
static const String _apiToken = 'YOUR_API_TOKEN';
```

**⚠️ WARNING**: Do NOT hardcode in production. Use Firebase config.

---

## 6️⃣ Test Your Setup

Run this in your app:

```dart
final service = UltraMessageService();

// Check instance status
final status = await service.getInstanceStatus();
print(status); // Should show connected: true

// Send test message
final result = await service.sendWhatsAppMessage(
  to: '919876543210', // Replace with test number
  message: 'Test message from Sugenix! 🎉'
);
print(result);
```

---

## 7️⃣ Troubleshooting

| Problem | Solution |
|---------|----------|
| `instanceId not found` | Check Firestore has correct ID |
| `Invalid API token` | Verify token in UltraMessage dashboard |
| `Instance not connected` | Scan QR code to connect WhatsApp |
| `Message not sent` | Check phone number format (10-13 digits) |
| `401 Unauthorized` | API token expired or incorrect |

---

## 8️⃣ Security Best Practices

✅ **DO:**
- Store credentials in Firestore (not code)
- Use environment variables for local dev
- Enable Firestore security rules
- Rotate API tokens regularly
- Validate phone numbers before sending

❌ **DON'T:**
- Hardcode credentials in production
- Share API tokens publicly
- Send unsolicited messages
- Store plain text passwords
- Commit `.env` files

---

## 9️⃣ Rate Limits

- Default: 10,000 messages/month
- Premium: Unlimited
- Retry: After 60 seconds on failure
- Batch: Max 100 messages per request

---

## API Documentation

- **Docs**: https://docs.ultramsg.com/
- **Status**: https://status.ultramsg.com/
- **Support**: support@ultramsg.com

