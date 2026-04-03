// lib/Provider/hotel_country_provider.dart
// Hotel-specific country provider — scoped to the Hotel Search module only.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/hotel_country_model.dart';

class HotelCountryProvider with ChangeNotifier {
  List<HotelCountryModel> _countries = [];
  bool _isLoading = false;
  String? _error;
  HotelCountryModel? _selectedCountry;

  List<HotelCountryModel> get countries => List.unmodifiable(_countries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  HotelCountryModel? get selectedCountry => _selectedCountry;
  String get selectedCountryName => _selectedCountry?.countryName ?? '';
  String get selectedCountryCode => _selectedCountry?.countryCode ?? '';

  /// Fetches the hotel country list from the API.
  /// Does nothing if countries are already loaded.
  Future<void> fetchHotelCountries() async {
    if (_countries.isNotEmpty) {
      log('[HotelCountryProvider] Countries already loaded (${_countries.length}), skipping fetch');
      return;
    }

    log('[HotelCountryProvider] Loading = true');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = '${ApiUrls.baseUrl}${ApiUrls.getCountries}';
    log('[HotelCountryAPI] Fetch started');
    log('[HotelCountryAPI] URL: $url');

    try {
      final result = await makeRequest(url, 'GET', {}, '');

      log('[HotelCountryAPI] Response status: ${result['success']}');

      if (result['success'] == true) {
        final response = HotelCountryResponseModel.fromJson(
            result['data'] as Map<String, dynamic>);
        _countries = response.data;
        _error = null;
        log('[HotelCountryAPI] Parsed countries: ${_countries.length}');
      } else {
        final msg =
            result['message']?.toString() ?? 'Failed to load hotel countries';
        log('[HotelCountryAPI] Error: $msg');
        _error = msg;
      }
    } catch (e, stackTrace) {
      log('[HotelCountryAPI] Exception: $e');
      log('[HotelCountryAPI] StackTrace: $stackTrace');
      _error = 'An error occurred while fetching hotel countries';
    }

    log('[HotelCountryProvider] Loading = false');
    _isLoading = false;
    notifyListeners();
  }

  /// Sets the selected hotel country.
  void selectHotelCountry(HotelCountryModel country) {
    log('[HotelCountryProvider] Selected hotel country = ${country.countryName} (${country.countryCode})');
    _selectedCountry = country;
    notifyListeners();
  }

  /// Clears the current hotel country selection.
  void clearHotelCountrySelection() {
    log('[HotelCountryProvider] Hotel country selection cleared');
    _selectedCountry = null;
    notifyListeners();
  }
}
