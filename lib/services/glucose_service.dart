import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlucoseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add glucose reading
  Future<void> addGlucoseReading({
    required double value,
    required String type,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      await _firestore.collection('glucose_readings').add({
        'userId': _auth.currentUser!.uid,
        'value': value,
        'type': type, // 'fasting', 'post_meal', 'random', 'bedtime'
        'notes': notes,
        'timestamp': timestamp ?? FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isAIFlagged': _shouldFlagReading(value, type),
        'aiAnalysis': _generateAIAnalysis(value, type),
      });
    } catch (e) {
      throw Exception('Failed to add glucose reading: ${e.toString()}');
    }
  }

  // Get glucose readings for current user
  Stream<List<Map<String, dynamic>>> getGlucoseReadings() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('glucose_readings')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Get glucose readings for date range
  Future<List<Map<String, dynamic>>> getGlucoseReadingsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await _firestore
          .collection('glucose_readings')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get glucose readings: ${e.toString()}');
    }
  }

  // Update glucose reading
  Future<void> updateGlucoseReading({
    required String readingId,
    double? value,
    String? type,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (value != null) {
        updateData['value'] = value;
        updateData['isAIFlagged'] = _shouldFlagReading(value, type ?? 'random');
        updateData['aiAnalysis'] = _generateAIAnalysis(value, type ?? 'random');
      }
      if (type != null) updateData['type'] = type;
      if (notes != null) updateData['notes'] = notes;

      await _firestore
          .collection('glucose_readings')
          .doc(readingId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update glucose reading: ${e.toString()}');
    }
  }

  // Delete glucose reading
  Future<void> deleteGlucoseReading(String readingId) async {
    try {
      await _firestore.collection('glucose_readings').doc(readingId).delete();
    } catch (e) {
      throw Exception('Failed to delete glucose reading: ${e.toString()}');
    }
  }

  // Get glucose statistics
  Future<Map<String, dynamic>> getGlucoseStatistics({int days = 30}) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days));

      QuerySnapshot snapshot = await _firestore
          .collection('glucose_readings')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .get();

      List<double> values = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['value'] as double)
          .toList();

      if (values.isEmpty) {
        return {
          'average': 0.0,
          'min': 0.0,
          'max': 0.0,
          'totalReadings': 0,
          'normalReadings': 0,
          'highReadings': 0,
          'lowReadings': 0,
        };
      }

      double average = values.reduce((a, b) => a + b) / values.length;
      double min = values.reduce((a, b) => a < b ? a : b);
      double max = values.reduce((a, b) => a > b ? a : b);

      int normalReadings = values.where((v) => v >= 70 && v <= 180).length;
      int highReadings = values.where((v) => v > 180).length;
      int lowReadings = values.where((v) => v < 70).length;

      return {
        'average': average,
        'min': min,
        'max': max,
        'totalReadings': values.length,
        'normalReadings': normalReadings,
        'highReadings': highReadings,
        'lowReadings': lowReadings,
      };
    } catch (e) {
      throw Exception('Failed to get glucose statistics: ${e.toString()}');
    }
  }

  // Check if reading should be flagged by AI
  bool _shouldFlagReading(double value, String type) {
    switch (type) {
      case 'fasting':
        return value < 70 || value > 130;
      case 'post_meal':
        return value < 70 || value > 180;
      case 'random':
        return value < 70 || value > 200;
      case 'bedtime':
        return value < 70 || value > 150;
      default:
        return value < 70 || value > 180;
    }
  }

  // Generate AI analysis for glucose reading
  String _generateAIAnalysis(double value, String type) {
    if (value < 70) {
      return "Low glucose detected. Consider immediate action: eat fast-acting carbohydrates like glucose tablets or fruit juice.";
    } else if (value > 180) {
      return "High glucose detected. Monitor closely and consider consulting your healthcare provider if this pattern continues.";
    } else {
      return "Glucose level is within normal range. Continue your current management routine.";
    }
  }

  // Get AI recommendations based on glucose patterns
  Future<List<String>> getAIRecommendations() async {
    try {
      // Get recent readings for pattern analysis
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7));

      List<Map<String, dynamic>> readings = await getGlucoseReadingsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (readings.isEmpty) {
        return [
          "Start monitoring your glucose levels regularly for better insights.",
        ];
      }

      List<String> recommendations = [];

      // Analyze patterns
      double average =
          readings.map((r) => r['value'] as double).reduce((a, b) => a + b) /
          readings.length;

      if (average > 150) {
        recommendations.add(
          "Consider adjusting your diet and medication timing.",
        );
        recommendations.add(
          "Increase physical activity to help manage glucose levels.",
        );
      } else if (average < 100) {
        recommendations.add("Monitor for hypoglycemia symptoms.");
        recommendations.add(
          "Consider adjusting medication dosage with your doctor.",
        );
      }

      // Add general recommendations
      recommendations.add("Maintain regular meal times and portion control.");
      recommendations.add("Stay hydrated throughout the day.");
      recommendations.add("Get adequate sleep for better glucose control.");

      return recommendations;
    } catch (e) {
      return ["Unable to generate recommendations at this time."];
    }
  }
}
