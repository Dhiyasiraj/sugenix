import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/models/doctor.dart';

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Doctor>> streamDoctors() {
    return _db.collection('doctors').snapshots().map((snapshot) {
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
    final snapshot = await _db.collection('doctors').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Doctor.fromJson({
        'id': data['id'] ?? doc.id,
        ...data,
      });
    }).toList();
  }
}


