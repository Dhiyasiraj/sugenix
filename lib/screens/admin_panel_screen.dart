import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/services/revenue_service.dart';
import 'package:sugenix/services/doctor_service.dart';
import 'package:sugenix/services/platform_settings_service.dart';
import 'package:sugenix/screens/admin_panel_pharmacy_tab.dart';
import 'package:intl/intl.dart';

class AdminPanelScreen extends StatefulWidget {
  final int? initialTab;
  
  const AdminPanelScreen({super.key, this.initialTab});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  int _totalUsers = 0;
  int _doctors = 0;
  int _pharmacies = 0;
  int _orders = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      initialIndex: widget.initialTab ?? 0,
      vsync: this,
    );
    _loadStats();
  }

  @override
  void didUpdateWidget(AdminPanelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab && widget.initialTab != null) {
      _tabController.animateTo(widget.initialTab!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final usersSnap = await _firestore.collection('users').get();
      final ordersSnap = await _firestore.collection('orders').get();

      // Filter by role client-side
      final doctors = usersSnap.docs.where((doc) {
        final data = doc.data();
        return data['role'] == 'doctor';
      }).length;

      final pharmacies = usersSnap.docs.where((doc) {
        final data = doc.data();
        return data['role'] == 'pharmacy';
      }).length;

      if (mounted) {
        setState(() {
          _totalUsers = usersSnap.size;
          _doctors = doctors;
          _pharmacies = pharmacies;
          _orders = ordersSnap.size;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0C4556),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Doctors'),
            Tab(text: 'Pharmacies'),
            Tab(text: 'Revenue'),
            Tab(text: 'Settings'),
            Tab(text: 'Records'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSummary(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const _UsersTab(),
                  const _DoctorsApprovalTab(),
                  const PharmaciesApprovalTab(),
                  const _RevenueTab(),
                  const _PlatformSettingsTab(),
                  const _AllMedicalRecordsTab(),
                  const _AllOrdersTab(),
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
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cardWidth = isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 24) / 2;
        
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(Icons.people, Colors.blue, 'Total Users', '$_totalUsers'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(Icons.medical_services, Colors.green, 'Doctors', '$_doctors'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(Icons.local_pharmacy, Colors.orange, 'Pharmacies', '$_pharmacies'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(Icons.receipt_long, Colors.purple, 'Orders', '$_orders'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(IconData icon, Color color, String title, String value) {
    return Container(
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
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab();

  @override
  Widget build(BuildContext context) {
    final revenueService = RevenueService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<double>(
            stream: revenueService.getAdminRevenueStream(),
            builder: (context, snapshot) {
              final totalRevenue = snapshot.data ?? 0.0;
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C4556), Color(0xFF1A6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Platform Revenue',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: revenueService.getRevenueTransactions(limit: 20),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final transactions = snapshot.data ?? [];
              if (transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No revenue transactions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  final amount = (txn['amount'] as num?)?.toDouble() ?? 0.0;
                  final createdAt = txn['createdAt'] as Timestamp?;

                  return Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Fee',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0C4556),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                createdAt != null
                                    ? DateFormat('MMM dd, yyyy • hh:mm a')
                                        .format(createdAt.toDate())
                                    : 'Date not available',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No users found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final userId = doc.id;
            final name = data['name'] as String? ?? 'Unknown';
            final email = data['email'] as String? ?? '';
            final role = data['role'] as String? ?? 'user';
            final phone = data['phone'] as String? ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final isActive = data['isActive'] as bool? ?? true;
            final approvalStatus = data['approvalStatus'] as String?;
            
            return InkWell(
              onTap: () => _showUserDetailsDialog(context, userId, data, role),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getRoleColor(role).withOpacity(0.1),
                          child: Icon(
                            _getRoleIcon(role),
                            color: _getRoleColor(role),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0C4556),
                                      ),
                                    ),
                                  ),
                                  if (!isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'INACTIVE',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (approvalStatus != null && approvalStatus != 'approved')
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: approvalStatus == 'pending'
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        approvalStatus.toUpperCase(),
                                        style: TextStyle(
                                          color: approvalStatus == 'pending'
                                              ? Colors.orange
                                              : Colors.red,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(role),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Phone: $phone',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Joined: ${DateFormat('MMM dd, yyyy').format(createdAt.toDate())}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'doctor':
        return Colors.green;
      case 'pharmacy':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'doctor':
        return Icons.medical_services;
      case 'pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.person;
    }
  }

  Future<void> _showUserDetailsDialog(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
    String role,
  ) async {
    final name = userData['name'] as String? ?? 'Unknown';
    final email = userData['email'] as String? ?? '';
    final phone = userData['phone'] as String? ?? '';
    final createdAt = userData['createdAt'] as Timestamp?;
    final isActive = userData['isActive'] as bool? ?? true;
    final approvalStatus = userData['approvalStatus'] as String?;
    
    // Fetch additional role-specific data
    Map<String, dynamic>? roleSpecificData;
    if (role == 'doctor') {
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();
      roleSpecificData = doctorDoc.data();
    } else if (role == 'pharmacy') {
      final pharmacyDoc = await FirebaseFirestore.instance
          .collection('pharmacies')
          .doc(userId)
          .get();
      roleSpecificData = pharmacyDoc.data();
    }

    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _getRoleColor(role).withOpacity(0.1),
                      child: Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C4556),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Role', role.toUpperCase()),
                _buildDetailRow('Phone', phone.isNotEmpty ? phone : 'Not provided'),
                if (createdAt != null)
                  _buildDetailRow(
                    'Joined',
                    DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt.toDate()),
                  ),
                _buildDetailRow(
                  'Status',
                  isActive ? 'Active' : 'Inactive',
                  valueColor: isActive ? Colors.green : Colors.red,
                ),
                if (approvalStatus != null)
                  _buildDetailRow(
                    'Approval Status',
                    approvalStatus.toUpperCase(),
                    valueColor: approvalStatus == 'approved'
                        ? Colors.green
                        : approvalStatus == 'pending'
                            ? Colors.orange
                            : Colors.red,
                  ),
                
                // Role-specific details
                if (role == 'doctor' && roleSpecificData != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Doctor Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C4556),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (roleSpecificData['specialization'] != null)
                    _buildDetailRow(
                      'Specialization',
                      roleSpecificData['specialization'] as String,
                    ),
                  if (roleSpecificData['hospital'] != null)
                    _buildDetailRow(
                      'Hospital',
                      roleSpecificData['hospital'] as String,
                    ),
                  if (roleSpecificData['consultationFee'] != null)
                    _buildDetailRow(
                      'Consultation Fee',
                      '₹${(roleSpecificData['consultationFee'] as num).toStringAsFixed(0)}',
                    ),
                  if (roleSpecificData['licenseNumber'] != null)
                    _buildDetailRow(
                      'License Number',
                      roleSpecificData['licenseNumber'] as String,
                    ),
                ],
                
                if (role == 'pharmacy' && roleSpecificData != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Pharmacy Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C4556),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (roleSpecificData['address'] != null)
                    _buildDetailRow(
                      'Address',
                      roleSpecificData['address'] as String,
                    ),
                  if (roleSpecificData['licenseNumber'] != null)
                    _buildDetailRow(
                      'License Number',
                      roleSpecificData['licenseNumber'] as String,
                    ),
                ],
                
                // Deactivate/Activate button for doctors and pharmacies
                if (role == 'doctor' || role == 'pharmacy') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _toggleUserAccountStatus(context, userId, role, !isActive);
                      },
                      icon: Icon(isActive ? Icons.block : Icons.check_circle),
                      label: Text(isActive ? 'Deactivate Account' : 'Activate Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? const Color(0xFF0C4556),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserAccountStatus(
    BuildContext context,
    String userId,
    String role,
    bool activate,
  ) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(activate ? 'Activate Account' : 'Deactivate Account'),
          content: Text(
            activate
                ? 'Are you sure you want to activate this ${role} account? They will be able to access the platform again.'
                : 'Are you sure you want to deactivate this ${role} account? They will not be able to access the platform.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: activate ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(activate ? 'Activate' : 'Deactivate'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(activate ? 'Activating account...' : 'Deactivating account...'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Update user status
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isActive': activate,
        'deactivatedAt': activate ? null : FieldValue.serverTimestamp(),
      });

      // Also update in role-specific collection
      if (role == 'doctor') {
        await FirebaseFirestore.instance.collection('doctors').doc(userId).update({
          'isActive': activate,
        });
      } else if (role == 'pharmacy') {
        await FirebaseFirestore.instance.collection('pharmacies').doc(userId).update({
          'isActive': activate,
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activate
                  ? 'Account activated successfully'
                  : 'Account deactivated successfully',
            ),
            backgroundColor: activate ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${activate ? 'activate' : 'deactivate'} account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AllMedicalRecordsTab extends StatelessWidget {
  const _AllMedicalRecordsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medical_records')
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
            child:
                Text('No records found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final title = (data['title'] as String?) ?? 'Record';
            final type = (data['recordType'] as String?) ??
                (data['type'] as String? ?? '');
            final addedBy = (data['addedByName'] as String?) ??
                (data['addedBy'] as String? ?? 'Unknown');
            final userId = data['userId'] as String? ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final userName = userData?['name'] as String? ?? 'Unknown User';
                
                return Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description, color: Color(0xFF0C4556)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF0C4556),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Type: $type',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'User: $userName',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.person_add, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Added by: $addedBy',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(createdAt.toDate())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PlatformSettingsTab extends StatefulWidget {
  const _PlatformSettingsTab();

  @override
  State<_PlatformSettingsTab> createState() => _PlatformSettingsTabState();
}

class _PlatformSettingsTabState extends State<_PlatformSettingsTab> {
  final PlatformSettingsService _platformSettings = PlatformSettingsService();
  final _feeValueController = TextEditingController();
  final _minimumFeeController = TextEditingController();
  final _maximumFeeController = TextEditingController();
  String _selectedFeeType = 'percentage';
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _feeValueController.dispose();
    _minimumFeeController.dispose();
    _maximumFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _platformSettings.getPlatformFeeSettings();
      setState(() {
        _selectedFeeType = settings['feeType'] as String? ?? 'percentage';
        _feeValueController.text = (settings['feeValue'] as double? ?? 5.0).toString();
        _minimumFeeController.text = (settings['minimumFee'] as double? ?? 0.0).toString();
        final maxFee = settings['maximumFee'] as double?;
        _maximumFeeController.text = maxFee != null ? maxFee.toString() : '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_feeValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee value is required')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final feeValue = double.tryParse(_feeValueController.text);
      if (feeValue == null || feeValue < 0) {
        throw Exception('Invalid fee value');
      }

      double? minimumFee;
      if (_minimumFeeController.text.isNotEmpty) {
        minimumFee = double.tryParse(_minimumFeeController.text);
        if (minimumFee == null || minimumFee < 0) {
          throw Exception('Invalid minimum fee');
        }
      }

      double? maximumFee;
      if (_maximumFeeController.text.isNotEmpty) {
        maximumFee = double.tryParse(_maximumFeeController.text);
        if (maximumFee == null || maximumFee < 0) {
          throw Exception('Invalid maximum fee');
        }
        if (minimumFee != null && maximumFee < minimumFee) {
          throw Exception('Maximum fee must be greater than minimum fee');
        }
      }

      await _platformSettings.updatePlatformFeeSettings(
        feeType: _selectedFeeType,
        feeValue: feeValue,
        minimumFee: minimumFee,
        maximumFee: maximumFee,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Platform settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Fee Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure how platform fees are calculated for medicine orders',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fee Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C4556),
                  ),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  title: const Text('Percentage'),
                  subtitle: const Text('Fee calculated as percentage of order total'),
                  value: 'percentage',
                  groupValue: _selectedFeeType,
                  onChanged: (value) {
                    setState(() {
                      _selectedFeeType = value!;
                    });
                  },
                  activeColor: const Color(0xFF0C4556),
                ),
                RadioListTile<String>(
                  title: const Text('Fixed Amount'),
                  subtitle: const Text('Fixed fee amount per order'),
                  value: 'fixed',
                  groupValue: _selectedFeeType,
                  onChanged: (value) {
                    setState(() {
                      _selectedFeeType = value!;
                    });
                  },
                  activeColor: const Color(0xFF0C4556),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _feeValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _selectedFeeType == 'percentage' ? 'Fee Percentage (%)' : 'Fixed Fee (₹)',
                    hintText: _selectedFeeType == 'percentage' ? 'e.g., 5 for 5%' : 'e.g., 10 for ₹10',
                    prefixIcon: const Icon(Icons.percent, color: Color(0xFF0C4556)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _minimumFeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum Fee (₹) - Optional',
                    hintText: 'e.g., 5',
                    prefixIcon: const Icon(Icons.arrow_downward, color: Color(0xFF0C4556)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _maximumFeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Maximum Fee (₹) - Optional',
                    hintText: 'e.g., 100',
                    prefixIcon: const Icon(Icons.arrow_upward, color: Color(0xFF0C4556)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4556),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Save Settings',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Platform fees are automatically calculated and shown to customers during checkout. Changes take effect immediately for new orders.',
                    style: TextStyle(color: Colors.blue[900], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllOrdersTab extends StatelessWidget {
  const _AllOrdersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            child:
                Text('No orders found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final total = (data['total'] as num?)?.toDouble() ?? 0.0;
            final status = (data['status'] as String?) ?? 'placed';
            final address = (data['address'] as String?) ?? '';
            final customerName = data['customerName'] as String? ?? 'Guest';
            final customerEmail = data['customerEmail'] as String? ?? '';
            final paymentMethod = data['paymentMethod'] as String? ?? 'COD';
            final createdAt = data['createdAt'] as Timestamp?;
            final items = data['items'] as List? ?? [];
            
            return Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: _getStatusColor(status),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0C4556),
                              ),
                            ),
                            Text(
                              '$customerName • $customerEmail',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${items.length} item(s)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        paymentMethod,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Order Date: ${DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt.toDate())}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
      case 'placed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _DoctorsApprovalTab extends StatelessWidget {
  const _DoctorsApprovalTab();

  @override
  Widget build(BuildContext context) {
    final doctorService = DoctorService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: doctorService.getPendingDoctors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final doctors = snapshot.data ?? [];
        if (doctors.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No pending doctor approvals',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final name = doctor['name'] ?? 'Unknown';
            final specialization = doctor['specialization'] ?? 'N/A';
            final hospital = doctor['hospital'] ?? 'N/A';
            final proofUrl = doctor['proofDocumentUrl'] as String?;
            final doctorId = doctor['id'] as String;

            return Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0C4556),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              specialization,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              hospital,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (proofUrl != null) ...[
                    const Text(
                      'Proof Document:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C4556),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBar(
                                  title: const Text('Proof Document'),
                                  backgroundColor: const Color(0xFF0C4556),
                                  foregroundColor: Colors.white,
                                ),
                                Expanded(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      proofUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Text('Failed to load image'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            proofUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reject Doctor'),
                                content: const Text(
                                    'Are you sure you want to reject this doctor?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                              try {
                                await doctorService.updateDoctorApprovalStatus(
                                    doctorId, 'rejected');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Doctor rejected. Email notification sent.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Approve Doctor'),
                                content: const Text(
                                    'Are you sure you want to approve this doctor?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                              try {
                                await doctorService.updateDoctorApprovalStatus(
                                    doctorId, 'approved');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Doctor approved successfully. Email notification sent.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
