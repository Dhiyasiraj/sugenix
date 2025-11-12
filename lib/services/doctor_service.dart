import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/models/doctor.dart';

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Doctor>> streamDoctors() {
    return _db.collection('doctors').snapshots().map((snapshot) {
      // Filter by approvalStatus before converting to Doctor objects
      final approvedDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        return (data['approvalStatus'] as String?) == 'approved';
      }).toList();

      return approvedDocs.map((doc) {
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
    final snapshot = await _db.collection('doctors').get();
    // Filter by approvalStatus before converting to Doctor objects
    final approvedDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      return (data['approvalStatus'] as String?) == 'approved';
    }).toList();

    return approvedDocs.map((doc) {
      final data = doc.data();
      return Doctor.fromJson({
        'id': data['id'] ?? doc.id,
        ...data,
      });
    }).toList();
  }

  // Get pending doctors for admin approval
  Stream<List<Map<String, dynamic>>> getPendingDoctors() {
    return _db.collection('doctors').snapshots().map((snapshot) {
      final allDoctors = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Filter by approvalStatus
      return allDoctors
          .where((d) => (d['approvalStatus'] as String?) == 'pending')
          .toList();
    });
  }

  // Approve or reject a doctor
  Future<void> updateDoctorApprovalStatus(
      String doctorId, String status) async {
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
