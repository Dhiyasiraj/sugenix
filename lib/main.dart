import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/firebase_options.dart';
import 'package:sugenix/splash.dart';
import 'package:sugenix/Login.dart';
import 'package:sugenix/signin.dart';
import 'package:sugenix/screens/home_screen.dart';
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
import 'package:sugenix/services/favorites_service.dart';
import 'package:sugenix/models/doctor.dart';

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
        // Note: Doctor details requires a Doctor object; navigate via MaterialPageRoute
        '/medical-records': (context) => const MedicalRecordsScreen(),
        '/medicine-orders': (context) => const MedicineOrdersScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/glucose-monitoring': (context) => const GlucoseMonitoringScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/wellness': (context) => const WellnessScreen(),
        '/medicine-scanner': (context) => const MedicineScannerScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const GlucoseMonitoringScreen(),
    const MedicalRecordsScreen(),
    const MedicineOrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: isTablet ? 28 : 24),
              activeIcon: Icon(Icons.home, size: isTablet ? 28 : 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.monitor_heart_outlined,
                size: isTablet ? 28 : 24,
              ),
              activeIcon: Icon(Icons.monitor_heart, size: isTablet ? 28 : 24),
              label: 'Glucose',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined, size: isTablet ? 28 : 24),
              activeIcon: Icon(Icons.assignment, size: isTablet ? 28 : 24),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined, size: isTablet ? 28 : 24),
              activeIcon: Icon(Icons.medication, size: isTablet ? 28 : 24),
              label: 'Medicine',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: isTablet ? 28 : 24),
              activeIcon: Icon(Icons.person, size: isTablet ? 28 : 24),
              label: 'Profile',
            ),
          ],
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
