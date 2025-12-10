import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../hotel/search_hotel_screen.dart';
import '../hotel/room_detail_screen.dart';
import '../hotel/search_screen.dart';
import '../notification/notifications_screen.dart';

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
  String _selectedCity = '';

  @override
  void dispose() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.tabController =
        TabController(length: categoryDatas.length, vsync: this);

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

  // ADD THIS METHOD
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
                        style: TextStyle(
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guests'.tr,
                        style: TextStyle(fontSize: 16),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
            onTap: () {

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
                    'assets/icons/location.svg',
                    width: 20,
                    height: 20,
                    color: Color(0xff6B7280),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCity.isEmpty ? 'City or destination'.tr : _selectedCity,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: _selectedCity.isEmpty ? Color(0xff6B7280) : Color(0xff1D2025),
                      ),
                    ),
                  ),
                ],
              ),
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
                      city: _selectedCity.isEmpty ? null : _selectedCity,
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
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 140,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1D2025),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Color(0xff6B7280),
                  ),
                ),
              ],
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
                    // Home tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          homeList == null
                              ? Center(child: CircularProgressIndicator())
                              : MixedItemList(homeList: homeList),
                        ],
                      ),
                    ),
                    // Hotels tab with search section
                    Column(
                      children: [
                        _buildHotelSearchSection(context),
                        _buildFeaturedDestinations(),
                        // _buildResultsCount(1, homeProvider, boatProvider,
                        //     tourProvider, spaceProvider, eventProvider, flightProvider),
                        // _buildFilterTabs(1),
                        // Expanded(
                        //   child: PropertyList(
                        //       hotelList: homeProvider.hotelListPerCategory[1] ?? HotelList()),
                        // ),
                      ],
                    ),
                    // Other tabs
                    ...List.generate(categoryDatas.length - 2, (index) {
                      int tabIndex = index + 2;
                      return Column(
                        children: [
                          _buildResultsCount(tabIndex, homeProvider, boatProvider,
                              tourProvider, spaceProvider, eventProvider, flightProvider),
                          _buildFilterTabs(tabIndex),
                          Expanded(
                            child: _buildTabContent(
                                tabIndex,
                                homeProvider,
                                boatProvider,
                                tourProvider,
                                spaceProvider,
                                eventProvider,
                                flightProvider),
                          ),
                        ],
                      );
                    }),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_getItemCount(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} ${'items found'.tr}'
                    .tr,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                    fontFamily: 'Inter'.tr),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '${'Showing'.tr} ${_getStartId(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} - ${_getEndId(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} ${'of'.tr} ${_getItemCount(index, homeProvider, boatProvider, tourProvider, spaceProvider, eventProvider, flightProvider)} ${'items'.tr}',
              style: TextStyle(
                  color: grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter'.tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int index) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: index == 6
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _showSortingOptions(index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Row(
                  children: [
                    Text(selectedSort),
                    SizedBox(width: 5),
                    SvgPicture.asset('assets/icons/arrow_down.svg'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6),
            if (index != 6)
              InkWell(
                onTap: () {
                  final homeProvider =
                  Provider.of<HomeProvider>(context, listen: false);
                  final tourProvider =
                  Provider.of<TourProvider>(context, listen: false);
                  final spaceProvider =
                  Provider.of<SpaceProvider>(context, listen: false);

                  final boatProvider =
                  Provider.of<BoatProvider>(context, listen: false);
                  final eventProvider =
                  Provider.of<EventProvider>(context, listen: false);

                  switch (index) {
                    case 1: // Hotels
                      final hotelList =
                      homeProvider.hotelListPerCategory[index];
                      if (hotelList != null && hotelList.data != null) {
                        log("Number of hotels being sent to map: ${hotelList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(),
                          ),
                        );
                      }
                      break;
                    case 2: // Tours
                      final tourList = tourProvider.tourListPerCategory[index];
                      if (tourList != null && tourList.data != null) {
                        log("Number of tours being sent to map: ${tourList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreenTour(),
                          ),
                        );
                      }
                      break;
                    case 3: // Spaces
                      final spaceList =
                      spaceProvider.spaceListPerCategory[index];
                      if (spaceList != null && spaceList.data != null) {
                        log("Number of spaces being sent to map: ${spaceList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreenSpace(),
                          ),
                        );
                      }
                      break;
                    case 4: // Cars
                      final carList = homeProvider.carListPerCategory[index];
                      if (carList != null && carList.data != null) {
                        log("Number of cars being sent to map: ${carList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreenCar(),
                          ),
                        );
                      }
                      break;
                    case 5: // Events
                      final eventList =
                      eventProvider.eventListPerCategory[index];
                      if (eventList != null && eventList.data != null) {
                        log("Number of events being sent to map: ${eventList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreenEvent(),
                          ),
                        );
                      }
                      break;
                    case 7: // Boats
                      final boatList = boatProvider.boatListPerCategory[index];
                      if (boatList != null && boatList.data != null) {
                        log("Number of boats being sent to map: ${boatList.data!.length}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreenBoat(),
                          ),
                        );
                      }
                      break;
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Row(
                    children: [
                      Text('Show on the map'.tr),
                      SizedBox(width: 5),
                      SvgPicture.asset('assets/icons/map_icon.svg'),
                    ],
                  ),
                ),
              ),
            SizedBox(width: index == 6 ? 115 : 6),
            InkWell(
              onTap: () {
                if (index == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterScreen();
                    },
                  ));
                } else if (index == 2) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterTourScreen();
                    },
                  ));
                } else if (index == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterSpaceScreen();
                    },
                  ));
                } else if (index == 4) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterCarScreen();
                    },
                  ));
                } else if (index == 5) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterEventScreen();
                    },
                  ));
                } else if (index == 6) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterFlightScreen();
                    },
                  ));
                } else if (index == 7) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FilterBoatScreen();
                    },
                  ));
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Row(
                  children: [
                    Text('Filter'.tr),
                    SvgPicture.asset('assets/icons/filter_icon.svg'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  style: TextStyle(
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
                              style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        SizedBox(height: 16),
                        Text(
                          offer.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          offer.desc.replaceAll('<br>', ' '),
                          style: TextStyle(
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
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
        print("Unhandled item type: ${item.type}");
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
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: eventList.data?.length,
            itemBuilder: (context, index) {
              var eventData = EvenData.fromEvent(eventList.data![index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: EventItem(
                    dataSrc: eventData,
                    press: () {
                      log("go to event");
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return EventsDetailsScreen(
                              eventId: eventList.data?[index].id ?? 0);
                        },
                      ));
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}

//Property item widget builder

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
    return GestureDetector(
      onTap: widget.press,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: kColor1,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageCarouselWithDots(
                  images: widget.dataSrc.images,
                ),
                Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () async {
                        log("fav 1");

                        // Retrieve the token from SharedPreferences
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
                              title: 'Log in to add to',
                              content: 'wishlists',
                              onCancel: () {
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
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

                        // Proceed with adding to wishlist if token is not null
                        final homeProvider =
                        Provider.of<HomeProvider>(context, listen: false);
                        final success = await homeProvider.addToWishlist(
                          widget.dataSrc.id.toString(),
                          'hotel',
                        );
                        homeProvider.homelistapi(0);
                        homeProvider.fetchHotelDetails(widget.dataSrc.id);
                        await homeProvider.hotellistapi(1, searchParams: {});

                        if (success == "Added to wishlist") {
                          setState(() {
                            widget.dataSrc.isWishlist = true;
                          });
                        } else if (success == "Removed from wishlist") {
                          setState(() {
                            widget.dataSrc.isWishlist = false;
                          });
                        }
                        // ignore: use_build_context_synchronously

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success)),
                        );
                      },
                      child: SvgPicture.asset(
                        widget.dataSrc.isWishlist
                            ? 'assets/icons/like.svg'
                            : 'assets/icons/heart.svg',
                        width: 24,
                        height: 20,
                      ),
                    )),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index <
                              double.parse(widget.dataSrc.reviewscore)
                                  .round()
                              ? Icons.star
                              : Icons.star_border,
                          color: flutterpads,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 250,
                    child: Text(
                      widget.dataSrc.propertyName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter'.tr,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.dataSrc.address,
                    style: TextStyle(fontFamily: 'Inter'.tr, color: darkgrey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${widget.dataSrc.reviewscore}/5',
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w400,
                              color: flutterpads,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.dataSrc.reviewtext,
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: flutterpads,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.dataSrc.reviewcount} reviews'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Inter'.tr,
                          color: darkgrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "from ".tr,
                        style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                          decorationColor: Colors.black,
                        ),
                      ),
                      Text(
                        "\$${widget.dataSrc.price}",
                        style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                          decorationColor: Colors.black,
                        ),
                      ),
                      Text(
                        "/night".tr,
                        style: TextStyle(
                          color: darkgrey,
                          fontFamily: 'Inter'.tr,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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
              var boatData = BoatData.fromBoat(boatList.data![index]);
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

  const FlightListItem({super.key, required this.flightList});

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
            itemCount: flightList.data?.length ?? 0,
            itemBuilder: (context, index) {
              var flightData = FlightData.fromFlight(flightList.data![index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: FlightItem(
                  dataSrc: flightData,
                  press: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlightDetailsScreen(
                        flightId: flightList.data![index].id ?? 1,
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

class OfferItem extends StatelessWidget {
  final home_item.Offer offer;
  final VoidCallback press;

  const OfferItem({Key? key, required this.offer, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(offer.title),
      subtitle: Text(offer.desc),
      onTap: press,
    );
  }
}

class DestinationItem extends StatelessWidget {
  final home_item.Location location;
  final VoidCallback press;

  const DestinationItem({Key? key, required this.location, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                location.imgUrl.isNotEmpty
                    ? location.imgUrl
                    : (location.bannerImgUrl ?? ''),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Text(
                        '${location.spaceCount} Spaces',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${location.tourCount} Tours',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${location.hotelCount} Hotels',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}