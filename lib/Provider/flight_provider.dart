import 'dart:convert';
import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/flight_booking_detail_model.dart';
import 'package:moonbnd/modals/flight_details_model.dart';
import 'package:moonbnd/modals/flight_list_model.dart';
import 'package:moonbnd/modals/flight_search_response_model.dart';
import 'package:moonbnd/modals/flight_prebook_response_model.dart';
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
    int page = 1,
  }) async {
    await loadToken();
    log('[FlightSearch] Search button pressed');

    // Build query parameters for the new API
    final Map<String, String> queryParams = {};

    // Map old parameter names to new API format
    String? origin;
    String? destination;
    String? departureDate;
    String? returnDate;
    String? tripType;
    int? adults = 0;
    int? children = 0;
    int? infants = 0;
    String? cabinClass = 'ECONOMY';

    if (searchParams?['from_where'] != null) {
      origin = searchParams!['from_where'].toString();
      queryParams['origin'] = origin;
    }

    if (searchParams?['to_where'] != null) {
      destination = searchParams!['to_where'].toString();
      queryParams['destination'] = destination;
    }

    if (searchParams?['start'] != null) {
      departureDate =
          DateFormat('yyyy-MM-dd').format(searchParams!['start'] as DateTime);
      queryParams['departure_date'] = departureDate;
    }

    if (searchParams?['return_date'] != null) {
      returnDate = DateFormat('yyyy-MM-dd')
          .format(searchParams!['return_date'] as DateTime);
      queryParams['return_date'] = returnDate;
    }

    if (searchParams?['trip_search_type'] != null) {
      tripType = searchParams!['trip_search_type'].toString();
      // Convert 'round_trip' to 'round_trip', 'one_way' to 'one_way'
      queryParams['trip_type'] = tripType;
    }

    // Parse passenger counts from seat_type
    if (searchParams?['seat_type'] != null) {
      final seatType = searchParams!['seat_type'] as Map<String, dynamic>;
      adults = seatType['adults'] as int?;
      children = seatType['children'] as int?;
      infants = seatType['infants'] as int?;

      if (adults != null) {
        queryParams['adults'] = adults.toString();
      }
      if (children != null) {
        queryParams['children'] = children.toString();
      }
      if (infants != null) {
        queryParams['infants'] = infants.toString();
      }
    }

    // Map cabin class from UI format to API format
    if (searchParams?['cabin_class'] != null) {
      final uiCabin = searchParams!['cabin_class'].toString();
      cabinClass = _mapCabinClass(uiCabin);
      queryParams['cabin_class'] = cabinClass;
    }

    // Debug logs
    log('[FlightSearch] Validation passed');
    log('[FlightSearch] Origin = $origin');
    log('[FlightSearch] Destination = $destination');
    log('[FlightSearch] Trip type = $tripType');
    log('[FlightSearch] Departure date = $departureDate');
    if (returnDate != null) log('[FlightSearch] Return date = $returnDate');
    log('[FlightSearch] Adults = $adults');
    log('[FlightSearch] Children = $children');
    log('[FlightSearch] Infants = $infants');
    log('[FlightSearch] Cabin class = $cabinClass');

    // Build URL with query parameters
    queryParams['page'] = page.toString();
    final queryString = Uri(queryParameters: queryParams).query;
    String url = '${ApiUrls.baseUrl}${ApiUrls.flightSearch}?$queryString';

    log('[FlightSearchAPI] POST started');
    log('[FlightSearchAPI] URL: $url');
    log('[FlightSearchAPI] Query params: $queryParams');

    // Make POST request instead of GET
    final result = await makeRequest(
      url,
      'POST',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("✅ Flight List Response SUCCESS for index $index");
      log("   Response data keys: ${result['data']?.keys?.toList()}");

      // Parse new FlightSearchResponse format
      final flightSearchResponse =
          FlightSearchResponse.fromJson(result['data'] ?? {});

      log('[FlightSearchAPI] Success count = ${flightSearchResponse.count}');
      log('[FlightSearchAPI] lastPage = ${flightSearchResponse.lastPage}');
      log('[FlightSearchAPI] total = ${flightSearchResponse.total}');

      // Convert new response format to old Flight model for backward compatibility
      final flightList =
          _convertFlightSearchResponseToFlightList(flightSearchResponse);

      log("   Total flights found: ${flightList.data?.length ?? 0}");
      flightListPerCategory[index] = flightList;
      notifyListeners();
      return flightList;
    } else {
      log("❌ Failed to fetch flight list");
      log("   Error message: ${result['message']}");
      log("   Response: ${result.toString()}");
      log('[FlightSearchAPI] Error: ${result['message']}');
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

  /// Prebook flight API call
  /// Called when user taps Select button on Available Flights screen
  /// Accepts the selected Flight object as single source of truth
  Future<FlightPreBookResponse?> preBookFlight({
    required Flight selectedFlight,
    required int adults,
    required int children,
    required int infants,
  }) async {
    await loadToken();

    try {
      // DEBUG: Log selected flight object to verify all fields are populated
      log('[FlightPreBook] Selected Flight Object:');
      log('  - id: ${selectedFlight.id}');
      log('  - provider: ${selectedFlight.provider}');
      log('  - origin: ${selectedFlight.origin}');
      log('  - destination: ${selectedFlight.destination}');
      log('  - airlineName: ${selectedFlight.airlineName}');
      log('  - airlineCode: ${selectedFlight.airlineCode}');
      log('  - cabinClass: ${selectedFlight.cabinClass}');
      log('  - flightNumber: ${selectedFlight.flightNumber}');
      log('  - stops: ${selectedFlight.stops}');
      log('  - totalPrice: ${selectedFlight.totalPrice}');

      // Extract flight data
      final offerId = selectedFlight.id ?? '';
      final provider = selectedFlight.provider ?? '';
      final depIata = selectedFlight.origin ?? '';
      final arrIata = selectedFlight.destination ?? '';

      // Get first flight detail for time and date info
      final flightDetail = selectedFlight.flightDetails?.isNotEmpty == true
          ? selectedFlight.flightDetails![0]
          : null;

      final depTime = flightDetail?.depTime ?? '';
      final depDate = flightDetail?.depDate ?? '';
      final arrTime = flightDetail?.arrTime ?? '';
      final arrDate = flightDetail?.arrDate ?? '';

      // Validate required fields
      if (offerId.isEmpty ||
          provider.isEmpty ||
          depIata.isEmpty ||
          arrIata.isEmpty) {
        log('[FlightPreBook] ERROR: Missing required flight data');
        log('[FlightPreBook] offerId=$offerId, provider=$provider, depIata=$depIata, arrIata=$arrIata');
        return null;
      }

      // Build query parameters
      final queryParams =
          'offer_id=$offerId&provider=$provider&adults=$adults&children=$children&infants=$infants';
      final url = '${ApiUrls.baseUrl}${ApiUrls.flightPreBook}?$queryParams';

      // Build request body with all flight details
      final requestBody = {
        'offer_id': offerId,
        'provider': provider,
        'dep_iata': depIata,
        'arr_iata': arrIata,
        'dep_time': depTime,
        'dep_date': depDate,
        'arr_time': arrTime,
        'arr_date': arrDate,
        'stops': selectedFlight.stops ?? 0,
        'price':
            double.tryParse(selectedFlight.totalPrice?.toString() ?? '0') ?? 0,
        'currency': selectedFlight.currency ?? 'GBP',
        'cabin_class': selectedFlight.cabinClass ?? 'ECONOMY',
        'trip_type': selectedFlight.isRoundTrip ? 'round_trip' : 'one_way',
        'adults': adults,
        'children': children,
        'infants': infants,
        'flight_number': flightDetail?.flightNumber ?? '',
        'airline_code': flightDetail?.airlineCode ?? '',
        'airline_name': selectedFlight.airlineName ?? '',
        'duration': selectedFlight.duration ?? '',
      };

      // Debug logs
      log('[FlightPreBook] ========== PREBOOK API CALL ==========');
      log('[FlightPreBook] Selected Flight ID: $offerId');
      log('[FlightPreBook] Selected Flight Provider: $provider');
      log('[FlightPreBook] Query Params: $queryParams');
      log('[FlightPreBook] Request Body: ${jsonEncode(requestBody)}');
      log('[FlightPreBook] Full URL: $url');
      log('[FlightPreBook] =====================================');

      // Make POST request with body
      final result = await makeRequest(
        url,
        'POST',
        requestBody,
        _token ?? '',
        requiresAuth: true,
      );

      log('[FlightPreBook] Raw Response: $result');

      if (result['success'] == true) {
        // Extract the actual API payload from inside the makeRequest wrapper
        final data = (result['data'] as Map<String, dynamic>?) ?? {};
        log('[FlightPreBook] ✅ PREBOOK SUCCESSFUL');
        log('[FlightPreBook] Data keys: ${data.keys.toList()}');
        log('[FlightPreBook] token = ${data["token"]}');
        log('[FlightPreBook] checkout_token = ${data["checkout_token"]}');
        log('[FlightPreBook] checkout_url = ${data["checkout_url"]}');
        log('[FlightPreBook] price = ${data["price"]}, currency = ${data["currency"]}');
        final response = FlightPreBookResponse.fromJson(data);
        return response;
      } else {
        log('[FlightPreBook] ❌ PREBOOK FAILED');
        log('[FlightPreBook] Message: ${result['message']}');
        log('[FlightPreBook] Errors: ${result['errors']}');
        return null;
      }
    } catch (e) {
      log('[FlightPreBook] ❌ EXCEPTION: $e');
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

  /// Map UI cabin class to API format
  /// Economy -> ECONOMY
  /// Premium Economy -> PREMIUM_ECONOMY
  /// Business -> BUSINESS
  /// First Class -> FIRST
  String _mapCabinClass(String uiCabin) {
    switch (uiCabin.toLowerCase()) {
      case 'economy':
        return 'ECONOMY';
      case 'premium economy':
        return 'PREMIUM_ECONOMY';
      case 'business':
        return 'BUSINESS';
      case 'first class':
        return 'FIRST';
      default:
        return 'ECONOMY';
    }
  }

  /// Convert new FlightSearchResponse to old FlightList format for backward compatibility
  FlightList _convertFlightSearchResponseToFlightList(
      FlightSearchResponse response) {
    final flightList = FlightList();
    flightList.data = <Flight>[];
    flightList.lastPage = response.lastPage;
    flightList.total = response.total;

    if (response.data != null && response.data!.isNotEmpty) {
      for (final searchItem in response.data!) {
        final flight = _convertFlightSearchItemToFlight(searchItem);
        flightList.data!.add(flight);
      }
    }

    log('[FlightProvider] Loading = false');
    log('[FlightProvider] Flight list updated = ${flightList.data?.length ?? 0} items');

    return flightList;
  }

  /// Convert individual FlightSearchItem to old Flight model
  Flight _convertFlightSearchItemToFlight(FlightSearchItem searchItem) {
    // Log all top-level flight fields
    log('[FlightModel] ====== PARSING FLIGHT ITEM ======');
    log('[FlightModel] id = ${searchItem.id}');
    log('[FlightModel] provider = ${searchItem.provider}');
    log('[FlightModel] origin = ${searchItem.origin}');
    log('[FlightModel] destination = ${searchItem.destination}');
    log('[FlightModel] departure_at = ${searchItem.departureAt}');
    log('[FlightModel] arrival_at = ${searchItem.arrivalAt}');
    log('[FlightModel] duration = ${searchItem.duration}');
    log('[FlightModel] stops = ${searchItem.stops}');
    log('[FlightModel] stops_label = ${searchItem.stopsLabel}');
    log('[FlightModel] is_next_day = ${searchItem.isNextDay}');
    log('[FlightModel] airline_name = ${searchItem.airlineName}');
    log('[FlightModel] airline_code = ${searchItem.airlineCode}');
    log('[FlightModel] airline_logo = ${searchItem.airlineLogo}');
    log('[FlightModel] flight_number = ${searchItem.flightNumber}');
    log('[FlightModel] total_amount = ${searchItem.totalAmount}');
    log('[FlightModel] currency = ${searchItem.currency}');
    log('[FlightModel] cabin_class = ${searchItem.cabinClass}');
    log('[FlightModel] badge = ${searchItem.badge}');
    log('[FlightModel] return_departure_at = ${searchItem.returnDepartureAt}');
    log('[FlightModel] return_arrival_at = ${searchItem.returnArrivalAt}');
    log('[FlightModel] return_duration = ${searchItem.returnDuration}');
    log('[FlightModel] return_stops = ${searchItem.returnStops}');
    log('[FlightModel] segments count = ${searchItem.segments?.length ?? 0}');
    log('[FlightModel] flight_details count = ${searchItem.flightDetails?.length ?? 0}');

    // Log segments details
    if (searchItem.segments != null && searchItem.segments!.isNotEmpty) {
      for (int i = 0; i < searchItem.segments!.length; i++) {
        final seg = searchItem.segments![i];
        log('[Segment $i] from=${seg.from} → to=${seg.to} | dep=${seg.depDatetime} | arr=${seg.arrDatetime}');
        log('[Segment $i]   flight=${seg.flightNumber} | airline=${seg.airlineCode} | baggage=${seg.baggage} | cabin=${seg.cabinClass}');
      }
    }

    // Log flight_details
    if (searchItem.flightDetails != null &&
        searchItem.flightDetails!.isNotEmpty) {
      for (int i = 0; i < searchItem.flightDetails!.length; i++) {
        final detail = searchItem.flightDetails![i];
        log('[FlightDetail $i] direction=${detail.direction}');
        log('[FlightDetail $i]   ${detail.depIata ?? detail.origin} ${detail.depTime ?? detail.departureAt} → ${detail.arrIata ?? detail.destination} ${detail.arrTime ?? detail.arrivalAt}');
        log('[FlightDetail $i]   airline=${detail.airlineName} (${detail.airlineCode}) | flight=${detail.flightNumber}');
        log('[FlightDetail $i]   duration=${detail.duration} | stops=${detail.stops} | is_next_day=${detail.isNextDay}');
        log('[FlightDetail $i]   segments count = ${detail.segments?.length ?? 0}');
      }
    }

    final flight = Flight(
      id: searchItem.id,
      totalPrice: searchItem.totalAmount?.toString(),
      currency: searchItem.currency,
      flightDetails: <FlightDetail>[],
      airlineName: searchItem.airlineName,
      airlineCode: searchItem.airlineCode,
      airlineLogo: searchItem.airlineLogo,
      stopsLabel: searchItem.stopsLabel ??
          (searchItem.stops == 0 ? 'Direct' : '${searchItem.stops} stop(s)'),
      badge: searchItem.badge,
      // Capture top-level API fields as fallback
      origin: searchItem.origin,
      destination: searchItem.destination,
      departureAt: searchItem.departureAt,
      arrivalAt: searchItem.arrivalAt,
      duration: searchItem.duration,
      stops: searchItem.stops,
      isNextDay: searchItem.isNextDay,
      // Round-trip fields
      returnDepartureAt: searchItem.returnDepartureAt,
      returnArrivalAt: searchItem.returnArrivalAt,
      returnDuration: searchItem.returnDuration,
      returnStops: searchItem.returnStops,
      // NEW: Transfer provider and flight details from API response
      provider: searchItem.provider,
      cabinClass: searchItem.cabinClass,
      flightNumber: searchItem.flightNumber,
    );

    // Parse top-level segments
    if (searchItem.segments != null) {
      flight.segments = <Segment>[];
      for (final seg in searchItem.segments!) {
        flight.segments!.add(Segment(
          from: seg.from,
          to: seg.to,
          depDatetime: seg.depDatetime,
          arrDatetime: seg.arrDatetime,
          flightNumber: seg.flightNumber,
          airlineCode: seg.airlineCode,
          airlineName: seg.airlineName,
          baggage: seg.baggage,
          cabinClass: seg.cabinClass,
        ));
      }
      log('[FlightModel] Parsed ${flight.segments!.length} top-level segments');
    }

    // Convert new flight details to old format
    if (searchItem.flightDetails != null) {
      for (final detail in searchItem.flightDetails!) {
        final convertedDetail = FlightDetail(
          direction: detail.direction ?? 'Departure',
          airlineName: detail.airlineName,
          airlineLogo: detail.airlineLogo,
          airlineCode: detail.airlineCode,
          flightNumber: detail.flightNumber,
          depIata: detail.depIata ??
              detail
                  .origin, // Use pre-formatted field first, fallback to origin
          depTime: detail.depTime ??
              _extractTime(detail.departureAt), // Use pre-formatted field first
          depDate: detail.depDate ??
              detail.departureAt, // Use pre-formatted field first
          arrIata: detail.arrIata ??
              detail
                  .destination, // Use pre-formatted field first, fallback to destination
          arrTime: detail.arrTime ??
              _extractTime(detail.arrivalAt), // Use pre-formatted field first
          arrDate: detail.arrDate ??
              detail.arrivalAt, // Use pre-formatted field first
          isNextDay: detail.isNextDay ?? false,
          duration: detail.duration,
          stops: detail.stops,
          segments: detail.segments != null
              ? detail.segments!.map((seg) {
                  return FlightSegment(
                    carrierCode: seg.airlineCode,
                    number: seg.flightNumber,
                    duration: null,
                    departure: SegmentLocation(
                      iataCode: seg.from,
                      at: seg.depDatetime,
                    ),
                    arrival: SegmentLocation(
                      iataCode: seg.to,
                      at: seg.arrDatetime,
                    ),
                  );
                }).toList()
              : null,
        );
        flight.flightDetails!.add(convertedDetail);
      }
      log('[FlightModel] Parsed ${flight.flightDetails!.length} flight details');
    }

    log('[FlightModel] ====== FLIGHT PARSING COMPLETE ======');
    return flight;
  }

  /// Extract time from datetime string (HH:mm format)
  String? _extractTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return null;
    try {
      final parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return null;
    }
  }
}
