import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController(text: 'Diabetologist');
  final _hospitalController = TextEditingController();
  final _languagesController = TextEditingController(text: 'English, Malayalam');
  final _feeController = TextEditingController(text: '300');
  final _bioController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    _languagesController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');
      final db = FirebaseFirestore.instance;
      final languages = _languagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

      await db.collection('doctors').doc(uid).set({
        'id': uid,
        'name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'hospital': _hospitalController.text.trim(),
        'languages': languages,
        'availability': {},
        'consultationFee': fee,
        'bio': _bioController.text.trim(),
        'rating': 0.0,
        'totalBookings': 0,
        'totalPatients': 0,
        'likes': 0,
        'isOnline': false,
        'profileImage': null,
      });
      await db.collection('users').doc(uid).set({
        'role': 'doctor',
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor profile created')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Doctor Registration',
          style: TextStyle(
            color: Color(0xFF0C4556),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, 'Full Name', Icons.person, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _buildField(_specializationController, 'Specialization', Icons.medical_services),
              const SizedBox(height: 12),
              _buildField(_hospitalController, 'Hospital/Clinic', Icons.local_hospital),
              const SizedBox(height: 12),
              _buildField(_languagesController, 'Languages (comma separated)', Icons.language),
              const SizedBox(height: 12),
              _buildField(_feeController, 'Consultation Fee', Icons.currency_rupee, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              _buildField(_bioController, 'Short Bio', Icons.description, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4556),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Profile', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon,
      {FormFieldValidator<String>? validator, TextInputType? keyboard, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      validator: validator,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0C4556)),
      ),
    );
  }
}


