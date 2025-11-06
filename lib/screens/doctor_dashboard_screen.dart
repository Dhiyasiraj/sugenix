import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  String? _uid() => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _appointments() {
    final id = _uid();
    if (id == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: id)
        .orderBy('date', descending: false)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _records() {
    final id = _uid();
    if (id == null) return const Stream.empty();
    // Optional: if records have doctorId assigned
    return FirebaseFirestore.instance
        .collection('medical_records')
        .where('doctorId', isEqualTo: id)
        .orderBy('recordDate', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C4556),
          bottom: const TabBar(
            labelColor: Color(0xFF0C4556),
            tabs: [
              Tab(text: 'Appointments'),
              Tab(text: 'Patient Records'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
              stream: _appointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = (snapshot.data as QuerySnapshot?)?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No upcoming appointments',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final patientName = (data['patientName'] as String?) ?? '';
                    final date = (data['date'] as String?) ?? '';
                    final time = (data['time'] as String?) ?? '';
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
                        leading: const Icon(Icons.event_available, color: Color(0xFF0C4556)),
                        title: Text(patientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
                        subtitle: Text('$date • $time',
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder(
              stream: _records(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = (snapshot.data as QuerySnapshot?)?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No assigned records',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final title = (data['title'] as String?) ?? 'Record';
                    final type = (data['type'] as String?) ?? '';
                    final userId = (data['userId'] as String?) ?? '';
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
                        leading: const Icon(Icons.description, color: Color(0xFF0C4556)),
                        title: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
                        subtitle: Text('$type • user $userId',
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
    );
  }
}


