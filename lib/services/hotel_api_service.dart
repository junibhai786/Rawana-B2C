import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moonbnd/modals/hotel_search_model.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';

class HotelApiService {
  static const int timeoutSeconds = 30;

  /// Search hotels via POST request
  ///
  /// Parameters:
  /// - [city]: City name (e.g., "Dubai")
  /// - [checkIn]: Check-in date as DateTime
  /// - [checkOut]: Check-out date as DateTime
  /// - [adults]: Number of adults
  /// - [children]: Number of children
  /// - [rooms]: Number of rooms
  /// - [childAges]: List of child ages (REQUIRED if children > 0)
  /// - [token]: Authorization token
  ///
  /// Returns: List of HotelModel objects
  ///
  /// Handles:
  /// - Double-wrapped response (outer wrapper + inner API response)
  /// - Date formatting (yyyy-MM-dd format, NOT DateTime.toString())
  /// - Safe null handling for all fields
  /// - Child ages validation (length must match children count)
  static Future<List<HotelModel>> searchHotels({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    List<int>? childAges,
    required String token,
  }) async {
    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.hotelSearch}';

      // === VALIDATION: Check child_ages consistency ===
      if (children > 0 && (childAges == null || childAges.isEmpty)) {
        log('[HOTEL SEARCH] ❌ VALIDATION ERROR: children=$children but childAges is null/empty');
        throw Exception(
            'ERROR: Selected $children child(ren) but no ages provided. Please enter their ages.');
      }

      if (children > 0 && childAges != null && childAges.length != children) {
        log('[HOTEL SEARCH] ❌ VALIDATION ERROR: childAges.length=${childAges.length} != children=$children');
        throw Exception(
            'ERROR: Age list length (${childAges.length}) does not match children count ($children).');
      }

      // === FORMAT DATES ===
      final checkInString = DateFormat('yyyy-MM-dd').format(checkIn);
      final checkOutString = DateFormat('yyyy-MM-dd').format(checkOut);

      log('');
      log('[HOTEL SEARCH] Starting hotel search request');
      log('[HOTEL SEARCH] URL: $url');
      log('[HOTEL SEARCH] Input Parameters:');
      log('[HOTEL SEARCH]   City: $city');
      log('[HOTEL SEARCH]   Check-in: $checkInString');
      log('[HOTEL SEARCH]   Check-out: $checkOutString');
      log('[HOTEL SEARCH]   Adults: $adults');
      log('[HOTEL SEARCH]   Children: $children');
      log('[HOTEL SEARCH]   Child Ages: $childAges');
      log('[HOTEL SEARCH]   Rooms: $rooms');
      log('');

      // === BUILD JSON REQUEST BODY ===
      final body = {
        'city': city,
        'check_in': checkInString,
        'check_out': checkOutString,
        'adults': adults.toString(),
        'children': children.toString(),
        'rooms': rooms.toString(),
      };

      // ONLY ADD child_ages if children > 0
      if (children > 0 && childAges != null && childAges.isNotEmpty) {
        body['child_ages'] = childAges as String;
        log('[HOTEL SEARCH] ✓ Added child_ages to request: $childAges');
      }

