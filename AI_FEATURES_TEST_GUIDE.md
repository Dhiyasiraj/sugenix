# AI Features Testing Guide

## Overview
This guide will help you test the **Scan Medicine** and **Prescription Upload** features that use AI to extract and analyze medicine information.

---

## ✅ What's Been Fixed

### 1. **Gemini AI Service** (Primary Fallback)
- ✅ Updated to **Gemini 1.5 Flash** (stable, fast model)
- ✅ Fixed JSON field names (`inlineData`, `mimeType`)
- ✅ Added automatic retry with exponential backoff
- ✅ API Key configured: `AIzaSyAPQr6I9Q1dIC6_Q-L3I3xlULH5sE3fYfs`

### 2. **Hugging Face Service** (Primary AI)
- ✅ Updated to send **raw image bytes** (better OCR accuracy)
- ✅ Using `microsoft/trocr-base-printed` for OCR
- ✅ Using `Mistral-7B-Instruct-v0.2` for text analysis
- ✅ Automatic fallback to Gemini if it fails

### 3. **Smart Fallback Logic**
- ✅ Medicine Scanner: Always tries Gemini if Hugging Face fails
- ✅ Prescription Upload: Always tries Gemini if Hugging Face fails
- ✅ Clear error messages for users
- ✅ Handles model loading delays (503 errors)

---

## 🧪 Testing Steps

### Test 1: Scan Medicine Feature

1. **Launch the App**
   ```bash
   flutter run
   ```

2. **Navigate to Medicine Scanner**
   - Go to the main menu
   - Tap on "Scan Medicine" or "Medicine Scanner"

3. **Take/Upload a Photo**
   - Click "Scan Medicine" button
   - Choose Camera or Gallery
   - Take a clear photo of a medicine label (ensure text is visible)
   - Good test medicines: Metformin, Paracetamol, Aspirin

4. **Expected Behavior**
   - ⏳ Shows "Processing image with AI..." message
   - 🔄 If Hugging Face is slow: Shows "Using alternative AI service..."
   - ✅ Displays medicine information:
     - Medicine Name
     - Manufacturer
     - Active Ingredients
     - Uses (list)
     - Side Effects (list)
     - Dosage
     - Precautions
   - 🟢 If available in pharmacy: Shows "Add to Cart" button
   - 🟠 If not available: Shows "Not Available in Pharmacy" message

5. **Possible Issues & Solutions**

   | Issue | Cause | Solution |
   |-------|-------|----------|
   | "Both AI services failed" | Poor image quality | Retake photo with better lighting |
   | "Request timeout" | Slow internet | Check connection, retry |
   | "Model is loading" | First time use | Wait 10 seconds, retry |
   | Blank information | Text not readable | Ensure label is clear and in focus |

---

### Test 2: Prescription Upload Feature

1. **Navigate to Prescription Upload**
   - Go to main menu
   - Tap "Upload Prescription"

2. **Add Prescription Images**
   - Click "Gallery" or "Camera"
   - Select/take photo of prescription
   - Can add multiple images
   - Click "Upload"

3. **Expected Behavior**
   - ⏳ Shows "Analyzing prescription with AI..."
   - 🔄 If Hugging Face fails: Shows "Using alternative AI service for prescription analysis..."
   - ✅ Displays:
     - "Prescription uploaded successfully"
     - List of medicines found
     - Separated into:
       - **Available in Pharmacy** (green, with price and "Add to Cart")
       - **Not Available in Pharmacy** (orange, with estimated info)

4. **Possible Issues & Solutions**

   | Issue | Cause | Solution |
   |-------|-------|----------|
   | "AI analysis failed - both services unavailable" | Network issue | Check internet, prescription still uploaded |
   | No medicines detected | Handwriting unclear | Use typed/printed prescriptions |
   | Wrong medicine names | Poor OCR | Verify manually, use catalog search |

---

## 📊 Success Criteria

### Medicine Scanner ✅
- [ ] Image uploads successfully
- [ ] AI processes the image (shows loading)
- [ ] Medicine name is extracted
- [ ] At least one of: uses, side effects, or ingredients is shown
- [ ] If in pharmacy DB: Shows price and "Add to Cart"
- [ ] If not in pharmacy: Shows "Not Available" message

