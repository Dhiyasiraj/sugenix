import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/cloudinary_service.dart';

class MedicineOrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add medicine to cart
  Future<void> addToCart({
    required String medicineId,
    required String medicineName,
    required double price,
    required int quantity,
    String? prescriptionId,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      // Check if item already exists in cart
      QuerySnapshot existingItem = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('medicineId', isEqualTo: medicineId)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Update quantity
        String cartItemId = existingItem.docs.first.id;
        await _firestore.collection('cart').doc(cartItemId).update({
          'quantity': FieldValue.increment(quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item to cart
        await _firestore.collection('cart').add({
          'userId': _auth.currentUser!.uid,
          'medicineId': medicineId,
          'medicineName': medicineName,
          'price': price,
          'quantity': quantity,
          'prescriptionId': prescriptionId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }

  // Get cart items
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await _firestore.collection('cart').doc(cartItemId).delete();
      } else {
        await _firestore.collection('cart').doc(cartItemId).update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update cart item: ${e.toString()}');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('cart').doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot cartItems = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Place order
  Future<String> placeOrder({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? prescriptionId,
    String? notes,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      // Get cart items
      QuerySnapshot cartItems = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      if (cartItems.docs.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Calculate total
      double total = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var doc in cartItems.docs) {
        Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        double itemTotal =
            (item['price'] as double) * (item['quantity'] as int);
        total += itemTotal;

        orderItems.add({
          'medicineId': item['medicineId'],
          'medicineName': item['medicineName'],
          'price': item['price'],
          'quantity': item['quantity'],
        });
      }

      // Create order
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'userId': _auth.currentUser!.uid,
        'orderNumber': _generateOrderNumber(),
        'items': orderItems,
        'total': total,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'prescriptionId': prescriptionId,
        'notes': notes,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cart after successful order
      await clearCart();

      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to place order: ${e.toString()}');
    }
  }

  // Get user orders
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Upload prescription
  Future<String> uploadPrescription(List<XFile> images) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      final cloudinaryService = CloudinaryService();
      List<String> imageUrls = await cloudinaryService.uploadImages(images);

      // Save prescription to Firestore
      DocumentReference prescriptionRef = await _firestore
          .collection('prescriptions')
          .add({
            'userId': _auth.currentUser!.uid,
            'imageUrls': imageUrls,
            'status': 'pending_verification',
            'createdAt': FieldValue.serverTimestamp(),
          });

      return prescriptionRef.id;
    } catch (e) {
      throw Exception('Failed to upload prescription: ${e.toString()}');
    }
  }

  // Get prescriptions
  Stream<List<Map<String, dynamic>>> getPrescriptions() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('prescriptions')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Search medicines
  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    try {
      // In a real implementation, you would search a medicines database
      // For now, we'll return mock data
      return [
            {
              'id': '1',
              'name': 'Metformin 500mg',
              'description': 'Diabetes medication',
              'price': 25.50,
              'manufacturer': 'Generic Pharma',
              'available': true,
            },
            {
              'id': '2',
              'name': 'Insulin Glargine',
              'description': 'Long-acting insulin',
              'price': 45.00,
              'manufacturer': 'MediCorp',
              'available': true,
            },
            {
              'id': '3',
              'name': 'Glucose Test Strips',
              'description': 'Blood glucose test strips',
              'price': 15.75,
              'manufacturer': 'TestCorp',
              'available': true,
            },
          ]
          .where(
            (medicine) =>
                (medicine['name'] as String).toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (medicine['description'] as String).toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search medicines: ${e.toString()}');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      int totalOrders = orders.docs.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalSpent = 0;

      for (var doc in orders.docs) {
        Map<String, dynamic> order = doc.data() as Map<String, dynamic>;
        String status = order['status'] as String;
        double total = (order['total'] as double?) ?? 0;

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'completed':
            completedOrders++;
            totalSpent += total;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: ${e.toString()}');
    }
  }

  // Generate order number
  String _generateOrderNumber() {
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    return 'SUG${timestamp.substring(timestamp.length - 8)}';
  }
}