      final bodyJson = jsonEncode(body);

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      log('');
      log('[HOTEL SEARCH REQUEST]');
      log('URL: $url');
      log('HEADERS: ${jsonEncode(headers)}');
      log('BODY: $bodyJson');
      log('');

      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: bodyJson,
      )
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw TimeoutException(
            'Hotel search request timed out after $timeoutSeconds seconds');
      });

      final responseBody = response.body;

      log('');
      log('[HOTEL SEARCH RESPONSE]');
      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: $responseBody');
      log('');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(responseBody) as Map<String, dynamic>;
        log('[HOTEL SEARCH] Parsed JSON response successfully');

        // === ISSUE 1: Handle double-wrapped response ===
        log('[HOTEL SEARCH] Checking response structure...');
        log('[HOTEL SEARCH] Top-level keys: ${raw.keys.toList()}');

        Map<String, dynamic> apiData;
        final inner = raw['data'];

        if (inner is Map<String, dynamic>) {
          log('[HOTEL SEARCH] Inner data is Map');
          log('[HOTEL SEARCH] Inner keys: ${inner.keys.toList()}');

          // Check if inner has 'data' and 'success' (double wrapped)
          if (inner.containsKey('data') && inner.containsKey('success')) {
            log('[HOTEL SEARCH] ✓ Double-wrapped response detected — unwrapping');
            apiData = Map<String, dynamic>.from(inner); // Unwrap one level
          } else {
            log('[HOTEL SEARCH] Single-wrapped response');
            apiData = raw;
          }
        } else {
          log('[HOTEL SEARCH] Using raw response (inner is not Map)');
          apiData = raw;
        }

        log('[HOTEL SEARCH] API success: ${apiData['success']}');
        log('[HOTEL SEARCH] Hotel count: ${apiData['count']}');

        if (apiData['success'] == true) {
          final hotelList = apiData['data'] ?? [];
          log('[HOTEL SEARCH] ✓ API returned success');
          log('[HOTEL SEARCH] Hotel list length: ${hotelList.length}');

          if (hotelList is! List) {
            log('[HOTEL SEARCH] ✗ ERROR: "data" is not a List, got ${hotelList.runtimeType}');
            throw Exception('Invalid response: "data" field is not a list');
          }

          final hotels = hotelList
              .whereType<Map<String, dynamic>>()
              .map((h) => HotelModel.fromJson(h))
              .toList();

          log('[HOTEL SEARCH] ✓ Successfully parsed ${hotels.length} hotels');
          return hotels;
        } else {
          final message = apiData['message'] ?? 'Unknown error';
          log('[HOTEL SEARCH] ✗ API returned false: $message');
          throw Exception('API error: $message');
        }
      } else {
        log('[HOTEL SEARCH] ✗ HTTP Error: ${response.statusCode}');
        log('[HOTEL SEARCH] Response: $responseBody');
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      log('[HOTEL SEARCH] ✗ EXCEPTION: $e');
      log('[HOTEL SEARCH] Stack: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Fetch hotel details by ID and provider
  ///
  /// Parameters:
  /// - [hotelId]: Hotel ID (local db ID or external provider ID)
  /// - [provider]: Provider name (e.g. "local", "rawana_b2b"). Required for disambiguation.
  /// - [token]: Authorization token
  ///
  /// Returns: Raw Map<String, dynamic> of hotel detail data
  static Future<Map<String, dynamic>> fetchHotelDetail({
    required String hotelId,
    String? provider,
    String? currency,
    required String token,
  }) async {
    try {
      final url = ApiUrls.hotelDetailUrl(hotelId,
          provider: provider, currency: currency);

      print('[HotelApiService] GET Hotel Detail');
      print('[HotelApiService] URL: $url');
      print('[HotelApiService] Provider: ${provider ?? "not specified"}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw TimeoutException(
            'Hotel detail request timed out after $timeoutSeconds seconds');
      });

      print('[HotelApiService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;

        // Handle double-wrapped response
        Map<String, dynamic> apiData;
        final inner = raw['data'];
        if (inner is Map<String, dynamic> &&
            inner.containsKey('data') &&
            inner.containsKey('success')) {
          apiData = Map<String, dynamic>.from(inner);
        } else {
          apiData = raw;
        }

        if (apiData['success'] == true || apiData['data'] != null) {
          return apiData;
        } else {
          final message = apiData['message'] ?? 'Hotel not found';
          throw Exception('API error: $message');
        }
      } else if (response.statusCode == 400) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw HotelDetailException(
          statusCode: 400,
          message: body['message']?.toString() ??
              'Bad request: provider parameter may be required',
        );
      } else if (response.statusCode == 404) {
        throw HotelDetailException(
          statusCode: 404,
          message: 'Hotel not found',
        );
      } else if (response.statusCode == 422) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw HotelDetailException(
          statusCode: 422,
          message: body['message']?.toString() ?? 'Invalid parameters',
        );
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('[HotelApiService] ✗ Hotel Detail EXCEPTION: $e');
      rethrow;
    }
  }

  /// Fetch hotel rooms with detailed availability and pricing
  ///
  /// Parameters:
  /// - [offerId]: Offer ID from search response
  /// - [cityCode]: City code
  /// - [checkIn]: Check-in date (yyyy-MM-dd format)
  /// - [checkOut]: Check-out date (yyyy-MM-dd format)
  /// - [adults]: Number of adults
  /// - [currency]: Currency code (e.g., "USD", "EUR")
  /// - [provider]: Hotel provider
  /// - [token]: Authorization token
  ///
  /// Returns: Response map with rooms data
  static Future<Map<String, dynamic>> fetchHotelRooms({
    required String offerId,
    required String cityCode,
    required String checkIn,
    required String checkOut,
    required int adults,
    required String currency,
    required String provider,
    required String token,
  }) async {
    try {
      final url = '${ApiUrls.baseUrl}hotels/rooms';

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        'offer_id': offerId,
        'city_code': cityCode,
        'check_in': checkIn,
        'check_out': checkOut,
        'adults': adults,
        'currency': currency,
        'provider': provider,
      };

      final bodyJson = jsonEncode(body);

      log('[HOTEL_ROOMS] Fetching rooms details');
      log('[HOTEL_ROOMS] URL: $url');
      log('[HOTEL_ROOMS] Request Body: $bodyJson');

      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: bodyJson,
      )
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw TimeoutException(
            'Hotel rooms request timed out after $timeoutSeconds seconds');
      });

      log('[HOTEL_ROOMS] Response Status: ${response.statusCode}');
      log('[HOTEL_ROOMS] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;

        // Handle potential double-wrapped response
        Map<String, dynamic> apiData;
        final inner = raw['data'];
        if (inner is Map<String, dynamic> &&
            inner.containsKey('data') &&
            inner.containsKey('success')) {
          log('[HOTEL_ROOMS] Double-wrapped response detected');
          apiData = Map<String, dynamic>.from(inner);
        } else {
          apiData = raw;
        }

        if (apiData['success'] == true || apiData['data'] != null) {
          log('[HOTEL_ROOMS] ✓ Successfully fetched rooms');
          return apiData;
        } else {
          final message = apiData['message'] ?? 'Failed to fetch rooms';
          throw Exception('API error: $message');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      log('[HOTEL_ROOMS] ✗ Error fetching rooms: $e');
      rethrow;
    }
  }
}

class HotelDetailException implements Exception {
  final int statusCode;
  final String message;
  HotelDetailException({required this.statusCode, required this.message});

  @override
  String toString() => 'HotelDetailException($statusCode): $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
