import 'package:flutter/material.dart';
import 'package:sugenix/screens/admin_panel_screen.dart';
import 'package:sugenix/screens/pharmacy_dashboard_screen.dart';

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1100;
          return Row(
            children: [
              if (isWide) Expanded(child: _buildHero()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildCTA(context),
                      const SizedBox(height: 32),
                      _buildFeatures(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Sugenix Web Portal',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0C4556),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Dedicated interfaces for Admins and Pharmacies.\nManage users, orders, inventory, and analytics from the web.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPanelScreen(initialTab: 0)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C4556),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text(
            'Go to Admin Portal',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PharmacyDashboardScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0C4556),
            side: const BorderSide(color: Color(0xFF0C4556)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.local_pharmacy),
          label: const Text(
            'Go to Pharmacy Portal',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final items = [
      (
        Icons.analytics_outlined,
        'Analytics Dashboard',
        'Monitor users, revenue, appointments, and operational KPIs.'
      ),
      (
        Icons.inventory_2_outlined,
        'Inventory & Orders',
        'Manage stock, track pharmacy orders, and handle fulfillment.'
      ),
      (
        Icons.shield_outlined,
        'Secure Access',
        'Role-based controls; admin and pharmacy are web-only for safety.'
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items
          .map(
            (item) => Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C4556).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$1, color: const Color(0xFF0C4556)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C4556),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.$3,
                    style: const TextStyle(color: Colors.black54, height: 1.4),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C4556),
            Color(0xFF1B6B8F),
          ],
        ),
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1582719478248-70e5711e4145?auto=format&fit=crop&w=1200&q=80',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black26,
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: const Text(
          'Operate your clinic & pharmacy\nfrom a powerful web dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

