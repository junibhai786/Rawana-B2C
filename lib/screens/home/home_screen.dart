import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/Provider/tour_provider.dart';

import 'package:moonbnd/data_models/boat_data_item.dart';
import 'package:moonbnd/data_models/car_data_Item.dart';
import 'package:moonbnd/data_models/event_data.dart';
import 'package:moonbnd/data_models/flight_data_item.dart';
import 'package:moonbnd/data_models/space_data_item.dart';
import 'package:moonbnd/data_models/tour_data_item.dart';
import 'package:moonbnd/modals/boat_list_model.dart';
import 'package:moonbnd/modals/car_list_model.dart';
import 'package:moonbnd/modals/event_list_model.dart';
import 'package:moonbnd/modals/flight_list_model.dart';
import 'package:moonbnd/modals/flight_airport_model.dart';
import 'package:moonbnd/modals/home_item.dart' as home_item;
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/modals/space_list_model.dart';
import 'package:moonbnd/modals/tour_list_model.dart';

import 'package:moonbnd/screens/boat/boat_detail_screen.dart';
import 'package:moonbnd/screens/boat/boat_filter_screen.dart';

import 'package:moonbnd/screens/car/car_details_screen.dart';
import 'package:moonbnd/screens/car/filter_car_screen.dart';

import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:moonbnd/screens/event/event_filter.dart';

import 'package:moonbnd/screens/flight/filter_flight_screen.dart';
import 'package:moonbnd/screens/hotel/filter_screen.dart';
import 'package:moonbnd/screens/flight/flight_checkout_screen.dart';

import 'package:moonbnd/screens/space/filter_space_screen.dart';

import 'package:moonbnd/screens/space/space_details_screen.dart';
import 'package:moonbnd/screens/tour/filter_tour_screen.dart';

import 'package:moonbnd/screens/tour/tour_details_screen.dart';
import 'package:moonbnd/widgets/flight_shimmer_card.dart';
import 'package:moonbnd/widgets/activity_search_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../Provider/hotel_country_provider.dart';
import '../../Provider/hotel_city_provider.dart';
import '../../Provider/search_hotel_provider.dart';
import '../../Provider/hotel_destination_provider.dart';
import '../../widgets/hotel_country_selection_sheet.dart';
import '../../widgets/hotel_city_selection_sheet.dart';
import '../../Provider/flight_airport_provider.dart';
import '../../widgets/flight_airport_selection_sheet.dart';
import '../../widgets/hotel_destination_selection_sheet.dart';
import '../../data_models/home_screen_data.dart';
import '../../widgets/card_widget.dart';
import '../hotel/search_hotel_screen.dart';
import '../hotel/room_detail_screen.dart';

import '../notification/notifications_screen.dart';
import '../../Provider/currency_provider.dart';
import '../../services/location_service.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool _isInitialFetchDone = false; // guard against duplicate startup fetches
  //zeeshan
  String selectedSort = 'Recommended'.tr;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  int _hotelAdultCount = 1;
  int _hotelChildCount = 0;
  int _hotelRoomCount = 1;
  List<int> _childrenAges = []; // Store ages for each child
  String _selectedCountry = '';
  int? _selectedCity = 0;
  int? fromWhereLocation = 0;
  int? toWhereLocation = 0;
  DateTime? fromDate;
  DateTime? toDate;

  String _selectedToCity = '';

  // Flight search variables
  bool _isRoundTrip = true;
  DateTime? _flightDepartureDate;
  DateTime? _flightReturnDate;
  int _adultCount = 1;
  int _childCount = 0;
  int _infantCount = 0;
  String _cabinClass = 'Economy';
  String _departureCity = '';
  String _destinationCity = '';
  // Store ONLY IATA codes - no location IDs
  String? _departureIataCode;
  String? _destinationIataCode;
  // Track if auto-detection has been done for the Flight tab
  bool _flightLocationAutoDetected = false;
  // Flight search loading state
  bool _isFlightSearchLoading = false;
  // Hotel search loading state
  bool _isHotelSearchLoading = false;

  // ── Tab data caching & guards ────────────────────────────────────────────
  /// Tracks which tabs have already loaded their data (prevent re-fetch on revisit)
  Map<int, bool> _tabDataLoaded = {
    0: false, // Explore
    1: false, // Hotels
    2: false, // Tours
    3: false, // Spaces
    4: false, // Cars
    5: false, // Events
    6: false, // Flights (no auto-load)
    7: false, // Boats
    8: false, // Activities (no API call)
  };

  /// Tracks which tabs are currently fetching (prevent concurrent API calls)
  Map<int, bool> _isTabFetching = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
  };

  void dispose() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.tabController?.dispose();
    _countryController.dispose();
    super.dispose();
  }

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _hotelDestinationController =
      TextEditingController();
  final TextEditingController _fromCityController = TextEditingController();
  final TextEditingController _toCityController = TextEditingController();
  final ScrollController _cityScrollController = ScrollController();

  // Form keys for validation
  final GlobalKey<FormState> _flightFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _hotelFormKey = GlobalKey<FormState>();
  bool _flightValidationAttempted = false;
  bool _hotelValidationAttempted = false;

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    homeProvider.tabController =
        TabController(length: categoryDatas.length, vsync: this);

    // Add listener to handle both tap and swipe
    homeProvider.tabController?.addListener(() {
      // Skip during initialization to avoid duplicate first-render fetch
      if (!_isInitialFetchDone) return;
      if (homeProvider.tabController?.indexIsChanging == false) {
        // Convert tab position to category ID
        final tabIndex = homeProvider.tabController?.index ?? 0;
        final categoryId = tabIndex < categoryDatas.length
            ? categoryDatas[tabIndex].id
            : categoryDatas.first.id;
        _fetchDataForTab(categoryId, animate: false);
      }
    });

    setState(() {
      isLoading = true;
    });
    // TODO: Re-enable when notification feature is active
    // Provider.of<VendorAuthProvider>(context, listen: false)
    //     .fetchunreadnotificationcount()
    //     .then((value) {});

    Provider.of<AuthProvider>(context, listen: false).getMe().then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // Fetch the first active tab (Hotels, id: 1) — single startup fetch
        _fetchDataForTab(categoryDatas.first.id).then((_) {
          if (mounted) {
            setState(() {
              _isInitialFetchDone = true;
            });
          }
        });
      }
    });

    // Move fetchLocations to post-frame callback to avoid setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        homeProvider.fetchLocations(); // preload cities after first frame
        // Removed duplicate _fetchDataForTab call — handled in getMe().then() above
      }
    });
  }

  Future _fetchDataForTab(int index, {bool animate = true}) async {
    // ────────────────────────────────────────────────────────────
    // GUARD 1: If data already loaded AND not fetching, skip entirely
    // ────────────────────────────────────────────────────────────
    if (_tabDataLoaded[index] == true && _isTabFetching[index] == false) {
      log('[_fetchDataForTab] ✓ Tab $index already loaded, skipping API call');
      // Just update tab selection without showing loader
      Provider.of<HomeProvider>(context, listen: false)
          .setSelectedHomeTab(index, animate: animate);
      return;
    }

    // ────────────────────────────────────────────────────────────
    // GUARD 2: If already fetching this tab, prevent concurrent request
    // ────────────────────────────────────────────────────────────
    if (_isTabFetching[index] == true) {
      log('[_fetchDataForTab] ⚠ Tab $index fetch already in progress, ignoring duplicate');
      return;
    }

    // Mark as fetching and show loader ONLY if we're doing API call
    if (mounted) {
      setState(() {
        _isTabFetching[index] = true;
        isLoading = true;
        Provider.of<HomeProvider>(context, listen: false)
            .setSelectedHomeTab(index, animate: animate);
      });
    }

    log('[▶] _fetchDataForTab START: index=$index, animate=$animate');

    try {
      switch (index) {
        case 0:
          // Explore
          log('[_fetchDataForTab] case 0: Explore');
          await Provider.of<HomeProvider>(context, listen: false)
              .homelistapi(index);
          break;

        case 1:
          // ===== HOTELS (Index 1) =====
          // CRITICAL FIX: Do NOT call API on plain tab revisit
          log('[_fetchDataForTab] case 1: Hotels check...');
          final homeProvider =
              Provider.of<HomeProvider>(context, listen: false);
          final hasHotelData = homeProvider.hotelListPerCategory[index] != null;
          log('[_fetchDataForTab] Hotels has cached data: $hasHotelData');

          // Check for valid search parameters before triggering API
          // We only auto-call if the user seems to have entered something (e.g. from a deep link or back nav)
          bool hasValidSearchParams = (_selectedCountry.isNotEmpty) ||
              (_selectedCity != null && _selectedCity != 0) ||
              _checkInDate != null ||
              _checkOutDate != null;

          if (!hasHotelData && hasValidSearchParams) {
            // Only call API on FIRST load if valid parameters are present
            log('[_fetchDataForTab] → Calling hotellistapi (first load with parameters)');
            await homeProvider.hotellistapi(index, searchParams: {
              if (_selectedCountry.isNotEmpty) 'country': _selectedCountry,
              if (_selectedCity != null && _selectedCity != 0)
                'city': _selectedCity,
              if (_checkInDate != null) 'check_in': _checkInDate,
              if (_checkOutDate != null) 'check_out': _checkOutDate,
              'guests': _hotelAdultCount,
            });
          } else if (!hasHotelData) {
            // First load: No search parameters yet. Skip API call and show form only.
            log('[_fetchDataForTab] → First load: No search parameters yet. Skipping API call.');
          } else {
            // Skip API on revisit - use cached data
            log('[_fetchDataForTab] → Skipping hotellistapi (using cache)');
          }
          break;

        case 2:
          // Tours
          log('[_fetchDataForTab] case 2: Tours');
          final tourProvider =
              Provider.of<TourProvider>(context, listen: false);
          if (tourProvider.tourListPerCategory[index] == null) {
            await tourProvider.tourlistapi(index, searchParams: {});
          }
          break;

        case 3:
          // Spaces
          log('[_fetchDataForTab] case 3: Spaces');
          final spaceProvider =
              Provider.of<SpaceProvider>(context, listen: false);
          if (spaceProvider.spaceListPerCategory[index] == null) {
            await spaceProvider.spacelistapi(index, searchParams: {});
          }
          break;

        case 4:
          // Cars
          log('[_fetchDataForTab] case 4: Cars');
          final homeProviderCars =
              Provider.of<HomeProvider>(context, listen: false);
          if (homeProviderCars.carListPerCategory[index] == null) {
            await homeProviderCars.carlistapi(index, searchParams: {});
          }
          break;

        case 5:
          // Events
          log('[_fetchDataForTab] case 5: Events');
          final eventProvider =
              Provider.of<EventProvider>(context, listen: false);
          if (eventProvider.eventListPerCategory[index] == null) {
            await eventProvider.eventlistapi(index, searchParams: {});
          }
          break;

        case 6:
          // Flight - auto-detect departure airport silently in background
          log('[_fetchDataForTab] case 6: Flight (starting background auto-detect)');
          if (!_flightLocationAutoDetected) {
            // Fire and forget: don't await, let it run in background
            _autoDetectDepartureAirport();
          }
          break;

        case 7:
          // Boats
          log('[_fetchDataForTab] case 7: Boats');
          final boatProvider =
              Provider.of<BoatProvider>(context, listen: false);
          if (boatProvider.boatListPerCategory[index] == null) {
            await boatProvider.boatlistapi(index, searchParams: {});
          }
          break;

        case 8:
          // Activities - UI only, no API call
          log('[_fetchDataForTab] case 8: Activities (no API)');
          break;
      }

      // Mark as successfully loaded
      if (mounted) {
        setState(() {
          _tabDataLoaded[index] = true;
          _isTabFetching[index] = false;
          isLoading = false;
        });
      }
      log('[✓] _fetchDataForTab COMPLETE: index=$index');
    } catch (e) {
      log('[✗] _fetchDataForTab ERROR: index=$index, error=$e');
      if (mounted) {
        setState(() {
          _isTabFetching[index] = false;
          isLoading = false;
        });
      }
      // Continue without re-throwing to keep UI responsive
    }
  }
