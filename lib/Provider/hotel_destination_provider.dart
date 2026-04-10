import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/modals/hotel_destination_model.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/services/fuzzy_search_service.dart';

class HotelDestinationProvider with ChangeNotifier {
  List<HotelDestinationResult> _hotelDestinationSuggestions = [];
  bool _isHotelDestinationLoading = false;
  String? _hotelDestinationError;
  HotelDestinationResult? _selectedHotelDestination;
  String _hotelDestinationInput = '';
  Timer? _debounceTimer;
  String? _token;

  /// True when the current suggestions came from fuzzy fallback, not API.
  bool _isFuzzyResult = false;

  /// The corrected query text shown in "Did you mean ...?" banner.
  String? _fuzzyDidYouMean;

  // Getters
  List<HotelDestinationResult> get hotelDestinationSuggestions =>
      List.unmodifiable(_hotelDestinationSuggestions);
  bool get isHotelDestinationLoading => _isHotelDestinationLoading;
  String? get hotelDestinationError => _hotelDestinationError;
  HotelDestinationResult? get selectedHotelDestination =>
      _selectedHotelDestination;
  String get hotelDestinationInput => _hotelDestinationInput;
  bool get isFuzzyResult => _isFuzzyResult;
  String? get fuzzyDidYouMean => _fuzzyDidYouMean;

  /// Whether a valid destination has been selected from the dropdown.
  bool get hasValidHotelDestination =>
      _selectedHotelDestination != null &&
      _hotelDestinationInput == _selectedHotelDestination!.displayName;

  HotelDestinationProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
    } catch (e) {
      log('[HotelDestinationProvider] Error loading token: $e');
    }
  }

  /// Called on every keystroke from the destination text field.
  void onHotelDestinationChanged(String text) {
    _hotelDestinationInput = text;

    // If user edits text after selecting, clear selection
    if (_selectedHotelDestination != null &&
        text != _selectedHotelDestination!.displayName) {
      _selectedHotelDestination = null;
    }

    _debounceTimer?.cancel();

    if (text.trim().isEmpty) {
      _hotelDestinationSuggestions = [];
      _isHotelDestinationLoading = false;
      _hotelDestinationError = null;
      _isFuzzyResult = false;
      _fuzzyDidYouMean = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchHotelDestinations(text.trim());
    });
  }

  /// Called when user taps a suggestion from the dropdown.
  void selectHotelDestination(HotelDestinationResult destination) {
    _selectedHotelDestination = destination;
    _hotelDestinationInput = destination.displayName ?? '';
    _hotelDestinationSuggestions = [];
    _hotelDestinationError = null;
    notifyListeners();
  }

  /// Clear everything.
  void clearHotelDestination() {
    _debounceTimer?.cancel();
    _hotelDestinationSuggestions = [];
    _selectedHotelDestination = null;
    _hotelDestinationInput = '';
    _isHotelDestinationLoading = false;
    _hotelDestinationError = null;
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    notifyListeners();
  }

  /// Called when user taps a "Did you mean ...?" suggestion.
  /// Re-searches with the corrected destination name.
  void acceptFuzzySuggestion(HotelDestinationResult destination) {
    final corrected = destination.destination ?? destination.displayName ?? '';
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    _hotelDestinationInput = corrected;
    notifyListeners();
    _searchHotelDestinations(corrected);
  }

  Future<void> _searchHotelDestinations(String keyword) async {
    _isHotelDestinationLoading = true;
    _hotelDestinationError = null;
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    notifyListeners();

    try {
      if (_token == null) await _loadToken();

      final url =
          '${ApiUrls.baseUrl}${ApiUrls.hotelLocationSearch}?keyword=${Uri.encodeComponent(keyword)}';

      log('[HotelDestination] GET $url');

      final result = await makeRequest(
        url,
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );

      if (result['success'] == true) {
        final data = result['data'];
        List<dynamic> list = [];

        if (data is Map<String, dynamic>) {
          // API returns {success: true, data: [...]}
          if (data['success'] == true && data['data'] is List) {
            list = data['data'];
          } else if (data['data'] is List) {
            list = data['data'];
          }
        } else if (data is List) {
          list = data;
        }

        _hotelDestinationSuggestions = list
            .whereType<Map<String, dynamic>>()
            .map((json) => HotelDestinationResult.fromJson(json))
            .toList();

        // Cache successful results to enrich fuzzy pool
        if (_hotelDestinationSuggestions.isNotEmpty) {
          FuzzySearchService.instance
              .cacheDestinations(_hotelDestinationSuggestions);
        }

        log('[HotelDestination] Found ${_hotelDestinationSuggestions.length} results');

        // ── Fuzzy fallback when API returns empty ──────────────────────
        if (_hotelDestinationSuggestions.isEmpty && keyword.length >= 2) {
          log('[HotelDestination] API empty → trying fuzzy fallback for "$keyword"');
          final fuzzyMatches =
              FuzzySearchService.instance.search(keyword, maxResults: 5);

          if (fuzzyMatches.isNotEmpty) {
            _isFuzzyResult = true;
            _fuzzyDidYouMean = fuzzyMatches.first.destination.displayName ?? '';
            _hotelDestinationSuggestions =
                fuzzyMatches.map((m) => m.destination).toList();
            log('[HotelDestination] Fuzzy found ${fuzzyMatches.length} suggestions, top: $_fuzzyDidYouMean');
          }
        }
      } else {
        _hotelDestinationError = result['message'] ?? 'Search failed';
        _hotelDestinationSuggestions = [];
        log('[HotelDestination] Error: ${result['message']}');
      }
    } catch (e) {
      _hotelDestinationError = 'Network error';
      _hotelDestinationSuggestions = [];
      log('[HotelDestination] Exception: $e');
    }

    _isHotelDestinationLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
