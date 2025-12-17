# API Keys Quick Reference

## 🔑 All API Keys That Need Configuration

### 1. Gemini API Key
**File:** `lib/services/gemini_service.dart` OR Firestore: `app_config/gemini` → `apiKey`
**Status:** ❌ Not configured
**Used For:** Prescription upload, Medicine scanner
**Get It:** https://makersuite.google.com/app/apikey

### 2. EmailJS Credentials
**File:** `lib/services/emailjs_service.dart` (lines 12-14)
**Status:** ⚠️ Placeholder values (need to replace)
**Used For:** Admin approval emails (pharmacy & doctor)
**Get It:** https://www.emailjs.com/

**Current Values:**
- Service ID: `service_f6ka8jm` ← Replace
- Template ID: `template_u50mo7i` ← Replace
- Public Key: `CHxG3ZYeXEUuvz1MA` ← Replace

### 3. Razorpay Test Key
**File:** `lib/services/razorpay_service.dart` (line 41)
**Status:** ⚠️ Dummy test key (should replace)
**Used For:** Online payment processing
**Get It:** https://dashboard.razorpay.com/app/keys

**Current Value:**
- Key ID: `rzp_test_1DP5mmOlF5G5ag` ← Replace with your test key

### 4. Ultramessage Credentials
**File:** `lib/services/ultramessage_service.dart` (lines 8-9) OR Firestore: `app_config/ultramessage`
**Status:** ❌ Not configured (placeholders)
**Used For:** WhatsApp emergency alerts
**Get It:** https://ultramsg.com/

**Current Values:**
- Instance ID: `YOUR_INSTANCE_ID` ← Replace
- API Token: `YOUR_API_TOKEN` ← Replace

---

## ✅ EmailJS Service Status

**EmailJS is integrated and will be called when:**
- Admin approves a pharmacy → Sends approval email
- Admin rejects a pharmacy → Sends rejection email
- Admin approves a doctor → Sends approval email
- Admin rejects a doctor → Sends rejection email

**Current Status:** ⚠️ Uses placeholder credentials, so emails may fail until you configure with your actual EmailJS credentials.

**How to verify it's working:**
1. Configure EmailJS credentials (see API_KEYS_SETUP_GUIDE.md)
2. Admin approves a pharmacy/doctor
3. Check console logs for "✅ Approval email sent successfully"
4. Check recipient's email inbox
5. Check EmailJS dashboard → Email Logs for sent emails

