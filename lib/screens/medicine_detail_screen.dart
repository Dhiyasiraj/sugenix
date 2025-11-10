import 'package:flutter/material.dart';
import 'package:sugenix/services/medicine_cart_service.dart';
import 'package:sugenix/utils/responsive_layout.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final MedicineCartService _cart = MedicineCartService();
  int _qty = 1;
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    final name = (m['name'] as String?) ?? 'Medicine';
    final manufacturer = (m['manufacturer'] as String?) ?? '';
    final description = (m['description'] as String?) ?? '';
    final price = (m['price'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0C4556),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: ResponsiveHelper.isMobile(context) ? 180 : 220,
              decoration: BoxDecoration(
                color: const Color(0xFF0C4556).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.medication, color: Color(0xFF0C4556), size: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                color: const Color(0xFF0C4556),
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              ),
            ),
            const SizedBox(height: 6),
            if (manufacturer.isNotEmpty)
              Text(
                manufacturer,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF0C4556),
                    fontWeight: FontWeight.w800,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                  ),
                ),
                const Spacer(),
                _buildQtySelector(),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF0C4556),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : 'No description provided.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _adding ? null : () => _addToCart(m, price),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4556),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _adding
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              setState(() {
                if (_qty > 1) _qty--;
              });
            },
          ),
          Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0C4556))),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              setState(() {
                _qty++;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> m, double price) async {
    setState(() => _adding = true);
    try {
      await _cart.addToCart(
        medicineId: (m['id'] as String?) ?? (m['name'] as String? ?? 'item'),
        name: (m['name'] as String?) ?? 'Medicine',
        price: price,
        quantity: _qty,
        manufacturer: m['manufacturer'] as String?,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }
}


