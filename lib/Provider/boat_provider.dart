import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/boat_detail_model.dart';
import 'package:moonbnd/modals/boat_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoatProvider with ChangeNotifier {
  String? _token;
  BoatDetailModel? boatDetail;
  BoatDetailModel? _boatDetail;
  Map<int, BoatList?> boatListPerCategory = {};

  // Pagination State
  final Map<int, Map<String, dynamic>> _lastSearchParams = {};
  final Map<int, bool> _isLoadingMore = {};
  final Map<int, int> _currentPage = {};

  bool isLoadingMore(int index) => _isLoadingMore[index] ?? false;

  Future<void> fetchNextPage(int index) async {
    if (isLoadingMore(index)) return;

    final currentList = boatListPerCategory[index];

    if (currentList == null ||
        currentList.currentPage == null ||
        currentList.lastPage == null ||
        currentList.currentPage! >= currentList.lastPage!) {
      return;
    }

    _isLoadingMore[index] = true;
    notifyListeners();

    try {
      final nextPage = currentList.currentPage! + 1;
      final params = _lastSearchParams[index] ?? {};

      // Call API with next page
      await boatlistapi(
        index,
        searchParams: params,
        page: nextPage,
        isLoadMore: true,
      );
    } catch (e) {
      log("Error fetching next page for index $index: $e");
    } finally {
      _isLoadingMore[index] = false;
      notifyListeners();
    }
  }

  Future<void> resetPagination(int index) async {
    _currentPage[index] = 1;
    _isLoadingMore[index] = false;
    final params = _lastSearchParams[index] ?? {};
    await boatlistapi(index, searchParams: params, page: 1, isLoadMore: false);
  }

  TextEditingController searchController = TextEditingController();

  int _selectedHomeTab = 1;

  int index = -1;

  void searchIndex(int txindex) {
    index = txindex;
    notifyListeners();
  }

  int get selectedHomeTab => _selectedHomeTab;

  Future fetchBoatDetails(int boatId) async {
    log("Fetching Boat Details for ID: $boatId");
    log("Fetching Boat Details for ID: ${ApiUrls.baseUrl}${ApiUrls.boatDetailsEndPoint}/$boatId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.boatDetailsEndPoint}/$boatId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      _boatDetail = BoatDetailModel.fromJson(result['data']);

      log("${_boatDetail?.data.address} address");
      boatDetail = _boatDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  void setSelectedHomeTab(int index) {
    _selectedHomeTab = index;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> leaveReviewForBoat({
    required String reviewTitle,
    required String reviewContent,
    required Map<String, int> reviewStats,
    required String serviceId,
    required String serviceType,
  }) async {
    await loadToken();

    final Map<String, String> body = {
      'review_title': reviewTitle.toString(),
      'review_content': reviewContent.toString(),
      'review_service_id': serviceId.toString(),
      'review_service_type': serviceType.toString(),
      'submit': 'Leave a Review',
    };

    // Add review stats to the body
    reviewStats.forEach((key, value) {
      body['review_stats[$key]'] = value.toString();
    });

    log("${body} bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.leaveReview} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.leaveReview}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Review submitted successfully: ${result['data']}");
      await fetchBoatDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("${result} result error");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return null;
    }
  }

  void updateBoatSearchParams({
    required String location,
    required DateTime? startDate,
    String? searchQuery,
  }) {
    boatlistapi(6, searchParams: {
      'location': location,
      'startDate': startDate,
    });
  }

  Future<bool> boatlistapi(int index,
      {String? sortBy,
      String? searchQuery,
      required Map<String, Object?> searchParams,
      int page = 1,
      bool isLoadMore = false}) async {
    log("Boat List API Call for category index $index ===> Page $page");
    await loadToken();

    // Cache search params for pagination (only if it's a fresh search)
    if (!isLoadMore) {
      _lastSearchParams[index] = Map.from(searchParams);
    }

    // Convert searchParams to query parameters
    final queryParams = {
      'page': page.toString(),
      'per_page': '5',
      if (searchParams['location'] != null)
        'location': searchParams['location'],
      if (searchParams['startDate'] != null)
        'start': DateFormat('MM/dd/yyyy')
            .format(searchParams['startDate'] as DateTime),
      if (searchParams['price_range'] != null)
        'price_range': searchParams['price_range'],
      if (searchParams['review_score'] != null &&
          searchParams['review_score'] != '')
        'review_score': searchParams['review_score'],
      if (searchParams['boat_type'] != null && searchParams['boat_type'] != '')
        'attrs[14]': searchParams['boat_type'],
      if (searchParams['boat_features'] != null &&
          searchParams['boat_features'] != '')
        'attrs[15]': searchParams['boat_features'],
      if (searchParams['text'] != null && searchParams['text'] != '')
        's': searchParams['text'],
      if (sortBy != null) 'orderby': sortBy,
    };

    final queryString = Uri(queryParameters: queryParams).query;
    log('$queryString queryStringgg');
    final url = '${ApiUrls.baseUrl}${ApiUrls.boatSearch}?$queryString';
    log('$url checkurl');

    log("API URL: $url");

    // 🧪 VISUAL TEST: Show toast when loading next page
    //if (page > 1) {
    // EasyLoading.showToast("⏳ Loading Page $page...",
    //    duration: const Duration(seconds: 1),
    //    toastPosition: EasyLoadingToastPosition.bottom);
    //}

    final result =
        await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

    if (result['success']) {
      log("Boat List Response for index $index ===> ${result['data']}");
      BoatList newBoatList = BoatList.fromJson(result['data']);

      if (isLoadMore && boatListPerCategory[index] != null) {
        // Append data
        final currentData = boatListPerCategory[index]!.data ?? [];
        final newData = newBoatList.data ?? [];

        boatListPerCategory[index]!.data = [...currentData, ...newData];
        boatListPerCategory[index]!.currentPage = newBoatList.currentPage;
        boatListPerCategory[index]!.lastPage = newBoatList.lastPage;
        boatListPerCategory[index]!.total = newBoatList.total;
        boatListPerCategory[index]!.text = newBoatList.text;
      } else {
        // Replace data
        boatListPerCategory[index] = newBoatList;
      }

      notifyListeners();

      // 🧪 VISUAL TEST: Confirm data loaded
      //if (page > 1) {
      // EasyLoading.showToast(
      //    "✅ Loaded ${newBoatList.data?.length ?? 0} new items!",
      //   duration: const Duration(seconds: 2),
      //   toastPosition: EasyLoadingToastPosition.bottom);
      // }
      return true;
    } else {
      log("Failed to fetch Car list. Error: ${result['message']}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> addToCartForBoat({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    required String hour,
    required String day,
    List<ExtraPriceBoat>? extraPrices,
    required int number,
    required String startTime,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': "boat",
      'start_date': dateFormat.format(startDate),
      'hour': hour.toString(),
      'day': day.toString(),
      'start_time': startTime.toString(),
      'number': number.toString(),
    };

    // Extra prices (existing code)
    if (extraPrices != null) {
      for (int i = 0; i < extraPrices.length; i++) {
        body['extra_price[$i][name]'] = extraPrices[i].name ?? "";
        body['extra_price[$i][price]'] = extraPrices[i].price ?? "";
        body['extra_price[$i][type]'] = extraPrices[i].type ?? "";
        body['extra_price[$i][number]'] = "0";
        body['extra_price[$i][enable]'] =
            extraPrices[i].valueType == true ? "1" : "0";
        body['extra_price[$i][price_type]'] = '';
      }
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
      EasyLoading.showToast("${result['data']["message"]}",
          maskType: EasyLoadingMaskType.black);
      return result['data'];
    } else {
      EasyLoading.showToast("${result['message']}",
          dismissOnTap: true, maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }
}
