// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/data_models/booking_history_model.dart';
import 'package:moonbnd/data_models/wishlist_modal.dart';
import 'package:moonbnd/modals/Booking_details.dart';
import 'package:moonbnd/modals/boat_list_model.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/modals/manage_coupon_model.dart';
import 'package:moonbnd/modals/manage_service_model.dart';
import 'package:get/get.dart' as gettt;
import 'package:moonbnd/modals/car_list_model.dart';
import 'package:moonbnd/modals/credit_balance_model.dart';
import 'package:moonbnd/modals/event_list_model.dart';
import 'package:moonbnd/modals/getlocationadd_Car_mdeol.dart';
import 'package:moonbnd/modals/home_item.dart' as home_item;
import 'package:moonbnd/modals/hotel_detail_model.dart';
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/modals/image_modal.dart';
import 'package:moonbnd/modals/space_list_model.dart';
import 'package:moonbnd/modals/tour_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../modals/country_modal.dart';
import '../modals/fetch_locations.dart';

class HomeProvider with ChangeNotifier {
  String? _token;
  Map<int, home_item.HomeList> homeListPerCategory = {};
  String paymentMethod = "offline";
  HotelDetail? hotelDetail;
  BookingResponse? bookingResponse;
  CountryResponse? countryResponse;

  Bookinghistory? bookingHistoryResponse;
  Map<int, HotelList?> hotelListPerCategory = {};
  Map<int, CarList?> carListPerCategory = {};
  Map<int, EventList?> eventListPerCategory = {};

  Map<int, SpaceList?> spaceListPerCategory = {};
  List<int> selectedpropertytypeIds = [];

  TextEditingController searchController = TextEditingController();
  CarDetailModal? carDetail;
  ImageModal? verifyIdCard;
  ImageModal? verifyTradeLicense;
  CarList? carlist;
  CarList? carlists;

  List<String> _countries = [];
  List<String> get countries => _countries;
  // HotelDetail? _hotelDetail;
  CarDetailModal? _carDetail;
  AddCarLocationModel? addcarlocation;
  AddCarLocationModel? addcarlocations;
  CarDetailModal? vendorcarDetail;
  CarDetailModal? _vendorcarDetail;
  CreditBalanceModel? creditbalance;
  CreditBalanceModel? creditbalances;
  CouponResponse? couponResponseList;
  ManageService? manageServiceResponse;

  //Fetch locations for hotel search filter.
  bool isLocationLoading = false;

  LocationResponse? locationResponse;
  List<LocationItem> locations = [];
  List<LocationItem> filteredLocations = [];

  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  ////end
  int _selectedHomeTab = 0;
  TabController? tabController;
  int index = 1;

  void searchIndex(int txindex) {
    index = txindex;
    notifyListeners();
  }

  int get selectedHomeTab => _selectedHomeTab;

  void setSelectedHomeTab(int index) {
    _selectedHomeTab = index;
    tabController?.animateTo(index);
    notifyListeners();
  }
  String selectedCity = '';
  String departureCity='';
  String destinationCity='';

  void selectCity(String city) {
    selectedCity = city;
    notifyListeners();
  }


  void selectDepartureCity(String city) {
    departureCity = city;
    notifyListeners();
  }

  void selectDestinationCity(String city) {
    destinationCity = city;
    notifyListeners();
  }
  //Fetch locations for hotel search Api

  Future<void> fetchLocations({int page = 1, bool loadMore = false}) async {
    if (isLocationLoading || isLoadingMore) return;
    if (!hasMore && loadMore) return;

    if (loadMore) {
      isLoadingMore = true;
    } else {
      isLocationLoading = true;
      currentPage = 1;
      locations.clear();
      filteredLocations.clear();
    }

    notifyListeners();

    try {
      final url = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.hotellocations}?page=$page',
      );

      log('Fetching locations page: $page');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

        final parsed = LocationResponse.fromJson(json);

        final newLocations = parsed.data ?? [];

        if (newLocations.isEmpty) {
          hasMore = false;
        } else {
          currentPage = page;
          locations.addAll(newLocations);
          filteredLocations = locations;
        }
      }
    } catch (e) {
      debugPrint('Fetch locations error: $e');
    } finally {
      isLocationLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }








