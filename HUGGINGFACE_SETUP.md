# Hugging Face AI Integration Guide

## Overview

The app now uses **Hugging Face Inference API** instead of Gemini for:
- ✅ **Scan Medicine** feature
- ✅ **Prescription Upload** feature

Hugging Face provides **free access** to AI models without requiring billing setup.

---

## How It Works

### Free Tier (No API Key Required)
- Works immediately without any configuration
- Uses public Hugging Face models
- Rate limits apply (but sufficient for testing)

### Optional: Get API Token for Higher Limits
1. Sign up at: https://huggingface.co/join
2. Go to: https://huggingface.co/settings/tokens
3. Create a new token (read access is enough)
4. Add to Firestore:
   - Collection: `app_config`
   - Document: `huggingface`
   - Field: `apiToken` (string) = `YOUR_TOKEN_HERE`

---

## Models Used

1. **OCR (Text Extraction)**: `microsoft/trocr-base-printed`
   - Extracts text from medicine labels and prescriptions
   - Works with printed text

2. **Image Understanding**: `Salesforce/blip-image-captioning-base`
   - Fallback for image analysis if OCR fails
   - Provides image descriptions

3. **Text Analysis**: `mistralai/Mistral-7B-Instruct-v0.2`
   - Analyzes prescription text
   - Extracts medicine information
   - Provides medicine details

---

## Features

### ✅ Scan Medicine
- Takes photo of medicine label
- Extracts text using OCR
- Analyzes medicine information
- Shows uses, side effects, dosage, etc.

### ✅ Prescription Upload
- Uploads prescription images
- Extracts text from prescription
- Identifies medicines listed
- Checks availability in pharmacy
- Provides medicine information

---

## Error Handling

The service handles:
- **Model Loading (503)**: Automatically retries after 5 seconds
- **Network Timeouts**: Shows user-friendly error messages
- **API Failures**: Gracefully falls back to allow upload without AI analysis

---

## Benefits Over Gemini

1. ✅ **No Billing Required**: Free tier works immediately
2. ✅ **No API Key Needed**: Works out of the box
3. ✅ **No Rate Limit Issues**: More generous free tier
4. ✅ **Open Source Models**: Transparent and reliable

---

## Troubleshooting

### Issue: "Model is loading" (503 error)
**Solution**: The model is starting up. Wait 5-10 seconds and try again. The app automatically retries.

### Issue: "Request timeout"
**Solution**: Check your internet connection. Hugging Face models may take a few seconds to respond.

### Issue: Poor text extraction
**Solution**: 
- Ensure image is clear and well-lit
- Make sure text is clearly visible
- Try taking photo from different angle

### Issue: Medicine information not accurate
**Solution**: 
- The AI analyzes text from the image
- If text is unclear, information may be incomplete
- Always verify with a healthcare professional

---

## Configuration

### Firestore Configuration (Optional)
```
Collection: app_config
Document: huggingface
Fields:
  - apiToken: "YOUR_HUGGINGFACE_TOKEN" (optional)
```

### Code Configuration
File: `lib/services/huggingface_service.dart`

Default models can be changed if needed:
```dart
static const String _ocrModel = 'microsoft/trocr-base-printed';
static const String _visionModel = 'Salesforce/blip-image-captioning-base';
static const String _textModel = 'mistralai/Mistral-7B-Instruct-v0.2';
```

---

## Testing

1. **Scan Medicine**:
   - Go to Medicine Scanner
   - Take photo of medicine label
   - Wait for AI analysis
   - Verify extracted information

2. **Prescription Upload**:
   - Go to Prescription Upload
   - Upload prescription image
   - Wait for AI analysis
   - Check suggested medicines

---

## Notes

- First request to a model may take longer (model loading)
- Subsequent requests are faster
- Free tier has rate limits but is sufficient for normal use
- For production, consider getting a Hugging Face API token for higher limits

---

## Support

If you encounter issues:
1. Check internet connection
2. Verify image quality
3. Try again after a few seconds
4. Check console logs for detailed error messages

