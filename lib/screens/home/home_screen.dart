import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/Provider/tour_provider.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';
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
import 'package:moonbnd/modals/home_item.dart' as home_item;
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/modals/space_list_model.dart';
import 'package:moonbnd/modals/tour_list_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/boat/boat_detail_screen.dart';
import 'package:moonbnd/screens/boat/boat_filter_screen.dart';
import 'package:moonbnd/screens/boat/boat_map_screen.dart';
import 'package:moonbnd/screens/car/car_details_screen.dart';
import 'package:moonbnd/screens/car/filter_car_screen.dart';
import 'package:moonbnd/screens/car/map_screen_car.dart';
import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:moonbnd/screens/event/event_filter.dart';
import 'package:moonbnd/screens/event/event_map_screen.dart';
import 'package:moonbnd/screens/flight/filter_flight_screen.dart';
import 'package:moonbnd/screens/hotel/filter_screen.dart';
import 'package:moonbnd/screens/flight/flight_details_screen.dart';
import 'package:moonbnd/screens/hotel/map_screen.dart';
import 'package:moonbnd/screens/space/filter_space_screen.dart';
import 'package:moonbnd/screens/space/map_screen_space.dart';
import 'package:moonbnd/screens/space/space_details_screen.dart';
import 'package:moonbnd/screens/tour/filter_tour_screen.dart';
import 'package:moonbnd/screens/tour/map_screen_tour.dart';
import 'package:moonbnd/screens/tour/tour_details_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../data_models/home_screen_data.dart';
import '../../widgets/card_widget.dart';
import '../hotel/search_hotel_screen.dart';
import '../hotel/room_detail_screen.dart';
import '../hotel/search_screen.dart';
import '../notification/notifications_screen.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  //zeeshan
  String selectedSort = 'Recommended'.tr;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  int?  _selectedCity = 0;
  int ?fromWhereLocation=0;
  int?toWhereLocation=0;
  DateTime?fromDate;
  DateTime?toDate;

  String _selectedToCity='';

  // Flight search variables
  bool _isRoundTrip = true;
  DateTime? _flightDepartureDate;
  DateTime? _flightReturnDate;
  int _passengerCount = 1;
  String _departureCity = '';
  String _destinationCity = '';


  @override
  void dispose() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.tabController?.dispose();
    super.dispose();
  }
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _fromCityController = TextEditingController();
  final TextEditingController _toCityController = TextEditingController();
  final ScrollController _cityScrollController = ScrollController();
  final ScrollController _departureCityScrollController = ScrollController();
  final ScrollController _destinationCityScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    homeProvider.fetchLocations(); // ✅ preload cities
    homeProvider.tabController = TabController(length: categoryDatas.length, vsync: this);

    // Add listener to handle both tap and swipe
    homeProvider.tabController?.addListener(() {
      if (homeProvider.tabController?.indexIsChanging == false) {
        // Tab animation completed, fetch data for new tab
        _fetchDataForTab(homeProvider.tabController?.index ?? 0);
      }
    });

    setState(() {
      isLoading = true;
    });
    Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchunreadnotificationcount()
        .then((value) {});

    Provider.of<AuthProvider>(context, listen: false).getMe().then((value) {
      setState(() {
        isLoading = false;
        _fetchDataForTab(0);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial tab based on HomeProvider
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      _fetchDataForTab(homeProvider.selectedHomeTab);
    });
  }

  Future _fetchDataForTab(int index) async {
    setState(() {
      isLoading = true;
      Provider.of<HomeProvider>(context, listen: false)
          .setSelectedHomeTab(index);
    });

    switch (index) {
      case 0:
        await Provider.of<HomeProvider>(context, listen: false)
            .homelistapi(index)
            .then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 1:
      // ignore: use_build_context_synchronously
        await Provider.of<HomeProvider>(context, listen: false)


            .hotellistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 2:
      // ignore: use_build_context_synchronously
        await Provider.of<TourProvider>(context, listen: false)
            .tourlistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 3:
      // ignore: use_build_context_synchronously
        await Provider.of<SpaceProvider>(context, listen: false)
            .spacelistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 4:
      // ignore: use_build_context_synchronously
        await Provider.of<HomeProvider>(context, listen: false)
            .carlistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 5:
      // ignore: use_build_context_synchronously
        await Provider.of<EventProvider>(context, listen: false)
            .eventlistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 6:
      // ignore: use_build_context_synchronously
        await Provider.of<FlightProvider>(context, listen: false)
            .flightlistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
      case 7:
      // ignore: use_build_context_synchronously
        await Provider.of<BoatProvider>(context, listen: false)
            .boatlistapi(index, searchParams: {}).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        break;
    }
  }
//zeeshan

  // Flight Passenger Selector
  void _showPassengerSelector() async {
    final int? result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int tempPassengerCount = _passengerCount;

        return StatefulBuilder(
          builder: (context, modalSetState) {
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
                        icon: const Icon(Icons.close,
                            color: Colors.redAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Passenger Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passengers'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.remove_circle_outline),
                            onPressed: tempPassengerCount > 1
                                ? () {
                              modalSetState(() {
                                tempPassengerCount--;
                              });
                            }
                                : null,
                          ),
                          Text(
                            '$tempPassengerCount',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.add_circle_outline),
                            onPressed: () {
                              modalSetState(() {
                                tempPassengerCount++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, tempPassengerCount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05A8C7),
                      ),
                      child: Text('Apply'.tr),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    /// ✅ Update parent state AFTER modal closes
    if (result != null) {
      setState(() {
        _passengerCount = result;
      });
    }
  }




  void _showGuestSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Guests'.tr,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          )
                      ),
                      IconButton(
                        icon: Icon(Icons.close,color: Colors.redAccent,),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guests'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: _guestCount > 1
                                ? () {
                              setState(() {
                                _guestCount--;
                              });
                            }
                                : null,
                          ),
                          Text(
                              '$_guestCount',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              )
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _guestCount++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF05A8C7),
                      ),
                      child: Text('Apply'.tr),
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



  void _departureCityScrollListener() {
    final homeProvider = context.read<HomeProvider>();

    if (_departureCityScrollController.position.pixels >=
        _departureCityScrollController.position.maxScrollExtent - 100 &&
        homeProvider.hasMore &&
        !homeProvider.isLoadingMore) {
      homeProvider.fetchLocations(
        page: homeProvider.currentPage + 1,
        loadMore: true,
      );
    }
  }

  void _destinationCityScrollListener() {
    final homeProvider = context.read<HomeProvider>();

    if (_destinationCityScrollController.position.pixels >=
        _destinationCityScrollController.position.maxScrollExtent - 100 &&
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
                      itemCount:
                      provider.filteredLocations.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Bottom loader
                        if (index ==
                            provider.filteredLocations.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child:
                                CircularProgressIndicator()),
                          );
                        }

                        final city =
                        provider.filteredLocations[index];

                        return ListTile(
                          leading:
                          const Icon(Icons.location_on),
                          title: Text(city.title ?? ''),
                          onTap: () {
                            provider
                                .selectCity(city.title ?? '');
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


  void _showDepartureLocation(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();

    // Fetch first page if empty
    if (homeProvider.locations.isEmpty) {
      await homeProvider.fetchLocations(page: 1);
    }

    // Prevent duplicate listeners
    _departureCityScrollController
        .removeListener(_departureCityScrollListener);

    // Add pagination listener
    _departureCityScrollController
        .addListener(_departureCityScrollListener);

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
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                        ? const Center(
                        child: CircularProgressIndicator())
                        : provider.filteredLocations.isEmpty
                        ? const Center(
                        child: Text('No locations found'))
                        : ListView.builder(
                      controller:
                      _departureCityScrollController,
                      itemCount:
                      provider.filteredLocations.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Bottom loader
                        if (index ==
                            provider.filteredLocations.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child:
                                CircularProgressIndicator()),
                          );
                        }

                        final city =
                        provider.filteredLocations[index];

                        return ListTile(
                          leading: const Icon(
                              Icons.location_on),
                          title: Text(city.title ?? ''),
                          onTap: () {
                            provider.selectDepartureCity(
                                city.title ?? '');
                            _fromCityController.text =
                                provider.departureCity;
                            fromWhereLocation = city.id;
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




  void _showDestinationLocation(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();

    // Fetch first page if empty
    if (homeProvider.locations.isEmpty) {
      await homeProvider.fetchLocations(page: 1);
    }

    // Prevent duplicate listeners
    _destinationCityScrollController
        .removeListener(_destinationCityScrollListener);

    // Add pagination listener
    _destinationCityScrollController
        .addListener(_destinationCityScrollListener);

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
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                        ? const Center(
                        child: CircularProgressIndicator())
                        : provider.filteredLocations.isEmpty
                        ? const Center(
                        child: Text('No locations found'))
                        : ListView.builder(
                      controller:
                      _destinationCityScrollController,
                      itemCount:
                      provider.filteredLocations.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Bottom loader
                        if (index ==
                            provider.filteredLocations.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child:
                                CircularProgressIndicator()),
                          );
                        }

                        final city =
                        provider.filteredLocations[index];

                        return ListTile(
                          leading: const Icon(
                              Icons.location_on),
                          title: Text(city.title ?? ''),
                          onTap: () {
                            provider.selectDestinationCity(
                                city.title ?? '');
                            _toCityController.text =
                                provider.destinationCity;
                            toWhereLocation = city.id;
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


  Widget _buildFlightSearchSection(BuildContext context) {
    String departureDateText = _flightDepartureDate != null
        ? '${_flightDepartureDate!.day}/${_flightDepartureDate!.month}/${_flightDepartureDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String returnDateText = _flightReturnDate != null
        ? '${_flightReturnDate!.day}/${_flightReturnDate!.month}/${_flightReturnDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String passengerText = _passengerCount == 1
        ? '1 Passenger'.tr
        : '$_passengerCount Passengers'.tr;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1D2025),
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  _showDepartureLocation(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 47,
                      padding: EdgeInsets.symmetric(horizontal: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/location.svg',
                            width: 20,
                            height: 20,
                            color: Color(0xff6B7280),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fromCityController,
                                decoration: InputDecoration(
                                  hintText: 'Departure City'.tr,
                                  border: InputBorder.none,
                                  hintStyle: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    color: const Color(0xff6B7280),
                                  ),
                                ),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: const Color(0xff1D2025),
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1D2025),
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  _showDestinationLocation(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Container(
                      height: 47,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/location.svg',
                            width: 20,
                            height: 20,
                            color: Color(0xff6B7280),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _toCityController,
                                decoration: InputDecoration(
                                  hintText: 'Destination City'.tr,
                                  border: InputBorder.none,
                                  hintStyle: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    color: const Color(0xff6B7280),
                                  ),
                                ),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: const Color(0xff1D2025),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1D2025),
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
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
                          });
                        }
                      },
                      child: Container(
                        height: 47,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/calendar.svg',
                              width: 20,
                              height: 20,
                              color: Color(0xff6B7280),
                            ),
                            SizedBox(width: 8),
                            Text(
                              departureDateText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: _flightDepartureDate != null
                                    ? Color(0xff1D2025)
                                    : Color(0xff6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isRoundTrip) SizedBox(width: 12),
                  if (_isRoundTrip)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _flightDepartureDate ?? DateTime.now(),
                            firstDate: _flightDepartureDate ?? DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _flightReturnDate = picked;
                            });
                          }
                        },
                        child: Container(
                          height: 47,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffE5E7EB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/calendar.svg',
                                width: 20,
                                height: 20,
                                color: Color(0xff6B7280),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _flightReturnDate != null
                                    ? '${_flightReturnDate!.day}/${_flightReturnDate!.month}/${_flightReturnDate!.year}'
                                    : 'Return'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: _flightReturnDate != null
                                      ? Color(0xff1D2025)
                                      : Color(0xff6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1D2025),
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: _showPassengerSelector,
                child: Container(
                  height: 47,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 20,
                        height: 20,
                        color: Color(0xff6B7280),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          passengerText,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Color(0xff1D2025),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Search Button
          Container(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // You need to get the flight data from somewhere
                // For example, from a provider

                final flightProvider = Provider.of<FlightProvider>(context, listen: false);
                flightProvider.flightlistapi(2,searchParams: {
                  'from_where': fromWhereLocation,
                  'to_where': toWhereLocation,
                  'start': _flightDepartureDate,
                  'end':_flightReturnDate,
                  'children': _passengerCount,
                }).then((_) {
                  setState(() {
                    isLoading = false;
                  });
                });
                final flightList = flightProvider.flightListPerCategory[6] ?? FlightList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightListItem(flightList: flightList),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF05A8C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildTripTypeButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF05A8C7) : Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Color(0xFF05A8C7) : Colors.transparent,
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
                  color: isSelected ? Colors.white : Color(0xff1D2025),
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
    // Calculate the text values directly
    String checkInText = _checkInDate != null
        ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String checkOutText = _checkOutDate != null
        ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String guestText = _guestCount == 1
        ? '1 Guest'.tr
        : '$_guestCount Guests'.tr;

    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where to?'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xff1D2025),
            ),
          ),
          SizedBox(height: 12),

          // City/Destination Field
          GestureDetector(
            onTap: () => _showCitySelection(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 47,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/location.svg',
                        width: 20,
                        height: 20,
                        color: const Color(0xff6B7280),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'City or destination'.tr,
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: const Color(0xff6B7280),
                              ),
                            ),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xff1D2025),
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

          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Check-in'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff1D2025),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        'Check-out'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff1D2025),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],

                )


              ],
            ),
          ),
          // Check-in & Check-out Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
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
                      });
                    }
                  },

                  child: Container(
                    height: 47,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/calendar.svg', // Add your calendar icon
                              width: 16,
                              height: 16,
                              color: Color(0xff6B7280),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              checkInText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1D2025),
                              ),
                            ),
                          ],),

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
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
                      });
                    }
                  },
                  child: Container(
                    height: 47,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/calendar.svg', // Add your calendar icon
                              width: 16,
                              height: 16,
                              color: Color(0xff6B7280),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              checkOutText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1D2025),
                              ),
                            ),
                          ],),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Guests Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guests label above the container
              Text(
                'Guests'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1D2025),
                ),
              ),
              SizedBox(height: 4),
              // Guest selector container
              GestureDetector(
                onTap: _showGuestSelector,
                child: Container(
                  height: 47,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 20,
                        height: 20,
                        color: Color(0xff6B7280),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          guestText,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Color(0xff1D2025), // Changed to darker color for better visibility
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
//zeeshan
          // Search Button
          // In the _buildHotelSearchSection method, update the Search Button
          Container(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(

              onPressed: () {
                // Navigate to hotel search results screen with search parameters
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelSearchResultsScreen(
                      city: _selectedCity==null ? 0 : _selectedCity,
                      checkInDate: _checkInDate,
                      checkOutDate: _checkOutDate,
                      guests: _guestCount,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF05A8C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG Search icon
                  SvgPicture.asset(
                    'assets/icons/search.svg', // Make sure you have this icon in your assets
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8), // Space between icon and text
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
                  color: Color(0xff1D2025),
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
                    color: Color(0xFF05A8C7),
                    fontWeight: FontWeight.w500,
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
                  imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
                  title: 'Paris, France',
                  subtitle: 'City of Love',
                  isBestSeller: true,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=400&h=250&fit=crop',
                  title: 'Tokyo, Japan',
                  subtitle: 'Modern Metropolis',
                  isBestSeller: false,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
                  title: 'Bali, Indonesia',
                  subtitle: 'Tropical Paradise',
                  isBestSeller: true,
                ),
                SizedBox(width: 12),
                _buildFeaturedDestinationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?w=400&h=250&fit=crop',
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
      width: 300,
      height: 300, // Even taller
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1D2025),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Color(0xff6B7280),
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
                                      fontSize: 14,
                                      color: Color(0xff65758B),
                                    ),
                                  ),
                                  Text(
                                    "Explore World".tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Color(0xff1D2025),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotificationsScreen(),
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
                          color: Color(0xffF1F5F9),
                        ),
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categoryDatas.asMap().entries.map((entry) {
                                int idx = entry.value.id;
                                var category = entry.value;
                                bool isSelected = homeProvider.selectedHomeTab == idx;

                                return GestureDetector(
                                  onTap: () async {
                                    await _fetchDataForTab(idx);
                                    if (selectedSort != 'Recommended'.tr) {
                                      selectedSort = 'Recommended'.tr;
                                    }
                                    homeProvider.setSelectedHomeTab(idx);
                                    homeProvider.tabController?.animateTo(idx);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFF05A8C7) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              category.kIcon,
                                              color: isSelected ? Colors.white : Color(0xFF6B7280),
                                              height: 16,
                                              width: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          category.category.tr,
                                          style: GoogleFonts.spaceGrotesk(
                                            color: isSelected ? Colors.white : Color(0xFF6B7280),
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
                  children: [
                    // Home tab (index 0)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          homeList == null
                              ? Center(child: CircularProgressIndicator())
                              : MixedItemList(homeList: homeList),
                        ],
                      ),
                    ),
                    // Hotels tab (index 1)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHotelSearchSection(context),
                          _buildFeaturedDestinations(),
                        ],
                      ),
                    ),
                    // Tours tab (index 2)
                    Column(
                      children: [
                        _buildResultsCount(2, homeProvider, boatProvider,
                            tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(2),
                        Expanded(
                          child: TourListItem(
                              tourList: tourProvider.tourListPerCategory[2] ?? TourList()),
                        ),
                      ],
                    ),
                    // Spaces tab (index 3)
                    Column(
                      children: [
                        _buildResultsCount(3, homeProvider, boatProvider,
                            tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(3),
                        Expanded(
                          child: SpaceListItem(
                              spaceList: spaceProvider.spaceListPerCategory[3] ?? SpaceList()),
                        ),
                      ],
                    ),
                    // Cars tab (index 4)
                    Column(
                      children: [
                        _buildResultsCount(4, homeProvider, boatProvider,
                            tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(4),
                        Expanded(
                          child: CarListItem(
                              carList: homeProvider.carListPerCategory[4] ?? CarList()),
                        ),
                      ],
                    ),
                    // Events tab (index 5)
                    Column(
                      children: [
                        _buildResultsCount(5, homeProvider, boatProvider,
                            tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(5),
                        Expanded(
                          child: EventListItem(
                              eventList: eventProvider.eventListPerCategory[5] ?? EventList()),
                        ),
                      ],
                    ),
                    // Flights tab (index 6)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFlightSearchSection(context),
                          _buildFeaturedDestinations(),
                          // SizedBox(height: 20),
                          // _buildResultsCount(6, homeProvider, boatProvider,
                          //     tourProvider, spaceProvider, eventProvider, flightProvider),
                          // _buildFilterTabs(6),
                          // FlightListItem(
                          //     flightList: flightProvider.flightListPerCategory[6] ?? FlightList()),
                        ],
                      ),
                    ),
                    // Boats tab (index 7)
                    Column(
                      children: [
                        _buildResultsCount(7, homeProvider, boatProvider,
                            tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(7),
                        Expanded(
                          child: BoatListItem(
                              boatList: boatProvider.boatListPerCategory[7] ?? BoatList()),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
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
                // SizedBox(height: 4),
                // Text(
                //   '${'Showing'.tr} ${_getStartId(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} - ${_getEndId(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} ${'of'.tr} $itemCount ${'items'.tr}',
                //   style: GoogleFonts.spaceGrotesk(
                //     color: grey,
                //     fontSize: 12,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
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
                  color: Color(0xff05A8C7),
                ),
                SizedBox(width: 4),
                Text(
                  'Filters'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Color(0xff05A8C7),
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
          return  '--';
        }
        return 'Paris';

      case 2: // Tours
        final data = tourProvider.tourListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return  '--';
        }
        return 'England';

      case 3: // Spaces
        final data = spaceProvider.spaceListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return  '--';
        }
        return 'England';

      case 4: // Cars
        final data = homeProvider.carListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return  '--';
        }
        return 'London';

      case 5: // Events
        final data = eventProvider.eventListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return  '--';
        }
        return 'Paris';

      case 6: // Flights
        return ''; // Flights might not have a single location

      case 7: // Boats
        final data = boatProvider.boatListPerCategory[index]?.data;
        if (data != null && data.isNotEmpty) {
          return  '--';
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
        return homeProvider.hotelListPerCategory[index]?.data?.length ?? 0;
      case 2:
        return tourProvider.tourListPerCategory[index]?.data?.length ?? 0;
      case 3:
        return spaceProvider.spaceListPerCategory[index]?.data?.length ?? 0;
      case 4:
        return homeProvider.carListPerCategory[index]?.data?.length ?? 0;
      case 5:
        return eventProvider.eventListPerCategory[index]?.data?.length ?? 0;
      case 6:
        return flightProvider.flightListPerCategory[index]?.data?.length ?? 0;
      case 7:
        return boatProvider.boatListPerCategory[index]?.data?.length ?? 0;
      default:
        return 0;
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
        return flightProvider.flightListPerCategory[index]?.startId ?? 1;
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
        return flightProvider.flightListPerCategory[index]?.endId ?? 1;
      case 7:
        return boatProvider.boatListPerCategory[index]?.endId ?? 1;
      default:
        return 1;
    }
  }

  Widget _buildTabContent(
      int index,
      HomeProvider homeProvider,
      BoatProvider boatProvider,
      TourProvider tourProvider,
      SpaceProvider spaceProvider,
      EventProvider eventProvider,
      FlightProvider flightProvider) {
    // Check if data exists for the current tab, if not show loading
    bool hasData = false;
    switch (index) {
      case 1:
        hasData = homeProvider.hotelListPerCategory.containsKey(1);
        break;
      case 2:
        hasData = tourProvider.tourListPerCategory.containsKey(2);
        break;
      case 3:
        hasData = spaceProvider.spaceListPerCategory.containsKey(3);
        break;
      case 4:
        hasData = homeProvider.carListPerCategory.containsKey(4);
        break;
      case 5:
        hasData = eventProvider.eventListPerCategory.containsKey(5);
        break;
      case 6:
        hasData = flightProvider.flightListPerCategory.containsKey(6);
        break;
      case 7:
        hasData = boatProvider.boatListPerCategory.containsKey(7);
        break;
      default:
        hasData = true;
    }

    if (!hasData) {
      return Center(child: CircularProgressIndicator());
    }

    switch (index) {
      case 2:
        return TourListItem(
            tourList: tourProvider.tourListPerCategory[2] ?? TourList());
      case 3:
        return SpaceListItem(
            spaceList: spaceProvider.spaceListPerCategory[3] ?? SpaceList());
      case 4:
        return CarListItem(
            carList: homeProvider.carListPerCategory[4] ?? CarList());
      case 5:
        return EventListItem(
            eventList: eventProvider.eventListPerCategory[5] ?? EventList());
      case 6:
        return FlightListItem(
            flightList:
            flightProvider.flightListPerCategory[6] ?? FlightList());
      case 7:
        return BoatListItem(
            boatList: boatProvider.boatListPerCategory[7] ?? BoatList());
      default:
        return SizedBox.shrink();
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

class MixedItemList extends StatelessWidget {
  final home_item.HomeList homeList;

  const MixedItemList({Key? key, required this.homeList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("MixedItemList build called with ${homeList.items.length} items");
    print(
        "Hotel items: ${homeList.items.where((item) => item.type == home_item.ItemType.hotel).map((item) => {
          'id': item.item.id,
          'title': item.item.title,
          'price': item.item.price,
          'isInWishlist': item.item.isInWishlist,
        }).toList()}");
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(
              "Bestseller Listing".tr,
              "Hotels highly rated for thoughtful design".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.hotel)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Our Best Promotion Tours".tr,
              "Most popular destinations".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.tour)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Rental Listing".tr,
              "Homes highly rated for thoughtful design".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.space)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Car Trending".tr,
              "Book incredible things to do around the world".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.car)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Boat Listing".tr,
              "Book incredible things to do around the world".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.boat)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Event Listing".tr,
              "Explore exciting events near you".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.event)
                  .toList(),
              context,
            ),
            _buildCategorySection(
              "Top Destinations".tr,
              "Hotel highly rated for thoughtful design".tr,
              homeList.items
                  .where((item) => item.type == home_item.ItemType.location)
                  .toList(),
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, String subtitle,
      List<home_item.HomeItem> items, BuildContext context) {
    print("Building category section: $title with ${items.length} items");

    if (items.isEmpty) return Text("Debug: No items for $title");

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
        ...items
            .map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: _buildItemWidget(item, context),
        ))
            .toList(),
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
                  hotelId: item.item.id,
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
          press: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FlightDetailsScreen(
                  flightId: item.item.id,
                )),
          ),
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

