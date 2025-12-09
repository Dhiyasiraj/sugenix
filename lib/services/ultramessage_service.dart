import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UltraMessageService {
  // ✅ REPLACE WITH YOUR ACTUAL CREDENTIALS
  static const String _instanceId = 'YOUR_INSTANCE_ID';
  static const String _apiToken = 'YOUR_API_TOKEN';
  static const String _apiUrl = 'https://api.ultramsg.com';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get Instance ID and API Token from Firebase Config
  /// This allows you to update credentials without rebuilding the app
  Future<Map<String, String>> _getApiCredentials() async {
    try {
      final doc =
          await _firestore.collection('app_config').doc('ultramessage').get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        return {
          'instanceId': data['instanceId'] ?? _instanceId,
          'apiToken': data['apiToken'] ?? _apiToken,
        };
      }
      return {
        'instanceId': _instanceId,
        'apiToken': _apiToken,
      };
    } catch (e) {
      print('Error getting API credentials: $e');
      return {
        'instanceId': _instanceId,
        'apiToken': _apiToken,
      };
    }
  }

  /// Send text message via WhatsApp
  ///
  /// Example:
  /// ```dart
  /// await sendWhatsAppMessage(
  ///   to: '919876543210',
  ///   message: 'Your glucose reading is 145 mg/dL'
  /// );
  /// ```
  Future<Map<String, dynamic>> sendWhatsAppMessage({
    required String to,
    required String message,
    String? id,
  }) async {
    try {
      final credentials = await _getApiCredentials();
      final instanceId = credentials['instanceId']!;
      final apiToken = credentials['apiToken']!;

      // Generate unique message ID if not provided
      final messageId = id ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Format phone number (remove +, ensure 10-13 digits)
      final cleanedNumber = to.replaceAll(RegExp(r'[^\d]'), '');

      final url =
          Uri.parse('$_apiUrl/$instanceId/messages/chat?token=$apiToken');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'to': cleanedNumber,
          'body': message,
          'priority': 10,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save message to Firebase for history
        await _saveMessageToHistory(
          phoneNumber: cleanedNumber,
          message: message,
          messageId: messageId,
          type: 'outgoing',
          status: 'sent',
          responseData: responseData,
        );

        return {
          'success': true,
          'messageId': messageId,
          'data': responseData,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        print('Error sending message: ${response.statusCode}');
        print('Response: ${response.body}');

        await _saveMessageToHistory(
          phoneNumber: cleanedNumber,
          message: message,
          messageId: messageId,
          type: 'outgoing',
          status: 'failed',
          responseData: responseData,
        );

        return {
          'success': false,
          'error': responseData['message'] ?? 'Failed to send message',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception sending WhatsApp message: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Send message with template
  /// Used for formatted responses (alerts, reports, etc.)
  Future<Map<String, dynamic>> sendWhatsAppTemplate({
    required String to,
    required String templateName,
    required List<String> parameters,
  }) async {
    try {
      final credentials = await _getApiCredentials();
      final instanceId = credentials['instanceId']!;
      final apiToken = credentials['apiToken']!;

      final cleanedNumber = to.replaceAll(RegExp(r'[^\d]'), '');

      final url =
          Uri.parse('$_apiUrl/$instanceId/messages/templates?token=$apiToken');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': cleanedNumber,
          'template': {
            'name': templateName,
            'language': {
              'code': 'en',
            },
            'parameters': {
              'body': {
                'parameters': [
                  for (String param in parameters)
                    {'type': 'text', 'text': param}
                ],
              }
            }
          }
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveMessageToHistory(
          phoneNumber: cleanedNumber,
          message: 'Template: $templateName',
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'template',
          status: 'sent',
          responseData: responseData,
        );

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Template send failed',
        };
      }
    } catch (e) {
      print('Error sending template: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Send media message (image, video, audio, document)
  Future<Map<String, dynamic>> sendWhatsAppMedia({
    required String to,
    required String mediaUrl,
    required String mediaType, // image, video, audio, document
    String? caption,
  }) async {
    try {
      final credentials = await _getApiCredentials();
      final instanceId = credentials['instanceId']!;
      final apiToken = credentials['apiToken']!;

      final cleanedNumber = to.replaceAll(RegExp(r'[^\d]'), '');

      final url =
          Uri.parse('$_apiUrl/$instanceId/messages/media?token=$apiToken');

      final body = {
        'to': cleanedNumber,
        'type': mediaType,
        'media': mediaUrl,
      };

      if (caption != null) {
        body['caption'] = caption;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Media send failed',
        };
      }
    } catch (e) {
      print('Error sending media: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Send alert to user (glucose alert, medication reminder, emergency alert)
  Future<Map<String, dynamic>> sendHealthAlert({
    required String to,
    required String
        alertType, // glucose_high, glucose_low, medication, emergency
    required Map<String, dynamic> data,
  }) async {
    try {
      String message = '';

      switch (alertType) {
        case 'glucose_high':
          message =
              '⚠️ *HIGH GLUCOSE ALERT*\n\nYour glucose is ${data['value']} mg/dL\n\n'
              'Target: 80-140 mg/dL\n'
              'Action: Check insulin, reduce carbs, drink water\n'
              'Time: ${DateTime.now().toString()}';
          break;

        case 'glucose_low':
          message =
              '🚨 *LOW GLUCOSE ALERT*\n\nYour glucose is ${data['value']} mg/dL\n\n'
              'Take immediate action:\n'
              '• Eat 15g fast carbs\n'
              '• Check again after 15 min\n'
              'Time: ${DateTime.now().toString()}';
          break;

        case 'medication':
          message = '💊 *MEDICATION REMINDER*\n\n${data['medicineName']}\n\n'
              'Dosage: ${data['dosage']}\n'
              'Time: ${data['time']}\n'
              'Do not skip!';
          break;

        case 'emergency':
          message = '🆘 *EMERGENCY ALERT*\n\n${data['message']}\n\n'
              'Emergency Contacts Notified\n'
              'Location: Shared\n'
              'Help Arriving Soon';
          break;

        default:
          message = data['message'] ?? 'Health Alert';
      }

      return await sendWhatsAppMessage(
        to: to,
        message: message,
      );
    } catch (e) {
      print('Error sending health alert: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get message status
  Future<Map<String, dynamic>> getMessageStatus(String messageId) async {
    try {
      final credentials = await _getApiCredentials();
      final instanceId = credentials['instanceId']!;
      final apiToken = credentials['apiToken']!;

      final url = Uri.parse(
          '$_apiUrl/$instanceId/messages/$messageId/status?token=$apiToken');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get status',
        };
      }
    } catch (e) {
      print('Error getting message status: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Save sent message to Firebase for history
  Future<void> _saveMessageToHistory({
    required String phoneNumber,
    required String message,
    required String messageId,
    required String type,
    required String status,
    required Map<String, dynamic> responseData,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('whatsapp_messages')
          .doc(messageId)
          .set({
        'phoneNumber': phoneNumber,
        'message': message,
        'messageId': messageId,
        'type': type,
        'status': status,
        'responseData': responseData,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving message to history: $e');
    }
  }

  /// Get message history
  Future<List<Map<String, dynamic>>> getMessageHistory({
    int limit = 50,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('whatsapp_messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting message history: $e');
      return [];
    }
  }

  /// Get instance status (check if instance is connected)
  Future<Map<String, dynamic>> getInstanceStatus() async {
    try {
      final credentials = await _getApiCredentials();
      final instanceId = credentials['instanceId']!;
      final apiToken = credentials['apiToken']!;

      final url =
          Uri.parse('$_apiUrl/$instanceId/instance/status?token=$apiToken');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'connected': data['accountStatus'] == 'connected',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'connected': false,
          'error': 'Failed to get instance status',
        };
      }
    } catch (e) {
      print('Error getting instance status: $e');
      return {
        'success': false,
        'connected': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Send pharmacy reminder or medicine availability notification
  Future<Map<String, dynamic>> sendMedicineNotification({
    required String to,
    required String medicineName,
    required String action, // available, outofstock, price_drop, reminder
  }) async {
    try {
      String message = '';

      switch (action) {
        case 'available':
          message = '✅ *$medicineName is now available*\n\n'
              'Stock: In Stock\n'
              'Tap to order now!';
          break;
        case 'outofstock':
          message = '❌ *$medicineName is out of stock*\n\n'
              'We will notify you when available.\n'
              'Check alternatives';
          break;
        case 'price_drop':
          message = '💰 *Price Drop Alert*\n\n'
              '$medicineName\n'
              'New Price: Lower than before\n'
              'Limited time offer!';
          break;
        case 'reminder':
          message = '💊 *Medicine Reminder*\n\n'
              '$medicineName\n'
              'Time to reorder\n'
              'Stock running low';
          break;
        default:
          message = medicineName;
      }

      return await sendWhatsAppMessage(
        to: to,
        message: message,
      );
    } catch (e) {
      print('Error sending medicine notification: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }
}
