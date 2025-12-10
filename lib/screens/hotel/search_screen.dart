import 'dart:developer';

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/home_screen_data.dart';
import 'package:moonbnd/widgets/search_field.dart';
import 'package:moonbnd/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Provider/space_provider.dart';
import '../../widgets/separator.dart';
import '../../Provider/flight_provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  late TabController _tabController;
  String searchLocation = '';
  String toLocation = '';
  int selectedRooms = 0;
  int selectedAdults = 0;
  int selectedChildren = 0;
  int selectedGuests = 0;
  final TextEditingController _toLocationController = TextEditingController();
  int _vipCount = 0;
  int _economyCount = 0;
  int _premiumCount = 0;
  int _firstClassCount = 0;
  int _businessCount = 0;
  int _petsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: categoryDatas.length - 1, vsync: this);
    Provider.of<HomeProvider>(context, listen: false).searchController.text =
        searchLocation;

    // Set default dates
    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(days: 1));
  }

  @override
  void dispose() {
    _tabController.dispose();
    Provider.of<HomeProvider>(context, listen: false)
        .searchController
        .dispose();
    _toLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Search".tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(ktext: "Where to?".tr),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categoryDatas.map((category) {
                        if (category.id == 0) return SizedBox.shrink();
                        return Row(
                          children: [
                            _buildTabButton(category.category, category.id),
                            SizedBox(width: 10),
                          ],
                        );
                      }).toList(),

                      // _buildTabButton("Hotel".tr, 0),
                      // SizedBox(width: 10),
                      // _buildTabButton("Space".tr, 1),
                      // SizedBox(width: 10),
                      // _buildTabButton("Tour".tr, 2),
                      // SizedBox(width: 10),
                      // _buildTabButton("Event".tr, 3),
                      // SizedBox(width: 10),
                      // _buildTabButton("Car".tr, 4),
                      // SizedBox(width: 10),
                      // _buildTabButton("Flight".tr, 5),
                      // SizedBox(width: 10),
                      // _buildTabButton("Boat".tr, 6),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (homeProvider.index != 5)
                    SearchField(
                      controller: homeProvider.searchController,
                      hint: "Search locations, cities".tr,
                      onChanged: (value) {
                        setState(() {
                          searchLocation = value.trim();
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHotelTabContent(1),
                  _buildTourTabContent(),
                  _buildSpaceTabContent(),
                  _buildCarTabContent(4),
                  _buildEventTabContent(),
                  _buildFlightTabContent(),
                  _buildBoatTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHotelTabContent(int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildDateSelector(),
          Separator(),
          _buildGuestSelector(),
        ],
      ),
    );
  }

  Widget _buildSpaceTabContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildFromToSelector(),
          Separator(),
        ],
      ),
    );
  }

  Widget _buildTourTabContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildFromToSelector(),
        ],
      ),
    );
  }

  Widget _buildEventTabContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildFromToSelector(),
        ],
      ),
    );
  }

  Widget _buildCarTabContent(int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildFromToSelector(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "Check in - Check out".tr),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime.now().subtract(Duration(days: 90)),
                maximumDate: DateTime.now().add(Duration(days: 90)),
                endDate: endDate,
                startDate: startDate,
                backgroundColor: kBackgroundColor,
                primaryColor: kPrimaryColor,
                onApplyClick: (start, end) {
                  setState(() {
                    endDate = end;
                    startDate = start;
                  });
                },
                onCancelClick: () {
                  setState(() {
                    endDate = null;
                    startDate = null;
                  });
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: kColor1),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/calendar.svg'),
                  SizedBox(width: 12),
                  Text(
                    "${startDate != null ? DateFormat("MMM dd").format(startDate!) : ''} - ${endDate != null ? DateFormat("MMM dd").format(endDate!) : 'Choose Date -'.tr}",
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontSize: 14,
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

  Widget _buildFromToSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "From - To".tr),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime.now().subtract(Duration(days: 90)),
                maximumDate: DateTime.now().add(Duration(days: 90)),
                endDate: endDate,
                startDate: startDate,
                backgroundColor: kBackgroundColor,
                primaryColor: kPrimaryColor,
                onApplyClick: (start, end) {
                  setState(() {
                    endDate = end;
                    startDate = start;
                  });
                },
                onCancelClick: () {
                  setState(() {
                    endDate = null;
                    startDate = null;
                  });
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: kColor1),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/calendar.svg'),
                  SizedBox(width: 12),
                  Text(
                    "${startDate != null ? DateFormat("MMM dd").format(startDate!) : ''} - ${endDate != null ? DateFormat("MMM dd").format(endDate!) : 'Choose Date -'.tr}",
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontSize: 14,
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

  Widget _buildGuestSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "Guests".tr),
          SizedBox(height: 16),
          _buildRoomSelector(),
          Divider(height: 32, thickness: 1),
          _buildAdultsSelector(),
          Divider(height: 32, thickness: 1),
          _buildChildrenSelector(),
          Divider(height: 32, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildRoomSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Room".tr,
          style: TextStyle(
            fontFamily: 'Inter'.tr,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuantitySelector(
          initialValue: selectedRooms,
          onChanged: (value) {
            setState(() {
              selectedRooms = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdultsSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Adults".tr,
          style: TextStyle(
            fontFamily: 'Inter'.tr,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuantitySelector(
          initialValue: selectedAdults,
          onChanged: (value) {
            setState(() {
              selectedAdults = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChildrenSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Children".tr,
          style: TextStyle(
            fontFamily: 'Inter'.tr,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuantitySelector(
          initialValue: selectedChildren,
          onChanged: (value) {
            setState(() {
              selectedChildren = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  searchLocation = '';
                  startDate = null;
                  endDate = null;
                  selectedRooms = 0;
                  selectedAdults = 0;
                  selectedChildren = 0;
                  _vipCount = 0;
                  _economyCount = 0;
                  _premiumCount = 0;
                  _firstClassCount = 0;
                  _businessCount = 0;
                  _petsCount = 0;
                  Provider.of<HomeProvider>(context, listen: false)
                      .searchController
                      .clear();
                  _toLocationController.clear();
                });
              },
              child: Text(
                "Clear all".tr,
                style: TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  print("Search button pressed");
                  _performSearch();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Search".tr,
                        style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    bool isSelected = homeProvider.index == index;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
        onPressed: () {
          log("$index");
          homeProvider.searchIndex(index);
          setState(() {
            _tabController.animateTo(index - 1);
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          backgroundColor: kBackgroundColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildBoatTabContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Separator(),
          _buildBoatStartDateSelector(),
        ],
      ),
    );
  }

  Widget _buildBoatStartDateSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "Start Date".tr),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(Duration(days: 365)),
                endDate: null,
                startDate: startDate,
                backgroundColor: kBackgroundColor,
                primaryColor: kPrimaryColor,
                onApplyClick: (start, end) {
                  setState(() {
                    startDate = start;
                  });
                },
                onCancelClick: () {
                  setState(() {
                    startDate = null;
                  });
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: kColor1),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/calendar.svg'),
                  SizedBox(width: 12),
                  Text(
                    startDate != null
                        ? DateFormat("MMM dd").format(startDate!)
                        : 'Choose Start Date'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontSize: 14,
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

  Widget _buildFlightTabContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlightLocationInputs(),
          Separator(),
          _buildFlightDepartureSelector(),
          Separator(),
          _buildFlightTravelersSelector(),
        ],
      ),
    );
  }

  Widget _buildFlightLocationInputs() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            controller: Provider.of<HomeProvider>(context, listen: false)
                .searchController,
            hint: "From where".tr,
            onChanged: (value) {
              setState(() {
                searchLocation = value.trim();
              });
            },
          ),
          SizedBox(height: 16),
          SearchField(
            controller: _toLocationController,
            hint: "To where".tr,
            onChanged: (value) {
              setState(() {
                toLocation = value.trim();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDepartureSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "Depart".tr),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(Duration(days: 365)),
                endDate: null,
                startDate: startDate,
                backgroundColor: kBackgroundColor,
                primaryColor: kPrimaryColor,
                onApplyClick: (start, end) {
                  setState(() {
                    startDate = start;
                  });
                },
                onCancelClick: () {
                  setState(() {
                    startDate = null;
                  });
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: kColor1),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/calendar.svg'),
                  SizedBox(width: 12),
                  Text(
                    startDate != null
                        ? DateFormat("MMM dd").format(startDate!)
                        : 'Choose Departure Date'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontSize: 14,
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

  Widget _buildFlightTravelersSelector() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(ktext: "Travelers".tr),
          SizedBox(height: 16),
          Column(
            children: [
              _buildTravelerRow("Adults VIP".tr),
              Divider(),
              _buildTravelerRow("Adults Economy".tr),
              Divider(),
              _buildTravelerRow("Adults Premium".tr),
              Divider(),
              _buildTravelerRow("Adults First Class".tr),
              Divider(),
              _buildTravelerRow("Adults Business".tr),
              Divider(),
              _buildTravelerRow("Pets".tr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerRow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter'.tr,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 20),
        QuantitySelector(
          onChanged: (int value) {},
        ),
      ],
    );
  }

  void _performSearch() async {
    print("Performing search...");
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    final boatProvider = Provider.of<BoatProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final searchLocation = homeProvider.searchController.text.trim();

    void showSnack(String msg) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg.tr)));
    }

    if (searchLocation.isEmpty && _tabController.index != 5) {
      // Flight allows two fields
      showSnack('Please enter a location');
      return;
    }

    switch (_tabController.index) {
      // 🏨 HOTEL
      case 0:
        if (startDate == null || endDate == null) {
          showSnack('Please select dates');
          return;
        }

        if (selectedRooms == 0 || selectedAdults == 0) {
          showSnack('Please select rooms and guests');
          return;
        }
        print('========== HOTEL SEARCH ==========');
        print('Location: $searchLocation');
        print('Start Date: $startDate');
        print('End Date: $endDate');
        print('Rooms: $selectedRooms');
        print('Adults: $selectedAdults');
        print('Children: $selectedChildren');
        print('Navigating to Tab: 0');
        print('==================================');

        homeProvider.updateHotelSearchParams(
          location: searchLocation,
          startDate: startDate,
          endDate: endDate,
          rooms: selectedRooms,
          adults: selectedAdults,
          children: selectedChildren,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(1);

        homeProvider.hotellistapi(1, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
          'endDate': endDate,
          'rooms': selectedRooms,
          'adults': selectedAdults,
          'children': selectedChildren,
        });

        break;

      // 🏠 SPACE

      case 2:
        print('========== SPACE SEARCH ==========');

        print('Location: $searchLocation');

        print('Start Date: $startDate');

        print('End Date: $endDate');

        print('==================================');

        spaceProvider.updateSpaceSearchParams(
          location: searchLocation,
          startDate: startDate,
          endDate: endDate,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(3);

        spaceProvider.spacelistapi(3, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
          'endDate': endDate,
        });

        break;

      // 🏞️ TOUR

      case 1:
        print('========== TOUR SEARCH ==========');
        print('Location: $searchLocation');
        print('Start Date: $startDate');
        print('End Date: $endDate');
        print('==================================');
        tourProvider.updateTourSearchParams(
          location: searchLocation,
          startDate: startDate,
          endDate: endDate,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(2);

        tourProvider.tourlistapi(2, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
          'endDate': endDate,
        });

        break;

      // 🎟️ EVENT

      case 4:
        print('========== EVENT SEARCH ==========');
        print('Location: $searchLocation');
        print('Start Date: $startDate');

        print('End Date: NOT SENT');

        print('==================================');

        eventProvider.updateEventSearchParams(
          location: searchLocation,
          startDate: startDate,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(5);

        eventProvider.eventlistapi(5, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
        });

        break;

      // 🚗 CAR

      case 3:
        print('========== CAR SEARCH ==========');

        print('Location: $searchLocation');

        print('Start Date: $startDate');

        print('End Date: $endDate');

        print('==================================');

        homeProvider.updateCarSearchParams(
          location: searchLocation,
          startDate: startDate,
          endDate: endDate,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(4);

        homeProvider.carlistapi(4, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
          'endDate': endDate,
        });

        break;

      // ✈️ FLIGHT

      case 5:
        final fromLocation = searchLocation;

        final toLocation = _toLocationController.text.trim();

        if (fromLocation.isEmpty || toLocation.isEmpty) {
          showSnack('Please enter both locations');

          return;
        }

        if (startDate == null) {
          showSnack('Please select departure date');

          return;
        }

        final travelers = {
          'vip': _vipCount,
          'economy': _economyCount,
          'premium': _premiumCount,
          'firstClass': _firstClassCount,
          'business': _businessCount,
          'pets': _petsCount,
        };

        print('========== FLIGHT SEARCH ==========');

        print('From Location: $fromLocation');

        print('To Location: $toLocation');

        print('Departure Date: $startDate');

        print('Travelers: $travelers');

        print('==================================');

        Navigator.pop(context);
        homeProvider.setSelectedHomeTab(6);
        flightProvider.flightlistapi(6, searchParams: {
          'from_where': fromLocation,
          'to_where': toLocation,
          'start': startDate!,
          'travelers': travelers,
        });

        break;

      // ⛵ BOAT

      case 6:
        print('========== BOAT SEARCH ==========');

        print('Location: $searchLocation');

        print('Start Date: $startDate');

        print('==================================');

        boatProvider.updateBoatSearchParams(
          location: searchLocation,
          startDate: startDate,
          searchQuery: searchLocation,
        );

        Navigator.pop(context);

        homeProvider.setSelectedHomeTab(7);

        boatProvider.boatlistapi(7, searchParams: {
          'location': searchLocation,
          'startDate': startDate,
        });

        break;

      default:
        print("No valid tab index found for search.");

        break;
    }
  }
}

// Quantity Selector Widget
class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  QuantitySelector({
    super.key,
    this.initialValue = 0,
    required this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialValue;
  }

  @override
  void didUpdateWidget(QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _count = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (_count > 0) {
              setState(() {
                _count--;
              });
              widget.onChanged(_count);
            }
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: kBackgroundColor,
            ),
            child: Icon(Icons.remove, size: 20, color: kPrimaryColor),
          ),
        ),
        SizedBox(
          width: 42,
          child: Center(
            child: Text(
              '$_count',
              style: TextStyle(
                fontFamily: 'Inter'.tr,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _count++;
            });
            widget.onChanged(_count);
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: kBackgroundColor,
            ),
            child: Icon(Icons.add, size: 20, color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
