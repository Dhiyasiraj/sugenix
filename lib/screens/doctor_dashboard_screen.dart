import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _todayAppointments = 0;
  int _pendingAppointments = 0;
  int _totalPatients = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> _loadStats() async {
    final id = _uid;
    if (id == null) {
      setState(() => _loadingStats = false);
      return;
    }

    try {
      final snap = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: id)
          .get();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      int today = 0;
      int pending = 0;
      final Set<String> patients = {};

      for (final doc in snap.docs) {
        final data = doc.data();
        final status = (data['status'] as String?) ?? 'scheduled';
        final patientId = data['patientId'] as String? ?? '';
        final timestamp = data['dateTime'];
        DateTime? dt;
        if (timestamp is Timestamp) {
          dt = timestamp.toDate();
        } else if (timestamp is DateTime) {
          dt = timestamp;
        }
        if (dt != null && dt.isAfter(startOfDay) && dt.isBefore(endOfDay)) {
          today++;
        }
        if (status == 'scheduled' || status == 'confirmed') {
          pending++;
        }
        if (patientId.isNotEmpty) patients.add(patientId);
      }

      if (mounted) {
        setState(() {
          _todayAppointments = today;
          _pendingAppointments = pending;
          _totalPatients = patients.length;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _appointments() {
    final id = _uid;
    if (id == null) return const Stream.empty();
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: id)
        .orderBy('dateTime', descending: false)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _records() {
    final id = _uid;
    if (id == null) return const Stream.empty();
    return _firestore
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
        backgroundColor: const Color(0xFFF5F6F8),
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
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSummary(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAppointmentsTab(),
                  _buildRecordsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    if (_loadingStats) {
      return Row(
        children: const [
          Expanded(
            child: SizedBox(
              height: 90,
              child: Card(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard(
          icon: Icons.event_available,
          color: Colors.blue,
          title: 'Today\'s Appointments',
          value: '$_todayAppointments',
        ),
        _summaryCard(
          icon: Icons.schedule,
          color: Colors.orange,
          title: 'Pending',
          value: '$_pendingAppointments',
        ),
        _summaryCard(
          icon: Icons.people,
          color: Colors.green,
          title: 'Total Patients',
          value: '$_totalPatients',
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return SizedBox(
      width: 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0C4556),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _appointments(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming appointments',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final patient = (data['patientName'] as String?) ?? 'Patient';
            final status = (data['status'] as String?) ?? 'scheduled';
            final timestamp = data['dateTime'];
            DateTime? dateTime;
            if (timestamp is Timestamp) {
              dateTime = timestamp.toDate();
            } else if (timestamp is DateTime) {
              dateTime = timestamp;
            }
            final formattedDate = dateTime != null
                ? DateFormat('EEE, MMM dd • hh:mm a').format(dateTime)
                : '${data['date'] ?? ''} • ${data['time'] ?? ''}';
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4556).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFF0C4556)),
                ),
                title: Text(
                  patient,
                  style: const TextStyle(
                    color: Color(0xFF0C4556),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecordsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _records(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No assigned medical records',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final title = (data['title'] as String?) ?? 'Record';
            final type = (data['recordType'] as String?) ?? (data['type'] as String? ?? 'General');
            final patient = (data['patientName'] as String?) ?? (data['userId'] as String? ?? '');
            final recordDate = data['recordDate'];
            DateTime? date;
            if (recordDate is Timestamp) {
              date = recordDate.toDate();
            } else if (recordDate is DateTime) {
              date = recordDate;
            } else if (recordDate is String) {
              try {
                date = DateTime.parse(recordDate);
              } catch (_) {
                date = null;
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description, color: Color(0xFF4CAF50)),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0C4556),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '$type • $patient',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  date != null ? DateFormat('MMM dd').format(date) : '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