//   Future<void> fetchLocations() async {
//     log('******************************Check A *******************************************');
//
//   //  if (locations.isNotEmpty) return; // 🛑 cache
//
//     isLocationLoading = true;
//     notifyListeners();
//
//     try {
//       final url = Uri.parse(ApiUrls.baseUrl + ApiUrls.hotellocations);
// log('*************************************************************************${url.toString()}');
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         log('*******************************   Response is 200  *************************');
//         final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
//         log(json.toString());
//         log('******************************Check B *******************************************');
//
//         final parsed = LocationResponse.fromJson(json);
// log('response is ${parsed.toString()}');
//         locationResponse = parsed;
//         locations = parsed.data ?? [];
//         filteredLocations = locations;
//       } else {
//         log('*******************************   Response Failed  *************************');
//
//         debugPrint('Failed to fetch locations: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('*******************************   Response in catch *************************');
//
//       debugPrint('Fetch locations error: $e');
//     } finally {
//       isLocationLoading = false;
//       notifyListeners();
//     }
//   }


  void filterLocations(String query) {
    if (query.isEmpty) {
      filteredLocations = locations;
    } else {
      filteredLocations = locations
          .where((e) =>
      e.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    }
    notifyListeners();
  }



  Future<bool> deletevendorcar({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.leaveReview} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendordeletecar}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Review submitted successfully: ${result['data']}");
      EasyLoading.showToast("Car delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  void updateHotelSearchParams({
    required String location,
    required DateTime? startDate,
    required DateTime? endDate,
    required int rooms,
    required int adults,
    required int children,
    String? searchQuery,
  }) {
    hotellistapi(1, searchParams: {
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'rooms': rooms,
      'adults': adults,
      'children': children,
    });
  }

  Future<bool> clonecarvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'car_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.clonecarvendor} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.clonecarvendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Car cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> publishcarvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'tour_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorpublishcar} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorpublishcar}/$id',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<bool> hidecarvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'car_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorcarhotel} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorcarhotel}/$id',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future fetchCarvendorDetails() async {
    log("Fetching Car Vendor Details: ${ApiUrls.baseUrl}${ApiUrls.vendorallcar}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorallcar}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success'] == true} success check");
    if (result['success']) {
      carlist = CarList.fromJson(result['data']);

      carlists = carlist;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch hotel details (4). Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future fetachaddcarlocation() async {
    log("Fetching Add Car Location: ${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      addcarlocation = AddCarLocationModel.fromJson(result['data']);

      addcarlocations = addcarlocation;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch hotel details (5) . Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  void updateCarSearchParams({
    required String location,
    required DateTime? startDate,
    required DateTime? endDate,
    String? searchQuery,
  }) {
    carlistapi(4, searchParams: {
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("Token $_token");
  }

  Future<home_item.HomeList?> homelistapi(int index) async {
    // if (homeListPerCategory.containsKey(index)) {
    //   return homeListPerCategory[index];
    // }

    log("Home List API Call for category index $index ===>");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.homeListEnd}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    // Log the entire API response
    log("Home List API Response: ${result.toString()}");

    if (result['success']) {
      log("Home List Response for index $index ===> ${result['data']}");

      List<home_item.HomeItem> homeItems = [];

      // Process offers
      if (result['data']['offers'] != null) {
        List<home_item.Offer> offers = (result['data']['offers'] as List)
            .map((item) => home_item.Offer.fromJson(item))
            .toList();
        homeItems.addAll(offers.map((offer) =>
            home_item.HomeItem(type: home_item.ItemType.offer, item: offer)));
        log("Processed ${offers.length} offers");
      }
      dynamic rawData = result['data'];
      List blocks = [];

      if (rawData is List) {
        blocks = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        blocks = rawData['data'];
      } else {
        log("❌ Unexpected data format: ${rawData.runtimeType}");

      }
      for (final block in blocks) {
        if (block is! Map<String, dynamic>) continue;

        if (block['type'] == 'list_hotel') {
          final model = block['model'];

          if (model is Map && model['data'] is List) {
            final List hotelList = model['data'];

            final offers = hotelList
                .map((e) => Hotel.fromJson(e))
                .toList();

            homeItems.addAll(
              offers.map(
                    (offer) => home_item.HomeItem(
                  type: home_item.ItemType.hotel,
                  item: offer,
                ),
              ),
            );

            log("✅ Processed ${offers.length} hotels");
          }
        }
      }





      // if (result['data']['data']['Tour'] != null) {
      //   List<Tour> offers = (result['data']['data']['Tour'] as List)
      //       .map((item) => Tour.fromJson(item))
      //       .toList();
      //   homeItems.addAll(offers.map((offer) =>
      //       home_item.HomeItem(type: home_item.ItemType.tour, item: offer)));
      //   log("Processed ${offers.length} offers");
      // }


      for (final block in blocks) {
        if (block is! Map<String, dynamic>) continue;

        if (block['type'] == 'list_tours') {
          final model = block['model'];

          if (model is Map && model['data'] is List) {
            final List tourList = model['data'];

            final List<Tour> offers = tourList
                .map((item) => Tour.fromJson(item))
                .toList();

            homeItems.addAll(
              offers.map(
                    (offer) => home_item.HomeItem(
                  type: home_item.ItemType.tour,
                  item: offer,
                ),
              ),
            );

            log("✅ Processed ${offers.length} tours");
          } else {
            log("⚠️ list_tours has no valid data list");
          }
        }
      }


      for (final block in blocks) {
        if (block is! Map<String, dynamic>) continue;

        final String? type = block['type'];
        final model = block['model'];

        if (model is! Map || model['data'] is! List) {
          log("⚠️ $type has no valid data list");
          continue;
        }

        final List dataList = model['data'];

        switch (type) {

          case 'list_car':
            final cars = dataList
                .map((e) => Car.fromJson(e))
                .toList();

            homeItems.addAll(
              cars.map((e) => home_item.HomeItem(
                type: home_item.ItemType.car,
                item: e,
              )),
            );

            log("✅ Processed ${cars.length} cars");
            break;

          case 'list_event':
            final events = dataList
                .map((e) => Event.fromJson(e))
                .toList();

            homeItems.addAll(
              events.map((e) => home_item.HomeItem(
                type: home_item.ItemType.event,
                item: e,
              )),
            );

            log("✅ Processed ${events.length} events");
            break;

          case 'list_boat':
            final boats = dataList
                .map((e) => Boat.fromJson(e))
                .toList();

            homeItems.addAll(
              boats.map((e) => home_item.HomeItem(
                type: home_item.ItemType.boat,
                item: e,
              )),
            );

            log("✅ Processed ${boats.length} boats");
            break;

          case 'list_space':
            final spaces = dataList
                .map((e) => Space.fromJson(e))
                .toList();

            homeItems.addAll(
              spaces.map((e) => home_item.HomeItem(
                type: home_item.ItemType.space,
                item: e,
              )),
            );

            log("✅ Processed ${spaces.length} spaces");
            break;

          case 'list_location':
            final locations = dataList
                .map((e) => home_item.Location.fromJson(e))
                .toList();

            homeItems.addAll(
              locations.map(
                    (location) => home_item.HomeItem(
                  type: home_item.ItemType.location,
                  item: location,
                ),
              ),
            );

            log("✅ Processed ${locations.length} locations");
            break;

        }
      }


      // if (result['data']['data']['Car'] != null) {
      //   List<Car> offers = (result['data']['data']['Car'] as List)
      //       .map((item) => Car.fromJson(item))
      //       .toList();
      //   homeItems.addAll(offers.map((offer) =>
      //       home_item.HomeItem(type: home_item.ItemType.car, item: offer)));
      //   log("Processed ${offers.length} offers");
      // }
      // if (result['data']['data']['Event'] != null) {
      //   List<Event> offers = (result['data']['data']['Event'] as List)
      //       .map((item) => Event.fromJson(item))
      //       .toList();
      //   homeItems.addAll(offers.map((offer) =>
      //       home_item.HomeItem(type: home_item.ItemType.event, item: offer)));
      //   log("Processed ${offers.length} offers");
      // }
      // if (result['data']['data']['Boat'] != null) {
      //   List<Boat> offers = (result['data']['data']['Boat'] as List)
      //       .map((item) => Boat.fromJson(item))
      //       .toList();
      //   homeItems.addAll(offers.map((offer) =>
      //       home_item.HomeItem(type: home_item.ItemType.boat, item: offer)));
      //   log("Processed ${offers.length} offers");
      // }
      // if (result['data']['data']['Space'] != null) {
      //   List<Space> offers = (result['data']['data']['Space'] as List)
      //       .map((item) => Space.fromJson(item))
      //       .toList();
      //   homeItems.addAll(offers.map((offer) =>
      //       home_item.HomeItem(type: home_item.ItemType.space, item: offer)));
      //   log("Processed ${offers.length} offers");
      // }

      // if (result['data']['data']['Location'] != null) {
      //   List<home_item.Location> locations =
      //       (result['data']['data']['Location'] as List)
      //           .map((item) => home_item.Location.fromJson(item))
      //           .toList();
      //   homeItems.addAll(locations.map((location) => home_item.HomeItem(
      //       type: home_item.ItemType.location, item: location)));
      //   log("Processed ${locations.length} locations");
      // }

      // Process other categories (hotel, car, event, tour, space, boat, flight)
      final categories = [
        (home_item.ItemType.hotel, 'Hotel'),
        (home_item.ItemType.car, 'Car'),
        (home_item.ItemType.event, 'Event'),
        (home_item.ItemType.tour, 'Tour'),
        (home_item.ItemType.space, 'Space'),
        (home_item.ItemType.boat, 'Boat'),
        (home_item.ItemType.flight, 'Flight'),
        (home_item.ItemType.location, 'Location'),
      ];

      for (var category in categories) {
        if (result['data'][category.$2] != null) {
          final list = result['data'][category.$2] as List<dynamic>? ?? [];
          final items = list
              .map((item) => home_item.HomeItem(type: category.$1, item: item))
              .toList();
          homeItems.addAll(items);
          log("Processed ${items.length} ${category.$2} items");
        } else {
          log("No data for ${category.$2}");
        }
      }

      home_item.HomeList homeList = home_item.HomeList(items: homeItems);
      homeListPerCategory[index] = homeList;
      log("Total processed items: ${homeItems.length}");
      log("Item types: ${homeItems.map((item) => item.type.toString()).toList()}");
      notifyListeners();
      return homeList;
    } else {
      log("Failed to fetch home list. Error: ${result['message']}");
      return null;
    }
  }
  String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(value);
    }
    if (value is String) {
      return DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(value));
    }
    throw Exception('Invalid date type');
  }


  Future<bool> hotellistapi(int index,
      {
        String? sortBy,
      String? searchQuery,
      required Map<String, Object?> searchParams}) async {
    log("check here");
    try {
      log("Hotel List API Call for category index $index ===>");
      await loadToken();

      // Convert searchParams to query parameters
      final queryParams = <String, String>{
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

        if (searchParams['page'] != null)
          'page': searchParams['page'].toString(),

        if (searchParams['per_page'] != null)
          'per_page': searchParams['per_page'].toString(),

        if (sortBy != null)
          'orderby': sortBy,
      };



      final queryString = Uri(queryParameters: queryParams).query;
      final uri = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.hotelSearch}',
      ).replace(queryParameters: queryParams);

      final url = uri.toString();
      log('API URL: $url');


      log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%API URL: $url");
     // return true;
      final result =
          await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

      if (result['success']) {
        log("Hotel List Response for index $index ===> ${result['data']}");
        HotelList hotelList = HotelList.fromJson(result['data']);
        hotelListPerCategory[index] = hotelList;
        notifyListeners();
        return true;
      } else {
        log("Failed to fetch hotel list. Error: ${result['message']}");
        return false;
      }
    } catch (e) {
      print('Error fetching hotel list: $e');
      return false;
    }
  }

  Future<bool> carlistapi(int index,
      {String? sortBy,
      String? searchQuery,
      required Map<String, Object?> searchParams}) async {
    log("Car List API Call for category index $index ===>");
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
      if (searchParams['car_type'] != null && searchParams['car_type'] != '')
        'attrs[9]': searchParams['car_type'],
      if (searchParams['car_features'] != null &&
          searchParams['car_features'] != '')
        'attrs[10]': searchParams['car_features'],
      if (sortBy != null) 'orderby': sortBy,
    };

    final queryString = Uri(queryParameters: queryParams).query;
    log('$queryString queryStringgg');
    final url = '${ApiUrls.baseUrl}${ApiUrls.carSearch}?$queryString';
    log('$url checkurl');

    log("API URL: $url");
    final result =
        await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

    if (result['success']) {
      log("Car filter Response for index $index ===> ${result['data']}");
      CarList carList = CarList.fromJson(result['data']);
      carListPerCategory[index] = carList;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch Car list. Error: ${result['message']}");
      return false;
    }
  }

  Future<EventList?> eventlistapi(
    int index, {
    String? sortBy,
  }) async {
    log("Event List API Call for category index $index ===>");
    await loadToken();

    String url = '${ApiUrls.baseUrl}${ApiUrls.eventListEndPoint}';
    if (sortBy != null) {
      url += '?sort_by=$sortBy';
    }

    final result =
        await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

    if (result['success']) {
      log("Event List Response for index $index ===> ${result['data']}");
      EventList eventList = EventList.fromJson(result['data']);
      eventListPerCategory[index] = eventList;
      notifyListeners();
      return eventList;
    } else {
      log("Failed to fetch event list. Error: ${result['message']}");
      return null;
    }
  }

  // Future<bool?> tourlistapi(int index,
  //     {String? sortBy, required Map<String, String> searchParams}) async {
  //   log("Tour List API Call for category index $index ===>");
  //   await loadToken();

  //   final queryParams = {
  //     if (searchParams['location'] != null)
  //       'location': searchParams['location'],
  //     if (searchParams['startDate'] != null)
  //       'start': DateFormat('MM/dd/yyyy')
  //           .format(searchParams['startDate'] as DateTime),
  //     if (searchParams['endDate'] != null)
  //       'end': DateFormat('MM/dd/yyyy')
  //           .format(searchParams['endDate'] as DateTime),
  //     if (searchParams['rooms'] != null)
  //       'room': searchParams['rooms'].toString(),
  //     if (searchParams['adults'] != null)
  //       'adults': searchParams['adults'].toString(),
  //     if (searchParams['children'] != null)
  //       'children': searchParams['children'].toString(),
  //     if (searchParams['star_rate'] != null && searchParams['star_rate'] != '')
  //       'star_rate': searchParams['star_rate'],
  //     if (searchParams['review_score'] != null &&
  //         searchParams['review_score'] != '')
  //       'review_score': searchParams['review_score'],
  //     if (searchParams['property_type'] != null &&
  //         searchParams['property_type'] != '')
  //       'attrs[5]': searchParams['property_type'],
  //     if (searchParams['facilities'] != null &&
  //         searchParams['facilities'] != '')
  //       'attrs[6]': searchParams['facilities'],
  //     if (searchParams['services'] != null && searchParams['services'] != '')
  //       'attrs[7]': searchParams['services'],
  //     if (searchParams['price_range'] != null)
  //       'price_range': searchParams['price_range'],
  //     if (sortBy != null) 'orderby': sortBy,
  //   };

  //   final queryString = Uri(queryParameters: queryParams).query;
  //   String url = '${ApiUrls.baseUrl}${ApiUrls.tourListEndPoint}';

  //   final result =
  //       await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

  //   if (result['success']) {
  //     log("Tour List Response for index $index ===> ${result['data']}");
  //     TourList tourList = TourList.fromJson(result['data']);
  //     tourListPerCategory[index] = tourList;
  //     notifyListeners();
  //     return true;
  //   } else {
  //     log("Failed to fetch tour list. Error: ${result['message']}");
  //     return false;
  //   }
  // }

  // Future<SpaceList?> spacelistapi(int index, {String? sortBy}) async {
  //   log("Space List API Call for category index $index ===>");
  //   await loadToken();

  //   String url = '${ApiUrls.baseUrl}${ApiUrls.spaceListEndPoint}';
  //   if (sortBy != null) {
  //     url += '?sort_by=$sortBy';
  //   }

  //   final result =
  //       await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

  //   if (result['success']) {
  //     log("Space List Response for index $index ===> ${result['data']}");
  //     SpaceList spaceList = SpaceList.fromJson(result['data']);
  //     spaceListPerCategory[index] = spaceList;
  //     notifyListeners();
  //     return spaceList;
  //   } else {
  //     log("Failed to fetch space list. Error: ${result['message']}");
  //     return null;
  //   }
  // }

  Future fetchHotelDetails(int hotelId) async {
    log("Fetching Hotel Details for ID: $hotelId");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.hotelDetailsEndPoint}/$hotelId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);
    if (result['success']) {
      log("Hotel Details Response: ${result['data']}");
      hotelDetail = HotelDetail.fromJson(result['data']);
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (1). Error: ${result['message']}");
      return null;
    }
  }

  Future fetchCarvendor(int carId) async {
    log("Fetching Car Vendor for ID: $carId");
    log("Fetching Car Vendor for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorcarDetailsEndPoint}/$carId");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorcarDetailsEndPoint}/$carId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      _vendorcarDetail = CarDetailModal.fromJson(result['data']);

      log("${_carDetail?.data?.address} address");
      vendorcarDetail = _vendorcarDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (2). Error: ${result['message']}");
      return null;
    }
  }

  Future fetchCarDetails(int carId) async {
    log("Fetching Car Details for ID: $carId");
    log("Fetching Car Details for ID: ${ApiUrls.baseUrl}${ApiUrls.carDetailsEndPoint}/$carId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.carDetailsEndPoint}/$carId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success checkkkkk");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      _carDetail = CarDetailModal.fromJson(result['data']);

      log("${_carDetail?.data?.address} address");
      carDetail = _carDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (3). Error: ${result['message']}");
      return null;
    }
  }

  Future<void> updateVerificationData(File idCardFile, File licenseFile) async {
    await loadToken();

    log("$idCardFile file");
    log("$licenseFile file");

    var uri = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.updateVerificationDataEndpoint}');
    var request = MultipartRequest('POST', uri);

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add form fields

    // Add file fields

    request.files
        .add(await http.MultipartFile.fromPath('id_card', idCardFile.path));

    request.files
        .add(await http.MultipartFile.fromPath('license', licenseFile.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        log('Update Verification Data Response: $jsonResponse');
        // Handle successful response
        notifyListeners();
      } else {
        showErrorToast(json.decode(response.body)["message"]);

        log('Failed to update verification data. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        // Handle error
      }
    } catch (e) {
      log('Error updating verification data: $e');
      // Handle exception
    }
  }

  Future<String> addToWishlist(String objectId, String objectModel) async {
    await loadToken();

    log('$objectId wishtanay');
    log('$objectModel wishtanay');
    log('$_token wishtanay');

    var headers = {'Authorization': 'Bearer $_token'};
    var request = MultipartRequest(
        'POST', Uri.parse("${ApiUrls.baseUrl}${ApiUrls.wishlist}"));
    request.fields.addAll({'object_id': objectId, 'object_model': objectModel});

    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      await fetchWishlist();

      return responseData["message"].toString();
    } else {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      return responseData["message"].toString();
    }
  }

  Future<WishlistResponse?> fetchWishlist() async {
    await loadToken();

    log("Fetching Wishlist ===>");

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.wishlist}',
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );
    if (result['success']) {
      log("Wishlist Response ===> ${result['data']}");

      WishlistResponse wishlistResponse =
          WishlistResponse.fromJson(result['data']);

      log("${wishlistResponse.data.length} length after");

      notifyListeners();

      return wishlistResponse;
    } else {
      log("Failed to fetch wishlist. Error: ${result['message']}");
      return null;
    }
  }

  Future<void> uploadVerificationImage(
      File imageFile, bool verifyIdCardCheck) async {
    await loadToken();

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.verificationImage}');
    var request = MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      log('Verification Upload Response: $jsonResponse');

      if (verifyIdCardCheck) {
        verifyIdCard = ImageModal.fromJson(jsonResponse['data']);
      } else {
        verifyTradeLicense = ImageModal.fromJson(jsonResponse['data']);
      }

      log("${verifyIdCard?.name} namename");
      log("${verifyTradeLicense?.name} namename");

      notifyListeners();
    } else {
      log('Failed to upload verification image. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      // Handle error
    }
  }

  Future<bool> submitVerification({
    required String phoneNumber,
    required ImageModal idCard,
    required List<ImageModal> tradeLicenses,
  }) async {
    await loadToken();

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.verificationEndpoint}');
    var request = MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    request.fields['verify_data_phone'] = phoneNumber;
    request.fields['verify_data_id_card'] = json.encode({
      'path': idCard.path,
      'name': idCard.name,
      'size': idCard.size,
      'file_type': idCard.fileType,
      'file_extension': idCard.fileExtension,
      'download': idCard.downloadUrl,
    });

    for (var license in tradeLicenses) {
      request.fields['verify_data_trade_license[]'] = json.encode({
        'path': license.path,
        'name': license.name,
        'size': license.size,
        'file_type': license.fileType,
        'file_extension': license.fileExtension,
        'download': license.downloadUrl,
      });
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      log('Verification Submission Response: $jsonResponse');
      // Handle successful response
      notifyListeners();
      return true;
    } else {
      log('Failed to submit verification. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      return false;
    }
  }

  // Handle error
  Future<Map<String, dynamic>?> checkHotelAvailability({
    required String hotelId,
    required DateTime startDate,
    required DateTime endDate,
    required int adults,
    required int children,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'hotel_id': hotelId,
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
      'adults': adults.toString(),
      'children': children.toString(),
    };

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.hotelAvailabilityEndPoint}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Hotel Availability Response: ${result['data']}");
      return result['data'];
    } else {
      log("Failed to check hotel availability. Error: ${result['message']}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendEnquiry({
    required String serviceId,
    required String serviceType,
    required String name,
    required String email,
    required String phone,
    required String note,
  }) async {
    await loadToken();

    final body = {
      'service_id': serviceId,
      'service_type': serviceType,
      'enquiry_name': name,
      'enquiry_email': email,
      'enquiry_phone': phone,
      'enquiry_note': note,
    };

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.sendEnquiry}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Enquiry sent successfully: ${result['data']}");
      return result['data'];
    } else {
      log("Failed to send enquiry. Error: ${result['message']}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> leaveReview({
    required String reviewTitle,
    required String reviewContent,
    required Map<String, int> reviewStats,
    required String serviceId,
    required String serviceType,
    required BuildContext context,
  }) async {
    await loadToken();

    final body = {
      'review_title': reviewTitle,
      'review_content': reviewContent,
      'review_service_id': serviceId,
      'review_service_type': serviceType,
      'submit': 'Leave a Review',
    };

    // Add review stats to the body
    reviewStats.forEach((key, value) {
      body['review_stats[$key]'] = value.toString();
    });

    log("$body bodycheck");
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

      await fetchCarDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warning: ${result['message']}')),
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> leaveReviewForCar({
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
      await fetchCarDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("${result} result error");
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCartForHotel({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    required DateTime endDate,
    List<ExtraPriceHotel>? extraPrices,
    required int adults,
    required int children,
    required List<Map<String, dynamic>> rooms,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': serviceType,
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
      'adults': adults.toString(),
      'children': children.toString(),
    };

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

    for (int i = 0; i < rooms.length; i++) {
      body['rooms[$i][id]'] = rooms[i]['id'].toString();
      body['rooms[$i][number_selected]'] =
          rooms[i]['number_selected'].toString();
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
      // log("Failed to add to cart. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCartForCar({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    required DateTime endDate,
    List<ExtraPriceCar>? extraPrices,
    required int number,
  }) async {
    await loadToken();

    log(serviceId);
    log(serviceType);
    log("$startDate");
    log("$endDate");
    log("$number");
    log("${extraPrices?.length}");

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': "car",
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
      'number': number.toString(),
    };

    for (int i = 0; i < (extraPrices ?? []).length; i++) {
      body['extra_price[$i][name]'] = extraPrices?[i].name ?? "";
      body['extra_price[$i][price]'] = extraPrices?[i].price ?? "";
      body['extra_price[$i][type]'] = extraPrices?[i].type ?? "";
      body['extra_price[$i][number]'] = "0";
      body['extra_price[$i][enable]'] =
          extraPrices?[i].valueType == true ? "1" : "0";
      body['extra_price[$i][price_type]'] = '';
    }

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.addToCart}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("${result['data']["message"]}",
          maskType: EasyLoadingMaskType.black);
      log("Add to Cart Response: ${result['data']}");
      return result['data'];
    } else {
      EasyLoading.showToast("${result['message']}",
          maskType: EasyLoadingMaskType.black);
      // log("Failed to add to cart. Error: ${result['message']}");
      return null;
    }
  }

  Future<BookingResponse?> fetchBookingDetails(String bookingCode) async {
    await loadToken();

    log("Fetching Booking Details for code: $bookingCode");

    try {
      final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.hotelbookingdetails}?booking_code=$bookingCode',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );
      // log("Full API Response: $result");
      if (result['success'] == true) {
        log("Booking Details Response: ${result['data']}");
        bookingResponse = BookingResponse.fromJson(result['data']);
        log("message: $bookingResponse");
        notifyListeners();
      } else {
        log("Failed to fetch booking details. Error: ${result['message'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e, stacktrace) {
      log("Exception occurred: $e\nStacktrace: $stacktrace");
      return null;
    }
    return null;
  }

  Future fetchCountries() async {
    await loadToken();

    try {
      final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.countryList}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );
      // log("Full API Response: $result");
      if (result['success'] == true) {
        log("Country Details Response: ${result['data']}");
        countryResponse = CountryResponse.fromJson(result['data']);
        log("message: $bookingResponse");
        notifyListeners();
      } else {
        log("Failed to fetch booking details. Error: ${result['message'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e, stacktrace) {
      log("Exception occurred: $e\nStacktrace: $stacktrace");
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkout({
    required String code,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    required String customerNotes,
    required String paymentGateway,
    required String termConditions,
    required String couponCode,
    required String credit,
  }) async {
    log("Checkout API Call ===>");
    await loadToken();

    // Request body
    final Map<String, String> body = {
      'code': code,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'customer_notes': customerNotes,
      'payment_gateway': paymentGateway,
      'term_conditions': termConditions,
      'coupon_code': couponCode.isEmpty ? '' : couponCode,
      'credit': credit,
    };

    log("Checkout Body: $body");

    try {
      final result = await makeMultipartRequest(
        '${ApiUrls.baseUrl}${ApiUrls.hotelcheckout}',
        'POST',
        body,
        _token ?? '',
        requiresAuth: true,
      );
      log("token: $_token");
      log("API Response: $result");

      if (result['success']) {
        log("Checkout successful: ${result['data']}");
        return result['data'];
      } else {
        log("Checkout failed. Error: ${result['message']}");
        return null;
      }
    } catch (e) {
      log("An exception occurred: $e");
      return null;
    }
  }

  Future<Bookinghistory?> fetchBookingHistory() async {
    try {
      log("Fetching Booking History ===>");
      await loadToken();

      final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.bookinghistoryendpoint}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );

      if (result['success']) {
        log("Booking History Response: ${result['data']}");
        bookingHistoryResponse = Bookinghistory.fromJson(result['data']);
        notifyListeners();
      } else {
        log("Failed to fetch booking history. Error: ${result['message']}");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> downloadInvoice(String bookingCode) async {
    await loadToken();

    final url =
        '${ApiUrls.baseUrl}${ApiUrls.downloadInvoice}?booking_code=$bookingCode';

    try {
      final result = await makeRequest(
        url,
        'GET',
        {},
        _token ?? '',
        requiresAuth: true,
      );

      if (result['success']) {
        log("Download invoice response: ${result['data']['url']}");
        // Extract the URL from the response data structure
        final invoiceUrl = result['data']
            ['url']; // Adjust this based on your actual API response structure
        if (await canLaunchUrl(Uri.parse(invoiceUrl))) {
          log("Invoice URL: $invoiceUrl");
          await launchUrl(Uri.parse(invoiceUrl),
              mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch invoice URL';
        }
      } else {
        log("Failed to download invoice. Error: ${result['message']}");
      }
    } catch (e) {
      log("Error downloading invoice: $e");
      rethrow;
    }
  }

  Future<bool> applyCoupon(
      String bookingCode, String couponCode, BuildContext context) async {
    await loadToken();

    final url = '${ApiUrls.baseUrl}${ApiUrls.applyCoupon}/$bookingCode';

    try {
      final body = {
        'coupon_code': couponCode,
      };

      final result = await makeMultipartRequest(
        url,
        'POST',
        body,
        _token ?? '',
        requiresAuth: true,
      );

      if (result['success']) {
        fetchBookingDetails(bookingCode);
        log("Coupon applied successfully: ${result['data']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result['data']['message']}')),
        );
        return true;
      } else {
        log("Failed to apply coupon. Error: ${result['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result['message']}')),
        );
        return false;
      }
    } catch (e) {
      log("Error applying coupon: $e");
      return false;
    }
  }

  Future<bool> removeCoupon(
      String bookingCode, String couponCode, BuildContext context) async {
    await loadToken();

    final url = '${ApiUrls.baseUrl}${ApiUrls.removeCoupon}/$bookingCode';

    try {
      final body = {
        'coupon_code': couponCode,
      };

      final result = await makeMultipartRequest(
        url,
        'POST',
        body,
        _token ?? '',
        requiresAuth: true,
      );

      if (result['success']) {
        fetchBookingDetails(bookingCode);
        log("Coupon removed successfully: ${result['data']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result['data']['message']}')),
        );
        return true;
      } else {
        log("Failed to remove coupon. Error: ${result['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result['message']}')),
        );
        return false;
      }
    } catch (e) {
      log("Error removing coupon: $e");
      return false;
    }
  }

  Future UserCreditbalance() async {
    log("Fetching User credit Details for ID: ${ApiUrls.baseUrl}${ApiUrls.usercreditbalance}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.usercreditbalance}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("User Credit Details Response: ${result['data']}");
      creditbalance = CreditBalanceModel.fromJson(result['data']);
      creditbalances = creditbalance;
      notifyListeners();
    } else {
      log("Failed to fetch user credit details. Error: ${result['message']}");

      return null;
    }
  }

  Future fetchVendorCoupons() async {
    log("Fetching User credit Details for ID: ${ApiUrls.baseUrl}${ApiUrls.getManageCoupon}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getManageCoupon}', 'GET', {}, _token ?? '',
        requiresAuth: true);
    CouponResponse? txxxcouponResponseList;

    log("${result['success']} success check");
    if (result['success']) {
      log("User Credit Details Response: ${result['data']}");
      txxxcouponResponseList = CouponResponse.fromJson(result['data']);
      couponResponseList = txxxcouponResponseList;
      notifyListeners();
    } else {
      log("Failed to fetch user credit details. Error: ${result['message']}");

      return null;
    }
  }

  Future<bool> deleteVendorCoupon(String couponId) async {
    log("Deleting Vendor Coupon with ID: $couponId");
    await loadToken();

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.deleteManageCoupon}',
      'POST',
      {'coupon_id': couponId},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast('${result['data']['message']}');
      notifyListeners();
      return true;
    } else {
      EasyLoading.showToast('${result['data']['message']}');
      return false;
    }
  }

  Future fetchVendorServices() async {
    log("Fetching Vendor Services");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorService}', 'GET', {}, _token ?? '',
        requiresAuth: true);
    ManageService? txmanageServiceResponse;

    if (result['success']) {
      log("Vendor Services Response: ${result['data']}");
      txmanageServiceResponse = ManageService.fromJson(result['data']);
      manageServiceResponse = txmanageServiceResponse;
      notifyListeners();
    } else {
      log("Failed to fetch vendor services. Error: ${result['message']}");

      return null;
    }
  }

  Future<bool> addVendorCoupon({
    required String code,
    required String name,
    required String amount,
    required String discountType,
    required String endDate,
    required String minTotal,
    required String maxTotal,
    required String services,
    required String quantityLimit,
    required String limitPerUser,
    required String status,
    required File image,
  }) async {
    log(endDate);
    await loadToken();

    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiUrls.baseUrl}${ApiUrls.addVendorService}'));
    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['code'] = code;
    request.fields['name'] = name;
    request.fields['amount'] = amount;
    request.fields['discount_type'] = discountType;
    request.fields['end_date'] = endDate;
    request.fields['min_total'] = minTotal;
    request.fields['max_total'] = maxTotal;
    request.fields['services'] = services;
    request.fields['quantity_limit'] = quantityLimit;
    request.fields['limit_per_user'] = limitPerUser;
    request.fields['status'] = status;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    if (response.statusCode == 200) {
      log("Vendor Coupon added successfully: $responseData");

      EasyLoading.showToast('Coupon added successfully');
      notifyListeners();
      return true;
    } else {
      log("Failed to add vendor coupon. Error: ${responseData['message']}");
      EasyLoading.showToast("${responseData['message']}",
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<bool> editVendorCoupon({
    required String id,
    required String code,
    required String name,
    required String amount,
    required String discountType,
    required String endDate,
    required String minTotal,
    required String maxTotal,
    required String services,
    required String quantityLimit,
    required String limitPerUser,
    required String status,
    File? image,
  }) async {
    log(endDate);
    await loadToken();

    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiUrls.baseUrl}${ApiUrls.editVendorService}'));
    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['coupon_id'] = id;
    request.fields['code'] = code;
    request.fields['name'] = name;
    request.fields['amount'] = amount;
    request.fields['discount_type'] = discountType;
    request.fields['end_date'] = endDate;
    request.fields['min_total'] = minTotal;
    request.fields['max_total'] = maxTotal;
    request.fields['services'] = services;
    request.fields['quantity_limit'] = quantityLimit;
    request.fields['limit_per_user'] = limitPerUser;
    request.fields['status'] = status;
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    if (response.statusCode == 200) {
      log("Vendor Coupon Update successfully: $responseData");

      EasyLoading.showToast('Coupon Update successfully');
      notifyListeners();
      return true;
    } else {
      log("Failed to add vendor coupon. Error: ${responseData['message']}");
      EasyLoading.showToast("${responseData['message']}",
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<void> saveFcmToken({
    required String fcmToken,
    required String platform,
  }) async {
    await loadToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}save-fcm-token'),
    );

    log('fcm token $fcmToken');

    request.fields.addAll({
      'fcm_token': fcmToken,
      'platform': 'android',
    });

    if (_token != null) {
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });
    }

    http.StreamedResponse response = await request.send();
    log('fcm token ${response.statusCode}');

    if (response.statusCode == 200) {
      log("fcm token ${await response.stream.bytesToString()}");
    } else {
      log("fcm token ${response.reasonPhrase ?? 'Unknown error'}");
    }
  }
}
