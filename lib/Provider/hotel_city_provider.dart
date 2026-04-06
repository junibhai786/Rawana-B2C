// lib/Provider/hotel_city_provider.dart
// Hotel-specific city provider — scoped to the Hotel Search module only.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/hotel_city_model.dart';

class HotelCityProvider with ChangeNotifier {
  List<HotelCityModel> _cities = [];
  bool _isLoading = false;
  String? _error;
  HotelCityModel? _selectedCity;

  /// Tracks which country code the current [_cities] list belongs to.
  /// Used to avoid redundant fetches for the same country.
  String? _fetchedForCountryCode;

  List<HotelCityModel> get cities => List.unmodifiable(_cities);
  bool get isLoading => _isLoading;
  String? get error => _error;
  HotelCityModel? get selectedCity => _selectedCity;
  String get selectedCityName => _selectedCity?.cityName ?? '';
  String get selectedCityCode => _selectedCity?.cityCode ?? '';

  /// Fetches cities for [countryCode].
  /// Skips the API call if cities were already fetched for the same country.
  Future<void> fetchHotelCities(String countryCode) async {
    if (_fetchedForCountryCode == countryCode && _cities.isNotEmpty) {
      log('[HotelCityProvider] Cities already loaded for $countryCode (${_cities.length}), skipping fetch');
      return;
    }

    log('[HotelCityProvider] Loading = true');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url =
        '${ApiUrls.baseUrl}${ApiUrls.hotelCitiesByCountry(countryCode)}';
    log('[HotelCityAPI] Fetch started');
    log('[HotelCityAPI] Country code = $countryCode');
    log('[HotelCityAPI] URL: $url');

    try {
      final result = await makeRequest(url, 'GET', {}, '');

      log('[HotelCityAPI] Response status: ${result['success']}');

      if (result['success'] == true) {
        final response = HotelCityResponseModel.fromJson(
            result['data'] as Map<String, dynamic>);
        _cities = response.data;
        _fetchedForCountryCode = countryCode;
        _error = null;
        log('[HotelCityAPI] Success: ${_cities.length} cities fetched');
      } else {
        final msg =
            result['message']?.toString() ?? 'Failed to load hotel cities';
        log('[HotelCityAPI] Error: $msg');
        _error = msg;
      }
    } catch (e, stackTrace) {
      log('[HotelCityAPI] Exception: $e');
      log('[HotelCityAPI] StackTrace: $stackTrace');
      _error = 'An error occurred while fetching hotel cities';
    }

    log('[HotelCityProvider] Loading = false');
    _isLoading = false;
    notifyListeners();
  }

  /// Sets the selected hotel city.
  void selectHotelCity(HotelCityModel city) {
    log('[HotelCityProvider] Selected city = ${city.cityName}');
    log('[HotelCityProvider] Selected city code = ${city.cityCode}');
    _selectedCity = city;
    notifyListeners();
  }

  /// Clears selected city and city list when country changes.
  void clearOnCountryChange() {
    log('[HotelCityProvider] Country changed, clearing old city selection');
    _selectedCity = null;
    _cities = [];
    _fetchedForCountryCode = null;
    _error = null;
    notifyListeners();
  }
}
