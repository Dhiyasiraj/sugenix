import 'package:flutter/material.dart';
import 'package:sugenix/services/medicine_cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MedicineCartService _cartService = MedicineCartService();
  String _address = '';

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
                            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter address',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) => _address = v,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('₹${total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
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
                  onPressed: () async {
                    try {
                      if (_address.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter address')),
                        );
                        return;
                      }
                      final orderId = await _cartService.checkout(address: _address.trim());
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order placed: #$orderId')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Checkout failed: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Place Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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


