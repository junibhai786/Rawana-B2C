import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:moonbnd/Provider/api_interface.dart'; // setToken()
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/hotel_checkout_request_model.dart';
import 'package:moonbnd/modals/hotel_checkout_response_model.dart';
import 'package:moonbnd/modals/hotel_booking_confirmation_model.dart';

class HotelCheckoutProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  HotelCheckoutResponse? _checkoutResponse;

  bool _isFetchingOrder = false;
  String? _orderError;
  HotelBookingConfirmationData? _orderData;

  bool get isFetchingOrder => _isFetchingOrder;
  String? get orderError => _orderError;
  HotelBookingConfirmationData? get orderData => _orderData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  HotelCheckoutResponse? get checkoutResponse => _checkoutResponse;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Submits hotel checkout. Returns `true` on success, `false` on failure.
  Future<bool> checkoutHotel({
    required String checkoutToken,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String paymentGateway,
  }) async {
    _isLoading = true;
    _error = null;
    _checkoutResponse = null;
    notifyListeners();

    try {
      // ── 1. Token guard ────────────────────────────────────────────────────
      final token = await setToken();

      log('');
      log('[CHECKOUT AUTH TOKEN DEBUG]');
      log('TOKEN SOURCE : SharedPreferences');
      log('TOKEN KEY    : userToken');
      log('TOKEN VALUE  : $token');
      log('TOKEN IS NULL: ${token.isEmpty}');
      log('TOKEN LENGTH : ${token.length}');

      if (token.isEmpty) {
        _error = 'User not authenticated. Please log in again.';
        log('[HOTEL CHECKOUT ERROR] ERROR: token is null or empty');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ── 2. Build request ──────────────────────────────────────────────────
      final url = '${ApiUrls.baseUrl}${ApiUrls.hotelCheckoutEndpoint}';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': Get.locale?.languageCode == 'en' ? 'en' : 'ar',
        'ngrok-skip-browser-warning': 'true',
      };

      final bodyJson = HotelCheckoutRequest(
        checkoutToken: checkoutToken,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        paymentGateway: paymentGateway,
      ).toJsonString();

      // ── 3. Log request ────────────────────────────────────────────────────
      log('');
      log('[HOTEL CHECKOUT REQUEST]');
      log('URL: $url');
      log('AUTH TOKEN: $token');
      log('HEADERS: ${json.encode(headers)}');
      log('TOKEN USED IN CHECKOUT REQUEST: $checkoutToken');
      log('BODY: $bodyJson');

      // ── 4. Execute ────────────────────────────────────────────────────────
      final response = await http
          .post(Uri.parse(url), headers: headers, body: bodyJson)
          .timeout(const Duration(seconds: 60));

      final rawBody = response.body;
      final statusCode = response.statusCode;

      // ── 5. Log response ───────────────────────────────────────────────────
      log('');
      log('[HOTEL CHECKOUT RESPONSE]');
      log('STATUS CODE: $statusCode');
      log('BODY: $rawBody');

      // ── 6. Handle non-success status codes ────────────────────────────────
      if (statusCode == 302) {
        _error = 'Unexpected redirect (302). Check ngrok or server config.';
        log('[HOTEL CHECKOUT ERROR] ERROR: 302 redirect — raw body: $rawBody');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (statusCode != 200 && statusCode != 201) {
        String errorMsg = 'Server error ($statusCode)';
        try {
          final errData = json.decode(rawBody);
          if (errData is Map && errData['message'] != null) {
            errorMsg = errData['message'].toString();
          }
        } catch (_) {}
        _error = errorMsg;
        log('');
        log('[HOTEL CHECKOUT ERROR]');
        log('ERROR: $errorMsg');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ── 7. Guard against HTML response ────────────────────────────────────
      if (rawBody.trimLeft().startsWith('<')) {
        _error = 'Server returned HTML instead of JSON.';
        log('[HOTEL CHECKOUT ERROR] ERROR: HTML response — check endpoint/auth');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ── 8. Parse JSON ─────────────────────────────────────────────────────
      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(rawBody) as Map<String, dynamic>;
      } catch (e) {
        _error = 'Invalid response format from server.';
        log('[HOTEL CHECKOUT ERROR] ERROR: JSON parse failed — $e');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _checkoutResponse = HotelCheckoutResponse.fromJson(responseJson);

      if (_checkoutResponse!.success) {
        // Log the exact 'url' field from Stripe response
        final stripeUrl = responseJson['url']?.toString();
        log('');
        log('[HOTEL CHECKOUT SUCCESS]');
        log('SUCCESS: ${_checkoutResponse!.success}');
        log('STRIPE URL: $stripeUrl');
        log('PARSED paymentUrl: ${_checkoutResponse!.paymentUrl}');
        // TODO: Navigate to WebView / launch URL when ready
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            _checkoutResponse!.message ?? 'Checkout failed. Please try again.';
        log('[HOTEL CHECKOUT ERROR] ERROR: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      log('');
      log('[HOTEL CHECKOUT ERROR]');
      log('ERROR: $e');
      log('STACKTRACE: $st');
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// GETs booking details from GET /api/hotels/order/{orderId} after
  /// Stripe payment succeeds. Returns true if data is available.
  Future<bool> fetchHotelOrderDetails(String orderId) async {
    _isFetchingOrder = true;
    _orderError = null;
    _orderData = null;
    notifyListeners();

    try {
      final token = await setToken();
      final url = '${ApiUrls.baseUrl}${ApiUrls.hotelOrderDetails}$orderId';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': Get.locale?.languageCode == 'en' ? 'en' : 'ar',
        'ngrok-skip-browser-warning': 'true',
      };

      log('');
      log('[BOOKING DETAILS API REQUEST]');
      log('URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      final rawBody = response.body;
      final statusCode = response.statusCode;

      log('');
      log('[BOOKING DETAILS API RESPONSE]');
      log('STATUS CODE: $statusCode');
      log('BODY: $rawBody');

      if (statusCode != 200 && statusCode != 201) {
        String errMsg = 'Failed to fetch order details ($statusCode)';
        try {
          final errData = json.decode(rawBody);
          if (errData is Map && errData['message'] != null) {
            errMsg = errData['message'].toString();
          }
        } catch (_) {}
        _orderError = errMsg;
        log('');
        log('[BOOKING FLOW ERROR]');
        log('ERROR: $errMsg');
        log('STACKTRACE: status $statusCode');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      if (rawBody.trimLeft().startsWith('<')) {
        _orderError = 'Server returned HTML instead of JSON.';
        log('');
        log('[BOOKING FLOW ERROR]');
        log('ERROR: HTML response — check endpoint/auth');
        log('STACKTRACE: HTML response');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(rawBody) as Map<String, dynamic>;
      } catch (e, st) {
        _orderError = 'Invalid response format.';
        log('');
        log('[BOOKING FLOW ERROR]');
        log('ERROR: JSON parse failed — $e');
        log('STACKTRACE: $st');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      if (responseJson['success'] != true) {
        _orderError =
            responseJson['message']?.toString() ?? 'Order fetch failed.';
        log('');
        log('[BOOKING FLOW ERROR]');
        log('ERROR: $_orderError');
        log('STACKTRACE: success=false in response');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      final dataJson = responseJson['data'];
      if (dataJson is Map<String, dynamic>) {
        _orderData = HotelBookingConfirmationData.fromJson(dataJson);
      }

      log('');
      log('[BOOKING DETAILS PARSED]');
      log('ORDER ID: ${_orderData?.orderId}');
      log('HOTEL   : ${_orderData?.hotelName}');
      log('STATUS  : ${_orderData?.status}');

      _isFetchingOrder = false;
      notifyListeners();
      return _orderData != null;
    } catch (e, st) {
      log('');
      log('[BOOKING FLOW ERROR]');
      log('ERROR: $e');
      log('STACKTRACE: $st');
      _orderError = 'An unexpected error occurred.';
      _isFetchingOrder = false;
      notifyListeners();
      return false;
    }
  }

  /// Terminal payment statuses — once reached, no further polling is needed.
  static const _terminalStatuses = {'paid', 'confirmed', 'completed'};

  /// Returns `true` if the given status string is a terminal paid/confirmed status.
  bool isTerminalStatus(String? status) {
    if (status == null) return false;
    return _terminalStatuses.contains(status.toLowerCase());
  }

  /// Polls GET /api/hotels/order/{bookingCode} up to [maxAttempts] times,
  /// waiting [interval] between each call. Returns `true` as soon as the
  /// order status reaches a terminal state (paid/confirmed/completed).
  ///
  /// On success, [orderData] will be populated and ready for the
  /// confirmation screen.
  Future<bool> pollForConfirmedStatus(
    String bookingCode, {
    int maxAttempts = 10,
    Duration interval = const Duration(seconds: 2),
  }) async {
    _isFetchingOrder = true;
    _orderError = null;
    notifyListeners();

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      log('');
      log('[PAYMENT POLL] attempt $attempt/$maxAttempts for $bookingCode');

      final fetched = await fetchHotelOrderDetails(bookingCode);

      if (fetched && _orderData != null) {
        final status = _orderData!.status?.toLowerCase();
        log('[PAYMENT POLL] status: $status');

        if (status != null && _terminalStatuses.contains(status)) {
          _isFetchingOrder = false;
          notifyListeners();
          return true;
        }
      }

      if (attempt < maxAttempts) {
        await Future.delayed(interval);
      }
    }

    // Exhausted all attempts — still pending
    _orderError =
        'Payment is still processing. Please check your bookings shortly.';
    _isFetchingOrder = false;
    notifyListeners();
    return false;
  }
}
