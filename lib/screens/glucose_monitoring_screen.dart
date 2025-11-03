import 'package:flutter/material.dart';
import 'package:sugenix/services/glucose_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoseMonitoringScreen extends StatefulWidget {
  const GlucoseMonitoringScreen({super.key});

  @override
  State<GlucoseMonitoringScreen> createState() =>
      _GlucoseMonitoringScreenState();
}

class _GlucoseMonitoringScreenState extends State<GlucoseMonitoringScreen> {
  final GlucoseService _glucoseService = GlucoseService();
  List<Map<String, dynamic>> _glucoseRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGlucoseRecords();
  }

  void _loadGlucoseRecords() {
    _glucoseService.getGlucoseReadings().listen((records) {
      if (mounted) {
        setState(() {
          _glucoseRecords = records;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Glucose Monitoring",
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
            icon: const Icon(Icons.add, color: Color(0xFF0C4556)),
            onPressed: () => _showAddGlucoseDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentReading(),
            const SizedBox(height: 30),
            _buildAIAnalysis(),
            const SizedBox(height: 30),
            _buildRecentReadings(),
            const SizedBox(height: 30),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReading() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final latestRecord = _glucoseRecords.isNotEmpty
        ? _glucoseRecords.first
        : null;
    final glucoseLevel = latestRecord != null
        ? (latestRecord['value'] as double)
        : 0.0;
    final status = _getGlucoseStatus(glucoseLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status['color'] as Color,
            (status['color'] as Color).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (status['color'] as Color).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Current Glucose Level",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${glucoseLevel.toStringAsFixed(0)} mg/dL",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status['message'] as String,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis() {
    // Calculate AI predictions based on recent data (UI only - no actual AI)
    final prediction = _calculateAIPrediction();
    
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C4556).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF0C4556),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "AI Analysis & Prediction",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4556),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (prediction['riskLevel'] != null)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: prediction['riskColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    prediction['riskIcon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction['riskTitle'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          prediction['riskMessage'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          const Text(
            "Trend Analysis",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prediction['trendAnalysis'] as String,
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 15),
          const Text(
            "Personalized Recommendations",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 10),
          ...(prediction['recommendations'] as List<String>)
              .map((rec) => _buildRecommendationItem(rec))
              .toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateAIPrediction() {
    if (_glucoseRecords.isEmpty) {
      return {
        'riskLevel': null,
        'trendAnalysis':
            'No data available yet. Start logging your glucose readings to get AI predictions and personalized recommendations.',
        'recommendations': [
          'Begin monitoring your glucose levels regularly',
          'Log readings at different times of the day',
          'Maintain a consistent monitoring schedule',
        ],
      };
    }

    // Calculate average and trend (mock AI prediction - UI only)
    final recentReadings = _glucoseRecords.take(7).toList();
    final avgGlucose = recentReadings.isEmpty
        ? 0.0
        : (recentReadings
                .map((r) => r['value'] as double)
                .reduce((a, b) => a + b) /
            recentReadings.length);

    final isRising = recentReadings.length > 1 &&
        (recentReadings.first['value'] as double) >
            (recentReadings.last['value'] as double);
    final isHigh = avgGlucose > 180;
    final isLow = avgGlucose < 70;

    String riskTitle;
    String riskMessage;
    Color riskColor;
    IconData riskIcon;

    if (isHigh) {
      riskTitle = 'High Glucose Alert';
      riskMessage =
          'Your average glucose levels are elevated. Consider consulting your doctor.';
      riskColor = Colors.red;
      riskIcon = Icons.warning;
    } else if (isLow) {
      riskTitle = 'Low Glucose Alert';
      riskMessage =
          'Your average glucose levels are low. Monitor closely and have a snack if needed.';
      riskColor = Colors.orange;
      riskIcon = Icons.warning;
    } else {
      riskTitle = 'Normal Range';
      riskMessage =
          'Your glucose levels are within the target range. Keep up the good work!';
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;
    }

    String trendAnalysis = isRising
        ? 'Your glucose levels show a rising trend. Monitor closely and maintain your medication schedule. Consider reviewing your diet and activity levels.'
        : 'Your glucose levels are relatively stable. Continue with your current management plan.';

    List<String> recommendations = [];
    if (isHigh) {
      recommendations = [
        'Take your medications as prescribed',
        'Limit carbohydrate intake in your next meal',
        'Consider light physical activity',
        'Stay well hydrated',
      ];
    } else if (isLow) {
      recommendations = [
        'Have a snack with 15g of carbohydrates',
        'Monitor glucose levels every 15-30 minutes',
        'Avoid strenuous activities until levels normalize',
        'Consult your doctor if levels remain low',
      ];
    } else {
      recommendations = [
        'Continue taking medication as prescribed',
        'Maintain your current diet and exercise routine',
        'Stay hydrated throughout the day',
        'Keep monitoring regularly',
      ];
    }

    return {
      'riskLevel': isHigh ? 'high' : (isLow ? 'low' : 'normal'),
      'riskTitle': riskTitle,
      'riskMessage': riskMessage,
      'riskColor': riskColor,
      'riskIcon': riskIcon,
      'trendAnalysis': trendAnalysis,
      'recommendations': recommendations,
    };
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0C4556), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReadings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Readings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        ..._glucoseRecords.map((record) => _buildReadingCard(record)).toList(),
      ],
    );
  }

  Widget _buildReadingCard(Map<String, dynamic> record) {
    final value = record['value'] as double;
    final status = _getGlucoseStatus(value);
    final timestamp = record['timestamp'] as Timestamp;
    final timeAgo = _getTimeAgo(timestamp.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (status['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.bloodtype,
              color: status['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${value.toStringAsFixed(0)} mg/dL",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C4556),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${_getTypeLabel(record['type'] as String)} • $timeAgo",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (record['notes'] != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    record['notes'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          if (record['isAIFlagged'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "AI Alert",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Add Reading",
                Icons.add,
                () => _showAddGlucoseDialog(),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton("View History", Icons.history, () {}),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton("Set Reminder", Icons.alarm, () {}),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton("Export Data", Icons.download, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, color: const Color(0xFF0C4556), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0C4556),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGlucoseDialog() {
    final glucoseController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'fasting';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Glucose Reading"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: glucoseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Glucose Level (mg/dL)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: "Reading Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                  DropdownMenuItem(
                    value: 'post_meal',
                    child: Text('Post Meal'),
                  ),
                  DropdownMenuItem(value: 'random', child: Text('Random')),
                  DropdownMenuItem(value: 'bedtime', child: Text('Bedtime')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (glucoseController.text.isNotEmpty) {
                  try {
                    await _glucoseService.addGlucoseReading(
                      value: double.parse(glucoseController.text),
                      type: selectedType,
                      notes: notesController.text.isNotEmpty
                          ? notesController.text
                          : null,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add reading: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getGlucoseStatus(double value) {
    const statusColor = Color(0xFF0C4556);
    if (value < 70) {
      return {
        'color': statusColor,
        'message': 'Low - Consider immediate action',
      };
    } else if (value > 180) {
      return {'color': statusColor, 'message': 'High - Monitor closely'};
    } else {
      return {'color': statusColor, 'message': 'Normal - Good control'};
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'fasting':
        return 'Fasting';
      case 'post_meal':
        return 'Post Meal';
      case 'random':
        return 'Random';
      case 'bedtime':
        return 'Bedtime';
      default:
        return 'Unknown';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
