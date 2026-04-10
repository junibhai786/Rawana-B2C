import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

class AppPermissionHandler {
  static const String logTag = '[AppPermissionHandler]';

  /// Request all app-level permissions at startup
  /// This includes location, camera, microphone, etc.
  static Future<void> requestAppLevelPermissions() async {
    developer.log('$logTag Requesting app-level permissions at startup');

    try {
      // Request location permission silently (no specific dialog needed for Flight auto-detect yet)
      await _requestLocationPermission();

      developer.log('$logTag App-level permissions request completed');
    } catch (e) {
      developer.log('$logTag Error requesting app-level permissions: $e');
    }
  }

  /// Request location permission for Flight auto-detection
  /// Called at app startup, not from Flight screen
  static Future<bool> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        developer.log('$logTag Location services are disabled on device');
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      developer.log('$logTag Current location permission: $permission');

      // If already denied forever, don't ask again
      if (permission == LocationPermission.deniedForever) {
        developer.log('$logTag Location permission permanently denied');
        return false;
      }

      // If not granted, request it
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        developer.log('$logTag Location permission result: $permission');
      }

      // Return true if granted
      final isGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (isGranted) {
        developer.log('$logTag ✓ Location permission granted');
      } else {
        developer.log('$logTag ✗ Location permission denied or restricted');
      }

      return isGranted;
    } catch (e) {
      developer.log('$logTag Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is already granted (without requesting)
  static Future<bool> isLocationPermissionGranted() async {
    try {
      final permission = await Geolocator.checkPermission();
      final isGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      developer.log('$logTag Location permission granted: $isGranted');
      return isGranted;
    } catch (e) {
      developer.log('$logTag Error checking location permission: $e');
      return false;
    }
  }
}
