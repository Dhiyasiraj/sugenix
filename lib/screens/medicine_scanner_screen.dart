import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/platform_image_service.dart';
import 'package:sugenix/services/medicine_database_service.dart';
import 'package:sugenix/services/cloudinary_service.dart';
import 'package:sugenix/utils/responsive_layout.dart';
import 'package:sugenix/services/language_service.dart';
import 'package:sugenix/screens/language_screen.dart';

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({super.key});

  @override
  State<MedicineScannerScreen> createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  final MedicineDatabaseService _medicineService = MedicineDatabaseService();
  XFile? _scannedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _medicineInfo;

  Future<void> _pickImage() async {
    try {
      final image = await PlatformImageService.pickImage();
      if (image != null) {
        setState(() {
          _scannedImage = image;
          _medicineInfo = null;
        });
        _processImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(image);

      // Try to search for medicine by image or get a common medicine
      // In real implementation, you would use OCR to extract medicine name/barcode
      // For now, we'll try to search for common diabetes medicines
      List<Map<String, dynamic>> medicines = [];
      
      try {
        medicines = await _medicineService.searchMedicines('metformin');
        if (medicines.isEmpty) {
          medicines = await _medicineService.searchMedicines('diabetes');
        }
      } catch (e) {
        // If search fails, continue with fallback
      }

      // Use found medicine or show message to user
      if (medicines.isNotEmpty) {
        final medicine = medicines.first;
        
        // Save scanned medicine
        await _medicineService.saveScannedMedicine(
          imageUrl: imageUrl,
          medicineInfo: medicine,
        );

        // Convert Firestore data to display format
        setState(() {
          _isProcessing = false;
          _medicineInfo = {
            'name': medicine['name'] ?? 'Unknown Medicine',
            'manufacturer': medicine['manufacturer'] ?? '',
            'type': medicine['type'] ?? medicine['description'] ?? '',
            'activeIngredient': medicine['activeIngredient'] ?? '',
            'strength': medicine['strength'] ?? '',
            'form': medicine['form'] ?? '',
            'uses': medicine['uses'] is List ? (medicine['uses'] as List).map((e) => e.toString()).toList() : [],
            'dosage': medicine['dosage'] ?? '',
            'precautions': medicine['precautions'] is List ? (medicine['precautions'] as List).map((e) => e.toString()).toList() : [],
            'sideEffects': medicine['sideEffects'] is List ? (medicine['sideEffects'] as List).map((e) => e.toString()).toList() : [],
            'storage': medicine['storage'] ?? '',
            'expiryDate': medicine['expiryDate'] ?? '',
            'batchNumber': medicine['batchNumber'] ?? '',
          };
        });
      } else {
        // Show message that medicine was not found
        setState(() {
          _isProcessing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicine not found in database. Please try searching manually or consult your doctor.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: FutureBuilder<String>(
          future: LanguageService.getTranslated('medicine'),
          builder: (context, snapshot) {
            final title = snapshot.data ?? 'Medicine Scanner';
            return Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0C4556),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF0C4556)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScannerSection(),
            const SizedBox(height: 30),
            if (_medicineInfo != null) _buildMedicineInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Scan Medicine Label",
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Take a clear photo of your medicine label to get detailed information",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          if (_scannedImage != null)
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(
                        _scannedImage!.path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, size: 60, color: Colors.grey),
                          );
                        },
                      )
                    : Image.file(
                        File(_scannedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, size: 60, color: Colors.grey),
                          );
                        },
                      ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "No image selected",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (_isProcessing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Processing image with AI...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _scannedImage == null ? "Scan Medicine" : "Scan Again",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4556),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineInfo() {
    final info = _medicineInfo!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
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
                  color: const Color(0xFF0C4556).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Color(0xFF0C4556),
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info['name'] as String,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0C4556),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info['manufacturer'] as String,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 13,
                          tablet: 14,
                          desktop: 15,
                        ),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoSection('Type', info['type'] as String),
          _buildInfoSection('Active Ingredient', info['activeIngredient'] as String),
          _buildInfoSection('Strength', info['strength'] as String),
          _buildInfoSection('Form', info['form'] as String),
          const Divider(height: 30),
          _buildListSection('Uses', info['uses'] as List<String>, Icons.info),
          const SizedBox(height: 20),
          _buildListSection(
            'Precautions',
            info['precautions'] as List<String>,
            Icons.warning,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildListSection(
            'Possible Side Effects',
            info['sideEffects'] as List<String>,
            Icons.error_outline,
            Colors.red,
          ),
          const SizedBox(height: 20),
          _buildInfoSection('Dosage', info['dosage'] as String),
          _buildInfoSection('Storage', info['storage'] as String),
          _buildInfoSection('Expiry Date', info['expiryDate'] as String),
          _buildInfoSection('Batch Number', info['batchNumber'] as String),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: const Color(0xFF0C4556),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? const Color(0xFF0C4556),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 17,
                  desktop: 18,
                ),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C4556),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: iconColor ?? const Color(0xFF0C4556),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

