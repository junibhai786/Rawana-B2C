import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/modals/hotel_destination_model.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/Provider/api_interface.dart';

class HotelDestinationProvider with ChangeNotifier {
  List<HotelDestinationResult> _hotelDestinationSuggestions = [];
  bool _isHotelDestinationLoading = false;
  String? _hotelDestinationError;
  HotelDestinationResult? _selectedHotelDestination;
  String _hotelDestinationInput = '';
  Timer? _debounceTimer;
  String? _token;

  // Getters
  List<HotelDestinationResult> get hotelDestinationSuggestions =>
      List.unmodifiable(_hotelDestinationSuggestions);
  bool get isHotelDestinationLoading => _isHotelDestinationLoading;
  String? get hotelDestinationError => _hotelDestinationError;
  HotelDestinationResult? get selectedHotelDestination =>
      _selectedHotelDestination;
  String get hotelDestinationInput => _hotelDestinationInput;

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
    notifyListeners();
  }

  Future<void> _searchHotelDestinations(String keyword) async {
    _isHotelDestinationLoading = true;
    _hotelDestinationError = null;
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

        log('[HotelDestination] Found ${_hotelDestinationSuggestions.length} results');
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
