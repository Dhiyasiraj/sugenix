import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineCartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cartCol =>
      _db.collection('users').doc(_uid).collection('cart');

  CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _db.collection('orders');

  Stream<List<Map<String, dynamic>>> streamCartItems() {
    return _cartCol.snapshots().map(
      (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  Future<void> addToCart({
    required String medicineId,
    required String name,
    required double price,
    int quantity = 1,
    String? manufacturer,
  }) async {
    final doc = _cartCol.doc(medicineId);
    final existing = await doc.get();
    if (existing.exists) {
      final q = (existing.data()!['quantity'] as int? ?? 1) + quantity;
      await doc.update({'quantity': q});
    } else {
      await doc.set({
        'medicineId': medicineId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'manufacturer': manufacturer,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateQuantity(String medicineId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(medicineId);
    } else {
      await _cartCol.doc(medicineId).update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String medicineId) async {
    await _cartCol.doc(medicineId).delete();
  }

  Future<void> clearCart() async {
    final snap = await _cartCol.get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }

  Future<String> checkout({
    required String address,
    String paymentMethod = 'COD',
    String? paymentId,
    String? orderId,
  }) async {
    final cartSnap = await _cartCol.get();
    if (cartSnap.docs.isEmpty) {
      throw Exception('Cart is empty');
    }

    double total = 0.0;
    final items = cartSnap.docs.map((d) {
      final data = d.data();
      final qty = (data['quantity'] as int? ?? 1);
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      total += price * qty;
      return {'id': d.id, ...data};
    }).toList();

    // Get pharmacy ID from first item (if available)
    String? pharmacyId;
    if (items.isNotEmpty) {
      // Try to get pharmacyId from medicine data
      final firstItem = items.first;
      if (firstItem.containsKey('pharmacyId')) {
        pharmacyId = firstItem['pharmacyId'] as String?;
      }
    }

    final orderData = {
      'userId': _uid,
      'status': paymentMethod == 'Razorpay' && paymentId != null ? 'confirmed' : 'placed',
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentMethod == 'Razorpay' ? 'paid' : 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      if (paymentId != null) 'paymentId': paymentId,
      if (orderId != null) 'razorpayOrderId': orderId,
      if (pharmacyId != null) 'pharmacyId': pharmacyId,
    };

    final orderRef = await _ordersCol.add(orderData);

    final batch = _db.batch();
    for (final item in items) {
      final itemRef = orderRef.collection('orderItems').doc(item['id'] as String);
      batch.set(itemRef, item);
      batch.delete(_cartCol.doc(item['id'] as String));
    }
    await batch.commit();

    return orderRef.id;
  }
}


