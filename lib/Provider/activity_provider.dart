// lib/Provider/activity_provider.dart

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/activity_model.dart';
import 'package:moonbnd/modals/activity_order_model.dart';
import 'package:moonbnd/modals/activity_prebook_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/services/session_manager.dart';

class ActivityProvider with ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  int _totalCount = 0;
  String? _error;
  String? _token;

  // ── Activity checkout state ────────────────────────────────────────────────
  bool _isCheckingOut = false;
  String? _checkoutError;
  String? _checkoutStripeUrl;
  String? _checkoutBookingCode;
  bool _isSessionExpired = false;

  // ── Activity order state ───────────────────────────────────────────────────
  bool _isFetchingOrder = false;
  String? _orderError;
  ActivityOrderData? _orderData;

  List<ActivityModel> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  int get totalCount => _totalCount;
  String? get error => _error;

  bool get isCheckingOut => _isCheckingOut;
  String? get checkoutError => _checkoutError;
  String? get checkoutStripeUrl => _checkoutStripeUrl;
  String? get checkoutBookingCode => _checkoutBookingCode;
  bool get isSessionExpired => _isSessionExpired;

  bool get isFetchingOrder => _isFetchingOrder;
  String? get orderError => _orderError;
  ActivityOrderData? get orderData => _orderData;

  ActivityProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
  }

  Future<bool> searchActivities(
      {required String destination, String? currency}) async {
    log('[ActivityProvider] ═══════════════════════════════════════════');
    log('[ActivityProvider] 🔍 Searching activities');
    log('[ActivityProvider] Destination parameter: "$destination"');
    log('[ActivityProvider] Currency parameter: "${currency ?? 'not specified'}"');
    log('[ActivityProvider] ═══════════════════════════════════════════');

    if (_token == null) {
      await _loadToken();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final url =
        '${ApiUrls.baseUrl}${ApiUrls.activitiesSearch}?destination=${Uri.encodeComponent(destination)}${currency != null ? '&currency=${Uri.encodeComponent(currency)}' : ''}';
    log('[ActivityProvider] 📡 Full URL: $url');

    try {
      final result = await makeRequest(
        url,
        'POST',
        {},
        _token ?? '',
        requiresAuth: true,
      );

      log('[ActivityProvider] Response success: ${result['success']}');

      if (result['success'] == true) {
        final rawData = result['data'];
        // ── DEBUG: raw API response shape ──────────────────────────────
        print(
            '════ [ActivityProvider] RAW result[data] type: ${rawData.runtimeType}');
        print('[ActivityProvider] RAW result[data]: $rawData');
        // ───────────────────────────────────────────────────────────────
        final response =
            ActivitySearchResponse.fromJson(rawData as Map<String, dynamic>);
        _activities = response.data;
        _totalCount = response.count;
        _error = null;
        // ── DEBUG: parsed activities ────────────────────────────────────
        print('[ActivityProvider] Parsed count: ${_activities.length}');
        for (final a in _activities) {
          print(
            '[ActivityProvider] Activity: title="${a.title}" '
            'category="${a.category}" '
            'price=${a.pricePerPerson} '
            'instant=${a.instantConfirmation}',
          );
        }
        // ───────────────────────────────────────────────────────────────
        log('[ActivityProvider] Loaded ${_activities.length} activities');
        log('[ActivityProvider] ✅ Search successful - Found ${_activities.length} activities');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message']?.toString() ?? 'Failed to load activities';
        log('[ActivityProvider] Error: $_error');
        _activities = [];
        _totalCount = 0;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      log('[ActivityProvider] Exception: $e');
      log('[ActivityProvider] StackTrace: $stackTrace');
      _error = 'An error occurred while fetching activities';
      _activities = [];
      _totalCount = 0;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Prebook activity API call
  /// Called when user taps "View Deal" on an activity card
  Future<ActivityPreBookResponse?> preBookActivity({
    required ActivityModel activity,
    required String selectedDate,
    required int participants,
  }) async {
    await _loadToken();

    try {
      log('[ActivityPreBook] ========== PREBOOK API CALL ==========');
      log('[ActivityPreBook] Activity ID: ${activity.id}');
      log('[ActivityPreBook] Activity Title: ${activity.title}');
      log('[ActivityPreBook] Provider: ${activity.provider}');
      log('[ActivityPreBook] Selected Date: $selectedDate');
      log('[ActivityPreBook] Participants: $participants');
      log('[ActivityPreBook] ====================================');

      // Build request body matching the API spec
      final requestBody = {
        'offer_id': activity.id,
        'provider': activity.provider,
        'activity_date': selectedDate,
        'participants': participants,
        'currency': activity.currency ?? 'AED',
        'activity_title': activity.title,
        'city': activity.city ?? '',
        'country': activity.country ?? '',
        'category': activity.category ?? '',
        'duration': activity.duration ?? '',
      };

      log('[ActivityPreBook] Request Body: ${jsonEncode(requestBody)}');

      final url = '${ApiUrls.baseUrl}${ApiUrls.activitiesPrebook}';
      log('[ActivityPreBook] URL: $url');

      final result = await makeRequest(
        url,
        'POST',
        requestBody,
        _token ?? '',
        requiresAuth: true,
      );

      log('[ActivityPreBook] Raw Response: $result');

      if (result['success'] == true) {
        final data = (result['data'] as Map<String, dynamic>?) ?? {};
        log('[ActivityPreBook] ✅ PREBOOK SUCCESSFUL');
        log('[ActivityPreBook] Data keys: ${data.keys.toList()}');
        log('[ActivityPreBook] checkout_token = ${data["checkout_token"]}');
        log('[ActivityPreBook] checkout_url = ${data["checkout_url"]}');
        log('[ActivityPreBook] total_price = ${data["total_price"]}, currency = ${data["currency"]}');

        final response = ActivityPreBookResponse.fromJson(data);
        return response;
      } else {
        log('[ActivityPreBook] ❌ PREBOOK FAILED');
        log('[ActivityPreBook] Message: ${result['message']}');
        log('[ActivityPreBook] Errors: ${result['errors']}');
        return null;
      }
    } catch (e) {
      log('[ActivityPreBook] ❌ EXCEPTION: $e');
      return null;
    }
  }

  void clearResults() {
    _activities = [];
    _error = null;
    notifyListeners();
  }

  // ── Activity checkout ──────────────────────────────────────────────────────

  /// Maps UI gender string to API single-char code.
  String _mapGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return 'F';
      case 'other':
        return 'O';
      case 'male':
      default:
        return 'M';
    }
  }

  /// Converts mm/dd/yyyy → yyyy-MM-dd.
  /// Returns input unchanged if it already contains '-' (already formatted).
  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    if (raw.contains('-')) return raw;
    try {
      final parts = raw.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
      }
    } catch (_) {}
    return raw;
  }

  /// Submits activity checkout. Returns `true` on success, `false` on failure.
  /// On success, [checkoutStripeUrl] and [checkoutBookingCode] are populated.
  Future<bool> activityCheckout({
    required String checkoutToken,
    required String contactEmail,
    required String contactPhone,
    required String paymentGateway,
    required String firstName,
    required String lastName,
    required String dob,
    required String nationality,
    required String gender,
    required String passport,
    required String passportExpiry,
    String specialRequests = '',
  }) async {
    _isCheckingOut = true;
    _checkoutError = null;
    _isSessionExpired = false;
    _checkoutStripeUrl = null;
    _checkoutBookingCode = null;
    notifyListeners();

    try {
      // ── 1. Auth token ────────────────────────────────────────────────────
      final token = await setToken();

      log('');
      log('[ActivityCheckout] ========== CHECKOUT API CALL ==========');
      log('[ActivityCheckout] AUTH TOKEN     : ${token.isNotEmpty ? "present (${token.length} chars)" : "MISSING"}');

      if (token.isEmpty) {
        _isSessionExpired = true;
        _checkoutError = 'session_expired';
        log('[ActivityCheckout] ERROR: auth token is empty — session expired');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      // ── 2. Build URL ─────────────────────────────────────────────────────
      final url = '${ApiUrls.baseUrl}${ApiUrls.activitiesCheckout}';

      // ── 3. Build body ────────────────────────────────────────────────────
      final bodyMap = {
        'checkout_token': checkoutToken,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'payment_gateway': paymentGateway,
        'passengers': [
          {
            'first_name': firstName,
            'last_name': lastName,
            'dob': _formatDate(dob),
            'nationality': nationality,
            'gender': _mapGender(gender),
            'passport': passport,
            'passport_expiry': _formatDate(passportExpiry),
          }
        ],
        'special_requests': specialRequests,
      };
      final bodyJson = jsonEncode(bodyMap);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': Get.locale?.languageCode == 'en' ? 'en' : 'ar',
        'ngrok-skip-browser-warning': 'true',
      };

      // ── 4. Debug log request ─────────────────────────────────────────────
      log('[ActivityCheckout] URL    : $url');
      log('[ActivityCheckout] BODY   : $bodyJson');

      // ── 5. Execute ───────────────────────────────────────────────────────
      final response = await http
          .post(Uri.parse(url), headers: headers, body: bodyJson)
          .timeout(const Duration(seconds: 60));

      final statusCode = response.statusCode;
      final rawBody = response.body;

      // ── 6. Debug log response ────────────────────────────────────────────
      log('[ActivityCheckout] STATUS : $statusCode');
      log('[ActivityCheckout] RESPONSE: $rawBody');

      // ── 7. Handle non-2xx ────────────────────────────────────────────────
      if (statusCode == 302) {
        _checkoutError =
            'Unexpected redirect (302). Check ngrok or server config.';
        log('[ActivityCheckout] ERROR: 302 redirect');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      if (statusCode != 200 && statusCode != 201) {
        String errorMsg = 'Server error ($statusCode)';
        try {
          final errData = jsonDecode(rawBody);
          if (errData is Map && errData['message'] != null) {
            errorMsg = errData['message'].toString();
          }
        } catch (_) {}

        // ── Detect 401 Unauthorized / Session Expired ──────────────────────
        if (SessionManager.isUnauthorized(
            statusCode: statusCode, message: errorMsg)) {
          _isSessionExpired = true;
          _checkoutError = 'session_expired';
          log('[ActivityCheckout] ❌ 401 Unauthorized — session expired');
          _isCheckingOut = false;
          notifyListeners();
          return false;
        }

        _checkoutError = errorMsg;
        log('[ActivityCheckout] ERROR: $errorMsg');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      // ── 8. Guard HTML response ───────────────────────────────────────────
      if (rawBody.trimLeft().startsWith('<')) {
        _checkoutError = 'Server returned HTML instead of JSON.';
        log('[ActivityCheckout] ERROR: HTML response');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      // ── 9. Parse JSON ────────────────────────────────────────────────────
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(rawBody) as Map<String, dynamic>;
      } catch (e) {
        _checkoutError = 'Invalid response format from server.';
        log('[ActivityCheckout] ERROR: JSON parse failed — $e');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      log('[ActivityCheckout] decoded keys: ${decoded.keys.toList()}');
      log('[ActivityCheckout] success=${decoded['success']}  url=${decoded['url']}  booking_code=${decoded['booking_code']}');

      // ── 10. Evaluate API success flag ────────────────────────────────────
      if (decoded['success'] == true) {
        _checkoutStripeUrl =
            (decoded['url'] ?? decoded['payment_url'] ?? '').toString();
        _checkoutBookingCode = decoded['booking_code']?.toString();
        log('[ActivityCheckout] ✅ SUCCESS — stripeUrl="$_checkoutStripeUrl"  bookingCode="$_checkoutBookingCode"');
        _isCheckingOut = false;
        notifyListeners();
        return true;
      } else {
        _checkoutError =
            (decoded['message'] ?? 'Checkout failed. Please try again.')
                .toString();
        log('[ActivityCheckout] ERROR: $_checkoutError');
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      log('[ActivityCheckout] EXCEPTION: $e');
      log('[ActivityCheckout] STACKTRACE: $st');
      _checkoutError = 'An unexpected error occurred. Please try again.';
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  // ── Activity order details ─────────────────────────────────────────────────

  /// Fetches GET /api/activities/order/{bookingCode}.
  /// Returns `true` on success and populates [orderData].
  Future<bool> fetchActivityOrderDetails(String bookingCode) async {
    _isFetchingOrder = true;
    _orderError = null;
    _orderData = null;
    notifyListeners();

    try {
      final token = await setToken();
      final url =
          '${ApiUrls.baseUrl}${ApiUrls.activitiesOrderDetails}$bookingCode';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': Get.locale?.languageCode == 'en' ? 'en' : 'ar',
        'ngrok-skip-browser-warning': 'true',
      };

      log('');
      log('[ACTIVITY ORDER API REQUEST] URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      final rawBody = response.body;
      final statusCode = response.statusCode;

      log('');
      log('[ACTIVITY ORDER API RESPONSE] STATUS CODE: $statusCode');
      log('[ACTIVITY ORDER API RESPONSE] BODY: $rawBody');

      if (statusCode != 200 && statusCode != 201) {
        String errMsg = 'Failed to fetch order details ($statusCode)';
        try {
          final errData = json.decode(rawBody);
          if (errData is Map && errData['message'] != null) {
            errMsg = errData['message'].toString();
          }
        } catch (_) {}
        _orderError = errMsg;
        log('[ACTIVITY ORDER ERROR] $errMsg');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      if (rawBody.trimLeft().startsWith('<')) {
        _orderError = 'Server returned HTML instead of JSON.';
        log('[ACTIVITY ORDER ERROR] HTML response — check endpoint/auth');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(rawBody) as Map<String, dynamic>;
      } catch (e, st) {
        _orderError = 'Invalid response format.';
        log('[ACTIVITY ORDER ERROR] JSON parse failed — $e');
        log('[ACTIVITY ORDER ERROR] STACKTRACE: $st');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      if (responseJson['success'] != true) {
        _orderError =
            responseJson['message']?.toString() ?? 'Order fetch failed.';
        log('[ACTIVITY ORDER ERROR] success=false — $_orderError');
        _isFetchingOrder = false;
        notifyListeners();
        return false;
      }

      final dataJson = responseJson['data'];
      if (dataJson is Map<String, dynamic>) {
        _orderData = ActivityOrderData.fromJson(dataJson);
      }

      log('');
      log('[ACTIVITY ORDER PARSED] ORDER ID: ${_orderData?.orderId}');
      log('[ACTIVITY ORDER PARSED] STATUS  : ${_orderData?.status}');
      log('[ACTIVITY ORDER PARSED] ACTIVITY: ${_orderData?.activityTitle}');

      _isFetchingOrder = false;
      notifyListeners();
      return _orderData != null;
    } catch (e, st) {
      log('[ACTIVITY ORDER ERROR] EXCEPTION: $e');
      log('[ACTIVITY ORDER ERROR] STACKTRACE: $st');
      _orderError = 'An unexpected error occurred.';
      _isFetchingOrder = false;
      notifyListeners();
      return false;
    }
  }

  /// Terminal statuses for activity orders.
  static const _activityTerminalStatuses = {'paid', 'confirmed', 'completed'};

  bool isActivityOrderTerminal(String? status) {
    if (status == null) return false;
    return _activityTerminalStatuses.contains(status.toLowerCase());
  }

  /// Polls GET /api/activities/order/{bookingCode} up to [maxAttempts] times,
  /// waiting [interval] between each attempt. Returns `true` as soon as the
  /// order status reaches a terminal state (paid/confirmed/completed).
  ///
  /// On success, [orderData] is populated and ready for the confirmation screen.
  Future<bool> pollForActivityConfirmedStatus(
    String bookingCode, {
    int maxAttempts = 10,
    Duration interval = const Duration(seconds: 2),
  }) async {
    _isFetchingOrder = true;
    _orderError = null;
    notifyListeners();

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      log('');
      log('[ACTIVITY POLL] attempt $attempt/$maxAttempts for $bookingCode');

      final fetched = await fetchActivityOrderDetails(bookingCode);

      if (fetched && _orderData != null) {
        final status = _orderData!.status?.toLowerCase();
        log('[ACTIVITY POLL] status: $status');

        if (status != null && _activityTerminalStatuses.contains(status)) {
          _isFetchingOrder = false;
          notifyListeners();
          return true;
        }
      }

      if (attempt < maxAttempts) {
        await Future.delayed(interval);
      }
    }

    _orderError =
        'Payment is still processing. Please check your bookings shortly.';
    _isFetchingOrder = false;
    notifyListeners();
    return false;
  }
}
