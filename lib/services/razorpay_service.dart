import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  
  // Razorpay Test Keys (Test Mode - No KYC required)
  // Get your test key from: https://dashboard.razorpay.com/app/keys
  // Use Test Mode keys (starts with rzp_test_)
  static const String _testKeyId = 'rzp_test_1DP5mmOlF5M5fd'; // TODO: Replace with your Razorpay test key from dashboard
  // Note: Key Secret is not needed in Flutter SDK, only Key ID is required
  
  Function(String)? onPaymentSuccess;
  Function(String)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response.paymentId ?? '');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response.message ?? 'Payment failed');
    }
    if (onPaymentFailure != null) {
      onPaymentFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  // Open Razorpay checkout
  void openCheckout({
    required double amount,
    required String appointmentId,
    required String patientName,
    required String patientEmail,
    required String patientPhone,
    String? description,
  }) {
    final options = {
      'key': _testKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Sugenix',
      'description': description ?? 'Appointment Consultation Fee',
      'prefill': {
        'contact': patientPhone,
        'email': patientEmail,
        'name': patientName,
      },
      'external': {
        'wallets': ['paytm'], // Optional: enable specific wallets
      },
      'theme': {
        'color': '#0C4556', // Sugenix brand color
      },
      'notes': {
        'appointment_id': appointmentId,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (onPaymentError != null) {
        onPaymentError!('Failed to open payment gateway: $e');
      }
    }
  }

  // Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}

