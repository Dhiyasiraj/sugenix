# Gemini API Setup Instructions

## Getting Your Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

## Setting Up the API Key

1. Open `lib/services/gemini_service.dart`
2. Find the line: `static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key

Example:
```dart
static const String _apiKey = 'AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567';
```

## Features Using Gemini API

- **Medicine Scanner**: Extracts text from medicine labels and provides detailed information
- **Prescription Analysis**: Analyzes prescriptions and suggests available medicines
- **AI Assistant**: Provides intelligent responses to health-related questions
- **Glucose Recommendations**: Suggests personalized diet plans, exercise routines, and tips based on glucose levels

## Important Notes

- Keep your API key secure and never commit it to version control
- The API key has usage limits based on your Google Cloud plan
- For production, consider using environment variables or secure storage

