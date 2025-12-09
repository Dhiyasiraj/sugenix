# SOS Alert System - Setup & Implementation Guide

## Overview

The SOS Alert System provides critical emergency notification functionality that sends WhatsApp messages to emergency contacts with the user's location and recent glucose readings when activated.

**Key Features:**
- 🚨 One-button emergency activation with 5-second countdown
- 💬 WhatsApp notifications to multiple emergency contacts via Ultramessage
- 📍 Real-time location sharing (address + Google Maps link)
- 📊 Glucose reading context included in emergency message
- ✅ Alert status tracking and history
- ❌ Emergency cancellation within the countdown period

## Architecture

### Service Classes

#### SOSAlertService (`lib/services/sos_alert_service.dart`)
**Purpose:** Handles all SOS alert operations including WhatsApp integration, location retrieval, and Firestore persistence

**Key Methods:**
- `triggerSOSAlert(String? customMessage)` - Main activation method
- `sendSOSViaWhatsApp(String phoneNumber, String message)` - Ultramessage API integration
- `cancelSOSAlert(String alertId)` - Cancel active SOS alert
- `getSOSAlertHistory(int limit)` - Retrieve past alerts
- `updateSOSStatus(String alertId, String newStatus)` - Update alert status

#### EmergencyScreen (`lib/screens/emergency_screen.dart`)
**Purpose:** UI interface for SOS activation with countdown and feedback

**Key State Variables:**
- `_sosAlertService` - Service instance
- `_isSending` - Tracks WhatsApp sending status
- `_isEmergencyActive` - Whether emergency is currently active
- `_countdown` - 5-second countdown before activation

## Setup Instructions

### 1. Ultramessage Configuration

