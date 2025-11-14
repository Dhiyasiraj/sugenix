import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/firebase_options.dart';
import 'package:sugenix/splash.dart';
import 'package:sugenix/Login.dart';
import 'package:sugenix/signin.dart';
import 'package:sugenix/screens/home_screen.dart';
import 'package:sugenix/screens/patient_home_screen.dart';
import 'package:sugenix/screens/medical_records_screen.dart';
import 'package:sugenix/screens/medicine_orders_screen.dart';
import 'package:sugenix/screens/profile_screen.dart';
import 'package:sugenix/screens/emergency_screen.dart';
import 'package:sugenix/screens/glucose_monitoring_screen.dart';
import 'package:sugenix/screens/ai_assistant_screen.dart';
import 'package:sugenix/screens/wellness_screen.dart';
import 'package:sugenix/screens/medicine_scanner_screen.dart';
import 'package:sugenix/screens/appointments_screen.dart';
import 'package:sugenix/screens/doctor_details_screen.dart';
import 'package:sugenix/screens/glucose_history_screen.dart';
import 'package:sugenix/screens/bluetooth_device_screen.dart';
import 'package:sugenix/screens/emergency_contacts_screen.dart';
import 'package:sugenix/services/favorites_service.dart';
import 'package:sugenix/services/auth_service.dart';
import 'package:sugenix/models/doctor.dart';
import 'package:sugenix/screens/doctor_registration_screen.dart';
import 'package:sugenix/screens/pharmacy_registration_screen.dart';
import 'package:sugenix/screens/medicine_catalog_screen.dart';
import 'package:sugenix/screens/patient_dashboard_screen.dart';
import 'package:sugenix/screens/pharmacy_dashboard_screen.dart';
import 'package:sugenix/screens/pharmacy_orders_screen.dart';
import 'package:sugenix/screens/pharmacy_inventory_screen.dart';
import 'package:sugenix/screens/doctor_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firebase offline persistence
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const SugenixApp());
}

class SugenixApp extends StatelessWidget {
  const SugenixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sugenix - Diabetes Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF0C4556),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0C4556),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C4556),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/home': (context) => const HomeScreen(),
        '/register-doctor': (context) => const DoctorRegistrationScreen(),
        '/register-pharmacy': (context) => const PharmacyRegistrationScreen(),
        // Note: Doctor details requires a Doctor object; navigate via MaterialPageRoute
        '/medical-records': (context) => const MedicalRecordsScreen(),
        '/medicine-orders': (context) => const MedicineOrdersScreen(),
        '/medicine-catalog': (context) => const MedicineCatalogScreen(),
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/glucose-monitoring': (context) => const GlucoseMonitoringScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/wellness': (context) => const WellnessScreen(),
        '/medicine-scanner': (context) => const MedicineScannerScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/glucose-history': (context) => const GlucoseHistoryScreen(),
        '/bluetooth-devices': (context) => const BluetoothDeviceScreen(),
        '/emergency-contacts': (context) => const EmergencyContactsScreen(),
        '/pharmacy-dashboard': (context) => const PharmacyDashboardScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final authService = AuthService();
      final profile = await authService.getUserProfile();
      setState(() {
        _userRole = profile?['role'] ?? 'user';
        _loadingRole = false;
      });
    } catch (e) {
      setState(() {
        _userRole = 'user';
        _loadingRole = false;
      });
    }
  }

  List<Widget> get _screens {
    if (_userRole == 'pharmacy') {
      return [
        const PharmacyDashboardScreen(),
        const PharmacyOrdersScreen(),
        const PharmacyInventoryScreen(),
        const ProfileScreen(),
      ];
    } else if (_userRole == 'doctor') {
      return [
        const DoctorDashboardScreen(),
        const AppointmentsScreen(),
        const MedicalRecordsScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Patient/User
      return [
        const PatientHomeScreen(),
        const GlucoseMonitoringScreen(),
        const MedicalRecordsScreen(),
        const MedicineOrdersScreen(),
        const ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    if (_userRole == 'pharmacy') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined, size: 24),
          activeIcon: Icon(Icons.dashboard, size: 24),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined, size: 24),
          activeIcon: Icon(Icons.receipt_long, size: 24),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined, size: 24),
          activeIcon: Icon(Icons.inventory_2, size: 24),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Profile',
        ),
      ];
    } else if (_userRole == 'doctor') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined, size: 24),
          activeIcon: Icon(Icons.dashboard, size: 24),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined, size: 24),
          activeIcon: Icon(Icons.calendar_today, size: 24),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined, size: 24),
          activeIcon: Icon(Icons.assignment, size: 24),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Profile',
        ),
      ];
    } else {
      // Patient/User
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monitor_heart_outlined, size: 24),
          activeIcon: Icon(Icons.monitor_heart, size: 24),
          label: 'Glucose',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined, size: 24),
          activeIcon: Icon(Icons.assignment, size: 24),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication_outlined, size: 24),
          activeIcon: Icon(Icons.medication, size: 24),
          label: 'Medicine',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF0C4556),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: isTablet ? 16 : 12,
          unselectedFontSize: isTablet ? 14 : 10,
          items: _navItems,
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
      ),
      body: const Center(
        child: Text(
          'Calendar Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Doctors'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
      ),
      body: StreamBuilder<List<Doctor>>(
        stream: favoritesService.streamFavoriteDoctors(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const Center(
              child: Text(
                'No favourites yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final d = doctors[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0C4556),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  d.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C4556),
                  ),
                ),
                subtitle: Text(
                  d.specialization,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailsScreen(doctor: d),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F6F8),
    );
  }
}
