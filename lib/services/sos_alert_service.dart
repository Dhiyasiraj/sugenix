import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/services/platform_location_service.dart';
import 'package:sugenix/services/ultramessage_service.dart';
import 'package:geolocator/geolocator.dart';

class SOSAlertService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UltraMessageService _ultraMessageService = UltraMessageService();

  // Generate SOS message with location
  static String _generateSOSMessage({
    required String userName,
    required String? address,
    required double? latitude,
    required double? longitude,
    required List<Map<String, dynamic>> recentReadings,
  }) {
    String message = '''🚨 *SOS EMERGENCY ALERT* 🚨

*User:* $userName
*Alert Type:* Medical Emergency - Diabetic Crisis

*Location Details:*
${address != null ? 'Address: $address' : ''}
${latitude != null && longitude != null 
    ? 'GPS Coordinates: $latitude, $longitude\nView Location: https://maps.google.com/?q=$latitude,$longitude' 
    : 'Location: Not available'}

*Recent Glucose Readings:*
''';

    if (recentReadings.isNotEmpty) {
      for (int i = 0; i < recentReadings.length && i < 3; i++) {
        final reading = recentReadings[i];
        final value = reading['value'] ?? 'N/A';
        final type = reading['type'] ?? 'Unknown';
        final timestamp = reading['timestamp'] ?? 'Unknown time';
        message += '\n• $value mg/dL ($type) - $timestamp';
      }
    } else {
      message += '\nNo recent readings available';
    }

    message += '''

*Emergency Contact Information:*
Please respond immediately! This is a critical health emergency.

*Sent from: Sugenix - Diabetes Management App*
''';

    return message;
  }

  // Send SOS alert via WhatsApp using Ultramessage
  Future<bool> _sendSOSViaWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Ensure phone number is in correct format (remove +, keep only digits)
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      // Add country code if missing (assume India +91)
      if (formattedPhone.length == 10) {
        formattedPhone = '91$formattedPhone';
      }

      final result = await _ultraMessageService.sendWhatsAppMessage(
        to: formattedPhone,
        message: message,
      );

      return result['success'] == true;
    } catch (e) {
      print('Error sending WhatsApp via Ultramessage: $e');
      return false;
    }
  }

  // Send SOS alert to all emergency contacts
  Future<Map<String, dynamic>> triggerSOSAlert({
    String? customMessage,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = _auth.currentUser!.uid;

      // Get user information
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'User';

      // Get current location with proper permission handling
      Position? position;
      String? address;
      
      try {
        // Request location permission first
        final hasPermission = await PlatformLocationService.hasLocationPermission();
        if (!hasPermission) {
          final granted = await PlatformLocationService.requestLocationPermission();
          if (!granted) {
            // Permission denied, continue without location
            print('Location permission denied - SOS will continue without location');
          }
        }
        
        // Get current location (works with GPS even without SIM card)
        // Timeout after 8 seconds to not delay SOS too much
        try {
          position = await PlatformLocationService.getCurrentLocation();
        } catch (e) {
          print('Location request failed: $e - SOS will continue without location');
          position = null;
        }
        
        if (position != null) {
          final pos = position; // Local variable
          try {
            address = await PlatformLocationService.getAddressFromCoordinates(
              pos.latitude,
              pos.longitude,
            ).timeout(const Duration(seconds: 3), onTimeout: () {
              return 'Latitude: ${pos.latitude.toStringAsFixed(6)}, Longitude: ${pos.longitude.toStringAsFixed(6)}';
            });
          } catch (e) {
            print('Error getting address: $e');
            // Continue with coordinates only
            address = 'Latitude: ${pos.latitude.toStringAsFixed(6)}, Longitude: ${pos.longitude.toStringAsFixed(6)}';
          }
        } else {
          print('Location not available - SOS will continue without location (this is OK, may be due to no SIM/WiFi)');
        }
      } catch (e) {
        print('Error getting location: $e - SOS will continue without location');
        // Continue without location - SOS should still work
      }

      // Get recent glucose readings
      final glucoseReadings = await _getRecentGlucoseReadings();

      // Get emergency contacts
      final emergencyContacts = await _getEmergencyContacts();

      if (emergencyContacts.isEmpty) {
        throw Exception('No emergency contacts saved');
      }

      // Generate SOS message
      final sosMessage = _generateSOSMessage(
        userName: userName,
        address: address,
        latitude: position?.latitude,
        longitude: position?.longitude,
        recentReadings: glucoseReadings,
      );

      // Store SOS alert in Firestore
      final alertDoc = await _firestore.collection('sos_alerts').add({
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
        'location': position != null
            ? {
                'latitude': position.latitude,
                'longitude': position.longitude,
                'address': address,
              }
            : null,
        'glucoseReadings': glucoseReadings,
        'customMessage': customMessage,
        'sosMessage': sosMessage,
        'status': 'active',
        'emergencyContactsCount': emergencyContacts.length,
        'notificationStatus': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send WhatsApp messages to all emergency contacts
      List<Map<String, dynamic>> notificationResults = [];
      Map<String, dynamic> notificationStatus = {};

      for (final contact in emergencyContacts) {
        try {
          final phoneNumber = contact['phone'] ?? contact['phoneNumber'] ?? '';
          final contactName = contact['name'] ?? 'Emergency Contact';

          if (phoneNumber.isNotEmpty) {
            final success = await _sendSOSViaWhatsApp(
              phoneNumber: phoneNumber,
              message: sosMessage,
            );

            notificationResults.add({
              'contact': contactName,
              'phone': phoneNumber,
              'status': success ? 'sent' : 'failed',
              'timestamp': DateTime.now().toIso8601String(),
            });

            notificationStatus[phoneNumber] = {
              'name': contactName,
              'status': success ? 'sent' : 'failed',
              'timestamp': FieldValue.serverTimestamp(),
            };
          }
        } catch (e) {
          print('Error notifying ${contact['name']}: $e');
        }

        // Add delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Update SOS alert with notification status
      await _firestore.collection('sos_alerts').doc(alertDoc.id).update({
        'notificationStatus': notificationStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'alertId': alertDoc.id,
        'message': sosMessage,
        'contactsNotified': notificationResults.length,
        'notificationDetails': notificationResults,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to trigger SOS alert: ${e.toString()}',
      };
    }
  }

  // Get recent glucose readings
  Future<List<Map<String, dynamic>>> _getRecentGlucoseReadings() async {
    try {
      if (_auth.currentUser == null) return [];

      final snapshot = await _firestore
          .collection('glucose_readings')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'value': data['value'],
          'type': data['type'],
          'timestamp': data['timestamp'],
          'notes': data['notes'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching glucose readings: $e');
      return [];
    }
  }

  // Get emergency contacts
  Future<List<Map<String, dynamic>>> _getEmergencyContacts() async {
    try {
      if (_auth.currentUser == null) return [];

      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(
          userData['emergencyContacts'] ?? [],
        );
      }

      return [];
    } catch (e) {
      print('Error fetching emergency contacts: $e');
      return [];
    }
  }

  // Update SOS alert status
  Future<void> updateSOSStatus({
    required String alertId,
    required String newStatus,
    String? notes,
  }) async {
    try {
      await _firestore.collection('sos_alerts').doc(alertId).update({
        'status': newStatus,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update SOS status: ${e.toString()}');
    }
  }

  // Get SOS alert history
  Future<List<Map<String, dynamic>>> getSOSAlertHistory({
    int limit = 10,
  }) async {
    try {
      if (_auth.currentUser == null) return [];

      final snapshot = await _firestore
          .collection('sos_alerts')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'timestamp': data['timestamp'],
          'status': data['status'],
          'location': data['location'],
          'contactsNotified': data['emergencyContactsCount'],
          'glucoseReadings': data['glucoseReadings'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching SOS history: $e');
      return [];
    }
  }

  // Cancel active SOS alert
  Future<void> cancelSOSAlert({required String alertId}) async {
    try {
      await updateSOSStatus(
        alertId: alertId,
        newStatus: 'cancelled',
        notes: 'Cancelled by user',
      );
    } catch (e) {
      throw Exception('Failed to cancel SOS alert: ${e.toString()}');
    }
  }
}
