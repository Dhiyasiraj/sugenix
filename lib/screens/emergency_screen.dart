import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isEmergencyActive = false;
  int _countdown = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: _isEmergencyActive
                ? [Colors.red, Colors.red.shade900]
                : [const Color(0xFF0C4556), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isEmergencyActive) ...[
                  _buildEmergencyIcon(),
                  const SizedBox(height: 30),
                  _buildEmergencyTitle(),
                  const SizedBox(height: 20),
                  _buildEmergencyDescription(),
                  const SizedBox(height: 40),
                  _buildSOSButton(),
                ] else ...[
                  _buildCountdownDisplay(),
                  const SizedBox(height: 30),
                  _buildEmergencyActiveContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.emergency, size: 60, color: Colors.white),
    );
  }

  Widget _buildEmergencyTitle() {
    return const Text(
      "Emergency SOS",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEmergencyDescription() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        "Press and hold the button below to activate emergency mode. Your location and medical information will be shared with emergency contacts.",
        style: TextStyle(fontSize: 16, color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTapDown: (_) => _startEmergency(),
      onTapUp: (_) => _cancelEmergency(),
      onTapCancel: () => _cancelEmergency(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "SOS",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _countdown.toString(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyActiveContent() {
    return Column(
      children: [
        const Text(
          "Emergency Activated!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Your emergency contacts have been notified.\nHelp is on the way!",
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _cancelEmergency,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            "Cancel Emergency",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _startEmergency() {
    setState(() {
      _isEmergencyActive = true;
      _countdown = 5;
    });
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isEmergencyActive && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else if (_isEmergencyActive) {
        _activateEmergency();
      }
    });
  }

  void _activateEmergency() {
    // Simulate emergency activation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Emergency activated! Contacts notified."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _cancelEmergency() {
    setState(() {
      _isEmergencyActive = false;
      _countdown = 5;
    });
  }
}

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Enable Location Services",
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C4556).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Color(0xFF0C4556),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Location",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4556),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your location services are currently turned off. Please enable location to use all features of the app.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Request location permission
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Location permission requested"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4556),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Enable Location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, dynamic>> helpItems = const [
    {"title": "Find a doctor", "icon": Icons.search},
    {"title": "Booking an appointment", "icon": Icons.calendar_today},
    {"title": "Canceling appointment", "icon": Icons.cancel},
    {"title": "Billing & payments", "icon": Icons.payment},
    {"title": "Feedback", "icon": Icons.feedback},
    {"title": "Medicine orders", "icon": Icons.medication},
    {"title": "Payment FAQs", "icon": Icons.help_outline},
    {"title": "My account and Profile", "icon": Icons.person},
    {"title": "Raise an issue or query", "icon": Icons.report_problem},
    {"title": "Other issues", "icon": Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Help center",
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          final item = helpItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                item["icon"] as IconData,
                color: const Color(0xFF0C4556),
              ),
              title: Text(
                item["title"] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                _handleHelpItemTap(context, item["title"] as String);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleHelpItemTap(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title help section coming soon!"),
        backgroundColor: const Color(0xFF0C4556),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Privacy policy",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sugenix Privacy Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C4556),
              ),
            ),
            const SizedBox(height: 20),
            _buildPolicySection(
              "1. Information We Collect",
              "We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This may include your name, email address, phone number, medical information, and other personal data.",
            ),
            _buildPolicySection(
              "2. How We Use Your Information",
              "We use the information we collect to provide, maintain, and improve our services, including diabetes management tools, AI-powered health recommendations, and emergency services.",
            ),
            _buildPolicySection(
              "3. Information Sharing",
              "We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this privacy policy or as required by law.",
            ),
            _buildPolicySection(
              "4. Data Security",
              "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.",
            ),
            _buildPolicySection(
              "5. Your Rights",
              "You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.",
            ),
            _buildPolicySection(
              "6. Emergency Services",
              "In case of emergency, we may share your location and medical information with emergency contacts and medical professionals to ensure your safety.",
            ),
            _buildPolicySection(
              "7. Contact Us",
              "If you have any questions about this privacy policy, please contact us at privacy@sugenix.com.",
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Last updated: March 2024\nVersion: 1.0",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
