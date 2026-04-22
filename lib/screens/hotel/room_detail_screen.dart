// ignore_for_file: unnecessary_const, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_local_variable, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/data_models/room_detail_screen_data.dart' as rd;
import 'package:moonbnd/modals/hotel_detail_model.dart';
import 'package:moonbnd/modals/hotel_room_model.dart' hide Room;
import 'package:moonbnd/modals/hotel_search_model.dart';
import 'package:moonbnd/modals/room_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';

import 'package:moonbnd/widgets/popup_login.dart';
import 'package:moonbnd/widgets/room_widget.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moonbnd/screens/hotel/hotel_checkout_screen.dart';
import 'package:moonbnd/modals/hotel_room_model.dart' as hotel_room;
import 'package:moonbnd/modals/room_model.dart' as model_room;
import 'package:moonbnd/Provider/search_hotel_provider.dart';
import 'package:moonbnd/Provider/currency_provider.dart';
import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../constants.dart';
import '../../modals/hotel_list_model.dart';

class RoomDetailScreen extends StatefulWidget {
  final String hotelId;
  final String? provider;
  final Room? room;
  final Hotel? hotelData;
  final HotelModel?
      searchData; // Search API data — when provided, no detail API call is made
  final Map<String, dynamic>?
      roomsApiResponse; // New API response from /api/hotels/rooms

  RoomDetailScreen(
      {super.key,
      required this.hotelId,
      this.provider,
      this.room,
      this.hotelData,
      this.searchData,
      this.roomsApiResponse});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with TickerProviderStateMixin {
  int currentPage = 0;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  RoomResponse? roomResponse;
  String selectedGuests = "1 ${'adults'.tr}, 0 ${'children'.tr}";
  int adultsCount = 1;
  int childrenCount = 0;
  bool loading = false;
  // Add this new variable
  int total = 0;
  int extraPrice = 0;
  // Add this variable to track selected rooms
  Map<int, int> selectedRooms = {};

  // Add this variable with other class variables
  double bookingFee = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _bookingKey = GlobalKey();
  bool checkingAvailability = false;

  // Track children ages
  List<int> _childrenAges = [];

  /// Whether we are using search data directly (no detail API call)
  bool get _useSearchData => widget.searchData != null;

  /// HotelDetail converted from search data (used when _useSearchData is true)
  HotelDetail? _searchConvertedDetail;

  /// Rooms parsed from roomsApiResponse (when API response is provided)
  List<HotelRoomModel> _apiParsedRooms = [];

  /// Debug log all search data fields to verify API→UI mapping
  void _debugLogSearchData(HotelModel model) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('🏨 [RoomDetailScreen] SEARCH DATA DEBUG LOG');
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('Hotel ID        : ${model.id}');
    debugPrint('DB Hotel ID     : ${model.dbHotelId}');
    debugPrint('Provider        : ${model.provider}');
    debugPrint('Name            : ${model.name}');
    debugPrint('Slug            : ${model.slug}');
    debugPrint(
        'Star Rating     : ${model.starRating} (type: ${model.starRating.runtimeType})');
    debugPrint('City            : ${model.city}');
    debugPrint('Country         : ${model.country}');
    debugPrint('Address         : ${model.address}');
    debugPrint(
        'Description     : ${(model.description ?? '').length > 80 ? '${model.description!.substring(0, 80)}...' : model.description}');
    debugPrint('Short Desc      : ${model.shortDescription}');
    debugPrint('Check-in Time   : ${model.checkInTime}');
    debugPrint('Check-out Time  : ${model.checkOutTime}');
    debugPrint(
        'Latitude        : ${model.latitude} (type: ${model.latitude.runtimeType})');
    debugPrint(
        'Longitude       : ${model.longitude} (type: ${model.longitude.runtimeType})');
    debugPrint(
        'Lowest Price    : ${model.lowestPrice} (type: ${model.lowestPrice.runtimeType})');
    debugPrint('Currency        : ${model.currency}');
    debugPrint('Badge           : ${model.badge}');
    debugPrint('API Source      : ${model.apiSource}');
    debugPrint('Images count    : ${model.images.length}');
    for (var i = 0; i < model.images.length; i++) {
      debugPrint('  Image[$i]      : ${model.images[i]}');
    }
    debugPrint('Amenities count : ${model.amenities.length}');
    for (var a in model.amenities) {
      debugPrint('  Amenity        : $a');
    }
    debugPrint('Services count  : ${model.services.length}');
    for (var s in model.services) {
      debugPrint('  Service        : $s');
    }
    debugPrint('Rooms count     : ${model.rooms.length}');
    for (var i = 0; i < model.rooms.length; i++) {
      final r = model.rooms[i];
      debugPrint('  ────── Room[$i] ──────');
      debugPrint('  Room ID        : ${r.id}');
      debugPrint('  Room Name      : ${r.name}');
      debugPrint('  Room Type      : ${r.roomType}');
      debugPrint('  Bed Config     : ${r.bedConfiguration}');
      debugPrint('  Max Adults     : ${r.maxAdults}');
      debugPrint('  Max Children   : ${r.maxChildren}');
      debugPrint(
          '  Base Price     : ${r.basePrice} (type: ${r.basePrice.runtimeType})');
      debugPrint(
          '  Total Price    : ${r.totalPrice} (type: ${r.totalPrice.runtimeType})');
      debugPrint('  Nights         : ${r.nights}');
      debugPrint('  Currency       : ${r.currency}');
      debugPrint('  Available      : ${r.isAvailable}');
      debugPrint('  Size (sqm)     : ${r.sizeSqm}');
      debugPrint('  View Type      : ${r.viewType}');
      debugPrint(
          '  Description    : ${(r.description ?? '').length > 60 ? '${r.description!.substring(0, 60)}...' : r.description}');
      debugPrint('  Images         : ${r.images.length} → ${r.images}');
      debugPrint('  Amenities      : ${r.amenities.length} → ${r.amenities}');
    }
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('🔄 [RoomDetailScreen] CONVERTED HotelDetail:');
    final det = _searchConvertedDetail;
    debugPrint('  detail.data.title    : ${det?.data?.title}');
    debugPrint('  detail.data.address  : ${det?.data?.address}');
    debugPrint(
        '  detail.data.content  : ${(det?.data?.content ?? '').length > 60 ? '${det!.data!.content!.substring(0, 60)}...' : det?.data?.content}');
    debugPrint('  detail.data.image    : ${det?.data?.image}');
    debugPrint('  detail.data.gallery  : ${det?.data?.gallery?.length} images');
    debugPrint('  detail.data.starRate : ${det?.data?.starRate}');
    debugPrint('  detail.data.price    : ${det?.data?.price}');
    debugPrint('  detail.data.mapLat   : ${det?.data?.mapLat}');
    debugPrint('  detail.data.mapLng   : ${det?.data?.mapLng}');
    debugPrint('  detail.data.checkIn  : ${det?.data?.checkInTime}');
    debugPrint('  detail.data.checkOut : ${det?.data?.checkOutTime}');
    debugPrint('  detail.status        : ${det?.status}');
    debugPrint('════════════════════════════════════════════════════════');
  }

  /// Convert HotelModel (search result) to HotelDetail for display compatibility
  HotelDetail _convertSearchData(HotelModel model) {
    final displayPrice = model.convertedLowestPrice ?? model.lowestPrice;
    return HotelDetail(
      data: Data(
        id: int.tryParse(model.id),
        title: model.name ?? '',
        address: model.address ?? '',
        content: model.description ?? model.shortDescription ?? '',
        gallery: model.images.isNotEmpty ? model.images : null,
        image: model.images.isNotEmpty ? model.images.first : null,
        starRate: (model.starRating is num)
            ? (model.starRating as num).toInt()
            : int.tryParse(model.starRating?.toString() ?? ''),
        checkInTime: model.checkInTime,
        checkOutTime: model.checkOutTime,
        mapLat: model.latitude?.toString(),
        mapLng: model.longitude?.toString(),
        price: displayPrice?.toString(),
      ),
      status: 1,
    );
  }

