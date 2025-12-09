# SOS Alert System - Code Examples & Implementation Patterns

## Table of Contents
1. Basic SOS Activation
2. Error Handling Patterns
3. Emergency Contact Management
4. Message Customization
5. Firestore Data Retrieval
6. UI Integration Examples
7. Testing Scenarios
8. Advanced Patterns

---

## 1. Basic SOS Activation

### Example 1: Simple SOS Trigger
```dart
// Minimal implementation - just trigger SOS
final sosService = SOSAlertService();

try {
  final result = await sosService.triggerSOSAlert();
  
  if (result['success']) {
    print('SOS activated successfully');
    print('Contacts notified: ${result['contactsNotified']}');
  }
} catch (e) {
  print('SOS failed: $e');
}
```

### Example 2: SOS with Custom Message
```dart
// Trigger SOS with custom message
final sosService = SOSAlertService();

final customMessage = """
🚨 URGENT - Severe Hypoglycemia Alert
Blood Sugar: 45 mg/dL (CRITICAL)
Location: 123 Main Street, NYC
Status: Needs immediate assistance
""";

try {
  final result = await sosService.triggerSOSAlert(customMessage);
  
  if (result['success']) {
    print('${result['contactsNotified']} contacts notified');
  }
} catch (e) {
  print('Error: $e');
}
```

### Example 3: SOS with UI Feedback
```dart
class EmergencyWidget extends StatefulWidget {
  @override
  State<EmergencyWidget> createState() => _EmergencyWidgetState();
}

class _EmergencyWidgetState extends State<EmergencyWidget> {
  final sosService = SOSAlertService();
  bool isSending = false;

  Future<void> activateSOS() async {
    setState(() => isSending = true);
    
    try {
      final result = await sosService.triggerSOSAlert();
      
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🚨 SOS Sent to ${result['contactsNotified']} contacts'
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SOS Failed: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isSending ? null : activateSOS,
      backgroundColor: Colors.red,
      child: isSending 
        ? CircularProgressIndicator(color: Colors.white)
        : Icon(Icons.emergency),
    );
  }
}
```

---

## 2. Error Handling Patterns

