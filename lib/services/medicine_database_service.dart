import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get medicine by name or partial match
  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final queryLower = query.toLowerCase();
      
      // Search in medicines collection
      QuerySnapshot snapshot = await _firestore
          .collection('medicines')
          .where('name', isGreaterThanOrEqualTo: queryLower)
          .where('name', isLessThan: queryLower + 'z')
          .limit(20)
          .get();

      List<Map<String, dynamic>> results = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] as String? ?? '').toLowerCase();
        final description = (data['description'] as String? ?? '').toLowerCase();
        
        // Check if query matches name or description
        if (name.contains(queryLower) || description.contains(queryLower)) {
          results.add({
            'id': doc.id,
            ...data,
          });
        }
      }

      // Also try searching by description if no results
      if (results.isEmpty) {
        final descSnapshot = await _firestore
            .collection('medicines')
            .where('description', isGreaterThanOrEqualTo: queryLower)
            .where('description', isLessThan: queryLower + 'z')
            .limit(20)
            .get();

        for (var doc in descSnapshot.docs) {
          final data = doc.data();
          results.add({
            'id': doc.id,
            ...data,
          });
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search medicines: ${e.toString()}');
    }
  }

  // Get medicine by ID
  Future<Map<String, dynamic>?> getMedicineById(String medicineId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('medicines')
          .doc(medicineId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get medicine: ${e.toString()}');
    }
  }

  // Get medicine by barcode or image hash (for scanning)
  Future<Map<String, dynamic>?> getMedicineByBarcode(String barcode) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('medicines')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get medicine by barcode: ${e.toString()}');
    }
  }

  // Get all medicines (with pagination)
  Stream<List<Map<String, dynamic>>> getAllMedicines({int limit = 50}) {
    return _firestore
        .collection('medicines')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Save scanned medicine result (for future reference)
  Future<void> saveScannedMedicine({
    required String imageUrl,
    required Map<String, dynamic> medicineInfo,
    String? barcode,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      await _firestore.collection('scanned_medicines').add({
        'userId': _auth.currentUser!.uid,
        'imageUrl': imageUrl,
        'medicineInfo': medicineInfo,
        'barcode': barcode,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save scanned medicine: ${e.toString()}');
    }
  }

  // Get user's scanned medicines history
  Stream<List<Map<String, dynamic>>> getScannedMedicinesHistory() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('scanned_medicines')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }
}

