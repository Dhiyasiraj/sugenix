import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PlatformLocationService {
  // Get current location with web compatibility
  static Future<Position?> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // For web, we'll use a simplified approach
        // In production, you might want to use a web-specific geolocation package
        return Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        // For mobile, use the standard geolocator
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          return null;
        }

        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    } catch (e) {
      return null;
    }
  }

  // Check location permission
  static Future<bool> hasLocationPermission() async {
    try {
      if (kIsWeb) {
        // Web doesn't have traditional permissions
        return true;
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        return permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      }
    } catch (e) {
      return false;
    }
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      if (kIsWeb) {
        // Web doesn't have traditional permissions
        return true;
      } else {
        PermissionStatus status = await Permission.location.request();
        return status == PermissionStatus.granted;
      }
    } catch (e) {
      return false;
    }
  }

  // Get address from coordinates (simplified for web)
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      if (kIsWeb) {
        // For web, return coordinates as string
        return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
      } else {
        // For mobile, use geocoding
        // Note: Placemark is not available in geolocator package
        // You would need to use a separate geocoding package like 'geocoding'
        return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      return 'Unknown location';
    }
  }
}
