# Razorpay Integration - Testing Guide

## Overview
This document explains how to test the Razorpay payment integration with dummy/test credentials.

## Current Setup

The app uses Razorpay test mode with dummy credentials. The integration is located in:
- **Service**: `lib/services/razorpay_service.dart`
- **Usage**: `lib/screens/cart_screen.dart`

## Getting Your Own Test Keys

To test with your own Razorpay account:

1. **Sign up for Razorpay** (Free, no KYC required for test mode)
   - Visit: https://razorpay.com/
   - Click "Sign Up" and create an account

2. **Get Test Keys**
   - Go to: https://dashboard.razorpay.com/app/keys
   - Make sure you're in **Test Mode** (toggle at top right)
   - Click **Generate Test Keys** if you don't have them
   - Copy your **Key ID** (starts with `rzp_test_`)

3. **Update the Code**
   - Open `lib/services/razorpay_service.dart`
   - Replace line 15:
   ```dart
   static const String _keyId = 'rzp_test_YOUR_ACTUAL_KEY_HERE';
   ```

## Testing with Dummy Credentials

If you don't have a Razorpay account, you can use the current dummy key. However, for full functionality, you'll need your own test keys.

### Test Card Numbers

When testing payment, use these test card numbers:

**✅ Success Cards:**
- **Card Number**: `4111 1111 1111 1111`
- **CVV**: Any 3 digits (e.g., `123`, `456`)
- **Expiry**: Any future date (e.g., `12/25`, `05/27`)
- **Name**: Any name

**❌ Failure Cards:**
- **Card Number**: `4000 0000 0000 0002` (Payment declined)
- **Card Number**: `4000 0000 0000 0069` (Insufficient funds)

### Test UPI IDs

For UPI testing:
- Use any UPI ID format: `success@razorpay` or `test@upi`
- The payment will be processed in test mode

### Test Wallet Payments

For wallet testing (Paytm, etc.):
- Use test mode wallet credentials
- Transactions won't charge real money

## Payment Flow

1. **User adds items to cart**
2. **User navigates to cart screen**
3. **User fills delivery address and customer details** (if guest)
4. **User selects payment method:**
   - **Cash on Delivery (COD)**: Order placed immediately with success animation
   - **Online Payment (Razorpay)**: Opens Razorpay checkout dialog
5. **For Razorpay:**
   - User enters payment details (card, UPI, wallet, etc.)
   - Payment is processed
   - On success: Order is automatically confirmed with payment details
   - On failure: Error message shown, user can retry

## Features

✅ **Multiple Payment Methods**
   - Credit/Debit Cards
   - UPI
   - Wallets (Paytm, etc.)
   - Net Banking

✅ **Validation**
   - Email format validation
   - Phone number validation (minimum 10 digits)
   - Amount validation (must be > 0)

✅ **Error Handling**
   - Payment failure handling
   - Invalid credentials handling
   - Network error handling

✅ **Order Integration**
   - Payment details saved to order
   - Order status updated automatically
   - Payment status tracking

## Code Structure

### RazorpayService

```dart
// Initialize Razorpay
RazorpayService.initialize(
  onSuccessCallback: (response) {
    // Handle successful payment
  },
  onErrorCallback: (response) {
    // Handle payment error
  },
  onExternalWalletCallback: (response) {
    // Handle external wallet selection
  },
);

// Open checkout
RazorpayService.openCheckout(
  amount: 1000.0,  // Amount in rupees
  name: 'John Doe',
  email: 'john@example.com',
  phone: '9876543210',
  description: 'Medicine Order Payment',
);
```

## Troubleshooting

### Payment dialog doesn't open
- Check if Razorpay key is valid
- Ensure internet connection
- Check console for error messages

### Payment fails immediately
- Verify test key is correct
- Check if you're using test mode
- Ensure amount is greater than 0

### "Invalid key" error
- Verify key format: `rzp_test_XXXXXXXXXX`
- Ensure you're using test key (not live key)
- Generate new test keys from Razorpay dashboard

### Payment succeeds but order not created
- Check Firebase connection
- Verify order creation logic in `_completeOrder` method
- Check console for error logs

## Production Deployment

⚠️ **IMPORTANT**: Before going live:

1. **Complete Razorpay KYC**
   - Visit Razorpay dashboard
   - Complete business verification
   - Get approval

2. **Switch to Live Mode**
   - Generate live keys from dashboard
   - Replace test key with live key in `razorpay_service.dart`
   - Test thoroughly in live mode

3. **Server-Side Verification** (Recommended)
   - Implement server-side order creation
   - Verify payment signatures server-side
   - This is more secure than client-side only

## Security Notes

- ✅ Test keys are safe to use in client-side code
- ✅ No real money is charged in test mode
- ⚠️ Never commit live keys to version control
- ⚠️ Always verify payments server-side in production
- ⚠️ Use environment variables for keys in production

## Support

For Razorpay documentation:
- API Docs: https://razorpay.com/docs/payments/server-integration/test-keys/
- Dashboard: https://dashboard.razorpay.com/
- Support: https://razorpay.com/support/

