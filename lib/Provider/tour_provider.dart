import 'dart:developer';
import 'package:moonbnd/modals/tour_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/tour_list_model.dart';
import 'api_interface.dart';
import '../Urls/url_holder_loan.dart';

class TourProvider with ChangeNotifier {
  String? _token;
  Map<int, TourList?> tourListPerCategory = {};
  TourDetailModal? tourDetail;
  TourDetailModal? _tourDetail;
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("Token loaded: $_token");
  }

  void updateTourSearchParams({
    required String location,
    required DateTime? startDate,
    required DateTime? endDate,
    String? searchQuery,
  }) {
    tourlistapi(1, searchParams: {
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  Future<bool?> tourlistapi(int index,
      {String? sortBy,
      String? searchQuery,
      required Map<String, dynamic> searchParams}) async {
    log("Tour List API Call for category index $index ===>");
    await loadToken();

    // Convert searchParams to query parameters
    final queryParams = {
      if (searchParams['location'] != null)
        'location': searchParams['location'],
      if (searchParams['startDate'] != null)
        'start': DateFormat('MM/dd/yyyy')
            .format(searchParams['startDate'] as DateTime),
      if (searchParams['endDate'] != null)
        'end': DateFormat('MM/dd/yyyy')
            .format(searchParams['endDate'] as DateTime),
      if (searchParams['price_range'] != null)
        'price_range': searchParams['price_range'],
      if (searchParams['review_score'] != null &&
          searchParams['review_score'] != '')
        'review_score': searchParams['review_score'],
      if (sortBy != null) 'orderby': sortBy,
      if (searchParams['tour_types'] != null &&
          searchParams['tour_types'] != '')
        'cat_id': searchParams['tour_types'],
      if (searchParams['facilities'] != null &&
          searchParams['facilities'] != '')
        'attrs[1]': searchParams['facilities'],
      if (searchParams['travel_styles'] != null &&
          searchParams['travel_styles'] != '')
        'attrs[2]': searchParams['travel_styles'],
    };

    final queryString = Uri(queryParameters: queryParams).query;
    log('$queryString queryStringgg');
    String url = '${ApiUrls.baseUrl}${ApiUrls.tourSearch}?$queryString';
    log('$url checkurl');
    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Tour List Response for index $index ===> ${result['data']}");
      TourList tourList = TourList.fromJson(result['data']);
      tourListPerCategory[index] = tourList;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch tour list. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future fetchTourDetails(int tourId) async {
    log("Fetching Tour Details for ID: $tourId");
    log("Fetching Tour Details for ID: ${ApiUrls.baseUrl}${ApiUrls.tourDetailsEndPoint}/$tourId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.tourDetailsEndPoint}/$tourId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Tour Details Response: ${result['data']}");
      _tourDetail = TourDetailModal.fromJson(result['data']);

      log("${_tourDetail?.data?.address} address");
      tourDetail = _tourDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> leaveReviewForTour({
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
      await fetchTourDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("${result} result error");
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCartForTour({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    required DateTime endDate,
    List<ExtraPrice>? extraPrices,
    required int number,
    List<Map<String, dynamic>>? personTypes,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': "tour",
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
      'guests': number.toString(),
    };

    // Add person types to the request
    if (personTypes != null) {
      for (int i = 0; i < personTypes.length; i++) {
        body['person_types[$i][name]'] = personTypes[i]['name'] ?? '';
        body['person_types[$i][desc]'] = personTypes[i]['desc'] ?? '';
        body['person_types[$i][min]'] =
            personTypes[i]['min']?.toString() ?? '1 ';
        body['person_types[$i][max]'] =
            personTypes[i]['max']?.toString() ?? '10';
        body['person_types[$i][price]'] =
            personTypes[i]['price']?.toString() ?? '0';
        body['person_types[$i][display_price]'] =
            personTypes[i]['display_price'] ?? '';
        body['person_types[$i][number]'] =
            personTypes[i]['number']?.toString() ?? '';
      }
    }

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
      return result['data'];
    } else {
      log("Failed to add to cart. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  ////////
  ///       VENDOR
  ///////
  ///
  ///
  ///
}
