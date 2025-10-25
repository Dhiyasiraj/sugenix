import 'package:flutter/material.dart';
import 'package:sugenix/models/glucose_record.dart';
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
                "AI Analysis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4556),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Your glucose levels are within normal range. Continue monitoring and maintain your current diet and medication routine.",
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 15),
          _buildRecommendationItem("Take your medication as prescribed"),
          _buildRecommendationItem("Stay hydrated throughout the day"),
          _buildRecommendationItem("Consider light exercise after meals"),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
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
    if (value < 70) {
      return {
        'color': Colors.red,
        'message': 'Low - Consider immediate action',
      };
    } else if (value > 180) {
      return {'color': Colors.orange, 'message': 'High - Monitor closely'};
    } else {
      return {'color': Colors.green, 'message': 'Normal - Good control'};
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
