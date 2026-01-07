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
import 'package:shared_preferences/shared_preferences.dart';

class FlightProvider with ChangeNotifier {
  String? _token;
  FlightDetailModal? _flightDetail;
  FlightDetailModal? flightDetail;
  FlightBookingResponse? bookingResponse;

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
    log("Flight List API Call for category index $index ===>");
    await loadToken();
    final Map<String, String> queryParams = {
      if (searchParams?['from_where'] != null)
        'from_where': searchParams!['from_where'].toString(),

      if (searchParams?['to_where'] != null)
        'to_where': searchParams!['to_where'].toString(),

      if (searchParams?['start'] != null)
        'start': DateFormat('yyyy-MM-dd')
            .format(searchParams!['start'] as DateTime),
      if (searchParams?['end'] != null)
        'end': DateFormat('yyyy-MM-dd')
            .format(searchParams!['end'] as DateTime),

      if (searchParams?['children'] != null)
        'children': searchParams!['children'].toString(),
      if (searchParams?['travelers'] != null)
        'travelers': searchParams!['travelers'].toString(),

      if (sortBy != null)
        'orderby': sortBy!,
    };

    // Convert searchParams to query parameters
    // final queryParams = {
    //   if (searchParams?['from_where'] != null)
    //     'from_where': searchParams!['from_where'],
    //   if (searchParams?['to_where'] != null)
    //     'to_where': searchParams!['to_where'],
    //   if (searchParams?['start'] != null)
    //     'start':
    //         DateFormat('MM/dd/yyyy').format(searchParams!['start'] as DateTime),
    //   if (searchParams?['travelers'] != null)
    //     'travelers': json.encode(searchParams!['travelers']),
    //   if (sortBy != null) 'orderby': sortBy,
    //   if (searchParams?['price_range'] != null)
    //     'price_range': searchParams?['price_range'],
    //   if (searchParams?['flight_types'] != null &&
    //       searchParams?['flight_types'] != '')
    //     'attrs[12]': searchParams?['flight_types'],
    //   if (searchParams?['facilities'] != null &&
    //       searchParams?['facilities'] != '')
    //     'attrs[13]': searchParams?['facilities'],
    // };

    final queryString = Uri(queryParameters: queryParams).query;
    String url = '${ApiUrls.baseUrl}${ApiUrls.flightSearch}?$queryString';
    log('################################### Hotels     $url checkurl');

    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Flight List Response for index $index ===> ${result['data']}");
      FlightList flightList = FlightList.fromJson(result['data']);
      flightListPerCategory[index] = flightList;
      notifyListeners();
      return flightList;
    } else {
      log("Failed to fetch flight list. Error: ${result['message']}");
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
