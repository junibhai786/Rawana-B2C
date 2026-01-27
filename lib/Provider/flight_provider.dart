import 'dart:convert';
import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/flight_booking_detail_model.dart';
import 'package:moonbnd/modals/flight_details_model.dart';
import 'package:moonbnd/modals/flight_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:moonbnd/modals/airport_search_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FlightProvider with ChangeNotifier {
  String? _token;
  FlightDetailModal? _flightDetail;
  FlightDetailModal? flightDetail;
  FlightBookingResponse? bookingResponse;

  // Airport Search State
  List<AirportResult> _airportResults = [];
  List<AirportResult> get airportResults => _airportResults;
  bool _isSearchingAirports = false;
  bool get isSearchingAirports => _isSearchingAirports;
  String _lastSearchKeyword = '';
  String get lastSearchKeyword => _lastSearchKeyword;

  Timer? _debounceTimer;
  http.Client? _searchClient;

  void clearAirportResults() {
    _airportResults = [];
    _isSearchingAirports = false;
    _lastSearchKeyword = '';
    _debounceTimer?.cancel();
    _searchClient?.close();
    notifyListeners();
  }

  Future<void> searchAirports(String keyword) async {
    _lastSearchKeyword = keyword;
    _debounceTimer?.cancel();

    if (keyword.length < 2) {
      _airportResults = [];
      _isSearchingAirports = false;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _executeAirportSearch(keyword);
    });
  }

  Future<void> _executeAirportSearch(String keyword) async {
    final String searchKeyword = keyword.trim().toUpperCase();
    log('[FlightSearch] keyword=$searchKeyword');

    _isSearchingAirports = true;
    notifyListeners();

    // Cancel previous request
    _searchClient?.close();
    _searchClient = http.Client();

    try {
      final url =
          '${ApiUrls.baseUrl}${ApiUrls.airportSearchEndpoint}?keyword=${Uri.encodeComponent(searchKeyword)}';

      final response = await _searchClient!.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final AirportSearchResponse searchResponse =
            airportSearchResponseFromJson(response.body);
        log('[FlightSearch] raw_total=${searchResponse.total}');

        // Strict Match Filter
        _airportResults = (searchResponse.results ?? []).where((airport) {
          final iataCode = (airport.iataCode ?? '').toUpperCase();
          final cityName = (airport.address?.cityName ?? '').toUpperCase();
          final airportName = (airport.name ?? '').toUpperCase();

          return iataCode.startsWith(searchKeyword) ||
              cityName.startsWith(searchKeyword) ||
              airportName.startsWith(searchKeyword);
        }).toList();

        log('[FlightSearch] filtered_total=${_airportResults.length}');
      }
    } catch (e) {
      if (e is! http.ClientException) {
        log('Error searching airports: $e');
      }
    } finally {
      _isSearchingAirports = false;
      notifyListeners();
    }
  }

  Map<int, FlightList?> flightListPerCategory = {};

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }

  void updateFlightSearchParams({
    required String fromLocation,
    required String toLocation,
    required DateTime departureDate,
    Map<String, dynamic>? travelers,
  }) {
    flightlistapi(2, searchParams: {
      'from_where': fromLocation,
      'to_where': toLocation,
      'start': departureDate,
      'travelers': travelers,
    });
  }

  Future<FlightList?> flightlistapi(
    int index, {
    String? sortBy,
    Map<String, dynamic>? searchParams,
  }) async {
    await loadToken();

    // Build query parameters using IATA codes
    final Map<String, String> queryParams = {};

    // Required parameters
    if (searchParams?['from_where'] != null) {
      queryParams['from_where'] = searchParams!['from_where'].toString();
    }
    if (searchParams?['to_where'] != null) {
      queryParams['to_where'] = searchParams!['to_where'].toString();
    }
    if (searchParams?['start'] != null) {
      queryParams['start'] =
          DateFormat('yyyy-MM-dd').format(searchParams!['start'] as DateTime);
    }

    // Optional parameters
    if (searchParams?['return_date'] != null) {
      queryParams['return_date'] = DateFormat('yyyy-MM-dd')
          .format(searchParams!['return_date'] as DateTime);
    }
    if (searchParams?['trip_search_type'] != null) {
      queryParams['trip_search_type'] =
          searchParams!['trip_search_type'].toString();
    }
    if (searchParams?['seat_type'] != null) {
      final seatType = searchParams!['seat_type'] as Map<String, dynamic>;
      if (seatType['adults'] != null) {
        queryParams['seat_type[adults]'] = seatType['adults'].toString();
      }
      if (seatType['children'] != null) {
        queryParams['seat_type[children]'] = seatType['children'].toString();
      }
      if (seatType['infants'] != null) {
        queryParams['seat_type[infants]'] = seatType['infants'].toString();
      }
    }
    if (searchParams?['cabin'] != null) {
      queryParams['cabin'] = searchParams!['cabin'].toString();
    }
    if (sortBy != null) {
      queryParams['orderby'] = sortBy;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    String url = '${ApiUrls.baseUrl}${ApiUrls.flightSearch}?$queryString';

    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("✅ Flight List Response SUCCESS for index $index");
      log("   Response data keys: ${result['data']?.keys?.toList()}");
      FlightList flightList = FlightList.fromJson(result['data']);
      log("   Total flights found: ${flightList.data?.length ?? 0}");
      flightListPerCategory[index] = flightList;
      notifyListeners();
      return flightList;
    } else {
      log("❌ Failed to fetch flight list");
      log("   Error message: ${result['message']}");
      log("   Response: ${result.toString()}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future fetchFlightDetails(int flightId) async {
    log("Fetching Flight Details for ID: $flightId");
    log("Fetching Flight Details for ID: ${ApiUrls.baseUrl}${ApiUrls.flightDetailsEndPoint}/$flightId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.flightDetailsEndPoint}/$flightId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Flight Details Response: ${result['data']}");
      _flightDetail = FlightDetailModal.fromJson(result['data']);

      log("${_flightDetail?.data?.id} name");
      flightDetail = _flightDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCartForFlight({
    required String serviceId,
    required List<Map<String, dynamic>> flightSeats,
  }) async {
    await loadToken();

    final Map<String, String> body = {
      'service_id': serviceId,
      'service_type': 'flight',
    };

    // Add flight seats to the request
    for (int i = 0; i < flightSeats.length; i++) {
      body['flight_seat[$i][id]'] = flightSeats[i]['id'].toString();
      body['flight_seat[$i][price]'] = flightSeats[i]['price'].toString();
      body['flight_seat[$i][seat_type][id]'] =
          flightSeats[i]['seat_type']['id'].toString();
      body['flight_seat[$i][seat_type][code]'] =
          flightSeats[i]['seat_type']['code'].toString();
      body['flight_seat[$i][number]'] = flightSeats[i]['number'].toString();
    }

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.addToCart}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Add to Cart Response: ${result['data']}");
      return result['data'];
    } else {
      log("Failed to add to cart. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<FlightBookingResponse?> fetchFlightBookingDetails(
      String bookingCode) async {
    await loadToken();

    log("Fetching Booking Details for code: $bookingCode");

    try {
      final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.flightBookingDetails}?booking_code=$bookingCode',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );
      // log("Full API Response: $result");
      if (result['success'] == true) {
        log("Booking Details Response: ${result['data']}");
        bookingResponse = FlightBookingResponse.fromJson(result['data']);
        log("message: $bookingResponse");
        notifyListeners();
      } else {
        log("Failed to fetch booking details. Error: ${result['message'] ?? 'Unknown error'}");
        EasyLoading.showToast(result['message'],
            maskType: EasyLoadingMaskType.black);
        return null;
      }
    } catch (e, stacktrace) {
      log("Exception occurred: $e\nStacktrace: $stacktrace");
      return null;
    }
    return null;
  }
}
