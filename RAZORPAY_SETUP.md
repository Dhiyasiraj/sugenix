# Razorpay Payment Integration Setup

This document explains how to set up Razorpay payment integration for medicine purchases.

## Step 1: Get Razorpay Test Keys

1. Go to [https://razorpay.com/](https://razorpay.com/)
2. Sign up for a free account
3. Go to **Dashboard** > **Settings** > **API Keys**
4. Click on **Generate Test Keys** (No KYC required for test mode)
5. Copy your **Key ID** (starts with `rzp_test_`)

## Step 2: Update the Code

1. Open `lib/services/razorpay_service.dart`
2. Replace the test key with your actual Razorpay test key:

```dart
static const String _keyId = 'your_razorpay_test_key_id_here';
```

## Step 3: Test Payment Flow

### Test Cards (No Real Money Required)

Use these test card numbers for testing:

**Success Cards:**
- Card Number: `4111 1111 1111 1111`
- CVV: Any 3 digits (e.g., `123`)
- Expiry: Any future date (e.g., `12/25`)
- Name: Any name

**Failure Cards:**
- Card Number: `4000 0000 0000 0002` (for declined payment)

### Test UPI IDs
- Use any UPI ID (e.g., `success@razorpay`)

## Step 4: Payment Flow

1. Patient adds medicines to cart
2. Patient goes to cart screen
3. Patient enters delivery address
4. Patient selects payment method:
   - **Cash on Delivery (COD)**: Order placed immediately
   - **Online Payment (Razorpay)**: Opens Razorpay checkout
5. After successful payment, order is confirmed automatically

## Features

- ✅ Test mode (no KYC required)
- ✅ Multiple payment methods (Cards, UPI, Wallets, Net Banking)
- ✅ Automatic order confirmation on payment success
- ✅ Payment status tracking
- ✅ Error handling for failed payments

## Payment Status

- **COD Orders**: Status = 'placed', Payment Status = 'pending'
- **Razorpay Orders**: Status = 'confirmed', Payment Status = 'paid'

## Security Notes

- Test keys are safe to use in client-side code
- Never use live keys in test mode
- For production, implement server-side order creation and verification
- Test keys don't process real money

## Troubleshooting

- **Payment not opening**: Check that Razorpay key is correct
- **Payment fails**: Verify test card details are correct
- **Order not created**: Check internet connection and Firestore permissions

## Production Setup

For production:
1. Get live keys from Razorpay (requires KYC)
2. Implement server-side order creation
3. Verify payment signatures on server
4. Update key in `razorpay_service.dart`

