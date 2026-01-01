import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/medicine_orders_service.dart';
import 'package:sugenix/services/huggingface_service.dart';
import 'package:sugenix/services/gemini_service.dart';
import 'package:sugenix/services/medicine_database_service.dart';
import 'package:sugenix/screens/medicine_catalog_screen.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final MedicineOrdersService _ordersService = MedicineOrdersService();
  final MedicineDatabaseService _medicineService = MedicineDatabaseService();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _uploading = false;
  bool _analyzing = false;
  String? _uploadedPrescriptionId;
  List<Map<String, dynamic>> _suggestedMedicines = [];
  List<Map<String, dynamic>> _availableMedicines = [];
  List<Map<String, dynamic>> _unavailableMedicines = [];

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages
          ..clear()
          ..addAll(images);
      });
    }
  }

  Future<void> _captureImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    setState(() {
      _uploading = true;
      _analyzing = true;
      _suggestedMedicines.clear();
      _availableMedicines.clear();
      _unavailableMedicines.clear();
    });
    
    try {
      // Step 1: Upload prescription
      final id = await _ordersService.uploadPrescription(_selectedImages);
      
      // Step 2: Analyze prescription using AI (Hugging Face first, then Gemini fallback)
      if (_selectedImages.isNotEmpty) {
        try {
          String extractedText = '';
          List<Map<String, dynamic>> medicines = [];

          // Try Hugging Face first
          try {
            extractedText = await HuggingFaceService.extractTextFromImage(_selectedImages.first);
            medicines = await HuggingFaceService.analyzePrescription(extractedText);
          } catch (hfError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Using alternative AI service for prescription analysis...'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            }

            // Use Gemini's vision to extract text then analyze prescription
            try {
              extractedText = await GeminiService.extractTextFromImage(_selectedImages.first);
              medicines = await GeminiService.analyzePrescription(extractedText);
            } catch (geminiError) {
              // If both AI services fail, skip analysis but allow upload
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prescription uploaded. AI analysis failed - both services unavailable.'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              medicines = []; // Empty list to skip further processing
            }
          }

          // Step 3: Check availability in pharmacy (only if we have medicines)
          if (medicines.isNotEmpty) {
            for (var medicine in medicines) {
              final medicineName = medicine['name'] ?? '';
              if (medicineName.isNotEmpty) {
                try {
                  final pharmacyMedicines = await _medicineService.searchMedicines(medicineName);
                  if (pharmacyMedicines.isNotEmpty) {
                    _availableMedicines.add({
                      ...medicine,
                      'pharmacyData': pharmacyMedicines.first,
                    });
                  } else {
                    // Get info from AI for unavailable medicines (try HF first, then Gemini)
                    try {
                      final medicineInfo = await HuggingFaceService.getMedicineInfo(medicineName);
                      _unavailableMedicines.add({
                        ...medicine,
                        'geminiInfo': medicineInfo, // Keep key name for compatibility
                      });
                    } catch (hfInfoError) {
                      // Try Gemini as fallback for medicine info
                      try {
                        final geminiInfo = await GeminiService.getMedicineInfo(medicineName);
                        _unavailableMedicines.add({
                          ...medicine,
                          'geminiInfo': geminiInfo,
                        });
                      } catch (geminiInfoError) {
                        // If both info services fail, just add medicine without info
                        _unavailableMedicines.add(medicine);
                      }
                    }
                  }
                } catch (e) {
                  // If search fails, mark as unavailable
                  _unavailableMedicines.add(medicine);
                }
              }
            }
          }

          setState(() {
            _suggestedMedicines = medicines;
          });
        } catch (e) {
          // If all AI services fail, still allow upload but skip analysis
          final errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('timeout') || errorMsg.contains('connection') || errorMsg.contains('network')) {
            // Network error - skip analysis but allow upload
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription uploaded. AI analysis failed - please check your internet connection.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            // Other error - rethrow to be caught by outer catch
            rethrow;
          }
        }
      }
      
      if (!mounted) return;
      setState(() {
        _uploadedPrescriptionId = id;
        _analyzing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_suggestedMedicines.isNotEmpty 
              ? 'Prescription analyzed! ${_availableMedicines.length} medicines available.'
              : 'Prescription uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _analyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Upload Prescription',
          style: TextStyle(
            color: Color(0xFF0C4556),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedImages.isNotEmpty && !_uploading)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _uploadedPrescriptionId = null;
                });
              },
              child: const Text('Clear', style: TextStyle(color: Color(0xFF0C4556))),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const Text(
                    'Add prescription images',
                    style: TextStyle(
                      color: Color(0xFF0C4556),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _uploading ? null : _pickImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C4556),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : _captureImage,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0C4556)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.photo_camera, color: Color(0xFF0C4556)),
                        label: const Text('Camera', style: TextStyle(color: Color(0xFF0C4556))),
                      ),
                      const Spacer(),
                      if (_selectedImages.isNotEmpty)
                        ElevatedButton(
                          onPressed: _uploading ? null : _upload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C4556),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Upload', style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedImages.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      itemCount: _selectedImages.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final file = _selectedImages[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(file.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                onTap: _uploading
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          if (_analyzing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Analyzing prescription with AI...'),
                  ],
                ),
              ),
            ),
          if (_suggestedMedicines.isNotEmpty && !_analyzing)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suggested Medicines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C4556),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_availableMedicines.isNotEmpty) ...[
                      const Text(
                        'Available in Pharmacy',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      ..._availableMedicines.map((medicine) => _buildMedicineCard(medicine, true)),
                      const SizedBox(height: 16),
                    ],
                    if (_unavailableMedicines.isNotEmpty) ...[
                      const Text(
                        'Not Available in Pharmacy',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      ..._unavailableMedicines.map((medicine) => _buildMedicineCard(medicine, false)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MedicineCatalogScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C4556),
                        ),
                        child: const Text('View All Medicines', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_uploadedPrescriptionId != null && _suggestedMedicines.isEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Uploaded. ID: $_uploadedPrescriptionId',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF0C4556).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description, size: 56, color: Color(0xFF0C4556)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No images selected',
            style: TextStyle(
              color: Color(0xFF0C4556),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your prescription to proceed',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, bool available) {
    final pharmacyData = medicine['pharmacyData'];
    final geminiInfo = medicine['geminiInfo'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: available ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  available ? Icons.check_circle : Icons.info,
                  color: available ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medicine['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            if (medicine['dosage'] != null) ...[
              const SizedBox(height: 4),
              Text('Dosage: ${medicine['dosage']}'),
            ],
            if (available && pharmacyData != null) ...[
              const SizedBox(height: 8),
              Text(
                'Price: ₹${(pharmacyData['price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicineCatalogScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4556),
                ),
                child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
              ),
            ] else if (geminiInfo != null) ...[
              const SizedBox(height: 8),
              if (geminiInfo['amount'] != null && geminiInfo['amount'].toString().isNotEmpty)
                Text('Package Size: ${geminiInfo['amount']}'),
              if (geminiInfo['priceRange'] != null && geminiInfo['priceRange'].toString().isNotEmpty)
                Text('Estimated Price: ${geminiInfo['priceRange']}'),
              if (medicine['dosage'] != null && medicine['dosage'].toString().isNotEmpty)
                Text('Dosage: ${medicine['dosage']}'),
              if (geminiInfo['uses'] != null && geminiInfo['uses'] is List) ...[
                const SizedBox(height: 8),
                const Text('Uses:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...(geminiInfo['uses'] as List).take(3).map((use) => Text('• $use')),
              ],
              if (geminiInfo['sideEffects'] != null && geminiInfo['sideEffects'] is List) ...[
                const SizedBox(height: 8),
                const Text('Side Effects:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                ...(geminiInfo['sideEffects'] as List).take(3).map((effect) => Text('• $effect', style: const TextStyle(color: Colors.red))),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
