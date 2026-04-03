import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/flight_airport_model.dart';

class FlightAirportProvider with ChangeNotifier {
  List<FlightAirportModel> _airports = [];
  List<FlightAirportModel> _filteredAirports = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<FlightAirportModel> get airports => _airports;
  List<FlightAirportModel> get filteredAirports => _filteredAirports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> fetchAirports() async {
    if (_airports.isNotEmpty) {
      log('[FlightAirportProvider] Airports already cached — skipping fetch');
      return;
    }

    log('[FlightAirportAPI] Fetch started');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.flightAirports}';
      log('[FlightAirportAPI] URL: $url');

      final result = await makeRequest(url, 'GET', {}, '');

      if (result['success'] == true) {
        final response = FlightAirportResponseModel.fromJson(
            result['data'] as Map<String, dynamic>);
        _airports = response.data;
        _filteredAirports = List.from(_airports);
        log('[FlightAirportAPI] Success: ${_airports.length} airports fetched');
      } else {
        _error = result['message']?.toString() ?? 'Failed to load airports';
        log('[FlightAirportAPI] Error: $_error');
      }
    } catch (e) {
      _error = 'An error occurred while loading airports';
      log('[FlightAirportAPI] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterAirports(String query) {
    _searchQuery = query;
    log('[FlightAirportProvider] Search query = $query');

    if (query.isEmpty) {
      _filteredAirports = List.from(_airports);
    } else {
      final q = query.toLowerCase();
      _filteredAirports = _airports.where((a) {
        return a.city.toLowerCase().contains(q) ||
            a.airport.toLowerCase().contains(q) ||
            a.iataCode.toLowerCase().contains(q) ||
            a.country.toLowerCase().contains(q);
      }).toList();
    }

    log('[FlightAirportProvider] Filtered results = ${_filteredAirports.length}');
    notifyListeners();
  }

  void clearFilter() {
    _searchQuery = '';
    _filteredAirports = List.from(_airports);
    notifyListeners();
  }

  void retryFetch() {
    _airports = [];
    _filteredAirports = [];
    _error = null;
    fetchAirports();
  }
}