//zeeshan

  // Flight Passenger Selector
  void _showPassengerSelector() async {
    final Map<String, int>? result =
        await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int tempAdult = _adultCount;
        int tempChild = _childCount;
        int tempInfant = _infantCount;

        return StatefulBuilder(
          builder: (context, modalSetState) {
            Widget _counterRow(
              String label,
              String subtitle,
              int count,
              VoidCallback onDecrement,
              VoidCallback onIncrement,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          subtitle.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: count > 0 ? onDecrement : null,
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: onIncrement,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passengers'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  _counterRow(
                    'Adult',
                    '18+ years',
                    tempAdult,
                    () => modalSetState(() {
                      if (tempAdult > 1) tempAdult--;
                    }),
                    () => modalSetState(() => tempAdult++),
                  ),
                  _counterRow(
                    'Child',
                    '0–17 years',
                    tempChild,
                    () => modalSetState(() {
                      if (tempChild > 0) tempChild--;
                    }),
                    () => modalSetState(() => tempChild++),
                  ),
                  _counterRow(
                    'Infant',
                    'Under 2 years',
                    tempInfant,
                    () => modalSetState(() {
                      if (tempInfant > 0) tempInfant--;
                    }),
                    () => modalSetState(() => tempInfant++),
                  ),

                  const SizedBox(height: 16),

                  /// Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'adults': tempAdult,
                          'children': tempChild,
                          'infants': tempInfant,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      child: Text('Apply'.tr),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _adultCount = result['adults'] ?? 1;
        _childCount = result['children'] ?? 0;
        _infantCount = result['infants'] ?? 0;

        // Log passenger selection
        log('[PassengerSelector] ✅ User applied passenger counts:');
        log('[PassengerSelector] Adults: $_adultCount');
        log('[PassengerSelector] Children: $_childCount');
        log('[PassengerSelector] Infants: $_infantCount');
        log('[PassengerSelector] Total: ${_adultCount + _childCount + _infantCount}');
      });
    }
  }

  void _showGuestSelector() async {
    final Map<String, dynamic>? result =
        await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int tempAdult = _hotelAdultCount;
        int tempChild = _hotelChildCount;
        int tempRoom = _hotelRoomCount;
        // Initialize temp child ages, preserving existing ages and padding with zeros
        List<int> tempChildAges = List<int>.from(_childrenAges);
        // Sync size of tempChildAges with tempChild count
        if (tempChildAges.length < tempChild) {
          // Add default ages for new children
          while (tempChildAges.length < tempChild) {
            tempChildAges.add(8); // Default age
          }
        } else if (tempChildAges.length > tempChild) {
          // Remove extra ages
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
                            color: kHeadingColor,
                          ),
                        ),
                        Text(
                          subtitle.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: kMutedColor,
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
                                    // Sync all state variables based on label
                                    if (label == 'Children') {
                                      tempChild = count;
                                      if (tempChildAges.isNotEmpty) {
                                        tempChildAges.removeLast();
                                      }
                                    } else if (label == 'Adults') {
                                      tempAdult = count;
                                    } else if (label == 'Rooms') {
                                      tempRoom = count;
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
                                    ? kPrimaryColor
                                    : const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: count > minVal
                                  ? kPrimaryColor
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
                              color: kHeadingColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            modalSetState(() {
                              count++;
                              // Update all state variables based on label
                              if (label == 'Children') {
                                tempChild = count;
                                tempChildAges
                                    .add(8); // Default age for new child
                              } else if (label == 'Adults') {
                                tempAdult = count;
                              } else if (label == 'Rooms') {
                                tempRoom = count;
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
                                color: kPrimaryColor,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // Dynamic child age rows builder - using plus/minus buttons like web version
            List<Widget> _buildChildAgeRows() {
              if (tempChild == 0) {
                return [];
              }

              print(
                  '[DEBUG] Child age rows rendering. Children count: $tempChild, Ages list length: ${tempChildAges.length}');

              return List.generate(
                tempChild,
                (index) {
                  // Ensure tempChildAges has enough elements
                  if (index >= tempChildAges.length) {
                    tempChildAges.add(8); // Default age
                  }
                  print(
                      '[DEBUG] Building child age row $index, current age: ${tempChildAges[index]}');
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
                                color: kHeadingColor,
                              ),
                            ),
                            Text(
                              'Years'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: kMutedColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Minus button
                            InkWell(
                              onTap: tempChildAges[index] > 0
                                  ? () {
                                      print(
                                          '[DEBUG] Child $index age decreased from ${tempChildAges[index]}');
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
                                        ? kPrimaryColor
                                        : const Color(0xffE5E7EB),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: tempChildAges[index] > 0
                                      ? kPrimaryColor
                                      : const Color(0xffD1D5DB),
                                ),
                              ),
                            ),
                            // Age value
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${tempChildAges[index]}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: kHeadingColor,
                                ),
                              ),
                            ),
                            // Plus button
                            InkWell(
                              onTap: () {
                                print(
                                    '[DEBUG] Child $index age increased from ${tempChildAges[index]}');
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
                                    color: kPrimaryColor,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: kPrimaryColor,
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guests & Rooms'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: kHeadingColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  // Room badge
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffE0F7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Room 1'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: kPrimaryColor,
                      ),
                    ),
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
                        tempChildAges.add(0); // Default age for new child
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _guestCounterRow(
                    'Rooms',
                    'Units',
                    tempRoom,
                    1,
                    () => modalSetState(() => tempRoom--),
                    () => modalSetState(() => tempRoom++),
                  ),

                  // Dynamic child age rows - plus/minus buttons matching web
                  if (tempChild > 0) ...[
                    const Divider(height: 1),
                    ..._buildChildAgeRows(),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'adults': tempAdult,
                          'children': tempChild,
                          'rooms': tempRoom,
                          'childrenAges': tempChildAges,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text('Apply'.tr),
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

    if (result != null) {
      setState(() {
        _hotelAdultCount = result['adults'] ?? 1;
        _hotelChildCount = result['children'] ?? 0;
        _hotelRoomCount = result['rooms'] ?? 1;
        _childrenAges = List<int>.from(result['childrenAges'] ?? []);
        _guestCount = _hotelAdultCount + _hotelChildCount;
      });
    }
  }

  void _cityScrollListener() {
    final homeProvider = context.read<HomeProvider>();

    if (_cityScrollController.position.pixels >=
            _cityScrollController.position.maxScrollExtent - 100 &&
        homeProvider.hasMore &&
        !homeProvider.isLoadingMore) {
      homeProvider.fetchLocations(
        page: homeProvider.currentPage + 1,
        loadMore: true,
      );
    }
  }

  void _showCitySelection(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();

    // Fetch first page if empty
    if (homeProvider.locations.isEmpty) {
      await homeProvider.fetchLocations(page: 1);
    }

    // Remove old listeners to avoid duplication
    _cityScrollController.removeListener(_cityScrollListener);

    // Add pagination listener
    _cityScrollController.addListener(_cityScrollListener);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text(
                    'Select City or Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// 🔍 Search
                  TextField(
                    onChanged: provider.filterLocations,
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 📍 City list + pagination
                  Expanded(
                    child: provider.isLocationLoading &&
                            provider.locations.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : provider.filteredLocations.isEmpty
                            ? const Center(child: Text('No locations found'))
                            : ListView.builder(
                                controller: _cityScrollController,
                                itemCount: provider.filteredLocations.length +
                                    (provider.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Bottom loader
                                  if (index ==
                                      provider.filteredLocations.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  final city =
                                      provider.filteredLocations[index];

                                  return ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(city.title ?? ''),
                                    onTap: () {
                                      provider.selectCity(city.title ?? '');
                                      _cityController.text =
                                          provider.selectedCity;
                                      _selectedCity = city.id;
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //Show city selection for hotel....
  // void _showCitySelection(BuildContext context) async {
  //   final homeProvider = context.read<HomeProvider>();
  //
  //   // ✅ fetch first
  //   if (homeProvider.locations.isEmpty) {
  //     await homeProvider.fetchLocations();
  //   }
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (_) {
  //       return Consumer<HomeProvider>(
  //         builder: (context, provider, _) {
  //           return Container(
  //             padding: const EdgeInsets.all(16),
  //             height: MediaQuery.of(context).size.height * 0.7,
  //             child: Column(
  //               children: [
  //                 const Text(
  //                   'Select City or Destination',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 /// 🔍 Search
  //                 TextField(
  //                   onChanged: provider.filterLocations,
  //                   decoration: InputDecoration(
  //                     hintText: 'Search city...',
  //                     prefixIcon: const Icon(Icons.search),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 16),
  //
  //                 /// 📍 City list
  //                 Expanded(
  //                   child: provider.isLocationLoading
  //                       ? const Center(child: CircularProgressIndicator())
  //                       : provider.filteredLocations.isEmpty
  //                       ? const Center(child: Text('No locations found'))
  //                       : ListView.builder(
  //                     itemCount: provider.filteredLocations.length,
  //                     itemBuilder: (context, index) {
  //                       final city = provider.filteredLocations[index];
  //
  //                       return ListTile(
  //                         leading: const Icon(Icons.location_on),
  //                         title: Text(city.title ?? ''),
  //                         onTap: () {
  //                           provider.selectCity(city.title ?? '');
  //                           _cityController.text = provider.selectedCity;
  //                           _selectedCity=city.id;
  //                           Navigator.pop(context);
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  /// Hotel-specific country selection — delegates to [HotelCountrySelectionSheet].
  void _showCountrySelection(BuildContext context) {
    HotelCountrySelectionSheet.show(
      context,
      onCountrySelected: (country) {
        _countryController.text = country.countryName;
        // Clear city selection whenever country changes
        _cityController.clear();
        context.read<HotelCityProvider>().clearOnCountryChange();
      },
    );
  }

  /// Airporttttttttt
  void _showAirportSelection(BuildContext context,
      {required bool isDeparture}) {
    FlightAirportSelectionSheet.show(
      context,
      isDeparture: isDeparture,
      otherSelectedIata:
          isDeparture ? _destinationIataCode : _departureIataCode,
      onAirportSelected: (airport) {
        final displayText = '${airport.city} (${airport.iataCode})';
        setState(() {
          if (isDeparture) {
            _departureCity = displayText;
            _departureIataCode = airport.iataCode;
            _fromCityController.text = displayText;
          } else {
            _destinationCity = displayText;
            _destinationIataCode = airport.iataCode;
            _toCityController.text = displayText;
          }
        });
      },
    );
  }

  /// Clear all flight search form fields
  void _clearFlightSearchForm() {
    setState(() {
      // Clear text controllers
      _fromCityController.clear();
      _toCityController.clear();

      // Clear flight search variables
      _departureCity = '';
      _destinationCity = '';
      _departureIataCode = null;
      _destinationIataCode = null;
      _flightDepartureDate = null;
      _flightReturnDate = null;

      // Reset passenger counts
      _adultCount = 1;
      _childCount = 0;
      _infantCount = 0;

      // Reset cabin class and trip type
      _cabinClass = 'Economy';
      _isRoundTrip = true;

      // Reset form validation state
      _flightValidationAttempted = false;
    });
  }

  /// Auto-detect departure airport silently in the background
  /// Does NOT block UI or show any loading indicators
  Future<void> _autoDetectDepartureAirport() async {
    // Prevent multiple auto-detection attempts
    if (_flightLocationAutoDetected) {
      log('[Flight AutoDetect] Already auto-detected, skipping');
      return;
    }

    log('[Flight AutoDetect] Starting silent background auto-detection...');

    // Mark as attempted to prevent duplicate calls
    if (mounted) {
      setState(() {
        _flightLocationAutoDetected = true;
      });
    }

    // Schedule auto-detection to run after the current frame
    // This ensures the UI remains interactive while detection runs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Get flight airports from provider
        final airportProvider =
            Provider.of<FlightAirportProvider>(context, listen: false);

        // Ensure airports are fetched
        if (airportProvider.airports.isEmpty) {
          log('[Flight AutoDetect] Fetching airports...');
          await airportProvider.fetchAirports();
        }

        if (airportProvider.airports.isEmpty) {
          log('[Flight AutoDetect] No airports available');
          return;
        }

        // Detect nearest airport based on current location
        final detectedIataCode = await LocationService.detectNearestAirportCode(
          airportProvider.airports,
        );

        if (detectedIataCode != null) {
          // Find the airport model for display
          FlightAirportModel? detectedAirport;
          try {
            detectedAirport = airportProvider.airports.firstWhere(
              (airport) => airport.iataCode == detectedIataCode,
            );
          } catch (e) {
            log('[Flight AutoDetect] Airport not found: $detectedIataCode');
            detectedAirport = null;
          }

          if (detectedAirport != null && mounted) {
            setState(() {
              final displayText =
                  '${detectedAirport!.city} (${detectedAirport.iataCode})';
              _departureCity = displayText;
              _departureIataCode = detectedAirport.iataCode;
              _fromCityController.text = displayText;
            });

            log('[Flight AutoDetect] ✓ Auto-detected: ${detectedAirport.iataCode} (${detectedAirport.city})');
          }
        } else {
          log('[Flight AutoDetect] Could not detect location (permission denied or unavailable)');
        }
      } catch (e) {
        log('[Flight AutoDetect] Error: $e');
      }
    });
  }

  Widget _buildFlightSearchSection(BuildContext context) {
    String departureDateText = _flightDepartureDate != null
        ? '${_flightDepartureDate!.day}/${_flightDepartureDate!.month}/${_flightDepartureDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String returnDateText = _flightReturnDate != null
        ? '${_flightReturnDate!.day}/${_flightReturnDate!.month}/${_flightReturnDate!.year}'
        : 'dd/mm/yyyy'.tr;

    final int _totalPassengers = _adultCount + _childCount + _infantCount;
    String passengerText;
    {
      final parts = <String>[];
      if (_adultCount > 0)
        parts.add('$_adultCount Adult${_adultCount > 1 ? 's' : ''}');
      if (_childCount > 0)
        parts.add('$_childCount Child${_childCount > 1 ? 'ren' : ''}');
      if (_infantCount > 0)
        parts.add('$_infantCount Infant${_infantCount > 1 ? 's' : ''}');
      passengerText = parts.isEmpty ? '1 Adult' : parts.join(', ');
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Form(
        key: _flightFormKey,
        autovalidateMode: _flightValidationAttempted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip type selection
            Row(
              children: [
                _buildTripTypeButton(
                  'One-way',
                  !_isRoundTrip,
                  () {
                    setState(() {
                      _isRoundTrip = false;
                    });
                  },
                ),
                SizedBox(width: 12),
                _buildTripTypeButton(
                  'Round-Trip',
                  _isRoundTrip,
                  () {
                    setState(() {
                      _isRoundTrip = true;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // From field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kHeadingColor,
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    _showAirportSelection(context, isDeparture: true);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _fromCityController,
                        readOnly: true,
                        onTap: () {
                          _showAirportSelection(context, isDeparture: true);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select departure city'.tr;
                          }
                          if (_departureIataCode == null) {
                            return 'Please select a valid airport'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Departure City'.tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kPrimaryColor),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icons/location.svg',
                              width: 20,
                              height: 20,
                              color: kMutedColor,
                            ),
                          ),
                          hintStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: kMutedColor,
                          ),
                        ),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: kHeadingColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // To field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kHeadingColor,
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    _showAirportSelection(context, isDeparture: false);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _toCityController,
                        readOnly: true,
                        onTap: () {
                          _showAirportSelection(context, isDeparture: false);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select destination city'.tr;
                          }
                          if (_destinationIataCode == null) {
                            return 'Please select a valid airport'.tr;
                          }
                          if (_departureIataCode != null &&
                              _destinationIataCode != null &&
                              _departureIataCode == _destinationIataCode) {
                            return 'Departure and destination must be different'
                                .tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Destination City'.tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kPrimaryColor),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icons/location.svg',
                              width: 20,
                              height: 20,
                              color: kMutedColor,
                            ),
                          ),
                          hintStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: kMutedColor,
                          ),
                        ),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: kHeadingColor,
                        ),
                      ),

                      // if (_tocitySuggestions.isNotEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 4),
                      //     constraints: const BoxConstraints(maxHeight: 250),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       border: Border.all(color: const Color(0xffE5E7EB)),
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: ListView.separated(
                      //       shrinkWrap: true,
                      //       itemCount: _tocitySuggestions.length,
                      //       separatorBuilder: (_, __) => const Divider(height: 1),
                      //       itemBuilder: (context, index) {
                      //         final suggestion = _tocitySuggestions[index];
                      //
                      //         return ListTile(
                      //           dense: true,
                      //           leading: const Icon(Icons.location_on, size: 20),
                      //           title: Text(
                      //             suggestion['description'],
                      //             style: GoogleFonts.spaceGrotesk(fontSize: 14),
                      //           ),
                      //           onTap: () {
                      //             setState(() {
                      //               _selectedToCity = suggestion['description'];
                      //               _toCityController.text = _selectedToCity;
                      //              _tocitySuggestions.clear();
                      //             });
                      //
                      //             FocusScope.of(context).unfocus();
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Date selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departure Date'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kHeadingColor,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FormField<DateTime>(
                        initialValue: _flightDepartureDate,
                        validator: (value) {
                          if (_flightDepartureDate == null) {
                            return 'Required'.tr;
                          }
                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _flightDepartureDate = picked;
                                      formFieldState.didChange(picked);
                                    });
                                  }
                                },
                                child: Container(
                                  height: 47,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: formFieldState.hasError
                                            ? Colors.red
                                            : kBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/calendar.svg',
                                        width: 20,
                                        height: 20,
                                        color: kMutedColor,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        departureDateText,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          color: _flightDepartureDate != null
                                              ? kHeadingColor
                                              : kMutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 4),
                                  child: Text(
                                    formFieldState.errorText ?? '',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (_isRoundTrip) SizedBox(width: 12),
                    if (_isRoundTrip)
                      Expanded(
                        child: FormField<DateTime>(
                          initialValue: _flightReturnDate,
                          validator: (value) {
                            if (_isRoundTrip && _flightReturnDate == null) {
                              return 'Required'.tr;
                            }
                            if (_isRoundTrip &&
                                _flightDepartureDate != null &&
                                _flightReturnDate != null &&
                                _flightReturnDate!
                                    .isBefore(_flightDepartureDate!)) {
                              return 'Must be after departure'.tr;
                            }
                            return null;
                          },
                          builder: (formFieldState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _flightDepartureDate ??
                                          DateTime.now(),
                                      firstDate: _flightDepartureDate ??
                                          DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _flightReturnDate = picked;
                                        formFieldState.didChange(picked);
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 47,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: formFieldState.hasError
                                              ? Colors.red
                                              : kBorderColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/calendar.svg',
                                          width: 20,
                                          height: 20,
                                          color: kMutedColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _flightReturnDate != null
                                              ? '${_flightReturnDate!.day}/${_flightReturnDate!.month}/${_flightReturnDate!.year}'
                                              : 'Return'.tr,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            color: _flightReturnDate != null
                                                ? kHeadingColor
                                                : kMutedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (formFieldState.hasError)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 12, top: 4),
                                    child: Text(
                                      formFieldState.errorText ?? '',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Passengers field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passengers'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kHeadingColor,
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: _showPassengerSelector,
                  child: Container(
                    height: 47,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/user.svg',
                          width: 20,
                          height: 20,
                          color: kMutedColor,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            passengerText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: kHeadingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Cabin Class field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cabin'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kHeadingColor,
                  ),
                ),
                SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _cabinClass,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _cabinClass = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: kHeadingColor,
                  ),
                  icon:
                      const Icon(Icons.keyboard_arrow_down, color: kMutedColor),
                  items: [
                    'Economy',
                    'Premium Economy',
                    'Business',
                    'First Class',
                  ].map((cabin) {
                    return DropdownMenuItem<String>(
                      value: cabin,
                      child: Text(cabin.tr),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Search Button
            Container(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFlightSearchLoading
                    ? null
                    : () {
                        // Trigger validation
                        setState(() {
                          _flightValidationAttempted = true;
                        });

                        // Check if form is valid
                        if (!_flightFormKey.currentState!.validate()) {
                          return; // Block search if validation fails
                        }

                        // Validate IATA codes
                        if (_departureIataCode == null ||
                            _destinationIataCode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select valid airports'.tr),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (_departureIataCode == _destinationIataCode) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Departure and destination must be different'
                                      .tr),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Build search parameters with IATA codes
                        final searchParams = {
                          'from_where': _departureIataCode,
                          'to_where': _destinationIataCode,
                          'start': _flightDepartureDate,
                          if (_isRoundTrip && _flightReturnDate != null)
                            'return_date': _flightReturnDate,
                          'trip_search_type':
                              _isRoundTrip ? 'round_trip' : 'one_way',
                          'seat_type': {
                            'adults': _adultCount,
                            'children': _childCount,
                            'infants': _infantCount,
                          },
                          'cabin_class': _cabinClass,
                        };

                        // Navigate immediately — FlightListItem handles the API call and shows shimmer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlightListItem(
                              flightList: FlightList(),
                              searchParams: searchParams,
                              adultCount: _adultCount,
                              childCount: _childCount,
                              infantCount: _infantCount,
                              isRoundTrip: _isRoundTrip,
                            ),
                          ),
                        );

                        _clearFlightSearchForm();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/search.svg',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Search Flights'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeButton(
      String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : kSurfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              Text(
                title.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : kHeadingColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//zeshan
  Widget _buildHotelSearchSection(BuildContext context) {
    String checkInText = _checkInDate != null
        ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String checkOutText = _checkOutDate != null
        ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
        : 'dd/mm/yyyy'.tr;

    final String guestSummary =
        '$_hotelRoomCount Unit${_hotelRoomCount > 1 ? 's' : ''} · $_hotelAdultCount Adult${_hotelAdultCount > 1 ? 's' : ''} · $_hotelChildCount Child${_hotelChildCount != 1 ? 'ren' : ''}';

    // Shared border style helper
    OutlineInputBorder _border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        );

    // Shared read-only field decoration
    InputDecoration _fieldDecoration({
      required String hint,
      required Widget prefixIcon,
      bool hasError = false,
    }) =>
        InputDecoration(
          hintText: hint,
          border: _border(kBorderColor),
          enabledBorder: _border(kBorderColor),
          focusedBorder: _border(kPrimaryColor),
          errorBorder: _border(Colors.red),
          focusedErrorBorder: _border(Colors.red),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: prefixIcon,
          ),
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: kMutedColor,
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Form(
        key: _hotelFormKey,
        autovalidateMode: _hotelValidationAttempted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Destination field ──────────────────────────────────────────
            Text(
              'Destination'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 4),
            Consumer<HotelDestinationProvider>(
              builder: (context, destProvider, _) {
                return TextFormField(
                  controller: _hotelDestinationController,
                  readOnly: true,
                  validator: (_) {
                    if (!destProvider.hasValidHotelDestination) {
                      return 'Please select a destination'.tr;
                    }
                    return null;
                  },
                  onTap: () {
                    // Open the hotel destination selection sheet
                    HotelDestinationSelectionSheet.show(
                      context,
                      onDestinationSelected: (destination) {
                        _hotelDestinationController.text =
                            destination.displayName ?? '';
                      },
                    );
                  },
                  decoration: _fieldDecoration(
                    hint: 'Search destination'.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: kMutedColor,
                      size: 20,
                    ),
                  ).copyWith(
                    suffixIcon: _hotelDestinationController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18, color: kMutedColor),
                            onPressed: () {
                              _hotelDestinationController.clear();
                              destProvider.clearHotelDestination();
                            },
                          )
                        : null,
                  ),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: kHeadingColor,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── Check-in / Check-out row ────────────────────────────────────
            Row(
              children: [
                // Check-in
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kHeadingColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormField<DateTime>(
                        initialValue: _checkInDate,
                        validator: (_) {
                          if (_checkInDate == null) return 'Required'.tr;
                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _checkInDate = picked;
                                      formFieldState.didChange(picked);
                                    });
                                  }
                                },
                                child: Container(
                                  height: 47,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: formFieldState.hasError
                                            ? Colors.red
                                            : kBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/calendar.svg',
                                        width: 16,
                                        height: 16,
                                        color: kMutedColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          checkInText,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _checkInDate != null
                                                ? kHeadingColor
                                                : kMutedColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, top: 4),
                                  child: Text(
                                    formFieldState.errorText ?? '',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 11),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Check-out
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-out'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kHeadingColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormField<DateTime>(
                        initialValue: _checkOutDate,
                        validator: (_) {
                          if (_checkOutDate == null) return 'Required'.tr;
                          if (_checkInDate != null &&
                              _checkOutDate != null &&
                              (_checkOutDate!.isBefore(_checkInDate!) ||
                                  _checkOutDate!
                                      .isAtSameMomentAs(_checkInDate!))) {
                            return 'After check-in'.tr;
                          }
                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _checkInDate ?? DateTime.now(),
                                    firstDate: _checkInDate ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _checkOutDate = picked;
                                      formFieldState.didChange(picked);
                                    });
                                  }
                                },
                                child: Container(
                                  height: 47,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: formFieldState.hasError
                                            ? Colors.red
                                            : kBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/calendar.svg',
                                        width: 16,
                                        height: 16,
                                        color: kMutedColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          checkOutText,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _checkOutDate != null
                                                ? kHeadingColor
                                                : kMutedColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, top: 4),
                                  child: Text(
                                    formFieldState.errorText ?? '',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 11),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Guests field ───────────────────────────────────────────────
            Text(
              'Guests'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _showGuestSelector,
              child: Container(
                height: 47,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/user.svg',
                      width: 20,
                      height: 20,
                      color: kMutedColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        guestSummary,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: kHeadingColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: kMutedColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Search Button ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isHotelSearchLoading
                    ? null
                    : () {
                        // Validate form
                        setState(() {
                          _hotelValidationAttempted = true;
                        });
                        if (!_hotelFormKey.currentState!.validate()) {
                          print('[HOTEL_SEARCH] Validation failed');
                          return;
                        }

                        // Get city from selected destination
                        final destProvider =
                            context.read<HotelDestinationProvider>();
                        if (!destProvider.hasValidHotelDestination) {
                          print(
                              '[HOTEL_SEARCH] Error: No destination selected');
                          return;
                        }

                        final cityName =
                            destProvider.selectedHotelDestination!.city ?? '';
                        if (cityName.isEmpty) {
                          print('[HOTEL_SEARCH] Error: City name is empty');
                          return;
                        }

                        print('[HOTEL_SEARCH] Search Hotels button tapped');
                        print(
                            '[HOTEL_SEARCH] Validation passed - City: $cityName, Check-in: $_checkInDate, Check-out: $_checkOutDate, Adults: $_hotelAdultCount, Children: $_hotelChildCount, Rooms: $_hotelRoomCount');

                        // Navigate immediately — results screen handles API and shimmer
                        print(
                            '[HOTEL_SEARCH] Navigating to results screen immediately');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelSearchResultsScreen(
                              cityName: cityName,
                              checkInDate: _checkInDate,
                              checkOutDate: _checkOutDate,
                              guests: _guestCount,
                              adults: _hotelAdultCount,
                              children: _hotelChildCount,
                              rooms: _hotelRoomCount,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/search.svg',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search Hotels'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //zeeshan
  Widget _buildFeaturedDestinations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Destinations'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kHeadingColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HotelSearchResultsScreen()));
                },
                child: Text(
                  'View all'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Static featured destinations images
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFeaturedDestinationCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
                  title: 'Paris, France',
                  subtitle: 'City of Love',
                  isBestSeller: true,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=400&h=250&fit=crop',
                  title: 'Tokyo, Japan',
                  subtitle: 'Modern Metropolis',
                  isBestSeller: false,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
                  title: 'Bali, Indonesia',
                  subtitle: 'Tropical Paradise',
                  isBestSeller: true,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?w=400&h=250&fit=crop',
                  title: 'New York, USA',
                  subtitle: 'The Big Apple',
                  isBestSeller: false,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

//zeeshan
  Widget _buildFeaturedDestinationCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required bool isBestSeller,
  }) {
    return Container(
      width: 280,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - takes more space
          Expanded(
            flex: 2, // Image takes 2/3 of the card
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Best Seller'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Text section
          Expanded(
            flex: 1, // Text takes 1/3 of the card
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kHeadingColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: kMutedColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider2 = Provider.of<VendorAuthProvider>(context, listen: true);
    return Consumer6<HomeProvider, BoatProvider, TourProvider, SpaceProvider,
        EventProvider, FlightProvider>(
      builder: (context, homeProvider, boatProvider, tourProvider,
          spaceProvider, eventProvider, flightProvider, child) {
        return DefaultTabController(
          length: categoryDatas.length,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(160),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        //search button
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Hello, Welcome back!".tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: kSubtitleColor,
                                    ),
                                  ),
                                  Text(
                                    "Explore World".tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: kHeadingColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Consumer<CurrencyProvider>(
                                    builder: (context, currencyProvider, _) {
                                      final currentCurrency = CurrencyProvider
                                                  .currencyMap[
                                              currencyProvider
                                                  .selectedCurrency] ??
                                          CurrencyProvider.currencyMap['USD']!;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: kBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: currencyProvider
                                                .selectedCurrency,
                                            isDense: true,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 18,
                                                color: kSubtitleColor),
                                            // Display button: flag + code
                                            selectedItemBuilder: (context) =>
                                                CurrencyProvider
                                                    .supportedCurrencies
                                                    .map((currencyCode) {
                                              final data =
                                                  CurrencyProvider.currencyMap[
                                                          currencyCode] ??
                                                      CurrencyProvider
                                                          .currencyMap['USD']!;
                                              return Center(
                                                child: Text(
                                                  '${data.flag} ${data.code}',
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: kHeadingColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            // Dropdown items: flag + code + name
                                            items: CurrencyProvider
                                                .supportedCurrencies
                                                .map((currencyCode) {
                                              final data =
                                                  CurrencyProvider.currencyMap[
                                                          currencyCode] ??
                                                      CurrencyProvider
                                                          .currencyMap['USD']!;
                                              return DropdownMenuItem(
                                                value: currencyCode,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      data.flag,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      data.code,
                                                      style: GoogleFonts
                                                          .spaceGrotesk(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: kHeadingColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                currencyProvider
                                                    .setCurrency(value);
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NotificationsScreen(),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/Bell.svg',
                                        ),
                                      ),
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          constraints: BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              provider2.notificationcountmodel
                                                      ?.unreadCount
                                                      .toString() ??
                                                  "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kSurfaceColor,
                        ),
                        height: 56,
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  categoryDatas.asMap().entries.map((entry) {
                                int categoryId = entry.value.id;
                                int tabIndex = entry.key; // sequential position
                                var category = entry.value;
                                bool isSelected =
                                    homeProvider.selectedHomeTab == categoryId;

                                return GestureDetector(
                                  onTap: () async {
                                    if (selectedSort != 'Recommended'.tr) {
                                      selectedSort = 'Recommended'.tr;
                                    }
                                    await _fetchDataForTab(categoryId);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? kPrimaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              category.kIcon,
                                              color: isSelected
                                                  ? Colors.white
                                                  : kMutedColor,
                                              height: 14,
                                              width: 14,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          category.category.tr,
                                          style: GoogleFonts.spaceGrotesk(
                                            color: isSelected
                                                ? Colors.white
                                                : kMutedColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: isLoading
                ? Center(child: CircularProgressIndicator())
                : Consumer<HomeProvider>(
                    builder: (
                      context,
                      homeProvider,
                      child,
                    ) {
                      final homeList = homeProvider.homeListPerCategory[0];

                      return TabBarView(
                        controller: homeProvider.tabController,
                        children: categoryDatas.map<Widget>((cat) {
                          return _buildTabContent(
                            cat.id,
                            homeList,
                            homeProvider,
                            boatProvider,
                            tourProvider,
                            spaceProvider,
                            eventProvider,
                            flightProvider,
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  /// Build tab content widget based on category ID
  Widget _buildTabContent(
    int categoryId,
    dynamic homeList,
    HomeProvider homeProvider,
    BoatProvider boatProvider,
    TourProvider tourProvider,
    SpaceProvider spaceProvider,
    EventProvider eventProvider,
    FlightProvider flightProvider,
  ) {
    switch (categoryId) {
      case 0: // Home
        return homeList == null
            ? const Center(child: CircularProgressIndicator())
            : MixedItemList(homeList: homeList);
      case 1: // Hotels
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHotelSearchSection(context),
              _buildFeaturedDestinations(),
            ],
          ),
        );
      case 2: // Tours
        return Column(
          children: [
            _buildResultsCount(2, homeProvider, boatProvider, tourProvider,
                spaceProvider, eventProvider, flightProvider),
            Expanded(
              child: TourListItem(
                  tourList: tourProvider.tourListPerCategory[2] ?? TourList()),
            ),
          ],
        );
      case 3: // Spaces
        return Column(
          children: [
            _buildResultsCount(3, homeProvider, boatProvider, tourProvider,
                spaceProvider, eventProvider, flightProvider),
            Expanded(
              child: SpaceListItem(
                  spaceList:
                      spaceProvider.spaceListPerCategory[3] ?? SpaceList()),
            ),
          ],
        );
      case 4: // Cars
        return Column(
          children: [
            _buildResultsCount(4, homeProvider, boatProvider, tourProvider,
                spaceProvider, eventProvider, flightProvider),
            Expanded(
              child: CarListItem(
                  carList: homeProvider.carListPerCategory[4] ?? CarList()),
            ),
          ],
        );
      case 5: // Events
        return Column(
          children: [
            _buildResultsCount(5, homeProvider, boatProvider, tourProvider,
                spaceProvider, eventProvider, flightProvider),
            Expanded(
              child: EventListItem(
                  eventList:
                      eventProvider.eventListPerCategory[5] ?? EventList()),
            ),
          ],
        );
      case 6: // Flights
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildFlightSearchSection(context),
              _buildFeaturedDestinations(),
            ],
          ),
        );
      case 7: // Boats
        return Column(
          children: [
            _buildResultsCount(7, homeProvider, boatProvider, tourProvider,
                spaceProvider, eventProvider, flightProvider),
            Expanded(
              child: BoatListItem(
                  boatList: boatProvider.boatListPerCategory[7] ?? BoatList()),
            ),
          ],
        );
      case 8: // Activities
        return SingleChildScrollView(
          child: Column(
            children: [
              const ActivitySearchWidget(),
              _buildFeaturedDestinations(),
            ],
          ),
        );
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildResultsCount(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    // Get location based on category
    String location = _getLocationForCategory(index, homeProvider, boatProvider,
        tourProvider, spaceProvider, eventProvider, flightProvider);

    // Get item count
    int itemCount = _getItemCount(index, homeProvider, boatProvider,
        tourProvider, spaceProvider, eventProvider, flightProvider);

    // Get results text (Showing X-Y of Z)
    String resultsText = _getResultsText(index, homeProvider, boatProvider,
        tourProvider, spaceProvider, eventProvider, flightProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location.isNotEmpty)
                  Text(
                    '$itemCount ${'items found in'.tr} $location',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                if (location.isEmpty)
                  Text(
                    '$itemCount ${'items found'.tr}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                if (resultsText.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    resultsText,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8),
          // Filter Icon Button
          GestureDetector(
            onTap: () => _navigateToFilterScreen(index),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/filters.svg',
                  color: kPrimaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'Filters'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//zeeshan friday 12.12.25
// Helper method to get location for each category
  String _getLocationForCategory(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    switch (index) {
      case 1: // Hotels
        final data = homeProvider.hotelListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'Paris';

      case 2: // Tours
        final data = tourProvider.tourListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'England';

      case 3: // Spaces
        final data = spaceProvider.spaceListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'England';

      case 4: // Cars
        final data = homeProvider.carListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'London';

      case 5: // Events
        final data = eventProvider.eventListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'Paris';

      case 6: // Flights
        return ''; // Flights might not have a single location

      case 7: // Boats
        final data = boatProvider.boatListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return '--';
        }
        return 'Marina';

      default:
        return '';
    }
  }

// Navigate to appropriate filter screen
  void _navigateToFilterScreen(int index) {
    switch (index) {
      case 1: // Hotels
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterScreen(),
        ));
        break;
      case 2: // Tours
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterTourScreen(),
        ));
        break;
      case 3: // Spaces
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterSpaceScreen(),
        ));
        break;
      case 4: // Cars
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterCarScreen(),
        ));
        break;
      case 5: // Events
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterEventScreen(),
        ));
        break;
      case 6: // Flights
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterFlightScreen(),
        ));
        break;
      case 7: // Boats
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FilterBoatScreen(),
        ));
        break;
    }
  }
//zeeshan friday 12.12.25...end

  void _showSortingOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            _buildSortOption('Price (High to Low)'.tr, 'price_high_low', index),
            Divider(),
            _buildSortOption('Price (Low to High)'.tr, 'price_low_high', index),
            Divider(),
            _buildSortOption('Rating (High to Low)'.tr, 'rate_high_low', index),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String sortBy, int index) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() => selectedSort = title);
        Navigator.pop(context);
        _fetchSortedData(sortBy, index);
      },
    );
  }

  void _fetchSortedData(String sortBy, int index) {
    log('$index loggggg');
    log('$sortBy loggggg');
    setState(() {
      isLoading = true;
    });

    switch (index) {
      case 1:
        Provider.of<HomeProvider>(context, listen: false)
            .hotellistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 2:
        Provider.of<TourProvider>(context, listen: false)
            .tourlistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 3:
        Provider.of<SpaceProvider>(context, listen: false)
            .spacelistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 4:
        Provider.of<HomeProvider>(context, listen: false)
            .carlistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 5:
        Provider.of<EventProvider>(context, listen: false)
            .eventlistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 6:
        Provider.of<FlightProvider>(context, listen: false)
            .flightlistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 7:
        Provider.of<BoatProvider>(context, listen: false)
            .boatlistapi(index, sortBy: sortBy, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
    }
  }

  int _getItemCount(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    switch (index) {
      case 1:
        return homeProvider.hotelListPerCategory[index]?.total ?? 0;
      case 2:
        return tourProvider.tourListPerCategory[index]?.total ?? 0;
      case 3:
        return spaceProvider.spaceListPerCategory[index]?.total ?? 0;
      case 4:
        return homeProvider.carListPerCategory[index]?.total ?? 0;
      case 5:
        return eventProvider.eventListPerCategory[index]?.total ?? 0;
      case 6:
        return flightProvider.flightListPerCategory[index]?.data?.length ?? 0;
      case 7:
        return boatProvider.boatListPerCategory[index]?.total ?? 0;
      default:
        return 0;
    }
  }

  String _getResultsText(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    switch (index) {
      case 1:
        return homeProvider.hotelListPerCategory[index]?.text ?? '';
      case 2:
        return tourProvider.tourListPerCategory[index]?.text ?? '';
      case 3:
        return spaceProvider.spaceListPerCategory[index]?.text ?? '';
      case 4:
        return homeProvider.carListPerCategory[index]?.text ?? '';
      case 5:
        return eventProvider.eventListPerCategory[index]?.text ?? '';
      case 6:
        return '';
      case 7:
        return boatProvider.boatListPerCategory[index]?.text ?? '';
      default:
        return '';
    }
  }

  int _getStartId(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    switch (index) {
      case 1:
        return homeProvider.hotelListPerCategory[index]?.startId ?? 1;
      case 2:
        return tourProvider.tourListPerCategory[index]?.startId ?? 1;
      case 3:
        return spaceProvider.spaceListPerCategory[index]?.startId ?? 1;
      case 4:
        return homeProvider.carListPerCategory[index]?.startId ?? 1;
      case 5:
        return eventProvider.eventListPerCategory[index]?.startId ?? 1;
      case 6:
        return 1;
      case 7:
        return boatProvider.boatListPerCategory[index]?.startId ?? 1;
      default:
        return 1;
    }
  }

  int _getEndId(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    switch (index) {
      case 1:
        return homeProvider.hotelListPerCategory[index]?.endId ?? 1;
      case 2:
        return tourProvider.tourListPerCategory[index]?.endId ?? 1;
      case 3:
        return spaceProvider.spaceListPerCategory[index]?.endId ?? 1;
      case 4:
        return homeProvider.carListPerCategory[index]?.endId ?? 1;
      case 5:
        return eventProvider.eventListPerCategory[index]?.endId ?? 1;
      case 6:
        return flightProvider.flightListPerCategory[index]?.data?.length ?? 0;
      case 7:
        return boatProvider.boatListPerCategory[index]?.endId ?? 1;
      default:
        return 1;
    }
  }
}

class OfferCarousel extends StatelessWidget {
  final List<home_item.Offer> offers;

  const OfferCarousel({Key? key, required this.offers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 10 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: offers.map((offer) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: NetworkImage(offer.backgroundImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (offer.featuredText != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              offer.featuredText!,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        SizedBox(height: 16),
                        Text(
                          offer.title,
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          offer.desc.replaceAll('<br>', ' '),
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class MixedItemList extends StatefulWidget {
  final home_item.HomeList homeList;

  const MixedItemList({super.key, required this.homeList});

  @override
  State<MixedItemList> createState() => _MixedItemListState();
}

class _MixedItemListState extends State<MixedItemList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<HomeProvider>();
        // Index 0 for Home
        if (!provider.isHomeLoadingMore(0)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more home blocks...");
          provider.fetchNextHomePage(0);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<HomeProvider>().resetHomePagination(0);
  }

  @override
  Widget build(BuildContext context) {
    final homeList = widget.homeList;
    final isLoadingMore =
        context.select<HomeProvider, bool>((p) => p.isHomeLoadingMore(0));

    print(
        "BLOCK TYPE => MixedItemList build with ${homeList.items.length} items");

    // Group items by type for display
    final hotelItems = homeList.items
        .where((item) => item.type == home_item.ItemType.hotel)
        .toList();
    final tourItems = homeList.items
        .where((item) => item.type == home_item.ItemType.tour)
        .toList();
    final spaceItems = homeList.items
        .where((item) => item.type == home_item.ItemType.space)
        .toList();
    final carItems = homeList.items
        .where((item) => item.type == home_item.ItemType.car)
        .toList();
    final boatItems = homeList.items
        .where((item) => item.type == home_item.ItemType.boat)
        .toList();
    final eventItems = homeList.items
        .where((item) => item.type == home_item.ItemType.event)
        .toList();
    final locationItems = homeList.items
        .where((item) => item.type == home_item.ItemType.location)
        .toList();

    // Debug print block types and image URLs
    for (var item in hotelItems) {
      final hotel = item.item as dynamic;
      print("BLOCK TYPE => list_hotel");
      print(
          "IMAGE URL => ${hotel.gallery?.isNotEmpty == true ? hotel.gallery!.first : 'null'}");
    }
    for (var item in tourItems) {
      final tour = item.item as dynamic;
      print("BLOCK TYPE => list_tours");
      print(
          "IMAGE URL => ${tour.gallery?.isNotEmpty == true ? tour.gallery!.first : 'null'}");
    }
    for (var item in carItems) {
      final car = item.item as dynamic;
      print("BLOCK TYPE => list_car");
      print(
          "IMAGE URL => ${car.gallery?.isNotEmpty == true ? car.gallery!.first : 'null'}");
    }
    for (var item in spaceItems) {
      final space = item.item as dynamic;
      print("BLOCK TYPE => list_space");
      print(
          "IMAGE URL => ${space.gallery?.isNotEmpty == true ? space.gallery!.first : 'null'}");
    }
    for (var item in boatItems) {
      final boat = item.item as dynamic;
      print("BLOCK TYPE => list_boat");
      print(
          "IMAGE URL => ${boat.gallery?.isNotEmpty == true ? boat.gallery!.first : 'null'}");
    }
    for (var item in eventItems) {
      final event = item.item as dynamic;
      print("BLOCK TYPE => list_event");
      print(
          "IMAGE URL => ${event.gallery?.isNotEmpty == true ? event.gallery!.first : 'null'}");
    }
    for (var item in locationItems) {
      final location = item.item as dynamic;
      print("BLOCK TYPE => list_location");
      print(
          "IMAGE URL => ${location.imgUrl ?? location.bannerImgUrl ?? 'null'}");
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hotelItems.isNotEmpty)
                _buildCategorySection(
                  "Bestseller Listing".tr,
                  "Hotels highly rated for thoughtful design".tr,
                  hotelItems,
                  context,
                ),
              if (tourItems.isNotEmpty)
                _buildCategorySection(
                  "Our Best Promotion Tours".tr,
                  "Most popular destinations".tr,
                  tourItems,
                  context,
                ),
              if (spaceItems.isNotEmpty)
                _buildCategorySection(
                  "Rental Listing".tr,
                  "Homes highly rated for thoughtful design".tr,
                  spaceItems,
                  context,
                ),
              if (carItems.isNotEmpty)
                _buildCategorySection(
                  "Car Trending".tr,
                  "Book incredible things to do around the world".tr,
                  carItems,
                  context,
                ),
              if (boatItems.isNotEmpty)
                _buildCategorySection(
                  "Boat Listing".tr,
                  "Book incredible things to do around the world".tr,
                  boatItems,
                  context,
                ),
              if (eventItems.isNotEmpty)
                _buildCategorySection(
                  "Event Listing".tr,
                  "Explore exciting events near you".tr,
                  eventItems,
                  context,
                ),
              if (locationItems.isNotEmpty)
                _buildCategorySection(
                  "Top Destinations".tr,
                  "Hotel highly rated for thoughtful design".tr,
                  locationItems,
                  context,
                ),
              if (isLoadingMore)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 4,
                        ),
                        SizedBox(height: 8),
                        Text("Loading more content...",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, String subtitle,
      List<home_item.HomeItem> items, BuildContext context) {
    print("BLOCK TYPE => ${title} | TOTAL ITEMS => ${items.length}");

    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: darkgrey,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.only(left: 0, right: 0),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: _buildItemWidget(item, context),
            );
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemWidget(home_item.HomeItem item, BuildContext context) {
    print("Building item widget for type: ${item.type}");
    switch (item.type) {
      case home_item.ItemType.hotel:
        return PropertyItem(
          dataSrc: PropertyData.fromHotel(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RoomDetailScreen(
                      hotelId: item.item.id?.toString() ?? '0',
                    )),
          ),
        );
      case home_item.ItemType.car:
        return CarDataItem(
          dataSrc: CarData.fromCar(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarRentalDetailsScreen(
                      carId: CarData.fromCar(item.item).id ?? 0,
                    )),
          ),
        );
      case home_item.ItemType.event:
        return EventItem(
          dataSrc: EvenData.fromEvent(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventsDetailsScreen(
                      eventId: EvenData.fromEvent(item.item).id ?? 0,
                    )),
          ),
        );
      case home_item.ItemType.tour:
        return TourItem(
          dataSrc: TourData.fromTour(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TourPage(tourId: item.item.id)),
          ),
        );
      case home_item.ItemType.space:
        return SpaceItem(
          dataSrc: SpaceData.fromSpace(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SpacePage(
                      spaceId: item.item.id,
                    )),
          ),
        );
      case home_item.ItemType.boat:
        return BoatItem(
          dataSrc: BoatData.fromBoat(item.item),
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BoatDetailsScreen(
                      boatId: item.item.id,
                    )),
          ),
        );
      case home_item.ItemType.flight:
        return FlightItem(
          dataSrc: FlightData.fromFlight(item.item),
          press: () {
            // NOTE: Old flight details navigation removed
            // Flight booking now uses the new prebook flow on Available Flights screen
            log('[HomeScreen] Flight item clicked - TODO: Implement new flow if needed');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please use the flights search to book'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      case home_item.ItemType.offer:
        return OfferItem(
          offer: item.item as home_item.Offer,
          press: () {
            // Handle offer item press
          },
        );
      case home_item.ItemType.location:
        return DestinationItem(
          location: item.item as home_item.Location,
          press: () {
            // Handle destination item press
          },
        );
      default:
        print("Unhandled item type: ${item.type}".tr);
        return SizedBox.shrink();
    }
  }
}

// property list

class HotelListItem extends StatelessWidget {
  final HotelList hotelList;

  const HotelListItem({super.key, required this.hotelList});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeProvider>().hotellistapi(1, searchParams: {});
  }

  @override
  Widget build(BuildContext context) {
    final hotelDataList = hotelList.data ?? [];

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _onRefresh(context),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: hotelDataList.length,
              itemBuilder: (context, index) {
                final hotel = hotelDataList[index];
                final propertyData = PropertyData.fromHotel(hotel);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: PropertyItem(
                    dataSrc: propertyData,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailScreen(
                              hotelId: propertyData.id.toString()),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CarListItem extends StatefulWidget {
  final CarList carList;

  const CarListItem({super.key, required this.carList});

  @override
  State<CarListItem> createState() => _CarListItemState();
}

class _CarListItemState extends State<CarListItem> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<HomeProvider>();
        // Index 4 for Cars in HomeScreen
        if (!provider.isCarLoadingMore(4)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more cars...");
          provider.fetchNextCarPage(4);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<HomeProvider>().resetCarPagination(4);
  }

  @override
  Widget build(BuildContext context) {
    final carDataList = widget.carList.data ?? [];
    final isLoadingMore =
        context.select<HomeProvider, bool>((p) => p.isCarLoadingMore(4));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: carDataList.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= carDataList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 8),
                          Text("Loading more cars...",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                final rawCar = carDataList[index];
                final carData = CarData.fromCar(rawCar);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: CarDataItem(
                    dataSrc: carData,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CarRentalDetailsScreen(carId: rawCar.id ?? 0),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class EventListItem extends StatefulWidget {
  final EventList eventList;

  const EventListItem({super.key, required this.eventList});

  @override
  State<EventListItem> createState() => _EventListItemState();
}

class _EventListItemState extends State<EventListItem> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<EventProvider>();
        // Index 5 for Events
        if (!provider.isLoadingMore(5)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more events...");
          provider.fetchNextPage(5);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<EventProvider>().resetPagination(5);
  }

  @override
  Widget build(BuildContext context) {
    final eventDataList = widget.eventList.data ?? [];
    final isLoadingMore =
        context.select<EventProvider, bool>((p) => p.isLoadingMore(5));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: eventDataList.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= eventDataList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 8),
                          Text("Loading more events...",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                final rawEvent = eventDataList[index];
                final eventData = EvenData.fromEvent(rawEvent);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: EventItem(
                    dataSrc: eventData,
                    press: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventsDetailsScreen(
                            eventId: rawEvent.id ?? 0,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

//new
// ================ HOTEL PROPERTY CARD ================
class PropertyItem extends StatefulWidget {
  const PropertyItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final PropertyData dataSrc;
  final VoidCallback press;

  @override
  State<PropertyItem> createState() => _PropertyItemState();
}

class _PropertyItemState extends State<PropertyItem> {
  @override
  Widget build(BuildContext context) {
    return buildPropertyCard(
      context: context,
      images: widget.dataSrc.images,
      title: widget.dataSrc.propertyName,
      subtitle: widget.dataSrc.address,
      rating: double.parse(widget.dataSrc.reviewscore),
      reviewCount: widget.dataSrc.reviewcount,
      reviewText: widget.dataSrc.reviewtext,
      price: widget.dataSrc.price,
      isWishlist: widget.dataSrc.isWishlist,
      isFeatured: true,
      discount: 0,
      onTap: widget.press,
      onWishlistTap: _handleWishlistTap,
      type: 'hotel'.tr,
      id: widget.dataSrc.id.toString(),
      badgeText: 'HOTEL'.tr,
      badgeColor: Colors.blue,
      priceSuffix: '/night'.tr,
      features: null,
    );
  }

  Future<void> _handleWishlistTap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken'.tr);

    if (token == null) {
      showLoginBottomSheet(context);
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final success = await homeProvider.addToWishlist(
      widget.dataSrc.id.toString(),
      'hotel'.tr,
    );

    homeProvider.homelistapi(0);
    homeProvider.fetchHotelDetails(widget.dataSrc.id.toString());
    await homeProvider.hotellistapi(1, searchParams: {});

    if (success == "Added to wishlist".tr) {
      setState(() {
        widget.dataSrc.isWishlist = true;
      });
    } else if (success == "Removed from wishlist".tr) {
      setState(() {
        widget.dataSrc.isWishlist = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class TourListItem extends StatefulWidget {
  final TourList tourList;

  const TourListItem({super.key, required this.tourList});

  @override
  State<TourListItem> createState() => _TourListItemState();
}

class _TourListItemState extends State<TourListItem> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<TourProvider>();
        // 2 is the index for Tours in HomeScreen
        if (!provider.isLoadingMore(2)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more tours...");
          provider.fetchNextPage(2);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<TourProvider>().resetPagination(2);
  }

  @override
  Widget build(BuildContext context) {
    final tourDataList = widget.tourList.data;
    final isLoadingMore =
        context.select<TourProvider, bool>((p) => p.isLoadingMore(2));

    if (tourDataList == null || tourDataList.isEmpty) {
      return Center(child: Text("No tours found".tr));
    }

    return Column(
      children: [
        Expanded(
          //........
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20, // Add bottom padding
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: tourDataList.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= tourDataList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.red, // Bright color for debugging
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 8),
                          Text("Loading more items...",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                var tourData = TourData.fromTour(tourDataList[index]);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TourItem(
                    dataSrc: tourData,
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TourPage(tourId: tourData.id!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SpaceListItem extends StatefulWidget {
  final SpaceList spaceList;

  const SpaceListItem({super.key, required this.spaceList});

  @override
  State<SpaceListItem> createState() => _SpaceListItemState();
}

class _SpaceListItemState extends State<SpaceListItem> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<SpaceProvider>();
        // Index 3 for Spaces
        if (!provider.isLoadingMore(3)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more spaces...");
          provider.fetchNextPage(3);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<SpaceProvider>().resetPagination(3);
  }

  @override
  Widget build(BuildContext context) {
    final spaceDataList = widget.spaceList.data;
    final isLoadingMore =
        context.select<SpaceProvider, bool>((p) => p.isLoadingMore(3));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: (spaceDataList?.length ?? 0) + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (spaceDataList == null || spaceDataList.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (index >= spaceDataList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 8),
                          Text("Loading more spaces...",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                var spaceData = SpaceData.fromSpace(spaceDataList[index]);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: SpaceItem(
                    dataSrc: spaceData,
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpacePage(
                          spaceId: spaceData.id!,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BoatListItem extends StatefulWidget {
  final BoatList boatList;

  const BoatListItem({super.key, required this.boatList});

  @override
  State<BoatListItem> createState() => _BoatListItemState();
}

class _BoatListItemState extends State<BoatListItem> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        final provider = context.read<BoatProvider>();
        // Index 7 for Boats in HomeScreen
        if (!provider.isLoadingMore(7)) {
          print("⚡ SCROLL LISTENER FIRED: Loading more boats...");
          provider.fetchNextPage(7);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<BoatProvider>().resetPagination(7);
  }

  @override
  Widget build(BuildContext context) {
    final boatDataList = widget.boatList.data;
    final isLoadingMore =
        context.select<BoatProvider, bool>((p) => p.isLoadingMore(7));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: (boatDataList?.length ?? 0) + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                final list = boatDataList;
                if (list == null || list.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (index >= list.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 8),
                          Text("Loading more boats...",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                final boatData = BoatData.fromBoat(list[index]);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: BoatItem(
                    dataSrc: boatData,
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BoatDetailsScreen(
                                boatId: widget.boatList.data![index].id ?? 1,
                              )),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────
// FLIGHT FILTER / SORT STATE  (file-private)
// ───────────────────────────────────────────────────────────

enum _FlightSortBy { price, duration, departure, arrival }

enum _StopsFilter { any, direct, oneStop, twoPlus }

enum _DepartureTimeFilter { any, morning, afternoon, evening }

class _FlightFilterState {
  final double minPrice;
  final double maxPrice;
  final _StopsFilter stopsFilter;
  final _DepartureTimeFilter departureTimeFilter;

  const _FlightFilterState({
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.stopsFilter = _StopsFilter.any,
    this.departureTimeFilter = _DepartureTimeFilter.any,
  });

  bool get isActive =>
      minPrice != 0 ||
      maxPrice != 50000 ||
      stopsFilter != _StopsFilter.any ||
      departureTimeFilter != _DepartureTimeFilter.any;

  _FlightFilterState copyWith({
    double? minPrice,
    double? maxPrice,
    _StopsFilter? stopsFilter,
    _DepartureTimeFilter? departureTimeFilter,
  }) =>
      _FlightFilterState(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        stopsFilter: stopsFilter ?? this.stopsFilter,
        departureTimeFilter: departureTimeFilter ?? this.departureTimeFilter,
      );
}

// ───────────────────────────────────────────────────────────
// FLIGHT LIST SCREEN
// ───────────────────────────────────────────────────────────

class FlightListItem extends StatefulWidget {
  final FlightList flightList;
  final Map<String, dynamic>? searchParams;
  final String? departureCity;
  final String? destinationCity;
  final VoidCallback? onBackPressed;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final bool isRoundTrip;

  const FlightListItem({
    super.key,
    required this.flightList,
    this.searchParams,
    this.departureCity,
    this.destinationCity,
    this.onBackPressed,
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
    this.isRoundTrip = false,
  });

  @override
  State<FlightListItem> createState() => _FlightListItemState();
}

class _FlightListItemState extends State<FlightListItem> {
  bool _showShimmer = true;
  List<Flight> _flights = [];

  // ── Pagination state ────────────────────────────────────
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalFlights = 0;
  bool _isLoadingMore = false;
  bool _allLoaded = false;
  final ScrollController _scrollController = ScrollController();

  // ── Filter / Sort state ─────────────────────────────────
  _FlightFilterState _activeFilter = const _FlightFilterState();
  _FlightSortBy _sortBy = _FlightSortBy.price;

  // ── Helpers ──────────────────────────────────────────────

  /// Safely parse any price-like value to double.
  static double _parsePrice(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  /// Parse duration strings like "10h 50m", "7h 54m", "45m" into total minutes.
  static int _parseDurationMinutes(String? s) {
    if (s == null || s.isEmpty) return 0;
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(s);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(s);
    final hours =
        hMatch != null ? int.tryParse(hMatch.group(1) ?? '0') ?? 0 : 0;
    final mins = mMatch != null ? int.tryParse(mMatch.group(1) ?? '0') ?? 0 : 0;
    return hours * 60 + mins;
  }

  /// Parse datetime strings. Handles:
  ///   "20 Apr, 2026 01:50"  (API full datetime)
  ///   "01:50"               (time-only, anchored to epoch date for comparison)
  ///   ISO 8601 "2026-04-20T01:50:00"
  static DateTime? _parseDateTime(String? s) {
    if (s == null || s.isEmpty) return null;
    // Try ISO 8601 first
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Try "dd MMM, yyyy HH:mm" or "dd MMM yyyy HH:mm"
    try {
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final re =
          RegExp(r'(\d{1,2})\s+([A-Za-z]+),?\s+(\d{4})\s+(\d{1,2}):(\d{2})');
      final m = re.firstMatch(s);
      if (m != null) {
        final day = int.parse(m.group(1)!);
        final month = months[m.group(2)] ?? 1;
        final year = int.parse(m.group(3)!);
        final hour = int.parse(m.group(4)!);
        final min = int.parse(m.group(5)!);
        return DateTime(year, month, day, hour, min);
      }
    } catch (_) {}
    // Try time-only "HH:MM" – anchor to epoch for ordering
    final timeRe = RegExp(r'^(\d{1,2}):(\d{2})$');
    final tm = timeRe.firstMatch(s.trim());
    if (tm != null) {
      return DateTime(
          2000, 1, 1, int.parse(tm.group(1)!), int.parse(tm.group(2)!));
    }
    return null;
  }

  /// Extract the departure hour for time-of-day filtering.
  /// Priority: flight.departureAt → flightDetails[0].depTime
  static int? _departureHour(Flight f) {
    // Try top-level departure_at first (most complete)
    final dt = _parseDateTime(f.departureAt);
    if (dt != null) return dt.hour;
    // Fall back to depTime from first flight detail
    final depTime = f.flightDetails?.isNotEmpty == true
        ? f.flightDetails![0].depTime
        : null;
    final dt2 = _parseDateTime(depTime);
    return dt2?.hour;
  }

  // ── Core filter + sort method ────────────────────────────

  List<Flight> _filtered(List<Flight> src) {
    final out = src.where((f) {
      // ── Price ───────────────────────────────────────────
      final price = _parsePrice(f.totalPrice);
      if (price > 0 &&
          (price < _activeFilter.minPrice || price > _activeFilter.maxPrice)) {
        return false;
      }

      // ── Stops ───────────────────────────────────────────
      final stops = f.stops ?? 0;
      switch (_activeFilter.stopsFilter) {
        case _StopsFilter.direct:
          if (stops != 0) return false;
          break;
        case _StopsFilter.oneStop:
          if (stops != 1) return false;
          break;
        case _StopsFilter.twoPlus:
          if (stops < 2) return false;
          break;
        case _StopsFilter.any:
          break;
      }

      // ── Departure Time ──────────────────────────────────
      switch (_activeFilter.departureTimeFilter) {
        case _DepartureTimeFilter.morning:
          final h = _departureHour(f);
          if (h == null || h < 6 || h >= 12) return false;
          break;
        case _DepartureTimeFilter.afternoon:
          final h = _departureHour(f);
          if (h == null || h < 12 || h >= 18) return false;
          break;
        case _DepartureTimeFilter.evening:
          final h = _departureHour(f);
          if (h == null || h < 18) return false;
          break;
        case _DepartureTimeFilter.any:
          break;
      }

      return true;
    }).toList();

    // ── Sort ─────────────────────────────────────────────
    switch (_sortBy) {
      case _FlightSortBy.price:
        out.sort((a, b) =>
            _parsePrice(a.totalPrice).compareTo(_parsePrice(b.totalPrice)));
        break;
      case _FlightSortBy.duration:
        out.sort((a, b) => _parseDurationMinutes(a.duration)
            .compareTo(_parseDurationMinutes(b.duration)));
        break;
      case _FlightSortBy.departure:
        out.sort((a, b) {
          final da = _parseDateTime(a.departureAt);
          final db = _parseDateTime(b.departureAt);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        break;
      case _FlightSortBy.arrival:
        out.sort((a, b) {
          final da = _parseDateTime(a.arrivalAt);
          final db = _parseDateTime(b.arrivalAt);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        break;
    }

    return out;
  }

  String get _sortLabel {
    switch (_sortBy) {
      case _FlightSortBy.price:
        return 'Price';
      case _FlightSortBy.duration:
        return 'Duration';
      case _FlightSortBy.departure:
        return 'Departure';
      case _FlightSortBy.arrival:
        return 'Arrival';
    }
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _FlightFilterSheet(
        initial: _activeFilter,
        onApply: (f) => setState(() => _activeFilter = f),
      ),
    );
  }

  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _FlightSortSheet(
        selected: _sortBy,
        onSelect: (s) => setState(() => _sortBy = s),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlights();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreFlights();
    }
  }

  /// Initial load — page 1 only. Replaces any existing list.
  Future<void> _loadFlights() async {
    final provider = Provider.of<FlightProvider>(context, listen: false);
    try {
      final result = await provider.flightlistapi(
        2,
        searchParams: widget.searchParams,
        page: 1,
      );
      if (!mounted) return;
      setState(() {
        _flights = List<Flight>.from(result?.data ?? []);
        _currentPage = 1;
        _lastPage = result?.lastPage ?? 1;
        _totalFlights = result?.total ?? _flights.length;
        _allLoaded = _lastPage <= 1;
        _showShimmer = false;
      });
      log('[FlightList] page 1 loaded ${_flights.length} flights, lastPage=$_lastPage total=$_totalFlights');
    } catch (e) {
      log('[FlightList] API error: $e');
      if (mounted) {
        setState(() {
          _flights = [];
          _showShimmer = false;
        });
      }
    }
  }

  /// Load next page and append. Called on scroll near bottom.
  Future<void> _loadMoreFlights() async {
    if (_isLoadingMore || _allLoaded) return;
    final nextPage = _currentPage + 1;
    if (nextPage > _lastPage) {
      if (mounted) setState(() => _allLoaded = true);
      return;
    }
    if (mounted) setState(() => _isLoadingMore = true);
    try {
      final provider = Provider.of<FlightProvider>(context, listen: false);
      final result = await provider.flightlistapi(
        2,
        searchParams: widget.searchParams,
        page: nextPage,
      );
      if (!mounted) return;
      setState(() {
        _flights.addAll(result?.data ?? []);
        _currentPage = nextPage;
        _allLoaded = _currentPage >= _lastPage;
        _isLoadingMore = false;
      });
      log('[FlightList] page $nextPage loaded ${result?.data?.length ?? 0} flights, total loaded=${_flights.length}');
    } catch (e) {
      log('[FlightList] load-more page $nextPage error: $e');
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFlights = _showShimmer ? <Flight>[] : _filtered(_flights);

    return Scaffold(
      backgroundColor: kScaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Available Flights'.tr,
          style: GoogleFonts.spaceGrotesk(
            color: kHeadingColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: kHeadingColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _showShimmer
          ? ListView.builder(
              itemCount: 4,
              itemBuilder: (_, __) => FlightShimmerCard(
                isRoundTrip: widget.isRoundTrip,
              ),
            )
          : _flights.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // ── Filter / Sort bar ──────────────────────────
                    _FlightFilterSortBar(
                      flightCount: _totalFlights,
                      sortLabel: _sortLabel,
                      filterActive: _activeFilter.isActive,
                      onFilter: _openFilter,
                      onSort: _openSort,
                    ),
                    // No-match state
                    if (filteredFlights.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 56, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No flights match your filters',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: kSubtitleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() =>
                                    _activeFilter = const _FlightFilterState()),
                                child: const Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Flight list
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredFlights.length + 1,
                          itemBuilder: (context, index) {
                            // Footer item
                            if (index == filteredFlights.length) {
                              if (_isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              }
                              if (_allLoaded && _flights.isNotEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      'All $_totalFlights flights loaded',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        color: kVeryMutedColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(height: 16);
                            }

                            final flight = filteredFlights[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: FlightCard(
                                flight: flight,
                                onSelectPressed: () async {
                                  log('[FlightListScreen] Select button tapped for flight: ${flight.id}');
                                  await _handleFlightSelect(
                                    context,
                                    flight,
                                    widget.adultCount,
                                    widget.childCount,
                                    widget.infantCount,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airplanemode_inactive,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 20),
            Text(
              'No Flights Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'We couldn\'t find any flights matching your search criteria.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: kSubtitleColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search parameters.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kVeryMutedColor,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Modify Search'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFlightSelect(
    BuildContext context,
    Flight flight,
    int adults,
    int children,
    int infants,
  ) async {
    log('[FlightSelect] ========== FLIGHT SELECT ==========');
    log('[FlightSelect] Flight ID: ${flight.id}');
    log('[FlightSelect] Provider: ${flight.provider}');
    log('[FlightSelect] Airline: ${flight.airlineName}');
    log('[FlightSelect] Price: ${flight.totalPrice} ${flight.currency}');
    log('[FlightSelect] 📋 Passenger counts being sent to prebook:');
    log('[FlightSelect] Adults: $adults');
    log('[FlightSelect] Children: $children');
    log('[FlightSelect] Infants: $infants');
    log('[FlightSelect] Total: ${adults + children + infants}');

    try {
      // Show loading
      EasyLoading.show(status: 'Preparing your booking...'.tr);

      // Get flight provider
      final flightProvider =
          Provider.of<FlightProvider>(context, listen: false);

      // Call prebook API with selected flight object
      log('[FlightSelect] Calling prebook API with selected flight...');
      final preBookResponse = await flightProvider.preBookFlight(
        selectedFlight: flight,
        adults: adults,
        children: children,
        infants: infants,
      );

      // Dismiss loading
      EasyLoading.dismiss();

      if (preBookResponse != null && preBookResponse.success == true) {
        log('[FlightSelect] ✅ PREBOOK SUCCESSFUL');
        log('[FlightSelect] Price: ${preBookResponse.price}, Currency: ${preBookResponse.currency}');

        // Prepare flight data for checkout screen
        final checkoutData = _prepareFlightCheckoutData(
            flight, preBookResponse, adults, children, infants);

        log('[FlightSelect] Navigating to checkout screen with data keys: ${checkoutData.keys.toList()}');

        // Navigate to checkout screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightCheckoutScreen(
              flightData: checkoutData,
            ),
          ),
        );
      } else {
        log('[FlightSelect] ❌ PREBOOK FAILED');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              preBookResponse?.message ??
                  'Failed to prebook flight. Please try again.'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      log('[FlightSelect] ❌ EXCEPTION: $e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again.'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Map<String, dynamic> _prepareFlightCheckoutData(
    Flight flight,
    dynamic preBookResponse,
    int adults,
    int children,
    int infants,
  ) {
    // Get flight detail if available
    final flightDetail = flight.flightDetails?.isNotEmpty == true
        ? flight.flightDetails![0]
        : null;

    return {
      // Flight info
      'airline_name': flight.airlineName ?? 'Unknown Airline',
      'airline_code': flightDetail?.airlineCode ?? '',
      'flight_number': flightDetail?.flightNumber ?? '',
      'provider': flight.provider,
      'offer_id': flight.id,

      // Route info
      'dep_iata': flight.origin ?? '',
      'arr_iata': flight.destination ?? '',
      'dep_time': flightDetail?.depTime ?? '',
      'arr_time': flightDetail?.arrTime ?? '',
      'dep_date': flightDetail?.depDate ?? '',
      'arr_date': flightDetail?.arrDate ?? '',
      'duration': flight.duration ?? '',
      'stops': flight.stops ?? 0,

      // Booking info
      'cabin_class': flight.cabinClass ?? 'ECONOMY',
      'trip_type': flight.isRoundTrip ? 'round_trip' : 'one_way',

      // Pricing
      'price': double.tryParse(flight.totalPrice?.toString() ?? '0') ?? 0,
      'currency': flight.currency ?? 'GBP',

      // Passengers
      'adults': adults,
      'children': children,
      'infants': infants,

      // Checkout response
      'checkout_url': preBookResponse?.checkoutUrl,
      'token': preBookResponse?.token,
    };
  }
}

// ───────────────────────────────────────────────────────────
// FLIGHT FILTER / SORT BAR  (always-visible row below AppBar)
// ───────────────────────────────────────────────────────────

class _FlightFilterSortBar extends StatelessWidget {
  final int flightCount;
  final String sortLabel;
  final bool filterActive;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  const _FlightFilterSortBar({
    required this.flightCount,
    required this.sortLabel,
    required this.filterActive,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$flightCount flight${flightCount == 1 ? '' : 's'} available',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kSubtitleColor,
              ),
            ),
          ),
          _FlightPill(
            icon: Icons.swap_vert_rounded,
            label: 'Sort: $sortLabel',
            active: false,
            onTap: onSort,
          ),
          const SizedBox(width: 8),
          _FlightPill(
            icon: Icons.tune_rounded,
            label: 'Filter',
            active: filterActive,
            onTap: onFilter,
          ),
        ],
      ),
    );
  }
}

class _FlightPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FlightPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kPrimaryColor : kPrimaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? kPrimaryColor : kPrimaryColor.withOpacity(0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : kPrimaryColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// FLIGHT FILTER BOTTOM SHEET
// ───────────────────────────────────────────────────────────

class _FlightFilterSheet extends StatefulWidget {
  final _FlightFilterState initial;
  final ValueChanged<_FlightFilterState> onApply;
  const _FlightFilterSheet({required this.initial, required this.onApply});

  @override
  State<_FlightFilterSheet> createState() => _FlightFilterSheetState();
}

class _FlightFilterSheetState extends State<_FlightFilterSheet> {
  late _FlightFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      snap: true,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // drag handle
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kSheetHeadingColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: kSheetHeadingColor),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade100),

            // scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  // ── PRICE PER FLIGHT ──────────────────────────
                  _FlightSectionLabel(text: 'PRICE'),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FlightPriceTag(
                          caption: 'Min',
                          value: '\$${_draft.minPrice.round()}'),
                      _FlightPriceTag(
                          caption: 'Up to',
                          value: '\$${_draft.maxPrice.round()}',
                          alignRight: true),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: kPrimaryColor,
                      inactiveTrackColor: kPrimaryColor.withOpacity(0.15),
                      thumbColor: kPrimaryColor,
                      overlayColor: kPrimaryColor.withOpacity(0.12),
                      trackHeight: 3,
                    ),
                    child: RangeSlider(
                      values: RangeValues(_draft.minPrice, _draft.maxPrice),
                      min: 0,
                      max: 50000,
                      divisions: 100,
                      onChanged: (v) => setState(() => _draft =
                          _draft.copyWith(minPrice: v.start, maxPrice: v.end)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 24),

                  // ── STOPS ──────────────────────────────────────
                  _FlightSectionLabel(text: 'STOPS'),
                  const SizedBox(height: 12),
                  ..._StopsFilter.values
                      .map((s) => _StopsTile(
                            value: s,
                            group: _draft.stopsFilter,
                            onChange: (v) => setState(
                                () => _draft = _draft.copyWith(stopsFilter: v)),
                          ))
                      .toList(),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 24),

                  // ── DEPARTURE TIME ─────────────────────────────
                  _FlightSectionLabel(text: 'DEPARTURE TIME'),
                  const SizedBox(height: 12),
                  ..._DepartureTimeFilter.values
                      .map((d) => _DepartureTimeTile(
                            value: d,
                            group: _draft.departureTimeFilter,
                            onChange: (v) => setState(() => _draft =
                                _draft.copyWith(departureTimeFilter: v)),
                          ))
                      .toList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // sticky action bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _draft = const _FlightFilterState()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          color: kSheetHeadingColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_draft);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// FLIGHT SORT BOTTOM SHEET
// ───────────────────────────────────────────────────────────

class _FlightSortSheet extends StatelessWidget {
  final _FlightSortBy selected;
  final ValueChanged<_FlightSortBy> onSelect;
  const _FlightSortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FlightSectionLabel(text: 'SORT BY'),
          const SizedBox(height: 12),
          ..._FlightSortBy.values
              .map((s) => _FlightSortTile(
                    value: s,
                    selected: selected == s,
                    onTap: () {
                      onSelect(s);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _FlightSortTile extends StatelessWidget {
  final _FlightSortBy value;
  final bool selected;
  final VoidCallback onTap;
  const _FlightSortTile(
      {required this.value, required this.selected, required this.onTap});

  String get _label {
    switch (value) {
      case _FlightSortBy.price:
        return ' Price';
      case _FlightSortBy.duration:
        return 'Duration';
      case _FlightSortBy.departure:
        return 'Departure ';
      case _FlightSortBy.arrival:
        return 'Arrival';
    }
  }

  IconData get _icon {
    switch (value) {
      case _FlightSortBy.price:
        return Icons.attach_money_rounded;
      case _FlightSortBy.duration:
        return Icons.timelapse_rounded;
      case _FlightSortBy.departure:
        return Icons.flight_takeoff_rounded;
      case _FlightSortBy.arrival:
        return Icons.flight_land_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color:
              selected ? kPrimaryColor.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? kPrimaryColor.withOpacity(0.40)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon,
                size: 17, color: selected ? kPrimaryColor : kMutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? kPrimaryColor : kSheetHeadingColor,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 17, color: kPrimaryColor),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// SHARED FLIGHT FILTER WIDGETS
// ───────────────────────────────────────────────────────────

class _FlightSectionLabel extends StatelessWidget {
  final String text;
  const _FlightSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Colors.grey.shade500,
        ),
      );
}

class _FlightPriceTag extends StatelessWidget {
  final String caption;
  final String value;
  final bool alignRight;
  const _FlightPriceTag(
      {required this.caption, required this.value, this.alignRight = false});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(caption,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, color: Colors.grey.shade400)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kPrimaryColor,
              )),
        ],
      );
}

class _StopsTile extends StatelessWidget {
  final _StopsFilter value;
  final _StopsFilter group;
  final ValueChanged<_StopsFilter> onChange;
  const _StopsTile(
      {required this.value, required this.group, required this.onChange});

  String get _label {
    switch (value) {
      case _StopsFilter.any:
        return 'Any';
      case _StopsFilter.direct:
        return 'Direct only';
      case _StopsFilter.oneStop:
        return '1 Stop';
      case _StopsFilter.twoPlus:
        return '2+ Stops';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = value == group;
    return InkWell(
      onTap: () => onChange(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _FlightRadioDot(selected: sel),
            const SizedBox(width: 10),
            Text(
              _label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? kSheetHeadingColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartureTimeTile extends StatelessWidget {
  final _DepartureTimeFilter value;
  final _DepartureTimeFilter group;
  final ValueChanged<_DepartureTimeFilter> onChange;
  const _DepartureTimeTile(
      {required this.value, required this.group, required this.onChange});

  String get _label {
    switch (value) {
      case _DepartureTimeFilter.any:
        return 'Any time';
      case _DepartureTimeFilter.morning:
        return 'Morning  (06:00 – 12:00)';
      case _DepartureTimeFilter.afternoon:
        return 'Afternoon  (12:00 – 18:00)';
      case _DepartureTimeFilter.evening:
        return 'Evening  (18:00+)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = value == group;
    return InkWell(
      onTap: () => onChange(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _FlightRadioDot(selected: sel),
            const SizedBox(width: 10),
            Text(
              _label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? kSheetHeadingColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightRadioDot extends StatelessWidget {
  final bool selected;
  const _FlightRadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? kPrimaryColor : Colors.grey.shade400,
          width: selected ? 5 : 1.5,
        ),
        color: Colors.white,
      ),
    );
  }
}

// ================ FLIGHT CARD ================
class FlightCard extends StatefulWidget {
  final Flight flight;
  final VoidCallback onSelectPressed;

  const FlightCard({
    Key? key,
    required this.flight,
    required this.onSelectPressed,
  }) : super(key: key);

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  bool _isLoading = false;

  Flight get flight => widget.flight;
  VoidCallback get onSelectPressed => widget.onSelectPressed;

  String _extractTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      log('[MobileFlightCard] _extractTime: received null/empty, returning "--:--"');
      return '--:--';
    }
    try {
      // If it's already in HH:MM format, return as-is
      if (RegExp(r'^\d{2}:\d{2}').hasMatch(timeString)) {
        log('[MobileFlightCard] _extractTime: detected HH:MM format in "$timeString", returning as-is');
        return timeString.substring(0, 5);
      }
      // Otherwise parse ISO 8601 format: "2025-01-15T14:30:00"
      log('[MobileFlightCard] _extractTime: parsing ISO format "$timeString"');
      final dateTime = DateTime.parse(timeString);
      final formatted =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      log('[MobileFlightCard] _extractTime: parsed and formatted to "$formatted"');
      return formatted;
    } catch (e) {
      log('[MobileFlightCard] _extractTime ERROR: Failed to parse "$timeString", Error: $e');
      return '--:--';
    }
  }

  String _extractDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      log('[MobileFlightCard] _extractDate: received null/empty, returning "--"');
      return '--';
    }
    try {
      // Check if it's already formatted like "19 Mar, 2026" - if so, return as-is
      if (RegExp(
              r'\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec),?\s+\d{4}',
              caseSensitive: false)
          .hasMatch(dateString)) {
        log('[MobileFlightCard] _extractDate: detected pre-formatted date "$dateString", returning as-is');
        // Extract just the date part if it has time attached
        final formatted =
            dateString.split(' ').take(3).join(' ').replaceAll(',', '');
        return formatted;
      }

      // Otherwise, parse ISO 8601 format: "2025-01-15T14:30:00"
      log('[MobileFlightCard] _extractDate: parsing ISO format "$dateString"');
      final dateTime = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final formatted = '${months[dateTime.month - 1]} ${dateTime.day}';
      log('[MobileFlightCard] _extractDate: parsed and formatted to "$formatted"');
      return formatted;
    } catch (e) {
      log('[MobileFlightCard] _extractDate ERROR: Failed to parse "$dateString", Error: $e');
      return '--';
    }
  }

  String _formatPrice(dynamic price, String? currency) {
    if (price == null) {
      log('[MobileFlightCard] _formatPrice: price is null, returning "N/A"');
      return 'N/A';
    }
    try {
      final amount = price is String
          ? double.parse(price)
          : double.parse(price.toString());
      final currencySymbol = _getCurrencySymbol(currency ?? 'USD');
      final formatted = '$currencySymbol${amount.toStringAsFixed(0)}';
      log('[MobileFlightCard] _formatPrice: amount=$amount, currency=$currency, formatted=$formatted');
      return formatted;
    } catch (e) {
      log('[MobileFlightCard] _formatPrice ERROR: Failed to format price=$price, currency=$currency, Error: $e');
      return 'N/A';
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    const currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'AED': 'د.إ',
      'SAR': 'ر.س',
      'QAR': 'ر.ق',
      'KWD': 'د.ك',
      'BHD': 'د.ب',
      'OMR': 'ر.ع.',
    };
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  Widget _buildLogoWidget() {
    final firstDetail = flight.flightDetails?.isNotEmpty == true
        ? flight.flightDetails![0]
        : null;
    final logoUrl = firstDetail?.airlineLogo;

    log('[MobileFlightCard] Airline Name = ${flight.airlineName ?? "N/A"}');
    log('[MobileFlightCard] Logo URL = $logoUrl');

    if (logoUrl == null || logoUrl.isEmpty) {
      log('[MobileFlightCard] Logo fallback used (empty URL)');
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.airplanemode_active,
          color: Colors.grey.shade600,
          size: 24,
        ),
      );
    }

    // Check if it's an SVG
    final isSvg = logoUrl.toLowerCase().endsWith('.svg');
    if (isSvg) {
      log('[MobileFlightCard] SVG logo detected');
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SvgPicture.network(
            logoUrl,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.airplanemode_active,
                color: Colors.grey.shade600,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    // Raster image (PNG, JPG, etc.)
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          logoUrl,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, e, __) {
            log('[MobileFlightCard] Raster logo failed to load: $e');
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.airplanemode_active,
                color: Colors.grey.shade600,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build a single flight segment section (for departure or return)
  Widget _buildFlightSegmentSection({
    required String segmentLabel,
    required String? depTime,
    required String? depDate,
    required String? depIata,
    required String? arrTime,
    required String? arrDate,
    required String? arrIata,
    required String? duration,
    required String? stopsLabel,
    required bool isReturn,
  }) {
    final finalDepTime = depTime ?? '--:--';
    final finalDepDate = depDate ?? '--';
    final finalDepCode = depIata ?? '--';
    final finalArrTime = arrTime ?? '--:--';
    final finalArrDate = arrDate ?? '--';
    final finalArrCode = arrIata ?? '--';
    final finalDuration = duration ?? '--';
    final finalStops = stopsLabel ?? 'Non-stop';

    if (isReturn) {
      log('[RoundTripFlightCard] return dep = $finalDepTime, $finalDepDate, $finalDepCode');
      log('[RoundTripFlightCard] return arr = $finalArrTime, $finalArrDate, $finalArrCode');
      log('[RoundTripFlightCard] return duration = $finalDuration');
      log('[RoundTripFlightCard] return stops = $finalStops');
    } else {
      log('[RoundTripFlightCard] outbound dep = $finalDepTime, $finalDepDate, $finalDepCode');
      log('[RoundTripFlightCard] outbound arr = $finalArrTime, $finalArrDate, $finalArrCode');
      log('[RoundTripFlightCard] outbound duration = $finalDuration');
      log('[RoundTripFlightCard] outbound stops = $finalStops');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segment label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            segmentLabel,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kVeryMutedColor,
            ),
          ),
        ),
        // Departure & Arrival Row
        Row(
          children: [
            // Departure
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finalDepTime,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kHeadingColor,
                  ),
                ),
                Text(
                  finalDepDate,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: kVeryMutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  finalDepCode,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kMutedColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Duration & Stops
            Column(
              children: [
                Text(
                  finalDuration,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kMutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  finalStops,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: kVeryMutedColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Arrival
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  finalArrTime,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kHeadingColor,
                  ),
                ),
                Text(
                  finalArrDate,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: kVeryMutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  finalArrCode,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kMutedColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRoundTrip = flight.isRoundTrip;

    // Get departure and return details
    final departureDetail = flight.getDepartureDetail();
    final returnDetail = flight.getReturnDetail();

    log('[RoundTripFlightCard] tripType = ${isRoundTrip ? "round_trip" : "one_way"}');

    if (isRoundTrip && returnDetail != null) {
      // ROUND-TRIP UI
      log('[RoundTripFlightCard] return_departure_at = ${flight.returnDepartureAt}');
      log('[RoundTripFlightCard] return_arrival_at = ${flight.returnArrivalAt}');
      log('[RoundTripFlightCard] return_duration = ${flight.returnDuration}');
      log('[RoundTripFlightCard] return_stops = ${flight.returnStops}');

      final priceStr = _formatPrice(flight.totalPrice, flight.currency);
      final airlineName = flight.airlineName ?? 'Unknown Airline';

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: Airline Logo + Name ───
              Row(
                children: [
                  _buildLogoWidget(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          airlineName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kHeadingColor,
                          ),
                        ),
                        // Provider Badge
                        if (flight.provider != null &&
                            flight.provider!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4EF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flight.provider!.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFD63384),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        // Flight Number
                        Text(
                          'Flight ${flight.flightNumber ?? "--"}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Original Badge (if badge field exists)
                  if (flight.badge != null && flight.badge!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        flight.badge!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffD97706),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Outbound Section ───
              _buildFlightSegmentSection(
                segmentLabel: 'Outbound',
                depTime: departureDetail?.depTime,
                depDate: departureDetail?.depDate,
                depIata: departureDetail?.depIata,
                arrTime: departureDetail?.arrTime,
                arrDate: departureDetail?.arrDate,
                arrIata: departureDetail?.arrIata,
                duration: departureDetail?.duration,
                stopsLabel: departureDetail != null
                    ? (departureDetail.stops == 0
                        ? 'Direct'
                        : '${departureDetail.stops} stop${(departureDetail.stops ?? 0) > 1 ? 's' : ''}')
                    : 'Non-stop',
                isReturn: false,
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 12),
              const SizedBox(height: 12),

              // ─── Return Section ───
              _buildFlightSegmentSection(
                segmentLabel: 'Return',
                depTime: returnDetail.depTime,
                depDate: returnDetail.depDate,
                depIata: returnDetail.depIata,
                arrTime: returnDetail.arrTime,
                arrDate: returnDetail.arrDate,
                arrIata: returnDetail.arrIata,
                duration: returnDetail.duration,
                stopsLabel: returnDetail.stops == 0
                    ? 'Direct'
                    : '${returnDetail.stops} stop${(returnDetail.stops ?? 0) > 1 ? 's' : ''}',
                isReturn: true,
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 12),

              // ─── Price & Select Button ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        priceStr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : onSelectPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Select'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // ONE-WAY UI (original)
      final firstDetail = flight.flightDetails?.isNotEmpty == true
          ? flight.flightDetails![0]
          : null;

      // RAW values from API response
      final depTimeRaw = firstDetail?.depTime;
      final depDateRaw = firstDetail?.depDate;
      final depIataRaw = firstDetail?.depIata;
      final arrTimeRaw = firstDetail?.arrTime;
      final arrDateRaw = firstDetail?.arrDate;
      final arrIataRaw = firstDetail?.arrIata;

      // Final display values - DIRECTLY from API response
      final finalDepartureTime = depTimeRaw ?? '--:--';
      final finalDepartureDate = depDateRaw ?? '--';
      final finalDepartureCode = depIataRaw ?? flight.origin ?? '--';
      final finalArrivalTime = arrTimeRaw ?? '--:--';
      final finalArrivalDate = arrDateRaw ?? '--';
      final finalArrivalCode = arrIataRaw ?? flight.destination ?? '--';

      // Duration and stops
      final finalDuration = firstDetail?.duration ?? flight.duration ?? '--';
      final finalStopsLabel = flight.stopsLabel ?? 'Non-stop';

      // Airline info
      final airlineName = flight.airlineName ?? 'Unknown Airline';
      final flightNumber = firstDetail?.flightNumber ?? '--';

      // Price
      final priceStr = _formatPrice(flight.totalPrice, flight.currency);

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: Airline Logo + Name + Flight Number ───
              Row(
                children: [
                  _buildLogoWidget(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          airlineName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kHeadingColor,
                          ),
                        ),
                        // Provider Badge
                        if (flight.provider != null &&
                            flight.provider!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4EF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flight.provider!.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFD63384),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        // Flight Number
                        Text(
                          'Flight $flightNumber',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge (optional)
                  if (flight.badge != null && flight.badge!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        flight.badge!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffD97706),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Departure & Arrival Times & Dates ───
              Row(
                children: [
                  // Departure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        finalDepartureTime,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kHeadingColor,
                        ),
                      ),
                      Text(
                        finalDepartureDate,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalDepartureCode,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Duration & Stops (Center)
                  Column(
                    children: [
                      Text(
                        finalDuration,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kMutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalStopsLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Arrival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        finalArrivalTime,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kHeadingColor,
                        ),
                      ),
                      Text(
                        finalArrivalDate,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalArrivalCode,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Divider ───
              Divider(
                color: Colors.grey.shade200,
                height: 12,
              ),

              // ─── Price & Select Button ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        priceStr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : onSelectPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Select'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

//new code**********************
// ================ OFFER ITEM CARD ================
class OfferItem extends StatelessWidget {
  final home_item.Offer offer;
  final VoidCallback press;

  const OfferItem({Key? key, required this.offer, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a simple card for offers
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CardStyle.borderRadius),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: CardStyle.shadowColor,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CardStyle.contentPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offer Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Offer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.desc,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//new code*******************************
// ================ DESTINATION ITEM CARD ================
class DestinationItem extends StatelessWidget {
  final home_item.Location location;
  final VoidCallback press;

  const DestinationItem({Key? key, required this.location, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _navigateToDestination() {
      press(); // Use the provided press callback
    }

    // Get the image URL
    final imageUrl = location.imgUrl.isNotEmpty
        ? location.imgUrl
        : (location.bannerImgUrl ?? '');

    // Create custom image widget
    final customImage = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(CardStyle.borderRadius),
        topRight: Radius.circular(CardStyle.borderRadius),
      ),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.location_on,
              color: Colors.grey,
              size: 48,
            ),
          );
        },
      ),
    );

    return buildPropertyCard(
      context: context,
      images: [], // Empty since we use custom image
      title: location.name,
      subtitle: '', // No subtitle for destinations
      rating: 0.0,
      reviewCount: 0,
      reviewText: '',
      price: 0, // No price for destinations
      isWishlist: false,
      isFeatured: false,
      discount: 0,
      onTap: _navigateToDestination,
      onWishlistTap: null,
      type: 'destination'.tr,
      id: location.id?.toString() ?? '0',
      badgeText: 'DESTINATION'.tr,
      badgeColor: Colors.deepOrange,
      priceSuffix: '',
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label.tr,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
