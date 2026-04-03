import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/modals/hotel_search_model.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';

class SearchHotelProvider with ChangeNotifier {
  // State
  List<HotelModel> _hotels = [];

  /// Count of items in current page (from API 'count' field).
  int _count = 0;

  /// True total across all pages (from API 'total' field).
  int _total = 0;
  int _perPage = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _token;

  // Cached last search params for load-more
  String _lastCity = '';
  DateTime? _lastCheckIn;
  DateTime? _lastCheckOut;
  int _lastAdults = 1;
  int _lastChildren = 0;
  int _lastRooms = 1;

  // Getters
  List<HotelModel> get hotels => _hotels;

  /// True total result count. Prefer this over [hotels.length] for UI display.
  int get totalCount => _total > 0 ? _total : _count;
  int get total => totalCount; // Backward compatibility
  int get count => _count;
  int get perPage => _perPage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMorePages => _currentPage < _lastPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  // Cached Search Params Getters
  DateTime? get lastCheckIn => _lastCheckIn;
  DateTime? get lastCheckOut => _lastCheckOut;
  int get lastAdults => _lastAdults;
  int get lastChildren => _lastChildren;
  int get lastRooms => _lastRooms;

  // Constructor - load token on init
  SearchHotelProvider() {
    _loadToken();
  }

