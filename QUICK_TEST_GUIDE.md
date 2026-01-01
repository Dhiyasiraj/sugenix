# 🚀 Quick Test Reference Card

## ✅ What's Working Now

### Both AI Features Are Ready:
1. **Scan Medicine** - Uses AI to read medicine labels
2. **Prescription Upload** - Uses AI to extract medicines from prescriptions

### AI Services Available:
- **Primary**: Hugging Face (Free, no API key needed)
- **Fallback**: Gemini AI (API Key: Configured ✅)

---

## 📱 How to Test

### 1️⃣ Scan Medicine
```
1. Open app → Navigate to "Medicine Scanner"
2. Click "Scan Medicine" button
3. Choose Camera or Gallery
4. Take/select photo of medicine label
5. Wait for AI processing (3-10 seconds)
6. View extracted information
```

**Expected Output:**
- Medicine Name
- Uses (what it treats)
- Side Effects
- Dosage information
- Price (if in pharmacy database)

---

### 2️⃣ Upload Prescription
```
1. Open app → Navigate to "Upload Prescription"
2. Click "Gallery" or "Camera"
3. Select/take photo of prescription
4. Click "Upload" button
5. Wait for AI analysis (5-15 seconds)
6. View detected medicines
```

**Expected Output:**
- List of medicines from prescription
- Availability status (in pharmacy or not)
- Prices for available medicines
- "Add to Cart" buttons

---

## 🎯 Test Images to Use

### Good Test Subjects:
- ✅ Medicine boxes with clear labels
- ✅ Printed prescriptions
- ✅ Well-lit photos
- ✅ Common medicines: Metformin, Paracetamol, Aspirin

### Avoid:
- ❌ Blurry images
- ❌ Handwritten prescriptions (harder to read)
- ❌ Dark/shadowy photos
- ❌ Torn or damaged labels

---

## 🔍 What to Look For

### Success Indicators:
1. ⏳ "Processing image with AI..." appears
2. 🔄 May show "Using alternative AI service..." (normal)
3. ✅ Medicine information displays
4. 🟢 "Add to Cart" appears if medicine is in stock

### Normal Behaviors:
- First scan may take 10-15 seconds (AI models "waking up")
- Subsequent scans are faster (2-5 seconds)
- May switch from Hugging Face to Gemini automatically
- Some medicines may not be in pharmacy database

---

## ⚠️ If Something Goes Wrong

| What You See | What It Means | What to Do |
|--------------|---------------|------------|
| "Using alternative AI service" | Hugging Face slow/down | ✅ Normal, wait for Gemini |
| "Both services unavailable" | Network or API issue | Check internet, retry |
| "Request timeout" | Slow connection | Wait, then retry |
| "Model is loading" | First time use | Wait 10 seconds, retry |
| Blank/wrong info | Poor image quality | Retake photo |

---

## 🎮 Testing Workflow

### Quick Test (5 minutes):
1. ✅ Scan 1 medicine → Verify info appears
2. ✅ Upload 1 prescription → Verify medicines detected
3. ✅ Try "Add to Cart" → Verify it works

### Full Test (15 minutes):
1. ✅ Scan 3 different medicines
2. ✅ Upload 2 different prescriptions
3. ✅ Test with poor quality image (verify error handling)
4. ✅ Test retry functionality
5. ✅ Check cart has correct items
6. ✅ Verify prescription history

---

## 📊 Success Checklist

### Medicine Scanner:
- [ ] Image uploads
- [ ] AI processes (shows loading)
- [ ] Medicine name extracted
- [ ] At least 2 fields shown (uses, side effects, etc.)
- [ ] Can add to cart (if available)

### Prescription Upload:
- [ ] Image uploads
- [ ] AI analyzes (shows loading)
- [ ] At least 1 medicine detected
- [ ] Medicines categorized (available/not available)
- [ ] Can view medicine details
- [ ] Prescription ID generated

---

## 💡 Pro Tips

1. **First Test**: Use a common medicine like Paracetamol or Metformin
2. **Lighting**: Natural daylight works best
3. **Distance**: Hold camera 6-8 inches from label
4. **Patience**: First scan takes longer (models loading)
5. **Retry**: If it fails, wait 5 seconds and try again

---

## 🆘 Emergency Troubleshooting

### App Won't Start:
```bash
flutter clean
flutter pub get
flutter run
```

### AI Not Working:
1. Check internet connection
2. Look at console for error messages
3. Verify Gemini API key in code (line 10 of gemini_service.dart)
4. Try again in 1 minute (models may be loading)

### Still Not Working:
- Check `AI_FEATURES_TEST_GUIDE.md` for detailed troubleshooting
- Look at Flutter console for specific error messages
- Verify Firebase is connected

---

## 📞 Quick Status Check

**Gemini API**: ✅ Configured  
**Hugging Face**: ✅ Ready (no key needed)  
**Fallback Logic**: ✅ Implemented  
**Error Handling**: ✅ Improved  
**Image Processing**: ✅ Optimized  

**Status**: 🟢 READY TO TEST

---

**Remember**: The AI features will work! If one service is slow, the app automatically tries the other. Just be patient on the first scan (10-15 seconds), then it gets faster.

Good luck! 🚀
