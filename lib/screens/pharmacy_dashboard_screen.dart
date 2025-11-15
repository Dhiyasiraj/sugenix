import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugenix/utils/responsive_layout.dart';

class PharmacyDashboardScreen extends StatefulWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  State<PharmacyDashboardScreen> createState() => _PharmacyDashboardScreenState();
}

class _PharmacyDashboardScreenState extends State<PharmacyDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _dosageController = TextEditingController();
  final _formController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _usesController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _precautionsController = TextEditingController();
  final _stockController = TextEditingController();
  
  bool _requiresPrescription = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _medicines = [];
  int _totalOrders = 0;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('pharmacyId', isEqualTo: userId)
          .get();

      int totalOrders = 0;
      double revenue = 0.0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        if (data['status'] != 'cancelled') {
          totalOrders++;
          // Use pharmacyAmount (after platform fee deduction) for revenue
          revenue += (data['pharmacyAmount'] as num?)?.toDouble() ?? 
                     ((data['total'] as num?)?.toDouble() ?? 0.0);
        }
      }

      if (mounted) {
        setState(() {
          _totalOrders = totalOrders;
          _totalRevenue = revenue;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadMedicines() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _firestore
          .collection('medicines')
          .where('pharmacyId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _medicines = snapshot.docs.map((doc) {
              final data = doc.data();
              return {'id': doc.id, ...data};
            }).toList();
          });
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _addMedicine() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');

      final uses = _usesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final sideEffects = _sideEffectsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final precautions = _precautionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await _firestore.collection('medicines').add({
        'name': _nameController.text.trim(),
        'genericName': _genericNameController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'form': _formController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'uses': uses,
        'sideEffects': sideEffects,
        'precautions': precautions,
        'requiresPrescription': _requiresPrescription,
        'pharmacyId': userId,
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add medicine: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _genericNameController.clear();
    _manufacturerController.clear();
    _dosageController.clear();
    _formController.clear();
    _priceController.clear();
    _stockController.clear();
    _descriptionController.clear();
    _usesController.clear();
    _sideEffectsController.clear();
    _precautionsController.clear();
    _requiresPrescription = false;
  }

  Future<void> _deleteMedicine(String medicineId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('medicines').doc(medicineId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicine deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _manufacturerController.dispose();
    _dosageController.dispose();
    _formController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _usesController.dispose();
    _sideEffectsController.dispose();
    _precautionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pharmacy Dashboard',
            style: TextStyle(color: Color(0xFF0C4556), fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C4556),
          bottom: const TabBar(
            labelColor: Color(0xFF0C4556),
            tabs: [
              Tab(text: 'Add Medicine'),
              Tab(text: 'My Medicines'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildStatsCards(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAddMedicineForm(),
                  _buildMedicinesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF5F6F8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Orders',
              '$_totalOrders',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenue',
              '₹${_totalRevenue.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Medicines',
              '${_medicines.length}',
              Icons.medication,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMedicineForm() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_nameController, 'Medicine Name *', Icons.medication),
          const SizedBox(height: 12),
          _buildTextField(_genericNameController, 'Generic Name', Icons.science),
          const SizedBox(height: 12),
          _buildTextField(_manufacturerController, 'Manufacturer', Icons.business),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_dosageController, 'Dosage', Icons.straighten)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_formController, 'Form (Tablet/Capsule)', Icons.medication_liquid)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _priceController,
                  'Price (₹) *',
                  Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _stockController,
                  'Stock Quantity *',
                  Icons.inventory,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField(_usesController, 'Uses (comma separated)', Icons.info, maxLines: 2),
          const SizedBox(height: 12),
          _buildTextField(_sideEffectsController, 'Side Effects (comma separated)', Icons.warning, maxLines: 2),
          const SizedBox(height: 12),
          _buildTextField(_precautionsController, 'Precautions (comma separated)', Icons.health_and_safety, maxLines: 2),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Requires Prescription'),
            value: _requiresPrescription,
            onChanged: (value) => setState(() => _requiresPrescription = value),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4556),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Medicine', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    if (_medicines.isEmpty) {
      return const Center(
        child: Text('No medicines added yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.medication, color: Color(0xFF0C4556)),
            title: Text(
              medicine['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${(medicine['price'] ?? 0.0).toStringAsFixed(2)}'),
                if (medicine['requiresPrescription'] == true)
                  const Text('Prescription Required', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMedicine(medicine['id']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0C4556)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

