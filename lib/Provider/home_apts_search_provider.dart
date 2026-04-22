import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/modals/home_apts_model.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/Provider/currency_provider.dart';

class HomeAptsSearchProvider with ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────
  List<HomeAptsModel> _homeAptsList = [];
  int _count = 0;
  int _total = 0;
  int _perPage = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _token;

  // Cached last search params for load-more
  String _lastDestination = '';
  String _lastCity = '';
  DateTime? _lastCheckIn;
  DateTime? _lastCheckOut;
  int _lastAdults = 1;
  int _lastChildren = 0;
  int _lastInfants = 0;

  // ── Getters ──────────────────────────────────────────────────────────
  List<HomeAptsModel> get homeAptsList => _homeAptsList;
  int get totalCount => _total > 0 ? _total : _count;
  int get total => totalCount;
  int get count => _count;
  int get perPage => _perPage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMorePages => _currentPage < _lastPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  DateTime? get lastCheckIn => _lastCheckIn;
  DateTime? get lastCheckOut => _lastCheckOut;
  int get lastAdults => _lastAdults;
  int get lastChildren => _lastChildren;
  int get lastInfants => _lastInfants;

  HomeAptsSearchProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      debugPrint(
          '[HomeAptsSearchProvider] Token loaded: ${_token != null ? "✓" : "✗ null"}');
    } catch (e) {
      debugPrint('[HomeAptsSearchProvider] Error loading token: $e');
    }
  }

  int _safeParseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  void _applyPagination(Map<String, dynamic> src, {int fallbackCount = 0}) {
    _count = _safeParseInt(src['count'], fallbackCount);
    _total = _safeParseInt(src['total'], _count);
    _perPage = _safeParseInt(src['per_page']);
    _currentPage = _safeParseInt(src['current_page'], 1);
    _lastPage = _safeParseInt(src['last_page'], 1);
    debugPrint('[HOME_APTS_SEARCH] ── Pagination ──────────────────────────');
    debugPrint('[HOME_APTS_SEARCH]   count        : $_count');
    debugPrint('[HOME_APTS_SEARCH]   total        : $_total');
    debugPrint('[HOME_APTS_SEARCH]   per_page     : $_perPage');
    debugPrint('[HOME_APTS_SEARCH]   current_page : $_currentPage');
    debugPrint('[HOME_APTS_SEARCH]   last_page    : $_lastPage');
    debugPrint('[HOME_APTS_SEARCH] ─────────────────────────────────────');
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Search home & apartments with given parameters.
  /// Pass [isLoadMore]=true to append the next page to existing results.
  Future<bool> searchHomeApts({
    String? destination,
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? infants,
    String? currency,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore && _isLoadingMore) return false;
    if (!isLoadMore && _isLoading) return false;

    if (isLoadMore) {
      if (_currentPage >= _lastPage) {
        debugPrint(
            '[HOME_APTS_SEARCH] No more pages (page $_currentPage of $_lastPage)');
        return true;
      }
      destination = _lastDestination;
      city = _lastCity;
      checkIn = _lastCheckIn;
      checkOut = _lastCheckOut;
      adults = _lastAdults;
      children = _lastChildren;
      infants = _lastInfants;
    }

    destination ??= '';
    city ??= destination;
    checkIn ??= DateTime.now();
    checkOut ??= DateTime.now().add(const Duration(days: 1));
    adults ??= 1;
    children ??= 0;
    infants ??= 0;

    final pageToLoad = isLoadMore ? _currentPage + 1 : 1;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _lastDestination = destination;
      _lastCity = city;
      _lastCheckIn = checkIn;
      _lastCheckOut = checkOut;
      _lastAdults = adults;
      _lastChildren = children;
      _lastInfants = infants;
      _isLoading = true;
      _homeAptsList = [];
    }
    _error = null;
    notifyListeners();

    try {
      if (_token == null) await _loadToken();

      final requestBody = {
        'destination': destination,
        'city': city,
        'check_in': _formatDate(checkIn),
        'check_out': _formatDate(checkOut),
        'adults': adults,
        'children': children,
        'infants': infants,
        'currency': currency ?? CurrencyProvider.defaultCurrency,
        'page': pageToLoad,
      };

      final requestBodyJson = jsonEncode(requestBody);
      final url = '${ApiUrls.baseUrl}${ApiUrls.homeAptsSearch}';

      debugPrint(
          '═══════════════════════════════════════════════════════════════');
      debugPrint(
          '[HOME_APTS_SEARCH] ${isLoadMore ? "LOAD MORE" : "POST REQUEST"}');
      debugPrint('[HOME_APTS_SEARCH] URL: $url');
      debugPrint('[HOME_APTS_SEARCH] Page: $pageToLoad / $_lastPage');
      debugPrint('[HOME_APTS_SEARCH] Request Body (JSON):');
      debugPrint('[HOME_APTS_SEARCH] $requestBodyJson');
      debugPrint('[HOME_APTS_SEARCH] Headers:');
      debugPrint('[HOME_APTS_SEARCH] Content-Type: application/json');
      debugPrint('[HOME_APTS_SEARCH] Authorization: Bearer \$_token');
      debugPrint(
          '═══════════════════════════════════════════════════════════════');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (_token != null) 'Authorization': 'Bearer $_token',
            },
            body: requestBodyJson,
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('[HOME_APTS_SEARCH] Response Status: ${response.statusCode}');
      debugPrint('[HOME_APTS_SEARCH] Response Body:');
      debugPrint('[HOME_APTS_SEARCH] ${response.body}');
      debugPrint('');

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint(
            '[HOME_APTS_SEARCH] Wrapper level - success: ${raw['success']}');

        if (raw['success'] == true) {
          final rawData = raw['data'];

          // Simple list wrapper: {success, data: [...]}
          if (rawData is List) {
            debugPrint('[HOME_APTS_SEARCH] ✓ Simple list wrapper detected');
            final parsed = (rawData as List)
                .whereType<Map<String, dynamic>>()
                .map((json) => HomeAptsModel.fromJson(json))
                .toList();

            if (isLoadMore) {
              _homeAptsList = [..._homeAptsList, ...parsed];
            } else {
              _homeAptsList = parsed;
            }
            _applyPagination(raw, fallbackCount: rawData.length);
            debugPrint(
                '[HOME_APTS_SEARCH] ✓ Parsed ${parsed.length} items, total loaded: ${_homeAptsList.length}');
            if (isLoadMore) {
              _isLoadingMore = false;
            } else {
              _isLoading = false;
            }
            notifyListeners();
            return true;
          }

          // Double-wrapped: {success, data: {success, count, data: [...]}}
          final inner = rawData as Map<String, dynamic>?;
          if (inner == null) {
            _error = 'Empty response from server';
            _isLoading = false;
            notifyListeners();
            debugPrint('[HOME_APTS_SEARCH] ✗ Inner data is null');
            return false;
          }

          final apiData =
              (inner.containsKey('data') && inner.containsKey('success'))
                  ? inner
                  : raw;

          if (apiData['success'] == true) {
            final homeAptsData = apiData['data'] as List?;

            if (homeAptsData == null || homeAptsData.isEmpty) {
              if (isLoadMore) {
                _isLoadingMore = false;
              } else {
                _homeAptsList = [];
                _count = 0;
                _total = 0;
                _isLoading = false;
              }
              notifyListeners();
              return true;
            }

            final parsed = homeAptsData
                .whereType<Map<String, dynamic>>()
                .map((json) => HomeAptsModel.fromJson(json))
                .toList();

            if (isLoadMore) {
              _homeAptsList = [..._homeAptsList, ...parsed];
            } else {
              _homeAptsList = parsed;
            }

            _applyPagination(apiData, fallbackCount: homeAptsData.length);
            debugPrint(
                '[HOME_APTS_SEARCH] ✓ Parsed ${parsed.length} items, total loaded: ${_homeAptsList.length}');

            if (isLoadMore) {
              _isLoadingMore = false;
            } else {
              _isLoading = false;
            }
            notifyListeners();
            return true;
          } else {
            _error = inner['message'] ?? 'API returned false';
            debugPrint('[HOME_APTS_SEARCH] ✗ API error: $_error');
            _isLoading = false;
            _isLoadingMore = false;
            notifyListeners();
            return false;
          }
        } else {
          _error = raw['message'] ?? 'Request failed';
          debugPrint('[HOME_APTS_SEARCH] ✗ Wrapper error: $_error');
          _isLoading = false;
          _isLoadingMore = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        debugPrint('[HOME_APTS_SEARCH] ✗ HTTP Error: $_error');
        debugPrint('[HOME_APTS_SEARCH] Response body: ${response.body}');
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = '$e';
      debugPrint('[HOME_APTS_SEARCH] ✗ EXCEPTION: $e');
      debugPrint('[HOME_APTS_SEARCH] StackTrace: $stackTrace');
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      return false;
    }
  }

  void resetSearch() {
    _homeAptsList = [];
    _count = 0;
    _total = 0;
    _perPage = 0;
    _currentPage = 1;
    _lastPage = 1;
    _error = null;
    notifyListeners();
  }

  void resetPagination() => resetSearch();

  String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return _formatDate(value);
    if (value is String) return value;
    return value.toString();
  }
}