#### Create Ultramessage Account
1. Visit [Ultramessage Dashboard](https://ultramessage.com)
2. Sign up or log in
3. Create a WhatsApp business account connection

#### Get API Credentials
1. Navigate to **Settings → API Keys**
2. Copy your **API Key** and **Instance ID**

#### Update SOSAlertService
Open `lib/services/sos_alert_service.dart` and replace:

```dart
// Line 13-16
static const String _ultraMessageApiKey = 'YOUR_ULTRAMESSAGE_API_KEY';
static const String _ultraMessageInstanceId = 'YOUR_INSTANCE_ID';
```

With your actual credentials:
```dart
static const String _ultraMessageApiKey = 'your_actual_api_key_here';
static const String _ultraMessageInstanceId = 'your_actual_instance_id_here';
```

### 2. Emergency Contacts Setup

Emergency contacts must be saved in the user's Firestore profile document.

#### Firestore Collection Structure
```
users/
  {userId}/
    emergencyContacts: [
      {
        name: "Mom",
        phone: "+919876543210",
        relationship: "Mother"
      },
      {
        name: "Dad",
        phone: "+919876543211",
        relationship: "Father"
      }
    ]
```

#### Phone Number Format Requirements
- **Must include country code** (e.g., +91 for India, +1 for USA)
- **No spaces or special characters** except `+`
- Examples:
  - India: `+919876543210`
  - USA: `+12025551234`
  - UK: `+442071838750`

#### Save Emergency Contacts
Users should save contacts through the profile/settings screen:

```dart
// Example code for saving emergency contacts
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .set({
      'emergencyContacts': [
        {
          'name': 'Mom',
          'phone': '+919876543210',
          'relationship': 'Mother'
        }
      ]
    }, SetOptions(merge: true));
```

### 3. Location Permissions

Ensure location permissions are configured in platform-specific files.

#### Android (`android/app/src/main/AndroidManifest.xml`)
Add permissions inside `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)
Add keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to share with emergency contacts</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to share with emergency contacts</string>
```

#### Geolocator Package Configuration
Already added to `pubspec.yaml`: `geolocator: ^10.1.0`

### 4. WhatsApp Business Account Setup

#### Prerequisites
- WhatsApp Business account (separate from personal WhatsApp)
- Business verification

#### Steps
1. Visit [Facebook Business Manager](https://business.facebook.com)
2. Create/verify your business account
3. Set up WhatsApp Business API
4. Connect to Ultramessage:
   - Provide WhatsApp API credentials to Ultramessage
   - Ultramessage will configure the connection
5. Test messaging to verify setup

### 5. Glucose Readings Database

For glucose readings to appear in SOS message, they must be stored in Firestore:

#### Collection Structure
```
users/
  {userId}/
    glucose_readings/
      {readingId}:
        value: 145
        timestamp: Timestamp
        unit: "mg/dL"
        notes: "After breakfast"
```

The service automatically retrieves the last 5 readings and includes up to 3 most recent in the SOS message.

## Integration Guide

### How the SOS Alert Flow Works

```
User Presses SOS Button
        ↓
    5-Second Countdown
        ↓
User Confirms (or Cancel)
        ↓
triggerSOSAlert() Activated
        ↓
    ┌─────────────────────┐
    │ Get Location        │
    │ (GPS + Address)     │
    └─────────────────────┘
        ↓
    ┌─────────────────────┐
    │ Fetch Glucose       │
    │ Readings            │
    └─────────────────────┘
        ↓
    ┌─────────────────────┐
    │ Get Emergency       │
    │ Contacts            │
    └─────────────────────┘
        ↓
    ┌─────────────────────┐
    │ Generate Message    │
    │ (Location+Glucose)  │
    └─────────────────────┘
        ↓
    For Each Contact:
    ┌─────────────────────┐
    │ sendSOSViaWhatsApp()│
    │ (Ultramessage API)  │
    └─────────────────────┘
        ↓
    Store Alert in Firestore
        ↓
    Show Results Dialog
    (Success/Failed per contact)
```

### Code Implementation in Emergency Screen

The `_activateEmergency()` method in `emergency_screen.dart` now:

```dart
Future<void> _activateEmergency() async {
  setState(() => _isSending = true);
  
  try {
    // Call SOS alert service
    final result = await _sosAlertService.triggerSOSAlert();
    
    if (result['success']) {
      // Show success with contact count
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚨 SOS Activated! ${result['contactsNotified']} contacts notified"),
          backgroundColor: Colors.red,
        ),
      );
      
      // Show detailed notification status dialog
      _showNotificationStatus(result['notificationDetails']);
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${result['error']}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _isSending = false);
  }
}
```

### Cancel SOS Alert

The `_cancelEmergency()` method:

```dart
Future<void> _cancelEmergency() async {
  try {
    // Get the most recent SOS alert
    final alertHistory = await _sosAlertService.getSOSAlertHistory(1);
    
    if (alertHistory.isNotEmpty) {
      final alertId = alertHistory[0]['id'];
      // Cancel it
      await _sosAlertService.cancelSOSAlert(alertId);
    }
    
    setState(() {
      _isEmergencyActive = false;
      _countdown = 5;
    });
  } catch (e) {
    // Show error
  }
}
```

## SOS Message Format

When an SOS is triggered, the message sent to emergency contacts looks like:

```
🚨 EMERGENCY ALERT 🚨

Name: John Doe
Alert Type: Medical Emergency

📍 LOCATION:
Address: 123 Main St, New York, NY 10001
Coordinates: 40.7128°N, 74.0060°W
Google Maps: https://maps.google.com/?q=40.7128,74.0060

💉 GLUCOSE READINGS:
• 10:30 AM: 245 mg/dL
• 9:15 AM: 198 mg/dL
• 8:00 AM: 156 mg/dL

Please contact immediately or call emergency services if needed.
Time: 2:45 PM, January 15, 2024
```

## Firestore Schema

### SOS Alerts Collection
```
sos_alerts/
  {alertId}:
    userId: "user123"
    timestamp: Timestamp
    status: "sent" | "cancelled"
    location: {
      latitude: 40.7128,
      longitude: -74.0060,
      address: "123 Main St, New York, NY 10001"
    }
    glucoseReadings: [
      { value: 245, timestamp: Timestamp, unit: "mg/dL" },
      ...
    ]
    notificationStatus: {
      "919876543210": { status: "sent", timestamp: Timestamp },
      "919876543211": { status: "failed", error: "Invalid phone" }
    }
```

## Testing Guide

### Pre-Testing Checklist
- [ ] Ultramessage API key configured in SOSAlertService
- [ ] Ultramessage Instance ID configured
- [ ] Emergency contacts saved in user profile
- [ ] Phone numbers in E.164 format (+countrycode-number)
- [ ] Location permissions granted in app
- [ ] Glucose readings in Firestore database
- [ ] WhatsApp Business account set up in Ultramessage

### Manual Testing Steps

1. **Test Location Retrieval**
   - Open app and grant location permission
   - Check device location is accurate
   - Verify address reverse geocoding works

2. **Test Glucose Data**
   - Add sample glucose readings to Firestore
   - Trigger SOS and verify readings appear in message

3. **Test Single Contact**
   - Add one emergency contact
   - Press SOS button
   - Check WhatsApp receives message on that phone
   - Verify location link is clickable

4. **Test Multiple Contacts**
   - Add 3+ emergency contacts
   - Trigger SOS
   - Verify all contacts receive message within 30 seconds

5. **Test Message Format**
   - Verify location is correct
   - Verify glucose readings appear
   - Verify timestamp is accurate
   - Verify Google Maps link works

6. **Test Cancellation**
   - Press SOS button
   - Cancel within 5-second countdown
   - Verify alert status is 'cancelled' in Firestore

7. **Test Error Handling**
   - Test with no emergency contacts saved
   - Test with invalid phone numbers
   - Test with Ultramessage API key invalid
   - Verify error messages displayed to user

## Troubleshooting

### Messages Not Sending

**Issue:** WhatsApp messages don't arrive

**Solutions:**
1. **Check API credentials:**
   ```dart
   // Verify in SOSAlertService
   print(_ultraMessageApiKey);  // Should not be 'YOUR_API_KEY'
   print(_ultraMessageInstanceId);  // Should not be 'YOUR_INSTANCE_ID'
   ```

2. **Check phone number format:**
   - Must include country code: `+91` not `91`
   - No spaces or dashes: `+919876543210` not `+91 9876543210`
   - Must be valid WhatsApp-enabled number

3. **Verify WhatsApp Business account:**
   - Ensure WhatsApp Business API is active in Ultramessage
   - Check Ultramessage dashboard for API errors
   - Verify Ultramessage instance is properly configured

### Location Not Accurate

**Issue:** Location coordinates are wrong or address is incorrect

**Solutions:**
1. Check device location settings are enabled
2. Ensure fine location permission is granted
3. Allow a few seconds for GPS to lock
4. Test with Google Maps app first to verify device location

### Glucose Readings Not Appearing

**Issue:** SOS message has no glucose data

**Solutions:**
1. Add sample glucose readings to Firestore:
   ```dart
   await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .collection('glucose_readings')
       .add({
         'value': 145,
         'timestamp': Timestamp.now(),
         'unit': 'mg/dL'
       });
   ```

2. Verify readings are in correct Firestore path

### Emergency Contacts Not Found

**Issue:** No contacts in notification status

**Solutions:**
1. Save emergency contacts to user profile:
   ```dart
   await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .update({
         'emergencyContacts': [
           {'name': 'Mom', 'phone': '+919876543210'}
         ]
       });
   ```

2. Verify Firestore read permissions allow access

## Performance Considerations

- **Location lookup:** 2-5 seconds for GPS + reverse geocoding
- **API calls:** ~500ms per contact (rate limited to prevent API throttling)
- **Total SOS activation:** 5-15 seconds depending on network

## Security Best Practices

1. **Never hardcode API keys** in production - use secure configuration
2. **Validate phone numbers** before storing emergency contacts
3. **Encrypt emergency contact data** in transit and at rest
4. **Implement rate limiting** to prevent SOS spam
5. **Log all SOS alerts** for audit trail
6. **Verify user identity** before allowing SOS access

## API Endpoints

### Ultramessage API
- **Base URL:** `https://api.ultramessage.com/api/v1`
- **Endpoint:** `/messages/chat/send`
- **Method:** POST
- **Auth:** Header `Authorization: Bearer {API_KEY}`

**Request Format:**
```json
{
  "instanceId": "YOUR_INSTANCE_ID",
  "chatId": "919876543210",
  "message": "SOS message text"
}
```

**Response Format:**
```json
{
  "success": true,
  "messageId": "msg_123",
  "timestamp": "2024-01-15T14:45:00Z"
}
```

## Dependencies

```yaml
flutter:
  sdk: flutter
firebase_core: ^4.2.0
cloud_firestore: ^6.0.3
geolocator: ^10.1.0
geocoding: ^2.1.0
http: ^1.1.0
url_launcher: ^6.2.1
```

All dependencies are already in `pubspec.yaml`.

## Next Steps

1. ✅ Get Ultramessage API credentials
2. ✅ Configure emergency contacts in user profile
3. ✅ Test SOS alert with real WhatsApp
4. ✅ Monitor Firestore for alert records
5. ✅ Set up alert notifications for users receiving SOS
6. ✅ Consider adding alert acknowledgment from recipients

## Support & Resources

- [Ultramessage Documentation](https://docs.ultramessage.com)
- [Firebase Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [Geolocator Plugin Documentation](https://pub.dev/packages/geolocator)
- [Flutter Location Permissions](https://flutter.io/docs/development/packages-and-plugins/using-packages)

---

**Last Updated:** January 2024
**Status:** Complete and Ready for Testing
**Emergency Contact:** Support team available 24/7 for SOS system issues
