import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHotelProvider with ChangeNotifier {
  List<Hotel> _hotels = [];
  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _token;

  List<Hotel> get hotels => _hotels;
  int get total => _total;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
  }

  void resetPagination() {
    _currentPage = 1;
    _isLoadingMore = false;
    _hasMoreData = true;
    _hotels = [];
    _total = 0;
    notifyListeners();
  }

  String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(value);
    }
    if (value is String) {
      try {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(value));
      } catch (e) {
        return value;
      }
    }
    return '';
  }

  Future<bool> searchHotels({
    required Map<String, dynamic> searchParams,
    String? sortBy,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (_isLoadingMore || !_hasMoreData) return false;
      _isLoadingMore = true;
      _currentPage++;
    } else {
      _isLoading = true;
      resetPagination();
    }
    notifyListeners();

    await loadToken();

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'per_page': '10', // Consistent pagination
        if (searchParams['city'] != null)
          'location_id': searchParams['city'].toString(),
        if (searchParams['check_in'] != null)
          'start_date': formatDate(searchParams['check_in']),
        if (searchParams['check_out'] != null)
          'end_date': formatDate(searchParams['check_out']),
        if (searchParams['guests'] != null)
          'adults': searchParams['guests'].toString(),
        if (searchParams['children'] != null)
          'children': searchParams['children'].toString(),
        if (searchParams['rooms'] != null)
          'rooms': searchParams['rooms'].toString(),
        if (sortBy != null) 'orderby': sortBy,
      };

      final uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.hotelSearch}')
          .replace(queryParameters: queryParams);
      final url = uri.toString();

      log('SEARCH_HOTEL API URL: $url');

      final result =
          await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

      if (result['success']) {
        HotelList response = HotelList.fromJson(result['data']);
        List<Hotel> newItems = response.data ?? [];

        _total = response.total ?? 0;
        _lastPage = response.lastPage ?? 1;

        if (isLoadMore) {
          _hotels.addAll(newItems);
        } else {
          _hotels = newItems;
        }

        _hasMoreData = _currentPage < _lastPage && newItems.isNotEmpty;

        print(
            'SEARCH_HOTEL PAGE:$_currentPage LAST:$_lastPage ITEMS:${newItems.length}');

        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      log('Error in Search Hotel API: $e');
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      return false;
    }
  }
}
