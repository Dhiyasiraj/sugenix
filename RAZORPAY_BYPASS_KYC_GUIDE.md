# How to Get Razorpay Test Keys WITHOUT KYC

If Razorpay is redirecting you to KYC when you sign in, follow these steps to bypass it and get test keys:

## 🎯 Quick Method (Direct Link)

**Just go directly to this URL** (after signing up/logging in):
```
https://dashboard.razorpay.com/app/keys
```

This bypasses the main dashboard and takes you straight to the API keys page.

---

## 📋 Step-by-Step Guide

### Step 1: Sign Up
1. Go to: https://razorpay.com/
2. Click "Sign Up"
3. Enter your email and create password
4. Verify your email

### Step 2: Skip KYC (If Popup Appears)

When you log in, if a KYC popup appears:

**Option A: Close the Popup**
- Look for an "X" button in the top-right corner of the popup
- Click "Skip" or "Do it later" if available
- Click outside the popup to close it

**Option B: Use Direct Link**
- Don't click anywhere on the popup
- Go directly to: https://dashboard.razorpay.com/app/keys
- This bypasses the KYC prompt

**Option C: Browser Back**
- If popup appears, use browser back button
- Then manually navigate to: https://dashboard.razorpay.com/app/keys

### Step 3: Ensure Test Mode is ON

1. Once on the API Keys page, look at the **top right corner**
2. You should see a toggle that says "Test Mode" or "Live Mode"
3. **Make sure "Test Mode" is selected** (should be highlighted/active)

### Step 4: Generate Test Keys

1. Look for a button that says **"Generate Test Key"** or **"Generate Keys"**
2. Click it
3. A popup will show:
   - **Key ID** (starts with `rzp_test_`)
   - **Key Secret** (starts with `key_`)
4. **IMPORTANT:** Copy the Key ID immediately (Secret is only shown once)
5. Copy the Key ID

### Step 5: Update Your Code

1. Open: `lib/services/razorpay_service.dart`
2. Find line 53 (or search for `_keyId`)
3. Replace:
   ```dart
   static const String _keyId = 'rzp_test_1DP5mmOlF5G5ag';
   ```
   With:
   ```dart
   static const String _keyId = 'rzp_test_YOUR_ACTUAL_KEY_HERE';
   ```
4. Paste your actual Key ID

---

## 🔑 Current Dummy Key

The code currently uses a dummy test key:
```
rzp_test_1DP5mmOlF5G5ag
```

**This is NOT a real key** - it's just a placeholder format. It will:
- ✅ Allow the app to run without crashing
- ✅ Pass validation checks
- ❌ **NOT work for actual payments** - Razorpay will reject it

You **MUST replace it** with your own test key from Razorpay dashboard for payments to work.

---

## ⚠️ Common Issues

### Issue 1: "KYC Required" Popup Keeps Appearing
**Solution:**
- Use the direct link: https://dashboard.razorpay.com/app/keys
- Don't interact with the popup - just navigate directly

### Issue 2: Can't Find "Generate Test Key" Button
**Solution:**
- Make sure you're in **Test Mode** (toggle at top right)
- If you see "Live Mode", switch to "Test Mode"
- Refresh the page

### Issue 3: Keys Already Generated
**Solution:**
- If you already generated keys, they should be visible on the page
- Look for "Key ID" - it should start with `rzp_test_`
- Copy that Key ID

### Issue 4: Dashboard Redirects to KYC
**Solution:**
- Don't use the main dashboard
- Use the direct API keys link: https://dashboard.razorpay.com/app/keys
- This bypasses most KYC prompts

---

## ✅ Verification

After updating the code with your test key:

1. Run the app
2. Try to place an order and select "Online Payment"
3. Use test card: `4111 1111 1111 1111`
4. If payment dialog opens, your key is working!

---

## 📝 Test Card Numbers

Once your key is configured, use these for testing:

**Success Card:**
- Number: `4111 1111 1111 1111`
- CVV: Any 3 digits (e.g., `123`)
- Expiry: Any future date (e.g., `12/25`)
- Name: Any name

**Failure Card:**
- Number: `4000 0000 0000 0002`
- (To test error handling)

---

## 🆘 Still Having Issues?

If you still can't get test keys:

1. **Contact Razorpay Support:**
   - Email: support@razorpay.com
   - Tell them: "I need test API keys for development, KYC is blocking me"

2. **Use COD Only:**
   - The app works with Cash on Delivery
   - You can test the app without online payments

3. **Check Console Logs:**
   - When payment fails, check the error message
   - It will tell you if the key is invalid

---

## 🎯 Key Points

- ✅ Test keys **DO NOT require KYC**
- ✅ Use direct link to bypass KYC prompts: https://dashboard.razorpay.com/app/keys
- ✅ Make sure "Test Mode" is ON
- ✅ Current dummy key won't work for payments - you need your own
- ✅ COD payments work without any Razorpay configuration

