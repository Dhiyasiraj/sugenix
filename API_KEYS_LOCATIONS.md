# API Keys - Exact File Locations

This document shows exactly where each API key needs to be configured.

---

## 1. Gemini API Key

### Option A: Firestore (Recommended)
**Location:** Firebase Console → Firestore Database
**Path:** Collection `app_config` → Document `gemini` → Field `apiKey`

**How to set:**
1. Open Firebase Console
2. Go to Firestore Database
3. Create/update document: `app_config/gemini`
4. Add field: `apiKey` (string) = `YOUR_GEMINI_API_KEY`

### Option B: Code
**File:** `lib/services/gemini_service.dart`
**Line:** 10
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**Current Status:** Empty string `''` - not configured

---

## 2. EmailJS Credentials

**File:** `lib/services/emailjs_service.dart`

**Lines to update:**
- **Line 12:** `static const String _serviceId = 'service_f6ka8jm';`
- **Line 13:** `static const String _templateId = 'template_u50mo7i';`
- **Line 14:** `static const String _publicKey = 'CHxG3ZYeXEUuvz1MA';`

**Replace with:**
```dart
static const String _serviceId = 'your_service_id_from_emailjs';
static const String _templateId = 'your_template_id_from_emailjs';
static const String _publicKey = 'your_public_key_from_emailjs';
```

**Current Status:** Placeholder values - need to replace with actual EmailJS credentials

**Is it working?** 
- ✅ Code is integrated correctly
- ✅ Called when admin approves pharmacy/doctor
- ⚠️ Will fail until you configure with your EmailJS credentials
- ⚠️ Errors are caught gracefully (approval still works, just email won't send)

---

## 3. Razorpay API Key

**File:** `lib/services/razorpay_service.dart`
**Line:** 41

**Current:**
```dart
static const String _keyId = 'rzp_test_1DP5mmOlF5G5ag'; // Dummy Test Key
```

**Replace with:**
```dart
static const String _keyId = 'rzp_test_YOUR_ACTUAL_KEY';
```

**Current Status:** Dummy test key - replace with your Razorpay test key

---

## 4. Ultramessage Credentials

### Option A: Firestore (Recommended)
**Location:** Firebase Console → Firestore Database
**Path:** Collection `app_config` → Document `ultramessage`

**Fields:**
- `instanceId` (string) = `YOUR_INSTANCE_ID`
- `apiToken` (string) = `YOUR_API_TOKEN`

### Option B: Code
**File:** `lib/services/ultramessage_service.dart`
**Lines:** 8-9

**Current:**
```dart
static const String _instanceId = 'YOUR_INSTANCE_ID';
static const String _apiToken = 'YOUR_API_TOKEN';
```

**Replace with:**
```dart
static const String _instanceId = 'your_instance_id';
static const String _apiToken = 'your_api_token';
```

**Current Status:** Placeholder values - not configured

---

## Summary Table

| API Key | File Location | Line(s) | Current Status | Priority |
|---------|---------------|---------|----------------|----------|
| **Gemini** | `lib/services/gemini_service.dart` | 10 | ❌ Empty | High |
| **EmailJS Service ID** | `lib/services/emailjs_service.dart` | 12 | ⚠️ Placeholder | Medium |
| **EmailJS Template ID** | `lib/services/emailjs_service.dart` | 13 | ⚠️ Placeholder | Medium |
| **EmailJS Public Key** | `lib/services/emailjs_service.dart` | 14 | ⚠️ Placeholder | Medium |
| **Razorpay Key** | `lib/services/razorpay_service.dart` | 41 | ⚠️ Dummy | High |
| **Ultramessage Instance ID** | `lib/services/ultramessage_service.dart` | 8 | ❌ Placeholder | Medium |
| **Ultramessage API Token** | `lib/services/ultramessage_service.dart` | 9 | ❌ Placeholder | Medium |

---

## EmailJS Service - Current Implementation

**Is EmailJS working?**
- ✅ **Code Integration:** Fully integrated and called correctly
- ✅ **Error Handling:** Wrapped in try-catch, won't break approval flow
- ⚠️ **Configuration:** Uses placeholder credentials, needs your actual EmailJS credentials

**When EmailJS is called:**
1. Admin clicks "Approve" on a pharmacy → `EmailJSService.sendApprovalEmail()` called
2. Admin clicks "Approve" on a doctor → `EmailJSService.sendApprovalEmail()` called
3. Admin clicks "Reject" → `EmailJSService.sendRejectionEmail()` called

**What happens if EmailJS fails:**
- Approval/rejection still succeeds (database is updated)
- Email just won't be sent
- Error is logged to console
- User sees "Email notification sent" message (even if it failed)

**To make it work:**
1. Get your EmailJS credentials from https://www.emailjs.com/
2. Update lines 12-14 in `lib/services/emailjs_service.dart`
3. Test by approving a pharmacy/doctor
4. Check console logs and EmailJS dashboard