  /// Parse rooms from /api/hotels/rooms response
  /// Expected structure: { "success": true, "data": [...], "message": "..." }
  void _parseRoomsApiResponse(Map<String, dynamic>? response) {
    if (response == null) {
      _apiParsedRooms = [];
      return;
    }

    try {
      debugPrint('🛏️ [RoomDetailScreen] Parsing rooms API response...');
      _apiParsedRooms = [];

      final data = response['data'];
      if (data == null || data is! List) {
        debugPrint('⚠️ Rooms API data is not a list or missing');
        return;
      }

      for (final roomData in data) {
        try {
          // Parse bed_configuration safely
          final bedConfig = _parseBedConfiguration(
              roomData['bed_type'] ?? roomData['bed_configuration']);

          // Parse is_available safely
          final isAvailable = _parseBoolValue(roomData['is_available']);

          final room = HotelRoomModel(
            id: (roomData['id'] ?? 'unknown').toString(),
            name: roomData['title'] ?? roomData['name'] ?? 'Room',
            roomType: roomData['room_type'] ?? '',
            bedConfiguration: bedConfig,
            maxAdults: _parseIntValue(roomData['max_adults']),
            maxChildren: _parseIntValue(roomData['max_children']),
            basePrice: roomData['base_price'] ?? roomData['price'],
            totalPrice:
                roomData['converted_total_price'] ?? roomData['total_price'],
            nights: _parseIntValue(roomData['nights']) ?? 1,
            currency: roomData['currency'] ?? '',
            convertedCurrency:
                roomData['converted_currency'] ?? roomData['currency'] ?? '',
            convertedBasePrice: roomData['converted_base_price'],
            convertedTotalPrice: roomData['converted_total_price'],
            isAvailable: isAvailable,
            sizeSqm: _parseIntValue(roomData['size'] ?? roomData['size_sqm']),
            viewType: roomData['view'] ?? roomData['view_type'],
            description: roomData['description'] ?? '',
            images: _parseImages(roomData['image'] ?? roomData['images']),
            amenities: _parseAmenities(roomData['amenities']),
          );
          _apiParsedRooms.add(room);
          debugPrint(
              '✅ Parsed room: ${room.name} (Available: ${room.isAvailable})');
        } catch (e) {
          debugPrint('❌ Error parsing room: $e');
        }
      }
      debugPrint(
          '✅ Successfully parsed ${_apiParsedRooms.length} rooms from API response');
    } catch (e) {
      debugPrint('❌ Error parsing rooms API response: $e');
      _apiParsedRooms = [];
    }
  }

