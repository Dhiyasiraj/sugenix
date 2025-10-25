import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/cloudinary_service.dart';

class MedicalRecordsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add medical record
  Future<void> addMedicalRecord({
    required String type, // 'report', 'prescription', 'invoice'
    required String title,
    String? description,
    required List<XFile> images,
    DateTime? recordDate,
    String? addedBy,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      List<String> imageUrls = [];

      // Upload images to Cloudinary
      imageUrls = await CloudinaryService.uploadImages(images);

      // Save record to Firestore
      await _firestore.collection('medical_records').add({
        'userId': _auth.currentUser!.uid,
        'type': type,
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'recordDate': recordDate ?? FieldValue.serverTimestamp(),
        'addedBy': addedBy ?? _auth.currentUser!.displayName ?? 'User',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      throw Exception('Failed to add medical record: ${e.toString()}');
    }
  }

  // Get medical records for current user
  Stream<List<Map<String, dynamic>>> getMedicalRecords() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('medical_records')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('isActive', isEqualTo: true)
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

  // Get medical records by type
  Stream<List<Map<String, dynamic>>> getMedicalRecordsByType(String type) {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('medical_records')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
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

  // Update medical record
  Future<void> updateMedicalRecord({
    required String recordId,
    String? title,
    String? description,
    List<XFile>? newImages,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;

      // Handle new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = await CloudinaryService.uploadImages(
          newImages,
        );

        // Get existing images and add new ones
        DocumentSnapshot doc = await _firestore
            .collection('medical_records')
            .doc(recordId)
            .get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> existingImages = List<String>.from(
          data['imageUrls'] ?? [],
        );
        existingImages.addAll(newImageUrls);

        updateData['imageUrls'] = existingImages;
      }

      await _firestore
          .collection('medical_records')
          .doc(recordId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update medical record: ${e.toString()}');
    }
  }

  // Delete medical record (soft delete)
  Future<void> deleteMedicalRecord(String recordId) async {
    try {
      await _firestore.collection('medical_records').doc(recordId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete medical record: ${e.toString()}');
    }
  }

  // Get medical record statistics
  Future<Map<String, dynamic>> getMedicalRecordsStatistics() async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await _firestore
          .collection('medical_records')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('isActive', isEqualTo: true)
          .get();

      int totalRecords = snapshot.docs.length;
      int reports = 0;
      int prescriptions = 0;
      int invoices = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String type = data['type'] as String;
        switch (type) {
          case 'report':
            reports++;
            break;
          case 'prescription':
            prescriptions++;
            break;
          case 'invoice':
            invoices++;
            break;
        }
      }

      return {
        'totalRecords': totalRecords,
        'reports': reports,
        'prescriptions': prescriptions,
        'invoices': invoices,
      };
    } catch (e) {
      throw Exception(
        'Failed to get medical records statistics: ${e.toString()}',
      );
    }
  }

  // Search medical records
  Future<List<Map<String, dynamic>>> searchMedicalRecords(String query) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await _firestore
          .collection('medical_records')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String title = (data['title'] as String? ?? '').toLowerCase();
        String description = (data['description'] as String? ?? '')
            .toLowerCase();
        String type = (data['type'] as String? ?? '').toLowerCase();

        if (title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            type.contains(query.toLowerCase())) {
          data['id'] = doc.id;
          results.add(data);
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search medical records: ${e.toString()}');
    }
  }

  // Share medical record (generate shareable link)
  Future<String> generateShareableLink(String recordId) async {
    try {
      // In a real implementation, you would create a secure shareable link
      // For now, we'll return a placeholder
      return 'https://sugenix.app/medical-record/$recordId';
    } catch (e) {
      throw Exception('Failed to generate shareable link: ${e.toString()}');
    }
  }

  // Export medical records (generate PDF or other format)
  Future<List<Map<String, dynamic>>> exportMedicalRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      Query query = _firestore
          .collection('medical_records')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('isActive', isEqualTo: true);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to export medical records: ${e.toString()}');
    }
  }
}
