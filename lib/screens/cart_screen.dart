import 'package:flutter/material.dart';
import 'package:sugenix/services/medicine_cart_service.dart';
import 'package:sugenix/services/razorpay_service.dart';
import 'package:sugenix/services/auth_service.dart';
import 'package:sugenix/services/platform_settings_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MedicineCartService _cartService = MedicineCartService();
  final AuthService _authService = AuthService();
  final PlatformSettingsService _platformSettings = PlatformSettingsService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPaymentMethod = 'COD'; // 'COD' or 'Razorpay'
  bool _processingPayment = false;
  Map<String, dynamic>? _userProfile;
  double _cartSubtotal = 0.0;
  double _platformFee = 0.0;
  double _cartTotal = 0.0;
  bool _isGuest = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    RazorpayService.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      // User is logged in
      setState(() {
        _isGuest = false;
      });
      await _loadUserProfile();
    } else {
      // Guest user
      setState(() {
        _isGuest = true;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    setState(() {
      _userProfile = profile;
      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
      }
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

      // Get customer details
      final name = _isGuest ? _nameController.text.trim() : (_userProfile?['name'] ?? 'User');
      final email = _isGuest ? _emailController.text.trim() : (_userProfile?['email'] ?? _authService.currentUser?.email ?? '');
      final phone = _isGuest ? _phoneController.text.trim() : (_userProfile?['phone'] ?? '');

      if (name.isEmpty || email.isEmpty || phone.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all customer details')),
          );
        }
        return;
      }

      final finalOrderId = await _cartService.checkout(
        address: address,
        customerName: name,
        customerEmail: email,
        customerPhone: phone,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        razorpayOrderId: orderId,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully! Order ID: #$finalOrderId'),
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

    // Get customer details (from profile if logged in, or from form if guest)
    final name = _isGuest ? _nameController.text.trim() : (_userProfile?['name'] ?? 'User');
    final email = _isGuest ? _emailController.text.trim() : (_userProfile?['email'] ?? _authService.currentUser?.email ?? '');
    final phone = _isGuest ? _phoneController.text.trim() : (_userProfile?['phone'] ?? '');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required for payment')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required')),
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
        phone: phone,
        description: 'Medicine Order Payment - Sugenix',
        notes: {
          'order_type': 'medicine',
          'user_id': _authService.currentUser?.uid ?? 'guest',
          'is_guest': _isGuest.toString(),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey(_refreshKey),
              future: _cartService.getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _cartTotal = 0.0);
                  });
                  return const Center(
                    child: Text('Your cart is empty', style: TextStyle(color: Colors.grey)),
                  );
                }
                double subtotal = 0.0;
                for (final i in items) {
                  final price = (i['price'] as num?)?.toDouble() ?? 0.0;
                  final qty = (i['quantity'] as int?) ?? 1;
                  subtotal += price * qty;
                }
                
                // Calculate platform fee and total
                _platformSettings.calculatePlatformFee(subtotal).then((feeCalc) {
                  if (mounted) {
                    setState(() {
                      _cartSubtotal = subtotal;
                      _platformFee = feeCalc['platformFee'] ?? 0.0;
                      _cartTotal = feeCalc['totalAmount'] ?? subtotal;
                    });
                  }
                });
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
                            if (_isGuest) ...[
                              const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Full Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Email Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  hintText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                            ],
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
                                onPressed: () async {
                                  await _cartService.updateQuantity(item['id'] as String, qty - 1);
                                  setState(() => _refreshKey++);
                                },
                              ),
                              Text(qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () async {
                                  await _cartService.updateQuantity(item['id'] as String, qty + 1);
                                  setState(() => _refreshKey++);
                                },
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
                      await _processPayment(_cartTotal);
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


