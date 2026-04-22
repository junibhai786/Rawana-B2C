import 'package:flutter/material.dart';
import 'package:moonbnd/modals/hotel_search_model.dart';
import 'package:moonbnd/services/hotel_api_service.dart';

class SearchHotelProvider with ChangeNotifier {
  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HotelModel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Search hotels with proper date formatting and error handling
  ///
  /// Parameters:
  /// - [city]: City name
  /// - [checkIn]: Check-in date (DateTime object — formatting handled internally)
  /// - [checkOut]: Check-out date (DateTime object — formatting handled internally)
  /// - [adults]: Number of adults
  /// - [children]: Number of children
  /// - [rooms]: Number of rooms
  /// - [token]: Authorization token
  Future<bool> searchHotels({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    required String token,
  }) async {
    // === Clear previous error before each call ===
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('[SearchHotelProvider] Starting hotel search...');
      print('[SearchHotelProvider] City: $city');
      print('[SearchHotelProvider] Check-in: $checkIn');
      print('[SearchHotelProvider] Check-out: $checkOut');
      print('[SearchHotelProvider] Guests: $adults adults, $children children');
      print('[SearchHotelProvider] Rooms: $rooms');

      // === Call API service (handles date formatting internally) ===
      final hotels = await HotelApiService.searchHotels(
        city: city,
        checkIn: checkIn,
        checkOut: checkOut,
        adults: adults,
        children: children,
        rooms: rooms,
        token: token,
      );

      print('[SearchHotelProvider] ✓ API returned ${hotels.length} hotels');

      _hotels = hotels;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print('[SearchHotelProvider] ✗ ERROR: $e');
      _errorMessage = e.toString();
      _hotels = [];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear all state
  void reset() {
    _hotels = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
