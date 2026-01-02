# AI API Connectivity Fix

If you are seeing "404 - Found / Not Found" errors, it means the API endpoint (URL) we are trying to reach does not exist for the API key/model version we are using.

## The Solution
I have updated the app to use the **Gemini 1.5 Flash** model on the **v1beta** API. This is the most reliable (and free) model currently available from Google for this purpose.

**Correct URL used now:**
`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

## Troubleshooting Steps
1.  **Restart the App**: Changes to `const` URLs require a full restart (`quit` -> `flutter run`).
2.  **Test Again**: Use the "Bug Icon" in the Prescription Upload screen.
3.  **Check Logs**: If it still fails, check the terminal. 
    *   If you see `404`, check if the URL matches the one above.
    *   If you see `400` or `403` (Bad Request/Forbidden), verify the API Key again.

## Verifying Model Availability
You can check which models are available for your key by running this CURL command in your terminal (replace YOUR_API_KEY):
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY"
```
This will list all valid model names (e.g., `gemini-1.5-flash`, `gemini-pro`).
