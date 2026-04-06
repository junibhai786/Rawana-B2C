import 'dart:convert';
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
  /// - [token]: Authorization token
  ///
  /// Returns: List of HotelModel objects
  ///
  /// Handles:
  /// - Double-wrapped response (outer wrapper + inner API response)
  /// - Date formatting (yyyy-MM-dd format, NOT DateTime.toString())
  /// - Safe null handling for all fields
  static Future<List<HotelModel>> searchHotels({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    required String token,
  }) async {
    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.hotelSearch}';

      // === ISSUE 3: Format dates correctly (yyyy-MM-dd, not DateTime.toString()) ===
      final checkInString = DateFormat('yyyy-MM-dd').format(checkIn);
      final checkOutString = DateFormat('yyyy-MM-dd').format(checkOut);

      print('[HotelApiService] POST REQUEST');
      print('[HotelApiService] URL: $url');
      print('[HotelApiService] City: $city');
      print('[HotelApiService] Check-in: $checkInString');
      print('[HotelApiService] Check-out: $checkOutString');
      print(
          '[HotelApiService] Adults: $adults, Children: $children, Rooms: $rooms');

      final body = {
        'city': city,
        'check_in': checkInString,
        'check_out': checkOutString,
        'adults': adults.toString(),
        'children': children.toString(),
        'rooms': rooms.toString(),
      };

      print('[HotelApiService] Request body: $body');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('[HotelApiService] Headers: ${headers.keys.toList()}');

      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw TimeoutException(
            'Hotel search request timed out after $timeoutSeconds seconds');
      });

      print('[HotelApiService] Response status code: ${response.statusCode}');
      print('[HotelApiService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;
        print('[HotelApiService] Parsed raw response');

        // === ISSUE 1: Handle double-wrapped response ===
        print('[HotelApiService] Checking response structure...');
        print('[HotelApiService] Raw keys: ${raw.keys.toList()}');

        Map<String, dynamic> apiData;
        final inner = raw['data'];

        if (inner is Map<String, dynamic>) {
          print('[HotelApiService] Inner data is Map');
          print('[HotelApiService] Inner keys: ${inner.keys.toList()}');

          // Check if inner has 'data' and 'success' (double wrapped)
          if (inner.containsKey('data') && inner.containsKey('success')) {
            print(
                '[HotelApiService] ✓ Double-wrapped response detected — unwrapping');
            apiData = Map<String, dynamic>.from(inner); // Unwrap one level
          } else {
            print('[HotelApiService] Single-wrapped response');
            apiData = raw;
          }
        } else {
          print('[HotelApiService] Using raw response (inner is not Map)');
          apiData = raw;
        }

        print('[HotelApiService] API data success: ${apiData['success']}');
        print('[HotelApiService] API data count: ${apiData['count']}');

        if (apiData['success'] == true) {
          final hotelList = apiData['data'] ?? [];
          print('[HotelApiService] ✓ API returned success');
          print('[HotelApiService] Hotel list length: ${hotelList.length}');

          if (hotelList is! List) {
            print(
                '[HotelApiService] ✗ ERROR: "data" is not a List, got ${hotelList.runtimeType}');
            throw Exception('Invalid response: "data" field is not a list');
          }

          final hotels = hotelList
              .whereType<Map<String, dynamic>>()
              .map((h) => HotelModel.fromJson(h))
              .toList();

          print(
              '[HotelApiService] ✓ Parsed ${hotels.length} hotels successfully');
          return hotels;
        } else {
          final message = apiData['message'] ?? 'Unknown error';
          print('[HotelApiService] ✗ API returned false: $message');
          throw Exception('API error: $message');
        }
      } else {
        print('[HotelApiService] ✗ HTTP Error: ${response.statusCode}');
        print('[HotelApiService] Response: ${response.body}');
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('[HotelApiService] ✗ EXCEPTION: $e');
      print('[HotelApiService] Stack: $e');
      rethrow;
    }
  }

  /// Fetch hotel details by ID and provider
  ///
  /// Parameters:
  /// - [hotelId]: Hotel ID (local db ID or external provider ID)
  /// - [provider]: Provider name (e.g. "local", "travolyo_b2b"). Required for disambiguation.
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
