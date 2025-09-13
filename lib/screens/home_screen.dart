import 'package:flutter/material.dart';
import 'package:sugenix/models/doctor.dart';
import 'package:sugenix/screens/doctor_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Doctor> liveDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialization: 'Diabetologist',
      rating: 4.8,
      isOnline: true,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Michael Chen',
      specialization: 'Endocrinologist',
      rating: 4.9,
      isOnline: true,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Emily Davis',
      specialization: 'Nutritionist',
      rating: 4.7,
      isOnline: true,
    ),
  ];

  final List<Doctor> popularDoctors = [
    Doctor(
      id: '4',
      name: 'Dr. Firozup Grab',
      specialization: 'Diabetologist',
      rating: 4.9,
      totalBookings: 180,
      totalPatients: 580,
      likes: 290,
    ),
    Doctor(
      id: '5',
      name: 'Dr. Blessing',
      specialization: 'Endocrinologist',
      rating: 4.8,
      totalBookings: 150,
      totalPatients: 450,
      likes: 250,
    ),
  ];

  final List<Doctor> pediatricDoctors = [
    Doctor(
      id: '6',
      name: 'Dr. Lisa Wong',
      specialization: 'Pediatric Diabetologist',
      rating: 4.9,
    ),
    Doctor(
      id: '7',
      name: 'Dr. James Wilson',
      specialization: 'Pediatric Endocrinologist',
      rating: 4.8,
    ),
    Doctor(
      id: '8',
      name: 'Dr. Maria Garcia',
      specialization: 'Pediatric Nutritionist',
      rating: 4.7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isTablet),
              SizedBox(height: isTablet ? 30 : 20),
              _buildSearchBar(),
              SizedBox(height: isTablet ? 40 : 30),
              _buildLiveDoctorsSection(isTablet),
              SizedBox(height: isTablet ? 40 : 30),
              _buildPopularDoctorsSection(),
              SizedBox(height: isTablet ? 40 : 30),
              _buildPediatricDoctorsSection(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, Homerwork!",
              style: TextStyle(
                fontSize: isTablet ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C4556),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Find Your Doctor",
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: isTablet ? 35 : 25,
          backgroundColor: const Color(0xFF0C4556),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isTablet ? 40 : 30,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLiveDoctorsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Live Doctors",
          style: TextStyle(
            fontSize: isTablet ? 28 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0C4556),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 15),
        SizedBox(
          height: isTablet ? 250 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: liveDoctors.length,
            itemBuilder: (context, index) {
              final doctor = liveDoctors[index];
              return Container(
                width: isTablet ? 200 : 150,
                margin: EdgeInsets.only(right: isTablet ? 20 : 15),
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
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C4556),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: isTablet ? 70 : 50,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
                      child: Column(
                        children: [
                          Text(
                            doctor.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialization,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: isTablet ? 16 : 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Popular Doctor",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        ...popularDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
      ],
    );
  }

  Widget _buildPediatricDoctorsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pediatric Doctor",
          style: TextStyle(
            fontSize: isTablet ? 28 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0C4556),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 15),
        SizedBox(
          height: isTablet ? 150 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pediatricDoctors.length,
            itemBuilder: (context, index) {
              final doctor = pediatricDoctors[index];
              return Container(
                width: isTablet ? 130 : 100,
                margin: EdgeInsets.only(right: isTablet ? 20 : 15),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 45 : 35,
                      backgroundColor: const Color(0xFF0C4556),
                      child: Text(
                        doctor.name.split(' ').map((e) => e[0]).join(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailsScreen(doctor: doctor),
          ),
        );
      },
      child: Container(
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
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF0C4556),
              child: Text(
                doctor.name.split(' ').map((e) => e[0]).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        doctor.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetailsScreen(doctor: doctor),
                  ),
                );
              },
              icon: const Icon(Icons.favorite_border, color: Color(0xFF0C4556)),
            ),
          ],
        ),
      ),
    );
  }
}