  /// Helper to parse bed configuration from API response
  Map<String, dynamic> _parseBedConfiguration(dynamic raw) {
    try {
      if (raw == null) return {};
      if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is Map<String, dynamic>) return first;
        if (first is String) {
          final decoded = jsonDecode(first);
          if (decoded is Map<String, dynamic>) return decoded;
        }
      }
      return {};
    } catch (e) {
      debugPrint('⚠️ Error parsing bedConfiguration: $e');
      return {};
    }
  }

  /// Helper to parse bool values safely
  bool _parseBoolValue(dynamic value) {
    if (value == null) return true; // Default to true (available)
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return true;
  }

  /// Helper to parse int values safely
  int? _parseIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Helper to parse image URLs from API response
  List<String> _parseImages(dynamic imageData) {
    if (imageData == null) return [];
    if (imageData is String) return [imageData];
    if (imageData is List) {
      return imageData
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Helper to parse amenities from API response
  List<String> _parseAmenities(dynamic amenitiesData) {
    if (amenitiesData == null) return [];
    if (amenitiesData is List) {
      return amenitiesData
          .map((e) {
            if (e is String) return e;
            if (e is Map && e.containsKey('name')) return e['name'].toString();
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();

    // Attempt to pull dates and guest counts from SearchHotelProvider if not already set
    final searchProvider =
        Provider.of<SearchHotelProvider>(context, listen: false);
    if (checkInDate == null && searchProvider.lastCheckIn != null) {
      checkInDate = searchProvider.lastCheckIn;
    }
    if (checkOutDate == null && searchProvider.lastCheckOut != null) {
      checkOutDate = searchProvider.lastCheckOut;
    }

    // Initialize guest defaults from search if available
    adultsCount = searchProvider.lastAdults > 0 ? searchProvider.lastAdults : 1;
    childrenCount = searchProvider.lastChildren;
    selectedGuests =
        "$adultsCount ${'adults'.tr}, $childrenCount ${'children'.tr}";

    if (_useSearchData) {
      // No API call needed — data comes from search response
      _searchConvertedDetail = _convertSearchData(widget.searchData!);
      _debugLogSearchData(widget.searchData!);

      // If roomsApiResponse is provided, parse it (it has priority over searchData rooms)
      if (widget.roomsApiResponse != null) {
        _parseRoomsApiResponse(widget.roomsApiResponse);
      }

      loading = false;
    } else {
      loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHotelDetails();
      });
    }
  }

  Future<void> _loadHotelDetails() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final currency =
        Provider.of<CurrencyProvider>(context, listen: false).selectedCurrency;
    final detail = await homeProvider.fetchHotelDetails(widget.hotelId,
        provider: widget.provider, currency: currency);

    if (!mounted) return;
    setState(() {
      loading = false;
      // Safely extract booking fee
      final fee = detail?.data?.bookingFee?.firstWhere(
        (fee) => fee.name == "Service fee",
        orElse: () => BookingFee(name: "Service fee".tr, price: "0"),
      );
      bookingFee = double.tryParse(fee?.price ?? "0") ?? 0;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = DateTime.now();

    // If checking out, use check-in date + 1 day as initial date if check-in is selected
    if (!isCheckIn && checkInDate != null) {
      initialDate = checkInDate!.add(Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? DateTime.now() : checkInDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = pickedDate;
          // Reset checkout date if it's before the new check-in date
          if (checkOutDate != null && checkOutDate!.isBefore(pickedDate)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = pickedDate;
        }
      });
    }
  }

  Future<void> _checkAvailability() async {
    // Parse adults and children from selectedGuests
    final adults = int.parse(selectedGuests.split(',')[0].split(' ')[0]);
    final children = int.parse(selectedGuests.split(',')[1].split(' ')[1]);

    // Check if both adults and children are 0
    if (adults == 0 && children == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one guest'.tr)),
      );
      return;
    }

    if (checkInDate == null || checkOutDate == null) {
      // Show an error message if dates are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select check-in and check-out dates'.tr)),
      );
      return;
    }

    setState(() {
      checkingAvailability = true;
    });

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final result = await homeProvider.checkHotelAvailability(
      hotelId: widget.hotelId,
      startDate: checkInDate!,
      endDate: checkOutDate!,
      adults: adults,
      children: children,
    );

    if (!mounted) return;
    setState(() {
      checkingAvailability = false;
    });

    if (result != null) {
      setState(() {
        roomResponse = RoomResponse.fromJson(result);
        selectedRooms = {for (var room in roomResponse!.rooms) room.id: 0};
      });
      if (roomResponse!.rooms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No rooms available'.tr)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Availability checked successfully'.tr)),
        );
      }
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check availability'.tr)),
      );
    }
  }

  /// Primary CTA handler - checks availability and loads rooms
  Future<void> _handleReserveNow() async {
    // First, check availability
    await _checkAvailability();
  }

  void _showGuestBottomSheet() {
    final guestParts = selectedGuests.split(',');
    final adults =
        int.parse(RegExp(r'\d+').firstMatch(guestParts[0])?.group(0) ?? '1');
    final children =
        int.parse(RegExp(r'\d+').firstMatch(guestParts[1])?.group(0) ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int tempAdult = adults;
        int tempChild = children;
        int tempUnit = 1;
        List<int> tempChildAges = List<int>.from(_childrenAges);

        // Sync tempChildAges with tempChild count
        if (tempChildAges.length < tempChild) {
          while (tempChildAges.length < tempChild) {
            tempChildAges.add(8);
          }
        } else if (tempChildAges.length > tempChild) {
          tempChildAges = tempChildAges.sublist(0, tempChild);
        }

        return StatefulBuilder(
          builder: (context, modalSetState) {
            Widget _guestCounterRow(
              String label,
              String subtitle,
              int count,
              int minVal,
              VoidCallback onDecrement,
              VoidCallback onIncrement,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xff1D2025),
                          ),
                        ),
                        Text(
                          subtitle.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: count > minVal
                              ? () {
                                  modalSetState(() {
                                    count--;
                                    if (label == 'Children') {
                                      tempChild = count;
                                      if (tempChildAges.isNotEmpty) {
                                        tempChildAges.removeLast();
                                      }
                                    } else if (label == 'Adults') {
                                      tempAdult = count;
                                    } else if (label == 'Unit') {
                                      tempUnit = count;
                                    }
                                  });
                                }
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: count > minVal
                                    ? AppColors.primary
                                    : const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: count > minVal
                                  ? AppColors.primary
                                  : const Color(0xffD1D5DB),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xff1D2025),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            modalSetState(() {
                              count++;
                              if (label == 'Children') {
                                tempChild = count;
                                tempChildAges.add(8);
                              } else if (label == 'Adults') {
                                tempAdult = count;
                              } else if (label == 'Unit') {
                                tempUnit = count;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            List<Widget> _buildChildAgeRows() {
              if (tempChild == 0) {
                return [];
              }
              return List.generate(
                tempChild,
                (index) {
                  if (index >= tempChildAges.length) {
                    tempChildAges.add(8);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Child ${index + 1} Age'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: const Color(0xff1D2025),
                              ),
                            ),
                            Text(
                              'Years'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: const Color(0xff6B7280),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: tempChildAges[index] > 0
                                  ? () {
                                      modalSetState(() {
                                        tempChildAges[index]--;
                                      });
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: tempChildAges[index] > 0
                                        ? AppColors.primary
                                        : const Color(0xffE5E7EB),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: tempChildAges[index] > 0
                                      ? AppColors.primary
                                      : const Color(0xffD1D5DB),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${tempChildAges[index]}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: const Color(0xff1D2025),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                modalSetState(() {
                                  tempChildAges[index]++;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guests'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xff1D2025),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  _guestCounterRow(
                    'Adults',
                    'Above 12 years',
                    tempAdult,
                    1,
                    () => modalSetState(() => tempAdult--),
                    () => modalSetState(() => tempAdult++),
                  ),
                  const Divider(height: 1),
                  _guestCounterRow(
                    'Children',
                    'Below 12 years',
                    tempChild,
                    0,
                    () {
                      modalSetState(() {
                        if (tempChild > 0) {
                          tempChild--;
                          if (tempChildAges.isNotEmpty) {
                            tempChildAges.removeLast();
                          }
                        }
                      });
                    },
                    () {
                      modalSetState(() {
                        tempChild++;
                        tempChildAges.add(8);
                      });
                    },
                  ),
                  if (tempChild > 0) ...[
                    const Divider(height: 1),
                    ..._buildChildAgeRows(),
                  ],
                  const Divider(height: 1),
                  _guestCounterRow(
                    'Unit',
                    'Rooms',
                    tempUnit,
                    1,
                    () => modalSetState(() => tempUnit--),
                    () => modalSetState(() => tempUnit++),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGuests =
                              "$tempAdult ${'adults'.tr}, $tempChild ${'children'.tr}";
                          adultsCount = tempAdult;
                          childrenCount = tempChild;
                          _childrenAges = tempChildAges;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text('Done'.tr),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Add this method to update selected rooms
  void updateSelectedRooms(int roomId, int quantity) {
    print('Room selected: Room ID $roomId, Quantity $quantity');
    setState(() {
      selectedRooms[roomId] = quantity;
    });
  }

  Future<void> _onRoomSelected(dynamic room) async {
    if (checkInDate == null || checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select check-in and check-out dates'.tr)),
      );
      // Scroll to booking section if dates are missing
      Scrollable.ensureVisible(
        _bookingKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    EasyLoading.show(status: 'Preparing your booking...'.tr);

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Prepare data for prebook
    String roomId = '';
    String roomName = '';
    String offerId = widget.hotelId;
    String provider = widget.provider ?? (widget.searchData?.provider ?? '');

    hotel_room.HotelRoomModel? roomModel;

    if (room is hotel_room.HotelRoomModel) {
      roomModel = room;
      roomId = (room.roomId != null && room.roomId!.isNotEmpty)
          ? room.roomId!
          : room.id;
      offerId = (room.offerId != null && room.offerId!.isNotEmpty)
          ? room.offerId!
          : widget.hotelId;
      roomName = room.name ?? '';
    } else if (room is model_room.Room) {
      roomId = room.id.toString();
      roomName = room.title;
      // Map model_room.Room to hotel_room.HotelRoomModel for Checkout Screen
      roomModel = hotel_room.HotelRoomModel(
        id: room.id.toString(),
        name: room.title,
        totalPrice: room.price,
        currency: widget.searchData?.convertedCurrency ??
            widget.searchData?.currency ??
            'USD',
        images: [room.image],
        maxAdults: room.maxAdults,
        maxChildren: room.maxChildren,
      );
    }

    if (roomModel == null) {
      EasyLoading.dismiss();
      return;
    }

    final hotelData =
        _useSearchData ? widget.searchData : homeProvider.hotelDetail?.data;
    final hName =
        hotelData is HotelModel ? hotelData.name : (hotelData as Data?)?.title;
    final hCity = hotelData is HotelModel
        ? hotelData.city
        : (hotelData as Data?)?.address;
    final hCountry = hotelData is HotelModel ? hotelData.country : '';

    try {
      final response = await homeProvider.preBookHotel(
        offerId: offerId,
        roomId: roomId,
        checkIn: DateFormat('yyyy-MM-dd').format(checkInDate!),
        checkOut: DateFormat('yyyy-MM-dd').format(checkOutDate!),
        adults: adultsCount,
        provider: provider,
        hotelName: hName ?? '',
        roomName: roomName,
        city: hCity ?? '',
        country: hCountry ?? '',
      );

      EasyLoading.dismiss();

      if (response != null && response.success == true) {
        final hotelDetailObj = _useSearchData
            ? _searchConvertedDetail!
            : homeProvider.hotelDetail!;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelCheckoutScreen(
              hotel: hotelDetailObj,
              room: roomModel!,
              checkIn: checkInDate!,
              checkOut: checkOutDate!,
              adults: adultsCount,
              children: childrenCount,
              prebookResponse: response,
              city: widget.searchData?.city,
              country: widget.searchData?.country,
            ),
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      log("Error in _onRoomSelected: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.'.tr)),
      );
    }
  }

  /// Map amenity name to a suitable icon
  IconData _amenityIcon(String amenity) {
    final a = amenity.toLowerCase();
    if (a.contains('wifi') || a.contains('wi-fi')) return Icons.wifi;
    if (a.contains('pool') || a.contains('swimming')) return Icons.pool;
    if (a.contains('restaurant') || a.contains('dining'))
      return Icons.restaurant_menu;
    if (a.contains('spa') || a.contains('wellness')) return Icons.spa;
    if (a.contains('gym') || a.contains('fitness')) return Icons.fitness_center;
    if (a.contains('parking')) return Icons.local_parking;
    if (a.contains('bar')) return Icons.local_bar;
    if (a.contains('breakfast')) return Icons.free_breakfast;
    if (a.contains('shuttle') || a.contains('metro') || a.contains('transport'))
      return Icons.directions_bus;
    if (a.contains('water sport')) return Icons.surfing;
    if (a.contains('room service') || a.contains('الخدمة'))
      return Icons.room_service;
    return Icons.check_circle_outline;
  }

  Widget _buildAmenityPill(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black87),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Failed to load hotel details'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'.tr),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                    ),
                    onPressed: _loadHotelDetails,
                    child: Text('Retry'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Hotel details not available'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRoomCard(HotelRoomModel room) {
    final price = room.convertedTotalPrice ??
        room.convertedBasePrice ??
        room.totalPrice ??
        room.basePrice;
    final priceStr = price != null
        ? double.tryParse(price.toString())?.toStringAsFixed(2) ?? '0.00'
        : '0.00';
    final currency = room.convertedCurrency?.isNotEmpty == true
        ? room.convertedCurrency!
        : (room.currency ??
            widget.searchData?.convertedCurrency ??
            widget.searchData?.currency ??
            'USD');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Name & Type
          Text(
            room.name ?? 'Room'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: kPrimaryColor,
            ),
          ),
          if (room.roomType != null && room.roomType!.isNotEmpty)
            Text(
              room.roomType!,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 12),

          // Details Row (Icons)
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _roomDetailChip(
                  Icons.person_outline, "Max ${room.maxAdults ?? 0} Adults"),
              _roomDetailChip(Icons.child_care_outlined,
                  "Max ${room.maxChildren ?? 0} Children"),
              if (room.sizeSqm != null)
                _roomDetailChip(
                    Icons.square_foot_outlined, '${room.sizeSqm} sqm'),
              if (room.viewType != null && room.viewType!.isNotEmpty)
                _roomDetailChip(Icons.landscape_outlined, room.viewType!),
            ],
          ),
          const SizedBox(height: 12),

          // Description (Truncated)
          if (room.description != null && room.description!.isNotEmpty)
            Text(
              room.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: const Color(0xFF65758B),
                height: 1.5,
              ),
            ),

          const SizedBox(height: 12),

          // Bed configuration if available in a readable way
          if (room.bedConfiguration.isNotEmpty)
            Text(
              room.bedConfiguration.entries
                  .map((e) => "${e.value}x ${e.key}")
                  .join(", "),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xffF1F5F9)),
          ),

          // Price and Select Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.isAvailable ? 'Available'.tr : 'Not Available'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: room.isAvailable ? AppColors.secondary : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryColor,
                      ),
                      children: [
                        TextSpan(text: "$currency $priceStr"),
                        if (room.nights != null)
                          TextSpan(
                            text: " / ${room.nights} nights",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _onRoomSelected(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Select",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomShimmer() {
    return Column(
      children: List.generate(
          2,
          (index) => Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator()),
              )),
    );
  }

  Widget _buildEmptyRoomsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.hotel_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No rooms available for selected dates".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomDetailChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<HomeProvider>(context, listen: true);

    // Unified detail: search-converted data takes priority, then provider detail
    final detail = _useSearchData ? _searchConvertedDetail : item.hotelDetail;
    final detailError = _useSearchData ? null : item.hotelDetailError;
    final hasData = detail?.data != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          detail?.data?.title ?? '',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : detailError != null
              ? _buildErrorState(detailError)
              : !hasData
                  ? _buildEmptyState()
                  : SafeArea(
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //appbar + haven slider
                                // This replaces the entire previous Stack(children: [...]) structure
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ─────────────────────────────────────
                                        // 1. IMAGE SLIDER — full width, no padding
                                        // ─────────────────────────────────────
                                        Builder(builder: (context) {
                                          final gallery = _useSearchData
                                              ? (widget.searchData?.images ??
                                                  [])
                                              : (detail?.data?.gallery ?? []);
                                          if (gallery.isEmpty) {
                                            return Container(
                                              height: 260,
                                              width: double.infinity,
                                              color: const Color(0xFFE3F2FD),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.hotel,
                                                      size: 64,
                                                      color: Color(0xFF90CAF9)),
                                                  const SizedBox(height: 8),
                                                  Text('No Image'.tr,
                                                      style: GoogleFonts
                                                          .spaceGrotesk(
                                                              color: const Color(
                                                                  0xFF90CAF9),
                                                              fontSize: 14)),
                                                ],
                                              ),
                                            );
                                          }
                                          return ClipRRect(
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  height: 260,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: PageView.builder(
                                                    onPageChanged: (value) =>
                                                        setState(() =>
                                                            currentPage =
                                                                value),
                                                    itemCount: gallery.length,
                                                    itemBuilder: (context,
                                                            index) =>
                                                        SliderContent(
                                                            imageUrl:
                                                                gallery[index]),
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 12,
                                                  right: 12,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.black),
                                                    child: Text(
                                                      '${currentPage + 1} / ${gallery.length}',
                                                      style: GoogleFonts
                                                          .spaceGrotesk(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),

                                        // ─────────────────────────────────────
                                        // 2. CONTENT BELOW IMAGE
                                        // ─────────────────────────────────────
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Hotel name
                                              Text(
                                                detail?.data?.title ?? ''.tr,
                                                style: GoogleFonts.spaceGrotesk(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 22,
                                                    color: Colors.black),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),

                                              // Star rating
                                              Builder(builder: (context) {
                                                final stars = (_useSearchData
                                                        ? ((widget.searchData
                                                                        ?.starRating
                                                                    as num?)
                                                                ?.toInt() ??
                                                            0)
                                                        : (detail?.data
                                                                ?.starRate ??
                                                            0))
                                                    .clamp(0, 5);
                                                if (stars == 0)
                                                  return const SizedBox
                                                      .shrink();
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Row(
                                                    children: List.generate(
                                                        stars,
                                                        (_) => const Icon(
                                                            Icons.star_rounded,
                                                            color: AppColors.accent,
                                                            size: 18)),
                                                  ),
                                                );
                                              }),

                                              // Location
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                      Icons.location_on_rounded,
                                                      color: Colors.black54,
                                                      size: 18),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      _useSearchData
                                                          ? [
                                                              detail?.data
                                                                      ?.address ??
                                                                  '',
                                                              if (widget.searchData
                                                                          ?.city !=
                                                                      null &&
                                                                  widget
                                                                      .searchData!
                                                                      .city!
                                                                      .isNotEmpty)
                                                                widget
                                                                    .searchData!
                                                                    .city!,
                                                              if (widget.searchData
                                                                          ?.country !=
                                                                      null &&
                                                                  widget
                                                                      .searchData!
                                                                      .country!
                                                                      .isNotEmpty)
                                                                widget
                                                                    .searchData!
                                                                    .country!,
                                                            ]
                                                              .where((s) =>
                                                                  s.isNotEmpty)
                                                              .toSet()
                                                              .join(', ')
                                                          : (detail?.data
                                                                      ?.address ??
                                                                  '')
                                                              .tr,
                                                      style: GoogleFonts
                                                          .spaceGrotesk(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black54),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Check-in / Check-out time
                                              Builder(builder: (context) {
                                                final checkIn = _useSearchData
                                                    ? (widget.searchData
                                                            ?.checkInTime ??
                                                        '')
                                                    : (detail?.data
                                                            ?.checkInTime ??
                                                        '');
                                                final checkOut = _useSearchData
                                                    ? (widget.searchData
                                                            ?.checkOutTime ??
                                                        '')
                                                    : (detail?.data
                                                            ?.checkOutTime ??
                                                        '');
                                                if (checkIn.isEmpty &&
                                                    checkOut.isEmpty)
                                                  return const SizedBox
                                                      .shrink();
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .access_time_rounded,
                                                          color: Colors.black54,
                                                          size: 18),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          '$checkIn – $checkOut',
                                                          style: GoogleFonts
                                                              .spaceGrotesk(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black54)),
                                                    ],
                                                  ),
                                                );
                                              }),

                                              // Amenity pills
                                              if (_useSearchData &&
                                                  widget.searchData!.amenities
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 12),
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: widget
                                                        .searchData!.amenities
                                                        .take(4)
                                                        .map((a) =>
                                                            _buildAmenityPill(
                                                                a,
                                                                _amenityIcon(
                                                                    a)))
                                                        .toList(),
                                                  ),
                                                )
                                              else if (!_useSearchData)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 12),
                                                  child: Row(
                                                    children: [
                                                      _buildAmenityPill(
                                                          'Wifi', Icons.wifi),
                                                      const SizedBox(width: 8),
                                                      _buildAmenityPill(
                                                          'Pool', Icons.pool),
                                                      const SizedBox(width: 8),
                                                      _buildAmenityPill(
                                                          'Restaurant',
                                                          Icons
                                                              .restaurant_menu),
                                                    ],
                                                  ),
                                                ),

                                              // Description
                                              ExpandableHtmlContent(
                                                content:
                                                    detail?.data?.content ?? '',
                                                primaryColor: kPrimaryColor,
                                                textStyle:
                                                    GoogleFonts.spaceGrotesk(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        height: 21 / 14,
                                                        letterSpacing: 0,
                                                        color: const Color(
                                                            0xFF65758B)),
                                                readMoreText: 'Read more'.tr,
                                              ),

                                              if (!_useSearchData) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${detail?.data?.reviewScore?.totalReview ?? 0} Reviews"
                                                      .tr,
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 13,
                                                          color: const Color(
                                                              0xFF65758B)),
                                                ),
                                              ],
                                              const SizedBox(height: 12),
                                            ],
                                          ),
                                        ),
                                        // const SizedBox(height: 12),
                                      ],
                                    ),

                                    // Padding(
                                    //   padding: EdgeInsets.symmetric(
                                    //     horizontal: 16.0,
                                    //     vertical: 20.0,
                                    //   ),
                                    //   child: Column(
                                    //     key: _bookingKey,
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       // Section Title: "Book Your Stay"
                                    //       Text(
                                    //         'Book Your Stay'.tr,
                                    //         style: GoogleFonts.spaceGrotesk(
                                    //           fontSize: 22,
                                    //           fontWeight: FontWeight.w700,
                                    //           color: Colors.black,
                                    //         ),
                                    //       ),
                                    //       const SizedBox(height: 6),

                                    //       // Subtitle
                                    //       Text(
                                    //         'Select a room below to see pricing'
                                    //             .tr,
                                    //         style: GoogleFonts.spaceGrotesk(
                                    //           fontSize: 13,
                                    //           fontWeight: FontWeight.w400,
                                    //           color: Colors.grey[600],
                                    //         ),
                                    //       ),
                                    //       const SizedBox(height: 20),

                                    //       // Booking Card
                                    //       Container(
                                    //         decoration: BoxDecoration(
                                    //           color: Colors.white,
                                    //           borderRadius:
                                    //               BorderRadius.circular(12),
                                    //           boxShadow: [
                                    //             BoxShadow(
                                    //               color: Colors.grey
                                    //                   .withOpacity(0.15),
                                    //               spreadRadius: 1,
                                    //               blurRadius: 8,
                                    //             ),
                                    //           ],
                                    //           border: Border.all(
                                    //               color: Colors.grey.shade200),
                                    //         ),
                                    //         child: Column(
                                    //           mainAxisSize: MainAxisSize.min,
                                    //           children: [
                                    //             // Date and Guest Selection Container
                                    //             Padding(
                                    //               padding: const EdgeInsets.all(
                                    //                   16.0),
                                    //               child: Column(
                                    //                 children: [
                                    //                   // Check-in and Check-out in row
                                    //                   Row(
                                    //                     children: [
                                    //                       // Check-in date
                                    //                       Expanded(
                                    //                         child:
                                    //                             GestureDetector(
                                    //                           onTap: () =>
                                    //                               _selectDate(
                                    //                                   context,
                                    //                                   true),
                                    //                           child: Column(
                                    //                             crossAxisAlignment:
                                    //                                 CrossAxisAlignment
                                    //                                     .start,
                                    //                             children: [
                                    //                               Text(
                                    //                                 "Check-in"
                                    //                                     .tr,
                                    //                                 style: GoogleFonts
                                    //                                     .spaceGrotesk(
                                    //                                   fontSize:
                                    //                                       13,
                                    //                                   fontWeight:
                                    //                                       FontWeight
                                    //                                           .w400,
                                    //                                   color: const Color(
                                    //                                       0xff1D2025),
                                    //                                 ),
                                    //                               ),
                                    //                               const SizedBox(
                                    //                                   height:
                                    //                                       6),
                                    //                               Container(
                                    //                                 height: 48,
                                    //                                 padding: const EdgeInsets
                                    //                                     .symmetric(
                                    //                                     horizontal:
                                    //                                         12,
                                    //                                     vertical:
                                    //                                         8),
                                    //                                 decoration:
                                    //                                     BoxDecoration(
                                    //                                   borderRadius:
                                    //                                       BorderRadius.circular(
                                    //                                           8),
                                    //                                   border: Border.all(
                                    //                                       color:
                                    //                                           const Color(0xffE5E7EB)),
                                    //                                   color: Colors
                                    //                                       .white,
                                    //                                 ),
                                    //                                 child: Row(
                                    //                                   children: [
                                    //                                     SvgPicture
                                    //                                         .asset(
                                    //                                       'assets/icons/calendar.svg',
                                    //                                       width:
                                    //                                           16,
                                    //                                       height:
                                    //                                           16,
                                    //                                       color:
                                    //                                           const Color(0xff6B7280),
                                    //                                     ),
                                    //                                     const SizedBox(
                                    //                                         width:
                                    //                                             8),
                                    //                                     Expanded(
                                    //                                       child:
                                    //                                           Text(
                                    //                                         checkInDate != null
                                    //                                             ? '${checkInDate!.day}/${checkInDate!.month}/${checkInDate!.year}'
                                    //                                             : 'dd/mm/yyyy'.tr,
                                    //                                         style:
                                    //                                             GoogleFonts.spaceGrotesk(
                                    //                                           fontSize: 13,
                                    //                                           fontWeight: FontWeight.w500,
                                    //                                           color: checkInDate != null ? const Color(0xff1D2025) : const Color(0xff6B7280),
                                    //                                         ),
                                    //                                       ),
                                    //                                     ),
                                    //                                   ],
                                    //                                 ),
                                    //                               ),
                                    //                             ],
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                       const SizedBox(
                                    //                           width: 10),
                                    //                       // Check-out date
                                    //                       Expanded(
                                    //                         child:
                                    //                             GestureDetector(
                                    //                           onTap: () =>
                                    //                               _selectDate(
                                    //                                   context,
                                    //                                   false),
                                    //                           child: Column(
                                    //                             crossAxisAlignment:
                                    //                                 CrossAxisAlignment
                                    //                                     .start,
                                    //                             children: [
                                    //                               Text(
                                    //                                 "Check-out"
                                    //                                     .tr,
                                    //                                 style: GoogleFonts
                                    //                                     .spaceGrotesk(
                                    //                                   fontSize:
                                    //                                       13,
                                    //                                   fontWeight:
                                    //                                       FontWeight
                                    //                                           .w400,
                                    //                                   color: const Color(
                                    //                                       0xff1D2025),
                                    //                                 ),
                                    //                               ),
                                    //                               const SizedBox(
                                    //                                   height:
                                    //                                       6),
                                    //                               Container(
                                    //                                 height: 48,
                                    //                                 padding: const EdgeInsets
                                    //                                     .symmetric(
                                    //                                     horizontal:
                                    //                                         12,
                                    //                                     vertical:
                                    //                                         8),
                                    //                                 decoration:
                                    //                                     BoxDecoration(
                                    //                                   borderRadius:
                                    //                                       BorderRadius.circular(
                                    //                                           8),
                                    //                                   border: Border.all(
                                    //                                       color:
                                    //                                           const Color(0xffE5E7EB)),
                                    //                                   color: Colors
                                    //                                       .white,
                                    //                                 ),
                                    //                                 child: Row(
                                    //                                   children: [
                                    //                                     SvgPicture
                                    //                                         .asset(
                                    //                                       'assets/icons/calendar.svg',
                                    //                                       width:
                                    //                                           16,
                                    //                                       height:
                                    //                                           16,
                                    //                                       color:
                                    //                                           const Color(0xff6B7280),
                                    //                                     ),
                                    //                                     const SizedBox(
                                    //                                         width:
                                    //                                             8),
                                    //                                     Expanded(
                                    //                                       child:
                                    //                                           Text(
                                    //                                         checkOutDate != null && checkOutDate!.isAfter(checkInDate ?? DateTime.now())
                                    //                                             ? '${checkOutDate!.day}/${checkOutDate!.month}/${checkOutDate!.year}'
                                    //                                             : (checkOutDate != null && checkInDate != null && !checkOutDate!.isAfter(checkInDate!) ? 'Invalid'.tr : 'dd/mm/yyyy'.tr),
                                    //                                         style:
                                    //                                             GoogleFonts.spaceGrotesk(
                                    //                                           fontSize: 13,
                                    //                                           fontWeight: FontWeight.w500,
                                    //                                           color: checkOutDate != null ? (checkOutDate!.isAfter(checkInDate ?? DateTime.now()) ? const Color(0xff1D2025) : Colors.red) : const Color(0xff6B7280),
                                    //                                         ),
                                    //                                       ),
                                    //                                     ),
                                    //                                   ],
                                    //                                 ),
                                    //                               ),
                                    //                             ],
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     ],
                                    //                   ),

                                    //                   const SizedBox(
                                    //                       height: 16),

                                    //                   // Guests Selector
                                    //                   Column(
                                    //                     crossAxisAlignment:
                                    //                         CrossAxisAlignment
                                    //                             .start,
                                    //                     children: [
                                    //                       Text(
                                    //                         "Guests".tr,
                                    //                         style: GoogleFonts
                                    //                             .spaceGrotesk(
                                    //                           fontSize: 13,
                                    //                           fontWeight:
                                    //                               FontWeight
                                    //                                   .w400,
                                    //                           color: const Color(
                                    //                               0xff1D2025),
                                    //                         ),
                                    //                       ),
                                    //                       const SizedBox(
                                    //                           height: 6),
                                    //                       InkWell(
                                    //                         onTap:
                                    //                             _showGuestBottomSheet,
                                    //                         child: Container(
                                    //                           height: 48,
                                    //                           padding:
                                    //                               const EdgeInsets
                                    //                                   .symmetric(
                                    //                                   horizontal:
                                    //                                       12,
                                    //                                   vertical:
                                    //                                       8),
                                    //                           decoration:
                                    //                               BoxDecoration(
                                    //                             border: Border.all(
                                    //                                 color: const Color(
                                    //                                     0xffE5E7EB)),
                                    //                             borderRadius:
                                    //                                 BorderRadius
                                    //                                     .circular(
                                    //                                         8),
                                    //                             color: Colors
                                    //                                 .white,
                                    //                           ),
                                    //                           child: Row(
                                    //                             children: [
                                    //                               SvgPicture
                                    //                                   .asset(
                                    //                                 'assets/icons/user.svg',
                                    //                                 width: 20,
                                    //                                 height: 20,
                                    //                                 color: const Color(
                                    //                                     0xff6B7280),
                                    //                               ),
                                    //                               const SizedBox(
                                    //                                   width: 8),
                                    //                               Expanded(
                                    //                                 child: Text(
                                    //                                   selectedGuests,
                                    //                                   style: GoogleFonts
                                    //                                       .spaceGrotesk(
                                    //                                     fontSize:
                                    //                                         14,
                                    //                                     color: const Color(
                                    //                                         0xff1D2025),
                                    //                                     fontWeight:
                                    //                                         FontWeight.w500,
                                    //                                   ),
                                    //                                   overflow:
                                    //                                       TextOverflow
                                    //                                           .ellipsis,
                                    //                                 ),
                                    //                               ),
                                    //                               const Icon(
                                    //                                 Icons
                                    //                                     .keyboard_arrow_down,
                                    //                                 color: Color(
                                    //                                     0xff6B7280),
                                    //                                 size: 20,
                                    //                               ),
                                    //                             ],
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),

                                    //             // Divider before button
                                    //             Divider(
                                    //               thickness: 1,
                                    //               color: Colors.grey.shade200,
                                    //               height: 0,
                                    //             ),

                                    //             // Reserve Now Button (full-width, medium height)
                                    //             Padding(
                                    //               padding: EdgeInsets.symmetric(
                                    //                   horizontal: 16,
                                    //                   vertical: 12),
                                    //               child: SizedBox(
                                    //                 width: double.infinity,
                                    //                 height: 48,
                                    //                 child: ElevatedButton(
                                    //                   style: ElevatedButton
                                    //                       .styleFrom(
                                    //                     backgroundColor:
                                    //                         kSecondaryColor,
                                    //                     foregroundColor:
                                    //                         Colors.white,
                                    //                     shape:
                                    //                         RoundedRectangleBorder(
                                    //                       borderRadius:
                                    //                           BorderRadius
                                    //                               .circular(8),
                                    //                     ),
                                    //                     elevation: 0,
                                    //                   ),
                                    //                   onPressed:
                                    //                       _handleReserveNow,
                                    //                   child: Text(
                                    //                     'Reserve Now'.tr,
                                    //                     style: GoogleFonts
                                    //                         .spaceGrotesk(
                                    //                       fontSize: 16,
                                    //                       fontWeight:
                                    //                           FontWeight.w600,
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),

                                    if (checkingAvailability)
                                      _buildRoomShimmer()
                                    else if (roomResponse != null)
                                      roomResponse!.rooms.isEmpty
                                          ? _buildEmptyRoomsState()
                                          : Column(
                                              children: roomResponse!.rooms
                                                  .map((room) => RoomWidget(
                                                        room: room,
                                                        onQuantityChanged:
                                                            updateSelectedRooms,
                                                        onSelect: () =>
                                                            _onRoomSelected(
                                                                room),
                                                      ))
                                                  .toList(),
                                            ),

                                    // Show rooms from API response or search data (API response takes priority)
                                    if (_useSearchData &&
                                        roomResponse == null &&
                                        (_apiParsedRooms.isNotEmpty ||
                                            widget.searchData!.rooms
                                                .isNotEmpty)) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 16,
                                            bottom: 8),
                                        child: Text(
                                          'Available Rooms'.tr,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      // Display API parsed rooms if available, otherwise use search data rooms
                                      ...(_apiParsedRooms.isNotEmpty
                                          ? _apiParsedRooms.map((room) =>
                                              _buildSearchRoomCard(room))
                                          : widget.searchData!.rooms.map(
                                              (room) =>
                                                  _buildSearchRoomCard(room))),
                                    ],

                                    // Show amenities from search data
                                    if (_useSearchData &&
                                        widget.searchData!.amenities
                                            .isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Text(
                                          'Amenities'.tr,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: widget.searchData!.amenities
                                              .map((amenity) {
                                            return Chip(
                                              label: Text(
                                                amenity,
                                                style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 13),
                                              ),
                                              backgroundColor:
                                                  const Color(0xffF1F5F9),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                side: BorderSide.none,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    SizedBox(
                                      height: 5,
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ), // Divider(
                                    //   thickness: 1,
                                    //   endIndent: 30,
                                    //   indent: 30,
                                    // ),

                                    if (!_useSearchData)
                                      ...detail?.data?.terms?.map((term) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // --- Category Heading ---
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  child: Text(
                                                    term.parent?.title ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  child: Wrap(
                                                    runSpacing:
                                                        0, // Vertical spacing between lines
                                                    spacing:
                                                        0, // Horizontal spacing between items
                                                    children: term.child
                                                            ?.map((facility) {
                                                          String iconPath = facility
                                                                  .imageUrl ??
                                                              'assets/haven/wifi.png';
                                                          return _buildFacilityItem(
                                                              iconPath,
                                                              facility.title ??
                                                                  '');
                                                        }).toList() ??
                                                        <Widget>[],
                                                  ),
                                                ),

                                                const SizedBox(height: 20),
                                              ],
                                            );
                                          }) ??
                                          [],

                                    SizedBox(
                                      height: 10,
                                    ),

                                    SizedBox(
                                      height: 5,
                                    ),
                                    // Padding(
                                    //   padding: EdgeInsets.all(20.0),
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text('Rules'.tr,
                                    //           style: TextStyle(
                                    //               color: kPrimaryColor,
                                    //               fontSize: 18,
                                    //               fontFamily: 'Inter'.tr,
                                    //               fontWeight: FontWeight.w600)),
                                    //       SizedBox(height: 20),
                                    //       _buildRuleItem('Check in'.tr,
                                    //           item.hotelDetail?.data?.checkInTime ?? ''),
                                    //       SizedBox(height: 10),
                                    //       _buildRuleItem('Check out'.tr,
                                    //           item.hotelDetail?.data?.checkOutTime ?? ''),
                                    //       SizedBox(height: 20),
                                    //       Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.start,
                                    //         children: item.hotelDetail?.data?.policy
                                    //                 ?.map((policy) {
                                    //               return Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                                    //                 children: [
                                    //                   Text(
                                    //                     policy.title ?? '',
                                    //                     style: TextStyle(
                                    //                       fontFamily: 'Inter'.tr,
                                    //                       fontWeight: FontWeight.w600,
                                    //                       fontSize: 16,
                                    //                       color: kPrimaryColor,
                                    //                     ),
                                    //                   ),
                                    //                   SizedBox(height: 8),
                                    //                   Text(
                                    //                     policy.content ?? '',
                                    //                     style: TextStyle(
                                    //                       fontFamily: 'Inter'.tr,
                                    //                       fontSize: 14,
                                    //                       color: Colors.grey[600],
                                    //                     ),
                                    //                   ),
                                    //                   SizedBox(height: 16),
                                    //                 ],
                                    //               );
                                    //             }).toList() ??
                                    //             [],
                                    //       ),
                                    //       SizedBox(height: 20),
                                    //       Divider(
                                    //         thickness: 1,
                                    //         indent: 20,
                                    //         endIndent: 20,
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    //
                                    // SizedBox(
                                    //   height: 5,
                                    // ),

                                    //map

                                    // Padding(
                                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                                    //   child: Text("Location".tr,
                                    //       style: TextStyle(
                                    //           fontFamily: 'Inter'.tr,
                                    //           color: kPrimaryColor,
                                    //           fontSize: 18,
                                    //           fontWeight: FontWeight.w600)),
                                    // ),
                                    // SizedBox(
                                    //   height: 12,
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                                    //   child: Container(
                                    //     height: 200,
                                    //     child: GoogleMap(
                                    //       initialCameraPosition: CameraPosition(
                                    //         target: LatLng(
                                    //             double.parse(
                                    //                 item.hotelDetail?.data?.mapLat ?? '0'),
                                    //             double.parse(
                                    //                 item.hotelDetail?.data?.mapLng?.toString() ??
                                    //                     '0')),
                                    //         zoom: double.parse(
                                    //             item.hotelDetail?.data?.mapZoom?.toString() ??
                                    //                 '12'),
                                    //       ),
                                    //       markers: {
                                    //         Marker(
                                    //           markerId: MarkerId('hotel'),
                                    //           position: LatLng(
                                    //             double.parse(
                                    //                 item.hotelDetail?.data?.mapLat ?? '0'),
                                    //             double.parse(
                                    //                 item.hotelDetail?.data?.mapLng?.toString() ??
                                    //                     '0'),
                                    //           ),
                                    //         ),
                                    //       },
                                    //     ),
                                    //   ),
                                    // ),
                                    //
                                    // SizedBox(
                                    //   height: 32,
                                    // ),
                                    //
                                    // Divider(
                                    //   thickness: 1,
                                    //   indent: 20,
                                    //   endIndent: 20,
                                    // ),
                                    // //review slider
                                    // SizedBox(
                                    //   height: 12,
                                    // ),
                                    if (detail != null && !_useSearchData) ...[
                                      _buildRatingSection(detail),
                                      _buildRatingBars(detail),
                                    ],
                                    if (!_useSearchData)
                                      ...(detail?.data?.reviewLists?.data ?? [])
                                          .map((review) =>
                                              _buildReviewItem(review)),
                                    SizedBox(
                                      height: 5,
                                    ),

                                    // This seciton is being comment out because it is the section where we are writing the review ...

                                    if (!_useSearchData) ...[
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text("Write a Review".tr,
                                            style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      _buildReviewWidget(
                                          detail ?? HotelDetail()),
                                    ],
                                    SizedBox(height: 10),
                                    if (!_useSearchData) Divider(thickness: 1),
                                    if (!_useSearchData)
                                      ...(detail?.data?.extraPrice ?? [])
                                          .map((element) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  value: element.valueType,
                                                  onChanged: (bool? value) {
                                                    if (value != null) {
                                                      element.valueType = value;

                                                      if (element.valueType ==
                                                          true) {
                                                        extraPrice += int.parse(
                                                            element.price ??
                                                                "0");
                                                      } else {
                                                        extraPrice -= int.parse(
                                                            element.price ??
                                                                "0");
                                                      }
                                                      setState(() {});
                                                    }
                                                  }),
                                              Text(element.name ?? ""),
                                              Spacer(),
                                              Text("\$${element.price}"),
                                            ],
                                          ),
                                        );
                                      }),
                                    if (!_useSearchData)
                                      _buildExtraServicesWidget(
                                          detail ?? HotelDetail(),
                                          selectedRooms),

                                    if (!_useSearchData) Divider(),

                                    SizedBox(
                                      height: 10,
                                    ),
                                    //  Divider(
                                    //   thickness: 1,
                                    // ),

                                    // const SizedBox(height: 10),

                                    // ───────────────────────────────
                                    // CHECK-IN / CHECK-OUT TIMES (Moved to end)
                                    // ───────────────────────────────
                                    if (detail?.data?.checkInTime != null ||
                                        detail?.data?.checkOutTime != null ||
                                        _useSearchData)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          margin:
                                              const EdgeInsets.only(bottom: 24),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // Icon(Icons.login,
                                                    //     size: 18,
                                                    //     color: kSecondaryColor),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Check-in'.tr,
                                                          style: GoogleFonts
                                                              .spaceGrotesk(
                                                            fontSize: 11,
                                                            color: const Color(
                                                                0xFF65758B),
                                                          ),
                                                        ),
                                                        Text(
                                                          detail?.data
                                                                  ?.checkInTime ??
                                                              '14:00',
                                                          style: GoogleFonts
                                                              .spaceGrotesk(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 30,
                                                color: Colors.grey.shade400,
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Icon(Icons.logout,
                                                    //     size: 18,
                                                    //     color: kSecondaryColor),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Check-out'.tr,
                                                          style: GoogleFonts
                                                              .spaceGrotesk(
                                                            fontSize: 11,
                                                            color: const Color(
                                                                0xFF65758B),
                                                          ),
                                                        ),
                                                        Text(
                                                          detail?.data
                                                                  ?.checkOutTime ??
                                                              '11:00',
                                                          style: GoogleFonts
                                                              .spaceGrotesk(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                //price & reserve button
                              ])),
                    ),
      bottomNavigationBar: null,
    );
  }
}

