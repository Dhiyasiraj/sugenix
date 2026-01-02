import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/medicine_orders_service.dart';
import 'package:sugenix/services/gemini_service.dart';
import 'package:sugenix/services/medicine_database_service.dart';
import 'package:sugenix/screens/medicine_catalog_screen.dart';
import 'package:sugenix/services/ocr_service.dart';

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
    final images = await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1024);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages
          ..clear()
          ..addAll(images);
      });
    }
  }

  Future<void> _captureImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1024);
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
      
      // Step 2: Analyze prescription using On-Device OCR (No API)
      if (_selectedImages.isNotEmpty) {
        try {
          String extractedText = '';
          List<Map<String, dynamic>> medicines = [];

          try {
            // Use OCR Service
            extractedText = await OCRService.extractText(_selectedImages.first);
            
            if (extractedText.isNotEmpty) {
               medicines = await _parseMedicinesFromOCR(extractedText);
            }
          } catch (e) {
            print('OCR Failed: $e');
            medicines = [];
          }

          // Step 3: Check availability in pharmacy (already done in _parseMedicinesFromOCR technically, but let's organize)
          // Actually _parseMedicinesFromOCR can just return the raw names found, and then we check DB.
          // But since _parseMedicinesFromOCR needs to check DB to know if it's a medicine, we effectively populate _availableMedicines there.
          
          setState(() {
             // _suggestedMedicines is combined list
             _suggestedMedicines = medicines;
          });
          
        } catch (e) {
             print("Analysis Error: $e");
             // Non-fatal
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
              ? 'Prescription scanned! ${_availableMedicines.length} medicines identified.'
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

  // Helper to parse medicines using Database matching
  Future<List<Map<String, dynamic>>> _parseMedicinesFromOCR(String text) async {
    final lines = text.split('\n');
    List<Map<String, dynamic>> results = [];
    final Set<String> addedIds = {};
    final Set<String> addedNames = {};
    
    for (var line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.length < 3) continue;
      if (_isNoise(cleanLine)) continue;

      final words = cleanLine.split(' ');

      // 1. Try search with full line
      var matches = await _searchBestMatch(cleanLine);
      
      // 2. If no match, try first word if it looks like a name
      if (matches.isEmpty && words.isNotEmpty && words[0].length >= 3) {
         matches = await _searchBestMatch(words[0]);
      }

      if (matches.isNotEmpty) {
         final match = matches.first;
         final id = match['id'] ?? '';
         final name = (match['name'] ?? '').toString().toLowerCase();

         // Strict deduplication
         if ((id.isNotEmpty && addedIds.contains(id)) || 
             (name.isNotEmpty && addedNames.contains(name))) {
           continue;
         }
         
         if (id.isNotEmpty) addedIds.add(id);
         if (name.isNotEmpty) addedNames.add(name);

         // It's a valid medicine in our DB
         _availableMedicines.add({
           'name': match['name'],
           'dosage': match['strength'] ?? 'As prescribed',
           'pharmacyData': match,
         });
         results.add({
           'name': match['name'],
           'dosage': match['strength'] ?? 'As prescribed',
         });
      } else {
         // Not found in DB -> Add to unavailable list
         // Heuristic: Name is text before numbers usually
         final nameCandidate = cleanLine.split(RegExp(r'[\d]')).first.trim(); 
         if (nameCandidate.length > 2 && !addedNames.contains(nameCandidate.toLowerCase())) {
             addedNames.add(nameCandidate.toLowerCase());
             
             _unavailableMedicines.add({
               'name': cleanLine, // Show full extracted text
               'dosage': 'Details from prescription',
             });
         }
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> _searchBestMatch(String query) async {
    try {
      final matches = await _medicineService.searchMedicines(query);
      // Filter out Matches that matched only description, we want Name matching for OCR
      return matches.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  bool _isNoise(String text) {
    final lower = text.toLowerCase();
    // Skip purely numeric/special
    if (RegExp(r'^[\d\W]+$').hasMatch(lower)) return true;
    
    // Skip common dosage/form keywords if the line implies it's just meta-info
    final keywords = ['tablet', 'tablets', 'cap', 'capsule', 'capsules', 'mg', 'ml', 'gm', 'g', 'mcg', 'daily', 'times', 'day', 'night', 'morning', 'after', 'before', 'food', 'dose', 'take', 'qty', 'quantity', 'total', 'price', 'mrp', 'exp', 'date', 'batch', 'no', 'code', 'reg'];
    
    // Check if line consists mostly of keywords + numbers
    final words = lower.split(RegExp(r'\s+'));
    int noiseCount = 0;
    for(var w in words) {
       if (keywords.any((k) => w.contains(k)) || double.tryParse(w.replaceAll(RegExp(r'[^\d.]'), '')) != null || w.length < 3) {
         noiseCount++;
       }
    }
    
    // If > 70% of words are noise, skip
    if (words.isNotEmpty && (noiseCount / words.length > 0.7)) return true;
    
    return false;
  }

  Future<void> _testApiConnection() async {
     // Deprecated / Not needed for OCR mode
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Using On-Device Scanning (Offline)')),
     );
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
          IconButton(
            icon: const Icon(Icons.scanner, color: Color(0xFF0C4556)),
            onPressed: null, // Just an indicator
            tooltip: "On-Device Scan Active",
          ),
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
                    Text('Scanning prescription...'),
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
                      'Detected Medicines',
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
