import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C4556),
          bottom: const TabBar(
            labelColor: Color(0xFF0C4556),
            tabs: [
              Tab(text: 'Records'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AllMedicalRecordsTab(),
            _AllOrdersTab(),
          ],
        ),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
    );
  }
}

class _AllMedicalRecordsTab extends StatelessWidget {
  const _AllMedicalRecordsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('medical_records')
          .orderBy('recordDate', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No records found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final title = (data['title'] as String?) ?? 'Record';
            final type = (data['type'] as String?) ?? '';
            final addedBy = (data['addedByName'] as String?) ?? (data['addedBy'] as String? ?? '');
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
                subtitle: Text('$type • by $addedBy',
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        );
      },
    );
  }
}

class _AllOrdersTab extends StatelessWidget {
  const _AllOrdersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No orders found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final total = (data['total'] as num?)?.toDouble() ?? 0.0;
            final status = (data['status'] as String?) ?? 'placed';
            final address = (data['address'] as String?) ?? '';
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
                leading: const Icon(Icons.receipt_long, color: Color(0xFF0C4556)),
                title: Text('₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
                subtitle: Text('$status • $address',
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        );
      },
    );
  }
}