//review slider item

class ReviewSliderItem extends StatelessWidget {
  ReviewSliderItem({
    super.key,
    required this.dataSrc,
  });

  final rd.ReviewData dataSrc;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: 0.75 * screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //rating, time
          Row(
            children: [
              RatingBarIndicator(
                rating: dataSrc.rating,
                itemCount: 5,
                itemSize: 12,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons.fiber_manual_record,
                size: 4,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                dataSrc.date,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),

          //review content
          Text(
            dataSrc.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Show more".tr,
            style: TextStyle(
              fontFamily: 'Inter'.tr,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(
            height: 16,
          ),

          //avatar, name, country
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(dataSrc.avatar),
                radius: 24,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataSrc.name,
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dataSrc.location,
                    style: TextStyle(
                      color: kColor1,
                      fontSize: 12,
                      fontFamily: 'Inter'.tr,
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

//offer item

class OfferItem extends StatelessWidget {
  OfferItem({
    super.key,
    required this.dataSrc,
  });

  final rd.OfferData dataSrc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(dataSrc.kIcon),
          SizedBox(
            width: 12,
          ),
          Text(
            dataSrc.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

//room specification item

class RoomSpecsItem extends StatelessWidget {
  RoomSpecsItem({
    super.key,
    required this.dataSrc,
  });

  final rd.RoomSpecsData dataSrc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              dataSrc.kIcon,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dataSrc.title,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dataSrc.subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 12,
                    color: kColor1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildRatingSection(HotelDetail hotelDetail) {
  const Color textColor = Colors.white;

  return Column(children: [
    Column(
      children: [
        // Guest Review Text above the container (centered)
        Padding(
          padding: const EdgeInsets.only(right: 210),
          child: Text(
            'Guest Review'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xff1D2025),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 120.0, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                      '${hotelDetail.data?.reviewScore?.scoreTotal ?? '0'}/5',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700, // Bold
                        fontSize: 36,
                        height: 40 / 36, // line-height
                        letterSpacing: 0,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (hotelDetail.data?.reviewScore?.scoreText ?? 'Very Good')
                          .tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w400, // Regular
                        fontSize: 14,
                        height: 20 / 14,
                        letterSpacing: 0,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    )
  ]);
}

// Assuming HotelDetail is defined in your project
// Assuming kSecondaryColor is defined

Widget _buildRatingBar(String title, double ratio) {
  final double score = ratio * 5.0;

  return Padding(
    // Added bottom padding to create separation between different bars
    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
      children: [
        // 1. Bar and Title Section (The left and central part of the visual)
        Expanded(
          // Takes up most of the horizontal space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: Color(0xff1D2025),
                ),
              ),

              const SizedBox(height: 4), // Space between title and bar

              // --- Rating Bar (Covers full width of this Expanded area) ---
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Background Bar (Light Grey)
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Foreground Bar (Secondary Color)
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            kSecondaryColor, // Assuming kSecondaryColor is the blue color
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Score Value (Right-aligned, outside the bar's Expanded area)
        const SizedBox(width: 8),
        Text(
          score.toStringAsFixed(1),
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w500, // Medium
              fontSize: 14,
              height: 20 / 14, // line-height
              letterSpacing: 0,
              color: Color(0xff1D2025)),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------------------
// NOTE: The _buildRatingBars widget remains mostly the same, as the changes
// are contained within the _buildRatingBar helper.
// ----------------------------------------------------------------------

Widget _buildRatingBars(HotelDetail hotelDetail) {
  final rateScores = hotelDetail.data?.reviewScore?.rateScore ?? [];

  return Container(
    // 1. Card Styling
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),

    // 2. Inner Padding and Content
    child: Padding(
      // Padding inside the card
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          for (var score in rateScores)
            _buildRatingBar(
              score.title ?? '',
              (score.percent ?? 0).toDouble() / 100,
            ),
        ],
      ),
    ),
  );
}

Widget _buildReviewItem(ReviewData review) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: Color(0xffFFFFFF),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(review.author?.avatarUrl ?? ''),
                radius: 20,
              ),
              const SizedBox(width: 12),

              // ★ FIX: Give bounded width to this Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NAME + DATE ROW FIXED
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(
                          review.author?.name ?? '',
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight:
                                  FontWeight.w500, // "Medium" in Figma = w500
                              fontSize: 14,
                              height: 20 / 14, // line-height = 20px
                              letterSpacing: 0,
                              color: Color(0xff1D2025)),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          DateFormat('dd MMM yyyy').format(
                            DateTime.parse(
                              review.createdAt ?? DateTime.now().toString(),
                            ),
                          ),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w400, // Regular
                            fontSize: 12,
                            height: 16 / 12, // exact line-height from Figma
                            letterSpacing: 0,
                            color: Color(0xff65758B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < (review.rateNumber ?? 0)
                              ? AppColors.accent
                              : Colors.grey,
                          size: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.content ?? '',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w400, // Regular
              fontSize: 14,
              height: 21 / 14, // Figma line-height (21px)
              letterSpacing: 0,
              color: Color(0xff65758B),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildReviewWidget(HotelDetail hotelDetail) {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Map<String, int> ratings = {
    'Service'.tr: 0,
    'Organization'.tr: 0,
    'Friendliness'.tr: 0,
    'Area Expert'.tr: 0,
    'Safety'.tr: 0,
  };

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title'.tr,
                filled: true, // Add this
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                labelStyle: TextStyle(color: grey),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Review Content'.tr,
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                labelStyle: TextStyle(color: grey),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your review'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kColor1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: ratings.entries
                    .map((entry) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(entry.key,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: grey,
                                      fontSize: 14)),
                              Row(
                                children: List.generate(
                                    5,
                                    (index) => GestureDetector(
                                          child: Icon(
                                            index < entry.value
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              ratings[entry.key] = index + 1;
                                            });
                                          },
                                        )),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
              ),
              child: TertiaryButton(
                text: "Leave a Review".tr,
                press: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('userToken');

                  if (token == null) {
                    // Show the custom bottom sheet
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => CustomBottomSheet(
                        title: 'Log in to leave a review'.tr,
                        content: '',
                        onCancel: () {
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                        onLogin: () {
                          // Close the bottom sheet
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                          ); // Navigate to SignInScreen
                        },
                      ),
                    );
                    return; // Exit the function if token is null
                  }
                  if (_formKey.currentState!.validate()) {
                    if (ratings.values.every((rating) => rating > 0)) {
                      final homeProvider =
                          Provider.of<HomeProvider>(context, listen: false);
                      final result = await homeProvider.leaveReview(
                        reviewTitle: _titleController.text,
                        reviewContent: _contentController.text,
                        reviewStats: ratings,
                        serviceId: hotelDetail.data?.id.toString() ?? '',
                        serviceType: 'hotel',
                        context: context,
                      );

                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Review submitted successfully'.tr)),
                        );
                        // Clear the form
                        _titleController.clear();
                        _contentController.clear();
                        setState(() {
                          ratings.updateAll((key, value) => 0);
                        });
                      } else {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Failed to submit review.')),
                        // );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please rate all categories'.tr)),
                      );
                    }
                  }
                },
              ),
            ),
          ]),
        ),
      );
    },
  );
}

