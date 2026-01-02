# SOS Feature Implementation Guide

The SOS Emergency Alert feature has been fully implemented to work **freely** using your device's native SMS capabilities. This bypasses the need for paid services like Twilio.

## Key Features
1.  **Direct SMS Sending**: Uses the `telephony` package to send SMS directly from your phone.
2.  **Location Tracking**: Automatically grabs your GPS coordinates and converts them into a Google Maps link.
3.  **Background Processing**: Sends alerts to ALL your emergency contacts in the background.
4.  **Robust Permissions**: proactively requests SMS and Location permissions when you open the Emergency screen to ensure no delays during a crisis.

## How to Test
1.  **Add Emergency Contacts**:
    *   Go to **Profile > Emergency Contacts**.
    *   Add at least one valid phone number (e.g., a friend or family member's device next to you).
    *   **Note**: Ensure the phone number includes the country code if needed (or just the 10-digit number for local calls). The app attempts to handle basic formatting.

2.  **Trigger SOS**:
    *   Go to the **Emergency (SOS)** screen (from the bottom nav or home dashboard).
    *   The app should ask for **SMS** and **Location** permissions. **Allow them**.
    *   Press and hold the big red **SOS** button.
    *   A 5-second countdown will start (you can cancel if testing).
    *   After the countdown, the app will send SMS messages to your saved contacts.

3.  **Verify**:
    *   Check the recipient's phone. They should receive a text with:
        *   "🚨 SOS EMERGENCY ALERT 🚨"
        *   Your name.
        *   Your location (Google Maps link).
        *   Recent glucose readings (if available).
    *   The app will show a confirmation "SOS sent to X contacts".

## Important Notes
*   **Real Device Required**: This feature **will not work on most emulators** because emulators cannot send real SMS messages. Use a physical Android phone.
*   **SIM Card**: The device must have a working SIM card with an active SMS plan.
*   **Permissions**: Since this works "freely" by using your phone plan, Android requires explicit `SEND_SMS` permission.
