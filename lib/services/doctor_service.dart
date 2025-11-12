import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/models/doctor.dart';

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Doctor>> streamDoctors() {
    return _db.collection('doctors')
        .where('approvalStatus', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure id field presence
        return Doctor.fromJson({
          'id': data['id'] ?? doc.id,
          ...data,
        });
      }).toList();
    });
  }

  Future<List<Doctor>> getDoctors() async {
    final snapshot = await _db.collection('doctors')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Doctor.fromJson({
        'id': data['id'] ?? doc.id,
        ...data,
      });
    }).toList();
  }

  // Get pending doctors for admin approval
  Stream<List<Map<String, dynamic>>> getPendingDoctors() {
    return _db.collection('doctors')
        .where('approvalStatus', isEqualTo: 'pending')
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

  // Approve or reject a doctor
  Future<void> updateDoctorApprovalStatus(String doctorId, String status) async {
    await _db.collection('doctors').doc(doctorId).update({
      'approvalStatus': status,
      'approvedAt': status == 'approved' ? FieldValue.serverTimestamp() : null,
    });
    
    // Also update in users collection
    await _db.collection('users').doc(doctorId).update({
      'approvalStatus': status,
    });
  }
}