// Add this new widget

Widget _buildExtraServicesWidget(
    HotelDetail hotelDetail, Map<int, int> selectedRooms) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Room".tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, fontWeight: FontWeight.w400, color: grey),
                ),
                Text(
                  (selectedRooms.values.fold(0, (sum, qty) => sum + qty))
                      .toString(),
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: kPrimaryColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hotelDetail.data?.bookingFee
                          ?.firstWhere(
                            (fee) => fee.name == "Service fee",
                            orElse: () =>
                                BookingFee(name: "Service fee", price: "0"),
                          )
                          .name ??
                      "Service fee".tr,
                  style: GoogleFonts.spaceGrotesk(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "\$${double.parse(hotelDetail.data?.bookingFee?.firstWhere(
                        (fee) => fee.name == "Service fee",
                        orElse: () =>
                            BookingFee(name: "Service fee", price: "0"),
                      ).price ?? "0").toStringAsFixed(2)}",
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, fontWeight: FontWeight.w400, color: grey),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class SliderContent extends StatelessWidget {
  SliderContent({
    super.key,
    required this.imageUrl,
  });
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 360,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text('Failed to load image'));
            },
          ),
        ),
        // gradient to make image darker
        Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff000000).withOpacity(0.7),
                Color(0xff343434).withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildFacilityItem(String svgIconPath, String label) {
  // CRITICAL: Fixed width Container to enforce two-column layout in the Wrap parent.
  return Container(
    width:
        160.0, // Adjust this width as needed for your specific screen size/padding
    padding: const EdgeInsets.symmetric(
        vertical: 8.0), // Vertical spacing between facility rows
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Retaining your original left padding
        const SizedBox(width: 14),

        // --- Icon/Image ---
        Image.network(
          svgIconPath,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 20);
          },
        ),

        // --- Space between icon and text ---
        const SizedBox(width: 14), // Original horizontal spacing

        // --- Text label ---
        Expanded(
          child: Text(
            label.tr,
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0,
                color: Color(0xff1D2025)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRuleItem(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontFamily: 'Inter'.tr,
              color: kPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20),
        Text(value,
            style: TextStyle(
                fontFamily: 'Inter'.tr,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: grey)),
      ],
    ),
  );
}

