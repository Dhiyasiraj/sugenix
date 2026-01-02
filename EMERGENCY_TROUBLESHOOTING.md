# Emergency Troubleshooting Guide

## If you're still seeing red screen errors:

### Step 1: Check what error you're seeing

Take a screenshot and look for:
- Error message text
- Stack trace
- When it happens (startup, scanning, uploading)

### Step 2: Try these quick fixes

#### Fix A: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

#### Fix B: Check Gemini API Key
1. Go to: https://makersuite.google.com/app/apikey
2. Create a NEW API key
3. Replace the key in `lib/services/gemini_service.dart` line 10

#### Fix C: Test without AI features
Temporarily disable AI scanning to see if app works:
- Just browse medicine catalog
- Don't use scanner or prescription upload yet

### Step 3: Get detailed error logs

Run with verbose logging:
```bash
flutter run -v 2>&1 | Out-File -FilePath error_log.txt
```

Then share the `error_log.txt` file

### Step 4: Rollback if needed

If nothing works, rollback my changes:
```bash
git checkout HEAD~3 lib/screens/medicine_scanner_screen.dart
git checkout HEAD~3 lib/screens/prescription_upload_screen.dart
```

## Common Error Messages & Solutions

### "API key not valid"
- Get new key from https://makersuite.google.com/app/apikey
- Update line 10 in gemini_service.dart

### "Quota exceeded"
- Wait 24 hours for quota reset
- Or upgrade to paid plan

### "Network error" / "Timeout"
- Check internet connection
- Try on different network
- Check if firewall is blocking Google APIs

### Still showing "410" error
- This means my fix didn't apply correctly
- Try: `flutter clean && flutter pub get`
- Then rebuild

## Need Help?

Share with me:
1. Screenshot of error
2. When it happens
3. Output of: `flutter doctor -v`
