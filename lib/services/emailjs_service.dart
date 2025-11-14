import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailJSService {
  // EmailJS Configuration
  // TODO: Replace these with your actual EmailJS credentials
  // Get these from https://www.emailjs.com/
  // 1. Sign up at https://www.emailjs.com/
  // 2. Create an email service (Gmail, Outlook, etc.)
  // 3. Create ONE email template (see EMAILJS_SETUP.md for template content)
  // 4. Get your Public Key from Account > API Keys
  static const String _serviceId = 'service_f6ka8jm'; // Your EmailJS Service ID
  static const String _templateId = 'template_u50mo7i'; // Your Single Template ID
  static const String _publicKey = 'CHxG3ZYeXEUuvz1MA'; // Your EmailJS Public Key
  static const String _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Send approval email to pharmacy or doctor
  static Future<bool> sendApprovalEmail({
    required String recipientEmail,
    required String recipientName,
    required String role, // 'pharmacy' or 'doctor'
  }) async {
    try {
      // Draft email content from code
      final subject = 'Account Approved - Sugenix';
      final title = 'Congratulations! Your Account Has Been Approved';
      
      final message = role == 'pharmacy'
          ? '''Dear ${recipientName},

We are pleased to inform you that your pharmacy account has been successfully approved by our admin team.

You can now log in to Sugenix and start:
• Managing your medicine inventory
• Adding new medicines to your catalog
• Processing orders from patients
• Tracking your sales and revenue

Welcome to the Sugenix platform! We look forward to working with you.

Best regards,
Sugenix Team'''
          : '''Dear ${recipientName},

We are pleased to inform you that your doctor account has been successfully approved by our admin team.

You can now log in to Sugenix and start:
• Accepting appointments from patients
• Managing your schedule
• Viewing patient medical records
• Providing consultations

Welcome to the Sugenix platform! We look forward to working with you.

Best regards,
Sugenix Team''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'to_name': recipientName,
            'subject': subject,
            'title': title,
            'message': message,
            'app_name': 'Sugenix',
            'login_url': 'https://sugenix.app/login',
            'support_email': 'support@sugenix.app',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Approval email sent successfully to $recipientEmail');
        return true;
      } else {
        print('EmailJS Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS Error: $e');
      return false;
    }
  }

  /// Send rejection email to pharmacy or doctor
  static Future<bool> sendRejectionEmail({
    required String recipientEmail,
    required String recipientName,
    required String role, // 'pharmacy' or 'doctor'
    String? reason,
  }) async {
    try {
      // Draft email content from code
      final subject = 'Account Application Status - Sugenix';
      final title = 'Account Application Update';
      
      final defaultMessage = '''Dear ${recipientName},

We regret to inform you that your ${role == 'pharmacy' ? 'pharmacy' : 'doctor'} account application has been reviewed and unfortunately, we are unable to approve it at this time.

Please review your application details and ensure all required information and documents are provided correctly. If you believe this is an error or have any questions, please contact our support team.

We appreciate your interest in joining the Sugenix platform.''';

      final message = reason != null && reason.isNotEmpty
          ? '''Dear ${recipientName},

We regret to inform you that your ${role == 'pharmacy' ? 'pharmacy' : 'doctor'} account application has been reviewed and unfortunately, we are unable to approve it at this time.

Reason: $reason

Please review your application details and ensure all required information and documents are provided correctly. If you have any questions, please contact our support team.

We appreciate your interest in joining the Sugenix platform.'''
          : defaultMessage;

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'to_name': recipientName,
            'subject': subject,
            'title': title,
            'message': message,
            'app_name': 'Sugenix',
            'support_email': 'support@sugenix.app',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Rejection email sent successfully to $recipientEmail');
        return true;
      } else {
        print('EmailJS Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS Error: $e');
      return false;
    }
  }
}

