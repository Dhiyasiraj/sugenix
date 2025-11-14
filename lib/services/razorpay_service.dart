import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static Razorpay? _razorpay;
  
  // Razorpay Test Keys (No KYC required)
  // Get these from: https://razorpay.com/docs/payments/server-integration/test-keys/
  // Or from your Razorpay Dashboard > Settings > API Keys > Test Keys
  // Just use the Key ID - no secret key needed for client-side integration
  static const String _keyId = 'rzp_test_1DP5mmOlF5G5ag'; // Test Key ID - Replace with your own
  
  // Callbacks for payment events
  static Function(PaymentSuccessResponse)? onSuccess;
  static Function(PaymentFailureResponse)? onError;
  static Function(ExternalWalletResponse)? onExternalWallet;

  /// Initialize Razorpay with callbacks
  static void initialize({
    Function(PaymentSuccessResponse)? onSuccessCallback,
    Function(PaymentFailureResponse)? onErrorCallback,
    Function(ExternalWalletResponse)? onExternalWalletCallback,
  }) {
    onSuccess = onSuccessCallback;
    onError = onErrorCallback;
    onExternalWallet = onExternalWalletCallback;
    
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Open Razorpay checkout
  static Future<void> openCheckout({
    required double amount,
    required String name,
    required String email,
    required String phone,
    String? description,
    Map<String, dynamic>? notes,
  }) async {
    if (_razorpay == null) {
      initialize();
    }

    final options = {
      'key': _keyId,
      'amount': (amount * 100).toInt(), // Amount in paise (multiply by 100)
      'name': 'Sugenix',
      'description': description ?? 'Medicine Order Payment',
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'external': {
        'wallets': ['paytm'], // Optional: Enable specific wallets
      },
      'theme': {
        'color': '#0C4556', // Your app's primary color
      },
      if (notes != null) 'notes': notes,
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      print('Razorpay Error: $e');
      // Error will be handled by _handlePaymentError when Razorpay SDK calls it
      // For now, just log the error
    }
  }

  /// Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  /// Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    if (onError != null) {
      onError!(response);
    }
  }

  /// Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  /// Dispose Razorpay
  static void dispose() {
    if (_razorpay != null) {
      _razorpay!.clear();
      _razorpay = null;
    }
    onSuccess = null;
    onError = null;
    onExternalWallet = null;
  }
}
