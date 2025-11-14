import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GeminiService {
  // Replace with your actual Gemini API key
  static const String _apiKey = 'AIzaSyAbOgEcLbLwautxmYSE6ZgkCwZYAFX8Tig';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
  static const String _textUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  // Generate text response using Gemini
  static Future<String> generateText(String prompt) async {
    try {
      final url = Uri.parse('$_textUrl?key=$_apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'No response';
      } else {
        throw Exception('Failed to generate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling Gemini API: ${e.toString()}');
    }
  }

  // Extract text from image using Gemini Vision
  static Future<String> extractTextFromImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Extract all text from this medicine label image. Return only the medicine name, manufacturer, dosage, and any other visible text in a structured format.'
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
      } else {
        throw Exception('Failed to extract text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting text: ${e.toString()}');
    }
  }

  // Get medicine information from Gemini
  static Future<Map<String, dynamic>> getMedicineInfo(
      String medicineName) async {
    try {
      final prompt = '''
Analyze this medicine: $medicineName

Provide detailed information in JSON format with the following structure:
{
  "name": "medicine name",
  "uses": ["use1", "use2"],
  "sideEffects": ["effect1", "effect2"],
  "dosage": "recommended dosage",
  "precautions": ["precaution1", "precaution2"],
  "priceRange": "estimated price range in INR",
  "manufacturer": "common manufacturers",
  "form": "tablet/capsule/syrup etc",
  "strength": "strength information"
}

Return only valid JSON, no additional text.
''';

      final response = await generateText(prompt);

      // Try to parse JSON from response
      try {
        // Extract JSON from response if it contains markdown
        String jsonStr = response;
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('```')) {
          jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
        }

        final data = jsonDecode(jsonStr);
        return Map<String, dynamic>.from(data);
      } catch (e) {
        // If JSON parsing fails, return structured text response
        return {
          'name': medicineName,
          'uses': _extractList(response, 'uses'),
          'sideEffects': _extractList(response, 'side effects'),
          'dosage': _extractField(response, 'dosage'),
          'precautions': _extractList(response, 'precautions'),
          'priceRange': _extractField(response, 'price'),
          'manufacturer': _extractField(response, 'manufacturer'),
          'form': _extractField(response, 'form'),
          'strength': _extractField(response, 'strength'),
          'rawResponse': response,
        };
      }
    } catch (e) {
      throw Exception('Error getting medicine info: ${e.toString()}');
    }
  }

  // Analyze prescription and suggest medicines
  static Future<List<Map<String, dynamic>>> analyzePrescription(
      String prescriptionText) async {
    try {
      final prompt = '''
Analyze this prescription and extract all medicine names:

$prescriptionText

Return a JSON array of medicines with this structure:
[
  {
    "name": "medicine name",
    "dosage": "dosage information",
    "frequency": "how often to take",
    "duration": "duration of treatment"
  }
]

Return only valid JSON array, no additional text.
''';

      final response = await generateText(prompt);

      try {
        String jsonStr = response;
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('```')) {
          jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
        }

        final data = jsonDecode(jsonStr);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } catch (e) {
        // Fallback: extract medicine names from text
        return _extractMedicinesFromText(response);
      }
    } catch (e) {
      throw Exception('Error analyzing prescription: ${e.toString()}');
    }
  }

  // Get glucose-based recommendations (diet, exercise, tips)
  static Future<Map<String, dynamic>> getGlucoseRecommendations({
    required double glucoseLevel,
    required String readingType,
    List<Map<String, dynamic>>? recentReadings,
  }) async {
    try {
      String readingsContext = '';
      if (recentReadings != null && recentReadings.isNotEmpty) {
        readingsContext =
            'Recent readings: ${recentReadings.map((r) => '${r['value']} mg/dL (${r['type']})').join(', ')}';
      }

      final prompt = '''
Based on this glucose reading: $glucoseLevel mg/dL (Type: $readingType)
$readingsContext

Provide personalized recommendations in JSON format:
{
  "dietPlan": {
    "breakfast": "suggested breakfast",
    "lunch": "suggested lunch",
    "dinner": "suggested dinner",
    "snacks": ["snack1", "snack2"]
  },
  "exercise": {
    "type": "recommended exercise type",
    "duration": "recommended duration",
    "frequency": "how often",
    "tips": ["tip1", "tip2"]
  },
  "tips": ["tip1", "tip2", "tip3"],
  "status": "normal/prediabetes/diabetes",
  "actionRequired": "any immediate action needed"
}

Return only valid JSON, no additional text.
''';

      final response = await generateText(prompt);

      try {
        String jsonStr = response;
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('```')) {
          jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
        }

        final data = jsonDecode(jsonStr);
        return Map<String, dynamic>.from(data);
      } catch (e) {
        // Fallback response
        return {
          'dietPlan': {
            'breakfast': 'Whole grain cereal with low-fat milk',
            'lunch': 'Grilled chicken with vegetables',
            'dinner': 'Fish with brown rice',
            'snacks': ['Nuts', 'Fruits']
          },
          'exercise': {
            'type': 'Brisk walking',
            'duration': '30 minutes',
            'frequency': 'Daily',
            'tips': ['Stay hydrated', 'Monitor glucose before and after']
          },
          'tips': [
            'Monitor regularly',
            'Take medications as prescribed',
            'Stay active'
          ],
          'status': glucoseLevel < 100
              ? 'normal'
              : (glucoseLevel < 126 ? 'prediabetes' : 'diabetes'),
          'actionRequired': glucoseLevel > 200
              ? 'Consult doctor immediately'
              : 'Continue monitoring',
        };
      }
    } catch (e) {
      throw Exception('Error getting recommendations: ${e.toString()}');
    }
  }

  // Chat with AI assistant
  static Future<String> chat(String userMessage, {String? context}) async {
    try {
      String prompt = userMessage;
      if (context != null) {
        prompt =
            'Context: $context\n\nUser: $userMessage\n\nProvide helpful, accurate medical advice for diabetes management.';
      } else {
        prompt =
            'You are a helpful AI assistant for diabetes management. Answer this question: $userMessage';
      }

      return await generateText(prompt);
    } catch (e) {
      throw Exception('Error in chat: ${e.toString()}');
    }
  }

  // Helper methods
  static List<String> _extractList(String text, String keyword) {
    final lines = text.split('\n');
    final list = <String>[];
    bool inList = false;

    for (var line in lines) {
      if (line.toLowerCase().contains(keyword.toLowerCase())) {
        inList = true;
        continue;
      }
      if (inList) {
        if (line.trim().isEmpty) break;
        final cleaned = line.replaceAll(RegExp(r'[-•*]'), '').trim();
        if (cleaned.isNotEmpty) list.add(cleaned);
      }
    }

    return list.isEmpty ? ['Information not available'] : list;
  }

  static String _extractField(String text, String keyword) {
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.toLowerCase().contains(keyword.toLowerCase())) {
        return line.split(':').length > 1
            ? line.split(':')[1].trim()
            : 'Not specified';
      }
    }
    return 'Not specified';
  }

  static List<Map<String, dynamic>> _extractMedicinesFromText(String text) {
    final medicines = <Map<String, dynamic>>[];
    final lines = text.split('\n');

    for (var line in lines) {
      if (line.trim().isNotEmpty &&
          (line.contains('mg') ||
              line.contains('tablet') ||
              line.contains('capsule'))) {
        medicines.add({
          'name': line.trim(),
          'dosage': 'As prescribed',
          'frequency': 'As prescribed',
          'duration': 'As prescribed'
        });
      }
    }

    return medicines;
  }
}
