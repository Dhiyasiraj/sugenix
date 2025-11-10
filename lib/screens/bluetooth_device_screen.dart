import 'package:flutter/material.dart';
import 'package:sugenix/utils/responsive_layout.dart';
import 'package:sugenix/services/language_service.dart';
import 'package:sugenix/screens/language_screen.dart';

class BluetoothDeviceScreen extends StatefulWidget {
  const BluetoothDeviceScreen({super.key});

  @override
  State<BluetoothDeviceScreen> createState() => _BluetoothDeviceScreenState();
}

class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
  bool _isScanning = false;
  bool _isConnected = false;
  String? _connectedDeviceName;
  List<Map<String, dynamic>> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDevices();
  }

  void _loadSavedDevices() {
    // Placeholder: Load saved devices from storage
    setState(() {
      _availableDevices = [
        {
          'name': 'Glucose Meter Pro',
          'address': '00:11:22:33:44:55',
          'type': 'glucose_meter',
          'isPaired': false,
        },
        {
          'name': 'Smart Monitor X1',
          'address': '00:11:22:33:44:56',
          'type': 'glucose_meter',
          'isPaired': true,
        },
      ];
    });
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    // Placeholder: Simulate device scanning
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
      _availableDevices = [
        {
          'name': 'Glucose Meter Pro',
          'address': '00:11:22:33:44:55',
          'type': 'glucose_meter',
          'isPaired': false,
        },
        {
          'name': 'Smart Monitor X1',
          'address': '00:11:22:33:44:56',
          'type': 'glucose_meter',
          'isPaired': true,
        },
        {
          'name': 'Diabetes Tracker 2024',
          'address': '00:11:22:33:44:57',
          'type': 'glucose_meter',
          'isPaired': false,
        },
      ];
    });
  }

  Future<void> _connectToDevice(Map<String, dynamic> device) async {
    setState(() {
      _isConnected = true;
      _connectedDeviceName = device['name'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to ${device['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _disconnectDevice() async {
    setState(() {
      _isConnected = false;
      _connectedDeviceName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device disconnected'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: FutureBuilder<String>(
          future: LanguageService.getTranslated('bluetooth_devices'),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Bluetooth Devices',
              style: TextStyle(
                color: const Color(0xFF0C4556),
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF0C4556)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isConnected)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 15 : 20),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.bluetooth_connected, color: Colors.green),
                  SizedBox(width: ResponsiveHelper.isMobile(context) ? 10 : 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected to $_connectedDeviceName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 4 : 5),
                        Text(
                          'Device is ready to sync glucose readings',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                            ),
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _disconnectDevice,
                  ),
                ],
              ),
            ),
          Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanForDevices,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bluetooth_searching),
                    label: Text(
                      _isScanning ? 'Scanning...' : 'Scan for Devices',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4556),
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.isMobile(context) ? 12 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _availableDevices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    itemCount: _availableDevices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceCard(_availableDevices[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.isMobile(context) ? 100 : 120,
              height: ResponsiveHelper.isMobile(context) ? 100 : 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0C4556).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bluetooth_disabled,
                size: ResponsiveHelper.isMobile(context) ? 50 : 60,
                color: const Color(0xFF0C4556),
              ),
            ),
            SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 30),
            Text(
              'No Devices Found',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C4556),
              ),
            ),
            SizedBox(height: ResponsiveHelper.isMobile(context) ? 10 : 15),
            Text(
              'Make sure your glucose meter is turned on and in pairing mode, then tap "Scan for Devices" to find it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 13,
                  tablet: 14,
                  desktop: 15,
                ),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isPaired = device['isPaired'] as bool? ?? false;
    final isConnected = _isConnected && _connectedDeviceName == device['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 15 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.transparent,
          width: 2,
        ),
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
            width: ResponsiveHelper.isMobile(context) ? 50 : 60,
            height: ResponsiveHelper.isMobile(context) ? 50 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0C4556).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.devices,
              size: ResponsiveHelper.isMobile(context) ? 25 : 30,
              color: const Color(0xFF0C4556),
            ),
          ),
          SizedBox(width: ResponsiveHelper.isMobile(context) ? 12 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device['name'] ?? 'Unknown Device',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0C4556),
                      ),
                    ),
                    if (isPaired) ...[
                      SizedBox(width: ResponsiveHelper.isMobile(context) ? 8 : 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Paired',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 10,
                              tablet: 11,
                              desktop: 12,
                            ),
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 4 : 5),
                Text(
                  device['address'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_connected, color: Colors.green),
              onPressed: _disconnectDevice,
            )
          else
            ElevatedButton(
              onPressed: () => _connectToDevice(device),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4556),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isMobile(context) ? 12 : 16,
                  vertical: ResponsiveHelper.isMobile(context) ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isPaired ? 'Connect' : 'Pair',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

