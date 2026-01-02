import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sugenix/services/platform_image_service.dart';
import 'package:sugenix/services/medicine_database_service.dart';
import 'package:sugenix/services/gemini_service.dart';
import 'package:sugenix/utils/responsive_layout.dart';
import 'package:sugenix/widgets/translated_text.dart';
import 'package:sugenix/services/medicine_cart_service.dart';
import 'package:sugenix/screens/medicine_catalog_screen.dart';

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({super.key});

  @override
  State<MedicineScannerScreen> createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  final MedicineDatabaseService _medicineService = MedicineDatabaseService();
  final MedicineCartService _cartService = MedicineCartService();
  XFile? _scannedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _medicineInfo;
  bool _medicineFoundInPharmacy = false;
  Map<String, dynamic>? _pharmacyMedicine;

  Future<void> _pickImage() async {
    try {
      // Show dialog to choose between camera and gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0C4556)),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF0C4556)),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      try {
        final image = await PlatformImageService.pickImage(source: source);
        if (image != null) {
          setState(() {
            _scannedImage = image;
            _medicineInfo = null;
          });
          _processImage(image);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Camera/Gallery access denied or unavailable. Please grant permissions in settings.'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
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
      _medicineInfo = null;
      _medicineFoundInPharmacy = false;
      _pharmacyMedicine = null;
    });
    try {
      // Use Gemini AI for medicine scanning
      Map<String, dynamic>? scanResult;

      try {
        // Use Gemini's vision with a labels-specific prompt
        final extractedText = await GeminiService.extractTextFromImage(
          image,
          prompt: 'Identify this medicine. Extract the name, manufacturer, and all visible text from the label.',
        );
        if (extractedText.isEmpty) {
          throw Exception('Could not extract text from the image. Please ensure the medicine label is clearly visible and try again.');
        }
        final geminiInfo = await GeminiService.getMedicineInfo(extractedText);
        scanResult = {
          'success': true,
          'rawText': extractedText,
          'parsed': {
            'medicineName': geminiInfo['name'] ?? '',
            'uses': geminiInfo['uses'] ?? '',
            'sideEffects': geminiInfo['sideEffects'] ?? '',
            'ingredients': geminiInfo['activeIngredient'] ?? geminiInfo['ingredients'] ?? '',
          },
        };
      } catch (geminiError) {
        // Gemini failed - provide helpful error message
        final errorMsg = geminiError.toString().toLowerCase();
        if (errorMsg.contains('api key') || errorMsg.contains('not configured')) {
          throw Exception('AI service not configured properly. Please contact support.');
        } else if (errorMsg.contains('quota') || errorMsg.contains('limit')) {
          throw Exception('Service temporarily unavailable due to usage limits. Please try again later.');
        } else if (errorMsg.contains('timeout') || errorMsg.contains('connection')) {
          throw Exception('Connection timeout. Please check your internet connection and try again.');
        } else {
          throw Exception('Failed to scan medicine. Please ensure the image is clear and try again.');
        }
      }

      final parsed = (scanResult?['parsed'] ?? {}) as Map<String, dynamic>;
      final medicineName = (parsed['medicineName'] ?? '').toString().trim();
      final usesText = parsed['uses'] is List
          ? (parsed['uses'] as List).join('\n')
          : (parsed['uses']?.toString() ?? '');
      final sideEffectsText = parsed['sideEffects'] is List
          ? (parsed['sideEffects'] as List).join('\n')
          : (parsed['sideEffects']?.toString() ?? '');

      final List<String> usesList = _normalizeList(usesText);
      final List<String> sideEffectsList = _normalizeList(sideEffectsText);

      if (medicineName.isEmpty) {
        throw Exception('Could not identify medicine name from image');
      }

      // Check pharmacy database for the medicine
      List<Map<String, dynamic>> pharmacyMedicines = [];
      try {
        pharmacyMedicines = await _medicineService.searchMedicines(medicineName);
      } catch (_) {
        // ignore search errors and continue with parsed data
      }

      Map<String, dynamic> medicineData;
      if (pharmacyMedicines.isNotEmpty) {
        _medicineFoundInPharmacy = true;
        _pharmacyMedicine = pharmacyMedicines.first;
        final pm = pharmacyMedicines.first;
        double price = 0.0;
        try {
          price = double.tryParse(pm['price']?.toString() ?? '') ?? 0.0;
        } catch (_) {
          price = 0.0;
        }

        medicineData = {
          'name': pm['name'] ?? medicineName,
          'manufacturer': pm['manufacturer'] ?? parsed['medicineName'] ?? '',
          'type': pm['type'] ?? 'Medicine',
          'activeIngredient': pm['activeIngredient'] ?? parsed['ingredients'] ?? '',
          'strength': pm['strength'] ?? '',
          'form': pm['form'] ?? '',
          'uses': pm['uses'] is List
              ? (pm['uses'] as List).map((e) => e.toString()).toList()
              : usesList,
          'dosage': pm['dosage'] ?? parsed['uses'] ?? '',
          'precautions': pm['precautions'] is List
              ? (pm['precautions'] as List).map((e) => e.toString()).toList()
              : <String>[],
          'sideEffects': pm['sideEffects'] is List
              ? (pm['sideEffects'] as List).map((e) => e.toString()).toList()
              : sideEffectsList,
          'price': price,
          'priceRange': pm['priceRange'] ?? '',
          'available': true,
        };
      } else {
        _medicineFoundInPharmacy = false;
        medicineData = {
          'name': medicineName,
          'manufacturer': parsed['medicineName'] ?? '',
          'type': 'Medicine',
          'activeIngredient': parsed['ingredients'] ?? '',
          'strength': '',
          'form': '',
          'uses': usesList,
          'dosage': '',
          'precautions': <String>[],
          'sideEffects': sideEffectsList,
          'price': 0.0,
          'priceRange': '',
          'available': false,
        };
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _medicineInfo = medicineData;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_medicineFoundInPharmacy
                ? 'Medicine found in pharmacy! You can add it to cart.'
                : 'Medicine information retrieved. Not available in pharmacy.'),
            backgroundColor:
                _medicineFoundInPharmacy ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        final msg = e.toString();
        String userMessage = 'Failed to process image: $msg';
        if (msg.contains('429')) {
          userMessage =
              'Rate limit reached while processing the image. Please try again later.';
        } else if (msg.toLowerCase().contains('timeout')) {
          userMessage =
              'The request timed out. Please check your connection and try again.';
        } else if (msg.toLowerCase().contains('api key') ||
            msg.toLowerCase().contains('not configured')) {
          userMessage =
              'AI service not configured: API key missing or invalid. Contact support.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                if (_scannedImage != null) {
                  _processImage(_scannedImage!);
                }
              },
            ),
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  List<String> _normalizeList(String? value) {
    if (value == null) return [];
    final cleaned = value
        .split('\n')
        .map((e) => e.trim())
        .where((e) =>
            e.isNotEmpty &&
            !_isValueUnavailable(e) &&
            e.toLowerCase() != 'not specified')
        .toList();
    return cleaned;
  }

  bool _isValueUnavailable(String? value) {
    if (value == null) return true;
    final v = value.trim().toLowerCase();
    return v.isEmpty || v.contains('not available') || v.contains('could not parse');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TranslatedAppBarTitle('medicine', fallback: 'Medicine Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScannerSection(),
              const SizedBox(height: 30),
              if (_medicineInfo != null) _buildMedicineInfo(),
              // Add bottom padding for Android navigation buttons
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
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
                            child:
                                Icon(Icons.image, size: 60, color: Colors.grey),
                          );
                        },
                      )
                    : Image.file(
                        File(_scannedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child:
                                Icon(Icons.image, size: 60, color: Colors.grey),
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
          _buildInfoSection(
              'Active Ingredient', info['activeIngredient'] as String),
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
          if (info['priceRange'] != null &&
              (info['priceRange'] as String).isNotEmpty)
            _buildInfoSection('Estimated Price', info['priceRange'] as String),
          if (_medicineFoundInPharmacy && _pharmacyMedicine != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Available in Pharmacy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price: ₹${(_pharmacyMedicine!['price'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C4556),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _cartService.addToCart(
                            medicineId: _pharmacyMedicine!['id'] ?? '',
                            name: _pharmacyMedicine!['name'] ??
                                info['name'] ??
                                'Medicine',
                            price:
                                (_pharmacyMedicine!['price'] ?? 0.0).toDouble(),
                            quantity: 1,
                            manufacturer: _pharmacyMedicine!['manufacturer'],
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicineCatalogScreen(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to add to cart: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4556),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Not Available in Pharmacy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This medicine is not currently available in our pharmacy. Please consult your doctor or visit a local pharmacy.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
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