### Example 4: Comprehensive Error Handling
```dart
Future<void> triggerSOSWithErrorHandling() async {
  final sosService = SOSAlertService();
  
  try {
    final result = await sosService.triggerSOSAlert();
    
    if (!result['success']) {
      // Handle service-level errors
      final error = result['error'];
      
      if (error.contains('No emergency contacts')) {
        // Prompt user to add contacts
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Emergency Contacts'),
            content: Text('Please add emergency contacts first'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyContactsScreen(),
                    ),
                  );
                },
                child: Text('Add Contacts'),
              ),
            ],
          ),
        );
      } else if (error.contains('Location permission')) {
        // Prompt for location permission
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text('Enable location to use SOS'),
            actions: [
              TextButton(
                onPressed: () => Geolocator.openLocationSettings(),
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  } on SocketException {
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No internet connection')),
    );
  } on TimeoutException {
    // Handle timeout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request timed out. Please try again')),
    );
  } catch (e) {
    // Generic error handling
    print('Unexpected error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

### Example 5: Per-Contact Error Tracking
```dart
Future<void> activateSOSAndTrackErrors() async {
  final sosService = SOSAlertService();
  
  try {
    final result = await sosService.triggerSOSAlert();
    
    if (result['success']) {
      // Track which contacts got notified vs failed
      final notificationDetails = result['notificationDetails'] as List;
      
      final successful = notificationDetails
          .where((n) => n['status'] == 'sent')
          .length;
      
      final failed = notificationDetails
          .where((n) => n['status'] == 'failed')
          .length;
      
      print('✅ Successfully notified: $successful');
      print('❌ Failed to notify: $failed');
      
      // Log failed contacts for debugging
      for (var notification in notificationDetails) {
        if (notification['status'] == 'failed') {
          print('Failed: ${notification['contact']} - ${notification['error']}');
        }
      }
    }
  } catch (e) {
    print('Critical error: $e');
  }
}
```

---

## 3. Emergency Contact Management

### Example 6: Save Emergency Contact
```dart
Future<void> addEmergencyContact({
  required String name,
  required String phone,
  required String relationship,
}) async {
  // Validate phone number format
  if (!phone.startsWith('+') || phone.length < 10) {
    throw Exception('Invalid phone format. Use +countrycode format');
  }
  
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
          'emergencyContacts': FieldValue.arrayUnion([
            {
              'name': name,
              'phone': phone,
              'relationship': relationship,
              'addedAt': Timestamp.now(),
            }
          ])
        });
    
    print('✅ Contact added: $name ($phone)');
  } catch (e) {
    print('❌ Failed to add contact: $e');
    rethrow;
  }
}
```

### Example 7: Retrieve Emergency Contacts
```dart
Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];
  
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    final contacts = List<Map<String, dynamic>>.from(
      userDoc['emergencyContacts'] ?? []
    );
    
    return contacts;
  } catch (e) {
    print('Error retrieving contacts: $e');
    return [];
  }
}
```

### Example 8: Update Emergency Contact
```dart
Future<void> updateEmergencyContact({
  required int index,
  required String name,
  required String phone,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  
  // Get current contacts
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
  
  List<Map<String, dynamic>> contacts = 
    List<Map<String, dynamic>>.from(userDoc['emergencyContacts'] ?? []);
  
  if (index >= 0 && index < contacts.length) {
    // Update the contact
    contacts[index]['name'] = name;
    contacts[index]['phone'] = phone;
    contacts[index]['updatedAt'] = Timestamp.now();
    
    // Save back to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'emergencyContacts': contacts});
    
    print('✅ Contact updated');
  }
}
```

### Example 9: Delete Emergency Contact
```dart
Future<void> deleteEmergencyContact({required int index}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  
  // Get current contacts
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
  
  List<Map<String, dynamic>> contacts = 
    List<Map<String, dynamic>>.from(userDoc['emergencyContacts'] ?? []);
  
  if (index >= 0 && index < contacts.length) {
    contacts.removeAt(index);
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'emergencyContacts': contacts});
    
    print('✅ Contact deleted');
  }
}
```

---

## 4. Message Customization

### Example 10: Custom SOS Message Builder
```dart
String buildCustomSOSMessage({
  required String userName,
  required double latitude,
  required double longitude,
  required String address,
  required int glucoseLevel,
  String? additionalInfo,
}) {
  final timestamp = DateTime.now().toString();
  final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
  
  return """
🚨 EMERGENCY ALERT - MEDICAL 🚨

👤 Name: $userName
📍 LOCATION:
   Address: $address
   Coordinates: $latitude, $longitude
   Google Maps: $mapsLink

💉 GLUCOSE LEVEL: $glucoseLevel mg/dL

${additionalInfo != null ? '📝 Notes: $additionalInfo' : ''}

⏰ Time: $timestamp

Please contact immediately or call emergency services.
This is an automated emergency alert.
""";
}

// Usage
final customMessage = buildCustomSOSMessage(
  userName: 'John Doe',
  latitude: 40.7128,
  longitude: -74.0060,
  address: '123 Main St, NYC',
  glucoseLevel: 45,
  additionalInfo: 'Severe hypoglycemia, unconscious',
);