class PropertyList extends StatelessWidget {
  final HotelList hotelList;

  const PropertyList({super.key, required this.hotelList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: hotelList.data?.length,
            itemBuilder: (context, index) {
              var propertyData = PropertyData.fromHotel(hotelList.data![index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: PropertyItem(
                  dataSrc: propertyData,
                  press: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoomDetailScreen(hotelId: propertyData.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CarListItem extends StatelessWidget {
  final CarList carList;

  const CarListItem({super.key, required this.carList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: carList.data?.length,
            itemBuilder: (context, index) {
              var carData = CarData.fromCar(carList.data![index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: CarDataItem(
                    dataSrc: carData,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarRentalDetailsScreen(
                              carId: carList.data?[index].id ?? 0),
                        ),
                      );
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class EventListItem extends StatelessWidget {
  final EventList eventList;

  const EventListItem({super.key, required this.eventList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            itemCount: eventList.data?.length ?? 0,
            itemBuilder: (context, index) {
              final rawEvent = eventList.data?[index];

              // ✅ Extra safety
              if (rawEvent == null) {
                return const SizedBox.shrink();
              }

              final eventData = EvenData.fromEvent(rawEvent);

              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: EventItem(
                  dataSrc: eventData,
                  press: () {
                    log("go to event".tr);
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
    homeProvider.fetchHotelDetails(widget.dataSrc.id);
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
class TourListItem extends StatelessWidget {
  final TourList tourList;

  const TourListItem({super.key, required this.tourList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: tourList.data?.length,
            itemBuilder: (context, index) {
              if (tourList.data == null || tourList.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              var tourData = TourData.fromTour(tourList.data![index]);
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
      ],
    );
  }
}

class SpaceListItem extends StatelessWidget {
  final SpaceList spaceList;

  const SpaceListItem({super.key, required this.spaceList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: spaceList.data?.length,
            itemBuilder: (context, index) {
              var spaceData = SpaceData.fromSpace(spaceList.data![index]);
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
      ],
    );
  }
}

class BoatListItem extends StatelessWidget {
  final BoatList boatList;

  const BoatListItem({super.key, required this.boatList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: boatList.data?.length,
            itemBuilder: (context, index) {
              final list = boatList.data;
              if (list == null || list.isEmpty || index >= list.length) {
                return const SizedBox.shrink();
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
                          boatId: boatList.data![index].id ?? 1,
                        )),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}





class FlightListItem extends StatelessWidget {
  final FlightList flightList;
  final String? departureCity;
  final String? destinationCity;
  final VoidCallback? onBackPressed;

  const FlightListItem({
    super.key,
    required this.flightList,
    this.departureCity,
    this.destinationCity,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final flights = flightList.data ?? [];
    final totalFlights = flightList.total ?? flights.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Flights'.tr,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: flights.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          // Header with search summary
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${flights.length} flights available'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const Spacer(), // ✅ replaces SizedBox(width: 190)

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FilterFlightScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/filters.svg',
                        color: Color(0xff05A8C7),
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filters'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Color(0xff05A8C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      SizedBox(height: 10,),
          // Flight list
          Expanded(
            child: ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) {
                final flight = flights[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: buildPropertyCard(
                    context: context,
                    images: flight.airlineImageUrl != null
                        ? [flight.airlineImageUrl!]
                        : [],
                    title: flight.title ?? 'Flight ${flight.code ?? ''}',
                    subtitle: flight.airline?.name ?? 'Airline',
                    rating: flight.reviewScore != null
                        ? double.tryParse(flight.reviewScore!) ?? 0.0
                        : 0.0,
                    reviewCount: 0,
                    reviewText: '',
                    price: flight.minPrice != null
                        ? double.tryParse(flight.minPrice!) ?? 0.0
                        : 0.0,
                    isWishlist: false,
                    isFeatured: false,
                    discount: 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlightDetailsScreen(
                          flightId: flight.id ?? 0,
                        ),
                      ),
                    ),
                    onWishlistTap: null,
                    type: 'flight',
                    id: flight.id?.toString() ?? '0',
                    badgeText: 'FLIGHT',
                    badgeColor: Colors.blueAccent,
                    priceSuffix: '',
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search parameters.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {

                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff05A8C7),
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
                      style:  GoogleFonts.spaceGrotesk(
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


