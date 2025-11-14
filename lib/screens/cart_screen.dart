import 'package:flutter/material.dart';
import 'package:sugenix/services/medicine_cart_service.dart';
import 'package:sugenix/services/razorpay_service.dart';
import 'package:sugenix/services/auth_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sugenix/widgets/translated_text.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MedicineCartService _cartService = MedicineCartService();
  final AuthService _authService = AuthService();
  final TextEditingController _addressController = TextEditingController();
  String _selectedPaymentMethod = 'COD'; // 'COD' or 'Razorpay'
  bool _processingPayment = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _addressController.dispose();
    RazorpayService.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  void _initializeRazorpay() {
    RazorpayService.initialize(
      onSuccessCallback: _handlePaymentSuccess,
      onErrorCallback: _handlePaymentError,
      onExternalWalletCallback: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _processingPayment = false;
    });
    
    // Complete the order with payment details
    _completeOrder(
      paymentMethod: 'Razorpay',
      paymentId: response.paymentId,
      orderId: response.orderId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _processingPayment = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
        ),
      );
    }
  }

  Future<void> _completeOrder({
    required String paymentMethod,
    String? paymentId,
    String? orderId,
  }) async {
    try {
      final address = _addressController.text.trim();
      if (address.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter address')),
          );
        }
        return;
      }

      final orderId = await _cartService.checkout(
        address: address,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully! Order ID: #$orderId'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(double amount) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    final name = _userProfile?['name'] ?? 'User';
    final email = _userProfile?['email'] ?? _authService.currentUser?.email ?? '';
    final phone = _userProfile?['phone'] ?? '';

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required for payment')),
      );
      return;
    }

    setState(() {
      _processingPayment = true;
    });

    try {
      await RazorpayService.openCheckout(
        amount: amount,
        name: name,
        email: email,
        phone: phone.isNotEmpty ? phone : '9999999999',
        description: 'Medicine Order Payment - Sugenix',
        notes: {
          'order_type': 'medicine',
          'user_id': _authService.currentUser?.uid ?? '',
        },
      );
    } catch (e) {
      setState(() {
        _processingPayment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
        actions: [
          TextButton(
            onPressed: () async {
              await _cartService.clearCart();
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFF0C4556))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _cartService.streamCartItems(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty', style: TextStyle(color: Colors.grey)),
                  );
                }
                double total = 0.0;
                for (final i in items) {
                  final price = (i['price'] as num?)?.toDouble() ?? 0.0;
                  final qty = (i['quantity'] as int?) ?? 1;
                  total += price * qty;
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                hintText: 'Enter delivery address',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Cash on Delivery'),
                                    value: 'COD',
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Online Payment'),
                                    value: 'Razorpay',
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('₹${total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C4556))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    final item = items[index];
                    final name = (item['name'] as String?) ?? '';
                    final manufacturer = (item['manufacturer'] as String?) ?? '';
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final qty = (item['quantity'] as int?) ?? 1;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.medication, color: Color(0xFF0C4556)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
                        subtitle: Text(
                          (manufacturer.isNotEmpty ? manufacturer : 'Medicine') +
                              ' • ₹' + price.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _cartService.updateQuantity(item['id'] as String, qty - 1),
                              ),
                              Text(qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _cartService.updateQuantity(item['id'] as String, qty + 1),
                              ),
                            ],
                          ),
                        ),
                        dense: true,
                        minVerticalPadding: 8,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        subtitleTextStyle: const TextStyle(color: Colors.grey),
                        onTap: () {},
                        isThreeLine: false,
                        // Show price under the title line
                        // Using trailing area for qty; include price in subtitle
                        // Already referenced via 'price' variable
                        
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4556),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _processingPayment ? null : () async {
                    if (_selectedPaymentMethod == 'Razorpay') {
                      // Process Razorpay payment
                      await _processPayment(total);
                    } else {
                      // Process COD order
                      await _completeOrder(paymentMethod: 'COD');
                    }
                  },
                  child: _processingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _selectedPaymentMethod == 'Razorpay' ? 'Pay Now' : 'Place Order (COD)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6F8),
    );
  }
}


