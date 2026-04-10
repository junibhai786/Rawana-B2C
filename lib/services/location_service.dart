import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moonbnd/modals/flight_airport_model.dart';

class LocationService {
  static const String logTag = '[LocationService]';

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log('$logTag Error checking location service: $e');
      return false;
    }
  }

  /// Request location permissions
  static Future<LocationPermission> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      developer.log('$logTag Location permission requested: $permission');
      return permission;
    } catch (e) {
      developer.log('$logTag Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Get current device location (GPS coordinates)
  /// Note: Permission should be pre-granted at app startup by AppPermissionHandler
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool isServiceEnabled = await isLocationServiceEnabled();
      if (!isServiceEnabled) {
        developer.log('$logTag Location services are disabled');
        return null;
      }

      // Check permissions (should already be granted from app startup)
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        developer.log(
            '$logTag Location permission not granted - skipping location detection');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      developer.log(
          '$logTag Got current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      developer.log('$logTag Error getting current location: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to get city and country
  static Future<Map<String, String>?> reverseGeocodeLocation(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        developer.log('$logTag No placemarks found');
        return null;
      }

      final placemark = placemarks.first;
      final city = placemark.locality ?? placemark.administrativeArea ?? '';
      final country = placemark.country ?? '';

      developer.log('$logTag Reverse geocoded: City=$city, Country=$country');

      return {
        'city': city,
        'country': country,
      };
    } catch (e) {
      developer.log('$logTag Error reverse geocoding: $e');
      return null;
    }
  }

  /// Find the nearest airport to given coordinates
  static FlightAirportModel? findNearestAirport(
    double latitude,
    double longitude,
    List<FlightAirportModel> airports,
  ) {
    if (airports.isEmpty) {
      developer.log('$logTag No airports available to search');
      return null;
    }

    FlightAirportModel? nearestAirport;
    double minDistance = double.infinity;

    for (final airport in airports) {
      // Skip airports without coordinates
      if (airport.latitude == null || airport.longitude == null) continue;

      // Calculate distance using Haversine formula
      final distance = _calculateDistance(
        latitude,
        longitude,
        airport.latitude!,
        airport.longitude!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestAirport = airport;
      }
    }

    if (nearestAirport != null) {
      developer.log(
          '$logTag Nearest airport: ${nearestAirport.iataCode} (${nearestAirport.city}) - ${minDistance.toStringAsFixed(2)} km away');
    }

    return nearestAirport;
  }

  /// Calculate distance between two coordinates using Haversine formula
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreeToRadian(lat2 - lat1);
    final dLon = _degreeToRadian(lon2 - lon1);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_degreeToRadian(lat1)) *
            math.cos(_degreeToRadian(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreeToRadian(double degree) {
    return degree * math.pi / 180.0;
  }

  /// Auto-detect and get the nearest airport IATA code based on current location
  static Future<String?> detectNearestAirportCode(
    List<FlightAirportModel> airports,
  ) async {
    try {
      // Step 1: Get current location
      final position = await getCurrentLocation();
      if (position == null) {
        developer.log('$logTag Could not get current location');
        return null;
      }

      // Step 2: Find nearest airport
      final nearestAirport = findNearestAirport(
        position.latitude,
        position.longitude,
        airports,
      );

      if (nearestAirport == null) {
        developer.log('$logTag Could not find nearest airport');
        return null;
      }

      developer
          .log('$logTag Auto-detected airport: ${nearestAirport.iataCode}');
      return nearestAirport.iataCode;
    } catch (e) {
      developer.log('$logTag Error detecting nearest airport: $e');
      return null;
    }
  }
}