await sosService.triggerSOSAlert(customMessage);
```

---

## 5. Firestore Data Retrieval

### Example 11: Get SOS Alert History
```dart
Future<void> viewSOSHistory() async {
  final sosService = SOSAlertService();
  
  try {
    // Get last 10 SOS alerts
    final alerts = await sosService.getSOSAlertHistory(10);
    
    for (var alert in alerts) {
      print('Alert ID: ${alert['id']}');
      print('Status: ${alert['status']}');
      print('Time: ${alert['timestamp']}');
      print('Location: ${alert['location']['address']}');
      print('Contacts notified: ${alert['notificationStatus'].length}');
      print('---');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Example 12: Check Last SOS Status
```dart
Future<Map<String, dynamic>?> getLastSOSStatus() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;
  
  try {
    final query = await FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    
    return query.docs.first.data();
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

// Usage
final lastSOS = await getLastSOSStatus();
if (lastSOS != null) {
  print('Last SOS Status: ${lastSOS['status']}');
  print('Was ${lastSOS['status']} at ${lastSOS['timestamp']}');
}
```

### Example 13: Query SOS by Date Range
```dart
Future<List<Map<String, dynamic>>> getSOSAlertsByDateRange({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];
  
  try {
    final query = await FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .get();
    
    return query.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

// Usage
final today = DateTime.now();
final lastWeek = today.subtract(Duration(days: 7));

final weekAlerts = await getSOSAlertsByDateRange(
  startDate: lastWeek,
  endDate: today,
);

print('SOS alerts this week: ${weekAlerts.length}');
```

---

## 6. UI Integration Examples

### Example 14: SOS Button with Countdown
```dart
class SOSButtonWithCountdown extends StatefulWidget {
  @override
  State<SOSButtonWithCountdown> createState() => _SOSButtonWithCountdownState();
}

class _SOSButtonWithCountdownState extends State<SOSButtonWithCountdown> {
  final sosService = SOSAlertService();
  int countdown = 5;
  bool isActive = false;
  
  void startCountdown() {
    setState(() {
      isActive = true;
      countdown = 5;
    });
    
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => countdown--);
      
      if (countdown == 0) {
        timer.cancel();
        activateSOS();
      }
    });
  }
  
  Future<void> activateSOS() async {
    final result = await sosService.triggerSOSAlert();
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 SOS Activated'))
      );
    }
    
    setState(() => isActive = false);
  }
  
  void cancel() {
    setState(() => isActive = false);
  }
  
  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Emergency activation in',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            countdown.toString(),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: cancel,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Cancel SOS'),
          ),
        ],
      );
    }
    
    return FloatingActionButton.large(
      onPressed: startCountdown,
      backgroundColor: Colors.red,
      child: Icon(Icons.emergency, size: 40),
    );
  }
}
```

### Example 15: SOS Status Card
```dart
class SOSStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getLastSOSStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final lastSOS = snapshot.data;
        
        if (lastSOS == null) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No SOS alerts yet'),
            ),
          );
        }
        
        final status = lastSOS['status'];
        final timestamp = (lastSOS['timestamp'] as Timestamp).toDate();
        final color = status == 'sent' ? Colors.red : Colors.orange;
        
        return Card(
          color: color.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last SOS Alert',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Status: ${status.toUpperCase()}'),
                Text('Time: ${timestamp.toString()}'),
                Text('Location: ${lastSOS['location']['address']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 7. Testing Scenarios

### Example 16: Unit Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('SOSAlertService Tests', () {
    late SOSAlertService sosService;
    
    setUp(() {
      sosService = SOSAlertService();
    });
    
    test('triggerSOSAlert returns success result', () async {
      final result = await sosService.triggerSOSAlert();
      
      expect(result['success'], isTrue);
      expect(result['contactsNotified'], isA<int>());
    });
    
    test('getSOSAlertHistory returns list', () async {
      final alerts = await sosService.getSOSAlertHistory(5);
      
      expect(alerts, isA<List>());
    });
    
    test('cancelSOSAlert updates status', () async {
      // Get latest alert
      final alerts = await sosService.getSOSAlertHistory(1);
      
      if (alerts.isNotEmpty) {
        final alertId = alerts[0]['id'];
        await sosService.cancelSOSAlert(alertId);
        
        // Verify status changed
        final updatedAlerts = await sosService.getSOSAlertHistory(1);
        expect(updatedAlerts[0]['status'], equals('cancelled'));
      }
    });
  });
}
```

### Example 17: Integration Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sugenix/screens/emergency_screen.dart';

void main() {
  group('Emergency Screen Integration Tests', () {
    testWidgets('SOS button triggers alert', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      // Navigate to emergency screen
      await tester.tap(find.byIcon(Icons.emergency));
      await tester.pumpAndSettle();
      
      // Tap SOS button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      
      // Verify countdown appears
      expect(find.text('5'), findsOneWidget);
      
      // Wait for countdown
      await tester.pumpAndSettle(Duration(seconds: 6));
      
      // Verify SOS message
      expect(
        find.text(contains('SOS Activated')),
        findsWidgets,
      );
    });
  });
}
```

---

## 8. Advanced Patterns

### Example 18: Retry Logic for Failed Contacts
```dart
Future<void> triggerSOSWithRetry({
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 5),
}) async {
  final sosService = SOSAlertService();
  int attempt = 0;
  bool success = false;
  
  while (attempt < maxRetries && !success) {
    try {
      final result = await sosService.triggerSOSAlert();
      
      if (result['success']) {
        success = true;
        print('✅ SOS activated on attempt ${attempt + 1}');
      } else {
        // Check for failed contacts and retry
        final notifications = result['notificationDetails'] as List;
        final failed = notifications.where((n) => n['status'] == 'failed').toList();
        
        if (failed.isNotEmpty) {
          print('⚠️ ${failed.length} contacts failed, retrying...');
          await Future.delayed(retryDelay);
          attempt++;
        } else {
          success = true;
        }
      }
    } catch (e) {
      print('Attempt ${attempt + 1} failed: $e');
      attempt++;
      
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }
  }
  
  if (!success) {
    print('❌ SOS activation failed after $maxRetries attempts');
  }
}
```

### Example 19: Real-time SOS Monitoring
```dart
Stream<DocumentSnapshot> monitorSOSAlerts() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  
  return FirebaseFirestore.instance
      .collection('sos_alerts')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots();
}

