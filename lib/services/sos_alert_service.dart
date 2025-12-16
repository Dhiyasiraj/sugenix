import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'emergency_service.dart';

class SOSAlertService {
  final Telephony _telephony = Telephony.instance;
  final EmergencyService _emergencyService = EmergencyService();

  Future<Map<String, dynamic>> triggerSOSAlert() async {
    try {
      final contacts =
          await _emergencyService.getEmergencyContacts().first;

      if (contacts.isEmpty) {
        return {
          'success': false,
          'error': 'No emergency contacts found'
        };
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationLink =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      final message = '''
🚨 SOS ALERT 🚨
I need immediate help!

📍 My location:
$locationLink
''';

      int sentCount = 0;
      List<Map<String, dynamic>> details = [];

      for (var contact in contacts) {
        final phone = contact['phone'];

        try {
          await _telephony.sendSms(
            to: phone,
            message: message,
          );

          sentCount++;
          details.add({
            'contact': contact['name'],
            'phone': phone,
            'status': 'sent',
          });
        } catch (_) {
          details.add({
            'contact': contact['name'],
            'phone': phone,
            'status': 'failed',
          });
        }
      }

      return {
        'success': true,
        'contactsNotified': sentCount,
        'notificationDetails': details,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
