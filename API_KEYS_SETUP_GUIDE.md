# API Keys Setup Guide

This document lists all API keys and credentials needed for the Sugenix application.

## 1. Gemini API Key (Required for Prescription Upload & Medicine Scanner)

**Location:** `lib/services/gemini_service.dart` or Firestore collection `app_config/gemini`

**Status:** ⚠️ Currently NOT configured (causes "API key missing" error)

**Setup Options:**

### Option A: Store in Firestore (Recommended for Production)
1. Go to Firebase Console > Firestore Database
2. Create/update document: `app_config` → `gemini`
3. Add field: `apiKey` with your Gemini API key

### Option B: Set in Code
1. Open `lib/services/gemini_service.dart`
2. Replace line 10:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```

**How to Get API Key:**
1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy the generated key

**Current Status:** Empty - causes errors when using prescription upload or medicine scanner

---

## 2. EmailJS Credentials (Required for Admin Approval Emails)

**Location:** `lib/services/emailjs_service.dart` (lines 12-14)

**Status:** ⚠️ Partially configured - has placeholder values

**Current Configuration:**
```dart
static const String _serviceId = 'service_f6ka8jm'; // Replace with your Service ID
static const String _templateId = 'template_u50mo7i'; // Replace with your Template ID
static const String _publicKey = 'CHxG3ZYeXEUuvz1MA'; // Replace with your Public Key
```

**Setup Steps:**
1. Sign up at https://www.emailjs.com/
2. Create an Email Service:
   - Go to "Email Services"
   - Add service (Gmail, Outlook, etc.)
   - Connect your email account
   - Copy the Service ID
3. Create Email Template:
   - Go to "Email Templates"
   - Create a new template
   - Use these template variables:
     - `{{to_email}}` - Recipient email
     - `{{to_name}}` - Recipient name
     - `{{subject}}` - Email subject
     - `{{title}}` - Email title
     - `{{message}}` - Email message body
     - `{{app_name}}` - App name (Sugenix)
   - Copy the Template ID
4. Get Public Key:
   - Go to "Account" → "General"
   - Copy your Public Key (User ID)
5. Update `lib/services/emailjs_service.dart`:
   ```dart
   static const String _serviceId = 'your_service_id_here';
   static const String _templateId = 'your_template_id_here';
   static const String _publicKey = 'your_public_key_here';
   ```

**Current Status:** Uses placeholder values - emails may not work until replaced with actual credentials

**When It's Used:**
- ✅ When admin approves a pharmacy → sends approval email
- ✅ When admin rejects a pharmacy → sends rejection email
- ✅ When admin approves a doctor → sends approval email
- ✅ When admin rejects a doctor → sends rejection email

---

## 3. Razorpay API Key (Required for Online Payments)

**Location:** `lib/services/razorpay_service.dart` (line 41)

**Status:** ⚠️ Uses dummy test key

**Current Configuration:**
```dart
static const String _keyId = 'rzp_test_1DP5mmOlF5G5ag'; // Dummy Test Key
```

**Setup Steps:**
1. Sign up at https://razorpay.com/
2. Go to Dashboard → Settings → API Keys
3. Generate Test Keys (no KYC required for testing)
4. Copy the Key ID (starts with `rzp_test_`)
5. Update `lib/services/razorpay_service.dart`:
   ```dart
   static const String _keyId = 'rzp_test_YOUR_KEY_HERE';
   ```

**Current Status:** Uses placeholder dummy key - replace with your test key for payments to work

**For Production:**
- Complete Razorpay KYC verification
- Generate Live Keys
- Replace test key with live key

---

## 4. Ultramessage Credentials (Required for WhatsApp/Emergency Alerts)

**Location:** `lib/services/ultramessage_service.dart` (lines 8-9) or Firestore `app_config/ultramessage`

**Status:** ⚠️ NOT configured - uses placeholders

**Current Configuration:**
```dart
static const String _instanceId = 'YOUR_INSTANCE_ID';
static const String _apiToken = 'YOUR_API_TOKEN';
```

**Setup Options:**

### Option A: Store in Firestore (Recommended)
1. Go to Firebase Console > Firestore Database
2. Create/update document: `app_config` → `ultramessage`
3. Add fields:
   - `instanceId`: Your Ultramessage Instance ID
   - `apiToken`: Your Ultramessage API Token

### Option B: Set in Code
1. Open `lib/services/ultramessage_service.dart`
2. Replace lines 8-9:
   ```dart
   static const String _instanceId = 'your_instance_id_here';
   static const String _apiToken = 'your_api_token_here';
   ```

**How to Get Credentials:**
1. Sign up at https://ultramsg.com/
2. Create an instance
3. Get Instance ID and API Token from dashboard
4. Configure WhatsApp connection

**Current Status:** Not configured - emergency WhatsApp alerts won't work

**When It's Used:**
- ✅ Emergency SOS alerts → sends WhatsApp message to emergency contacts
- ✅ Health alerts → sends WhatsApp notifications

---

## Summary Checklist

| Service | Status | Required For | Priority |
|---------|--------|--------------|----------|
| **Gemini API** | ❌ Not configured | Prescription upload, Medicine scanner | High |
| **EmailJS** | ⚠️ Placeholder values | Admin approval emails | Medium |
| **Razorpay** | ⚠️ Dummy test key | Online payments | High |
| **Ultramessage** | ❌ Not configured | Emergency WhatsApp alerts | Medium |

---

## Quick Setup Priority

### For Immediate Functionality:
1. **Gemini API Key** - Fixes prescription upload and medicine scanner
2. **Razorpay Test Key** - Enables online payments
3. **EmailJS Credentials** - Enables admin approval emails
4. **Ultramessage Credentials** - Enables emergency WhatsApp alerts

---

## Testing After Setup

### Test Gemini API:
- Try uploading a prescription
- Try scanning a medicine image
- Should not show "API key missing" error

### Test EmailJS:
- Admin approves a pharmacy/doctor
- Check if approval email is sent
- Check EmailJS dashboard for sent emails

### Test Razorpay:
- Add items to cart
- Select "Online Payment"
- Try making a test payment

### Test Ultramessage:
- Set emergency contacts in profile
- Trigger emergency SOS alert
- Check if WhatsApp message is sent to contacts