// Usage in StreamBuilder
StreamBuilder<DocumentSnapshot>(
  stream: monitorSOSAlerts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('Loading...');
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    if (!snapshot.hasData) {
      return Text('No SOS alerts');
    }
    
    final alert = snapshot.data!.data() as Map<String, dynamic>;
    return Text('Status: ${alert['status']}');
  },
)
```

### Example 20: Analytics & Logging
```dart
Future<void> logSOSEvent({
  required String eventType,
  required Map<String, dynamic> eventData,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;
  
  try {
    await FirebaseFirestore.instance
        .collection('sos_analytics')
        .add({
          'userId': userId,
          'eventType': eventType,
          'eventData': eventData,
          'timestamp': Timestamp.now(),
        });
  } catch (e) {
    print('Failed to log event: $e');
  }
}

// Usage
await logSOSEvent(
  eventType: 'sos_activated',
  eventData: {
    'contactsNotified': 3,
    'location': 'NYC',
    'glucoseLevel': 45,
  },
);

// Query analytics
Future<Map<String, int>> getSOSStats() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return {};
  
  final events = await FirebaseFirestore.instance
      .collection('sos_analytics')
      .where('userId', isEqualTo: userId)
      .get();
  
  int activated = 0;
  int cancelled = 0;
  int failed = 0;
  
  for (var event in events.docs) {
    final type = event['eventType'];
    if (type == 'sos_activated') activated++;
    else if (type == 'sos_cancelled') cancelled++;
    else if (type == 'sos_failed') failed++;
  }
  
  return {
    'activated': activated,
    'cancelled': cancelled,
    'failed': failed,
  };
}
```

---

## Summary

These examples cover:
- ✅ Basic SOS activation with and without custom messages
- ✅ Comprehensive error handling patterns
- ✅ Emergency contact CRUD operations
- ✅ Message customization and formatting
- ✅ Firestore data retrieval and querying
- ✅ UI components (buttons, cards, streaming data)
- ✅ Unit and integration testing
- ✅ Advanced patterns (retry logic, monitoring, analytics)

Use these as templates for your specific implementation needs!

---

**Last Updated:** January 2024