### Prescription Upload ✅
- [ ] Images upload successfully
- [ ] AI analyzes prescription (shows loading)
- [ ] At least one medicine is detected
- [ ] Medicines are categorized (available/not available)
- [ ] Can navigate to medicine catalog
- [ ] Prescription ID is generated

---

## 🔧 Troubleshooting

### If Both AI Services Fail:

1. **Check Internet Connection**
   ```bash
   ping google.com
   ```

2. **Verify Gemini API Key**
   - Key is in: `lib/services/gemini_service.dart` line 10
   - Current key: `AIzaSyAPQr6I9Q1dIC6_Q-L3I3xlULH5sE3fYfs`
   - Test at: https://aistudio.google.com/

3. **Check Console Logs**
   - Look for error messages in terminal
   - Common errors:
     - `401`: API key invalid
     - `429`: Rate limit exceeded
     - `503`: Model loading (wait and retry)
     - `timeout`: Network slow

4. **Test Gemini API Directly**
   - Visit: https://aistudio.google.com/app/apikey
   - Verify your API key is active
   - Check quota limits

### If Only Hugging Face Fails:
- ✅ This is NORMAL - app will use Gemini automatically
- You'll see: "Using alternative AI service..."
- No action needed

### If Only Gemini Fails:
- Check API key is correct
- Verify internet connection
- Check if quota exceeded at: https://console.cloud.google.com/

---

## 📱 Testing Checklist

### Before Testing:
- [ ] Flutter app builds without errors
- [ ] Internet connection is active
- [ ] Firebase is connected
- [ ] Have test medicine images ready

### During Testing:
- [ ] Test with good quality images
- [ ] Test with poor quality images (to see fallback)
- [ ] Test with multiple prescriptions
- [ ] Test "Add to Cart" functionality
- [ ] Test retry on failure

### After Testing:
- [ ] Verify data saved to Firebase (if applicable)
- [ ] Check cart has correct items
- [ ] Verify prescription history shows uploaded items

---

## 🎯 Expected Results

### Scenario 1: Perfect Conditions
- ✅ Hugging Face processes image in 3-5 seconds
- ✅ Medicine info displayed accurately
- ✅ Can add to cart if available

### Scenario 2: Hugging Face Slow/Down
- ⏳ Hugging Face takes >10 seconds or fails
- 🔄 App shows "Using alternative AI service..."
- ✅ Gemini processes image in 2-4 seconds
- ✅ Medicine info displayed accurately

### Scenario 3: Both Services Fail
- ❌ Shows error message
- 🔄 Provides "Retry" button
- 📝 For prescriptions: Upload succeeds, analysis skipped

---

## 📞 Support

If you encounter persistent issues:

1. **Check Error Messages**: Read the exact error shown in the app
2. **Console Logs**: Look at Flutter console for detailed errors
3. **API Status**: 
   - Gemini: https://status.cloud.google.com/
   - Hugging Face: https://status.huggingface.co/

---

## 🚀 Quick Test Commands

```bash
# Run the app
flutter run

# Run with verbose logging
flutter run -v

# Clear cache and rebuild
flutter clean
flutter pub get
flutter run

# Check for issues
flutter doctor
```

---

## ✨ Tips for Best Results

1. **Image Quality**:
   - Use good lighting
   - Keep camera steady
   - Ensure text is in focus
   - Avoid glare on packaging

2. **Prescription Photos**:
   - Capture full prescription
   - Ensure doctor's handwriting is clear
   - Use flash if needed
   - Take multiple angles if unclear

3. **Network**:
   - Use stable WiFi for first test
   - AI models may take 5-10 seconds first time
   - Subsequent requests are faster

4. **Retry Strategy**:
   - If it fails once, wait 5 seconds and retry
   - Models may be "waking up" on first use
   - Second attempt usually succeeds

---

**Last Updated**: 2026-01-01
**Status**: ✅ Ready for Testing