const int _kMaxChars = 300;

class ExpandableHtmlContent extends StatefulWidget {
  final String content;
  final String readMoreText;
  final TextStyle textStyle;
  final TextStyle readMoreStyle;
  final Color primaryColor; // Assuming kPrimaryColor is passed in

  const ExpandableHtmlContent({
    required this.content,
    required this.primaryColor,
    this.readMoreText = 'Read more',
    this.textStyle = const TextStyle(color: Colors.black54),
    this.readMoreStyle =
        const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
    Key? key,
  }) : super(key: key);

  @override
  _ExpandableHtmlContentState createState() => _ExpandableHtmlContentState();
}

class _ExpandableHtmlContentState extends State<ExpandableHtmlContent> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Default to collapsed if content exceeds the limit
    _isExpanded = widget.content.length <= _kMaxChars;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we need to truncate
    final bool isTruncated = widget.content.length > _kMaxChars;

    // Get the content to display: full text if expanded, or truncated text otherwise
    final String displayedContent = _isExpanded || !isTruncated
        ? widget.content
        : widget.content.substring(0, _kMaxChars) + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HTML Content
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: HtmlWidget(
            displayedContent,
            textStyle: widget.textStyle,
          ),
        ),

        // 2. Read More Button (only shown if truncation occurred and it's not yet expanded)
        if (isTruncated)
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Show less' : widget.readMoreText,
                style: widget.readMoreStyle.copyWith(
                  color: widget.primaryColor, // Use kPrimaryColor for the link
                ),
              ),
            ),
          ),
      ],
    );
  }
}
