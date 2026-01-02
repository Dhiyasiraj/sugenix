# Prescription Analysis Fix

The "AI analysis failed" error usually occurs due to one of the following reasons:
1. **Safety Filters**: The AI model might be flagging the medical prescription as "unsafe content" (e.g., misinterpreting it as PII or illicit drugs). I have updated the code to lower these safety thresholds.
2. **Image Size**: High-resolution camera images can cause timeouts or API errors. I have added automatic resizing to 1024px width to ensure smoother processing.
3. **Response Format**: Sometimes the AI returns the data wrapped in a JSON object instead of a list. I have added a fix to handle both formats.

## What is changed?

### 1. `GeminiService.dart`
*   **Safety Settings**: explicitly set to `BLOCK_ONLY_HIGH` for all categories. This reduces false positives for medical content.
*   **Error Logging**: Added detailed `print` statements so errors will show up in your terminal (run `flutter run` to see them).
*   **JSON Parsing**: Improved to handle nested JSON objects (e.g. `{"medicines": [...]}`).
*   **Image Timeout**: Increased timeout for image analysis to 45 seconds.

### 2. `PrescriptionUploadScreen.dart`
*   **Image Optimization**: Images are now automatically resized to max 1024px width and 70% quality before sending. This drastically improves success rates on mobile networks.
*   **Error Display**: The error message in the app is now more specific (e.g. "Quota exceeded" or "Safety block"), rather than a generic "Failed" message.

## How to Test
1. Re-run the app: `flutter run`
2. Go to **Upload Prescription**.
3. Select an image.
4. If it fails, check the red SnackBar message for the specific reason, or check the terminal logs.