  /// Load auth token from SharedPreferences
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      debugPrint(
          '[SearchHotelProvider] Token loaded: ${_token != null ? "✓" : "✗ null"}');
    } catch (e) {
      debugPrint('[SearchHotelProvider] Error loading token: $e');
    }
  }

  /// Safe integer parse helper.
  int _safeParseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  /// Extract and log pagination fields from an API data map.
  void _applyPagination(Map<String, dynamic> src, {int fallbackCount = 0}) {
    _count = _safeParseInt(src['count'], fallbackCount);
    _total = _safeParseInt(src['total'], _count);
    _perPage = _safeParseInt(src['per_page']);
    _currentPage = _safeParseInt(src['current_page'], 1);
    _lastPage = _safeParseInt(src['last_page'], 1);
    debugPrint('[HOTEL_SEARCH] ── Pagination ──────────────────────');
    debugPrint('[HOTEL_SEARCH]   count        : $_count');
    debugPrint('[HOTEL_SEARCH]   total        : $_total');
    debugPrint('[HOTEL_SEARCH]   per_page     : $_perPage');
    debugPrint('[HOTEL_SEARCH]   current_page : $_currentPage');
    debugPrint('[HOTEL_SEARCH]   last_page    : $_lastPage');
    debugPrint('[HOTEL_SEARCH] ───────────────────────────────────');
  }

  /// Format DateTime to yyyy-MM-dd string
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Search hotels with given parameters.
  /// Pass [isLoadMore]=true to append the next page to existing results.
  Future<bool> searchHotels({
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? rooms,
    // Backward compatibility: old API with searchParams dict
    Map<String, dynamic>? searchParams,
    bool isLoadMore = false,
  }) async {
    // Guard: don't stack concurrent loads
    if (isLoadMore && _isLoadingMore) return false;
    if (!isLoadMore && _isLoading) return false;

    // Handle old API (searchParams dict)
    if (searchParams != null) {
      city = searchParams['city']?.toString() ?? city;
      checkIn = searchParams['check_in'] as DateTime? ?? checkIn;
      checkOut = searchParams['check_out'] as DateTime? ?? checkOut;
      adults = int.tryParse(searchParams['adults']?.toString() ?? '') ?? adults;
      children =
          int.tryParse(searchParams['children']?.toString() ?? '') ?? children;
      rooms = int.tryParse(searchParams['rooms']?.toString() ?? '') ?? rooms;

      // Handle old param name 'guests' → split into adults
      if (searchParams['guests'] != null && adults == null) {
        adults = int.tryParse(searchParams['guests']?.toString() ?? '1') ?? 1;
      }
    }

    if (isLoadMore) {
      // No more pages available
      if (_currentPage >= _lastPage) {
        debugPrint(
            '[HOTEL_SEARCH] No more pages (page $_currentPage of $_lastPage)');
        return true;
      }
      // Re-use cached params
      city = _lastCity;
      checkIn = _lastCheckIn;
      checkOut = _lastCheckOut;
      adults = _lastAdults;
      children = _lastChildren;
      rooms = _lastRooms;
    }

    // Use defaults if not provided
    city ??= '';
    checkIn ??= DateTime.now();
    checkOut ??= DateTime.now().add(const Duration(days: 1));
    adults ??= 1;
    children ??= 0;
    rooms ??= 1;

    final pageToLoad = isLoadMore ? _currentPage + 1 : 1;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      // Fresh search — cache params and reset state
      _lastCity = city;
      _lastCheckIn = checkIn;
      _lastCheckOut = checkOut;
      _lastAdults = adults;
      _lastChildren = children;
      _lastRooms = rooms;
      _isLoading = true;
      _hotels = [];
    }
    _error = null;
    notifyListeners();

    try {
      // Ensure token is loaded
      if (_token == null) {
        await _loadToken();
      }

      // Build request body
      final requestBody = {
        'city': city,
        'check_in': _formatDate(checkIn),
        'check_out': _formatDate(checkOut),
        'adults': adults.toString(),
        'children': children.toString(),
        'rooms': rooms.toString(),
      };

      // Page goes as a query param on the POST URL
      final url = Uri.parse(
          '${ApiUrls.baseUrl}${ApiUrls.hotelSearch}?page=$pageToLoad');

      debugPrint(
          '═══════════════════════════════════════════════════════════════');
      debugPrint('[HOTEL_SEARCH] ${isLoadMore ? "LOAD MORE" : "POST REQUEST"}');
      debugPrint('[HOTEL_SEARCH] URL: $url');
      debugPrint('[HOTEL_SEARCH] Page: $pageToLoad / $_lastPage');
      debugPrint('[HOTEL_SEARCH] Body: $requestBody');
      debugPrint(
          '═══════════════════════════════════════════════════════════════');

      // Make POST request
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (_token != null) 'Authorization': 'Bearer $_token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[HOTEL_SEARCH] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final raw = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('[HOTEL_SEARCH] Wrapper level - success: ${raw['success']}');

        // === CRITICAL: Handle double-wrapped response ===
        if (raw['success'] == true) {
          final rawData = raw['data'];

          // Check if data is directly a list (simple wrapper: {success, data: [...]})
          if (rawData is List) {
            debugPrint(
                '[HOTEL_SEARCH] ✓ Simple wrapper detected - data is List');

            final hotelList = rawData as List?;

            if (hotelList == null || hotelList.isEmpty) {
              if (isLoadMore) {
                debugPrint('[HOTEL_SEARCH] No new hotels on page $pageToLoad');
                _isLoadingMore = false;
              } else {
                debugPrint('[HOTEL_SEARCH] ✓ No hotels found (empty list)');
                _hotels = [];
                _count = 0;
                _total = 0;
                _isLoading = false;
              }
              notifyListeners();
              return true;
            }

            // Parse hotels — append on load-more, replace on fresh search
            final parsed = hotelList
                .whereType<Map<String, dynamic>>()
                .map((json) => HotelModel.fromJson(json))
                .toList();

            if (isLoadMore) {
              _hotels = [..._hotels, ...parsed];
            } else {
              _hotels = parsed;
            }

            _applyPagination(raw, fallbackCount: hotelList.length);

            debugPrint(
                '[HOTEL_SEARCH] ✓ Parsed ${parsed.length} hotels, total loaded: ${_hotels.length} (simple list branch)');

            if (isLoadMore) {
              _isLoadingMore = false;
            } else {
              _isLoading = false;
            }
            notifyListeners();
            return true;
          }

          // Otherwise, treat as double-wrapped: {success, data: {success, count, data: [...]}}
          final inner = rawData as Map<String, dynamic>?;

          if (inner == null) {
            _error = 'Empty response from server';
            _isLoading = false;
            notifyListeners();
            debugPrint('[HOTEL_SEARCH] ✗ Inner data is null');
            return false;
          }

          debugPrint(
              '[HOTEL_SEARCH] Inner level - success: ${inner['success']}');
          debugPrint('[HOTEL_SEARCH] Inner level - count: ${inner['count']}');

          // Check if we're dealing with a double-wrapped response
          final apiData =
              (inner.containsKey('data') && inner.containsKey('success'))
                  ? inner
                  : raw;

          if (apiData['success'] == true) {
            final hotelList = apiData['data'] as List?;

            if (hotelList == null || hotelList.isEmpty) {
              if (isLoadMore) {
                debugPrint('[HOTEL_SEARCH] No new hotels on page $pageToLoad');
                _isLoadingMore = false;
              } else {
                debugPrint('[HOTEL_SEARCH] ✓ No hotels found (empty list)');
                _hotels = [];
                _count = 0;
                _total = 0;
                _isLoading = false;
              }
              notifyListeners();
              return true;
            }

            // Parse hotels — append on load-more, replace on fresh search
            final parsed = hotelList
                .whereType<Map<String, dynamic>>()
                .map((json) => HotelModel.fromJson(json))
                .toList();

            if (isLoadMore) {
              _hotels = [..._hotels, ...parsed];
            } else {
              _hotels = parsed;
            }

            _applyPagination(apiData, fallbackCount: hotelList.length);

            debugPrint(
                '[HOTEL_SEARCH] ✓ Parsed ${parsed.length} hotels, total loaded: ${_hotels.length} (double-wrapped branch)');

            if (isLoadMore) {
              _isLoadingMore = false;
            } else {
              _isLoading = false;
            }
            notifyListeners();
            return true;
          } else {
            _error = inner['message'] ?? 'API returned false';
            debugPrint('[HOTEL_SEARCH] ✗ API error: $_error');
            _isLoading = false;
            _isLoadingMore = false;
            notifyListeners();
            return false;
          }
        } else {
          _error = raw['message'] ?? 'Request failed';
          debugPrint('[HOTEL_SEARCH] ✗ Wrapper error: $_error');
          _isLoading = false;
          _isLoadingMore = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        debugPrint('[HOTEL_SEARCH] ✗ HTTP Error: $_error');
        debugPrint('[HOTEL_SEARCH] Response body: ${response.body}');
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = '$e';
      debugPrint('[HOTEL_SEARCH] ✗ EXCEPTION: $e');
      debugPrint('[HOTEL_SEARCH] StackTrace: $stackTrace');
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear search results
  void resetSearch() {
    _hotels = [];
    _count = 0;
    _total = 0;
    _perPage = 0;
    _currentPage = 1;
    _lastPage = 1;
    _error = null;
    notifyListeners();
  }

  /// Backward compatibility: reset pagination (now just clears search)
  void resetPagination() {
    resetSearch();
  }

  /// Backward compatibility: format date helper
  String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return _formatDate(value);
    }
    if (value is String) {
      try {
        return _formatDate(DateTime.parse(value));
      } catch (e) {
        return '';
      }
    }
    return '';
  }
}
