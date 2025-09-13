import 'package:flutter/material.dart';
import 'package:sugenix/screens/medical_records_screen.dart';
import 'package:sugenix/screens/medicine_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: "Abdullah Human");
  final _mobileController = TextEditingController(text: "+90700000000");
  final _emailController = TextEditingController(text: "abdullah@gmail.com");
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
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
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildPersonalInfoSection(),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF0C4556),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Setup your profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF0C4556),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Color(0xFF0C4556),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoField("Name", _nameController, Icons.person),
          const SizedBox(height: 20),
          _buildInfoField("Mobile Number", _mobileController, Icons.phone),
          const SizedBox(height: 20),
          _buildInfoField("Email", _emailController, Icons.email),
          const SizedBox(height: 20),
          _buildInfoField(
            "Address",
            _addressController,
            Icons.location_on,
            hintText: "Add Address",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(Icons.edit, color: const Color(0xFF0C4556)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Handle profile update
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated successfully!"),
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
            "CONTINUE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _textMessages = true;
  bool _pushAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Settings",
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSettings(),
            const SizedBox(height: 30),
            _buildMoreOptions(),
            const SizedBox(height: 30),
            _buildLanguageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    final accountItems = [
      {"title": "Change Password", "icon": Icons.lock},
      {"title": "Notifications", "icon": Icons.notifications},
      {"title": "Statistics", "icon": Icons.analytics},
      {"title": "About us", "icon": Icons.info},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Account settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        ...accountItems
            .map(
              (item) => _buildSettingsItem(
                item["title"] as String,
                item["icon"] as IconData,
                () {},
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildMoreOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "More options",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        _buildToggleItem("Text messages", _textMessages, (value) {
          setState(() {
            _textMessages = value;
          });
        }),
        _buildToggleItem("Push alerts", _pushAlerts, (value) {
          setState(() {
            _pushAlerts = value;
          });
        }),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Language",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        _buildSettingsItem("English", Icons.language, () {}),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C4556)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.settings, color: Color(0xFF0C4556)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0C4556),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C4556), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [_buildHeader(), _buildMenuItems(), _buildLogoutButton()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "USER NAME",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "+90700000000",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {"title": "My Doctors", "icon": Icons.medical_services},
      {"title": "Medical Records", "icon": Icons.assignment},
      {"title": "Medicines Orders", "icon": Icons.medication},
      {"title": "Privacy & Policy", "icon": Icons.privacy_tip},
      {"title": "Help Center", "icon": Icons.help},
      {"title": "Settings", "icon": Icons.settings},
    ];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
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
                  _navigateToMenuItem(context, item["title"] as String);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Handle logout
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMenuItem(BuildContext context, String title) {
    switch (title) {
      case "My Doctors":
        // Navigate to doctors list
        break;
      case "Medical Records":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MedicalRecordsScreen()),
        );
        break;
      case "Medicines Orders":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MedicineOrdersScreen()),
        );
        break;
      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$title feature coming soon!")));
    }
  }
}
