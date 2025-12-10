// ignore_for_file: prefer_const_constructors

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/search_field.dart';
import 'package:moonbnd/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  DateTime? startDate;
  DateTime? endDate;
  double _minPrice = 100;
  double _maxPrice = 900;
  int selectedHotelStar = -1;
  int selectedReviewScore = -1;
  List<String> selectedPropertyTypes = [];
  List<String> selectedFacilities = [];
  List<String> selectedServices = [];
  String searchLocation = '';

  final List<String> propertyTypes = [
    "Apartments".tr,
    "Hotels".tr,
    "Homestays".tr,
    "Holiday homes".tr,
    "Villas".tr,
    "Motels".tr,
    "Resorts".tr,
    "Lodges".tr,
    "Cruises".tr,
    "Boats".tr
  ];

  final List<String> facilities = [
    "Wake-up call".tr,
    "Car hire".tr,
    "Flat TV".tr,
    "Laundry & dry cleaning".tr,
    "Bicycle Hire".tr,
    "Internet – Wifi".tr,
    "Coffee and tea".tr
  ];

  final List<String> hotelServices = [
    "Havana Lobby bar".tr,
    "Fiesta Restaurant".tr,
    "Laundry Services".tr,
    "Pets welcome".tr,
    "Free luggage deposit".tr,
    "Tickets".tr,
    "Hotel transport services".tr
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).searchController =
        TextEditingController();
    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(days: 1));
  }

  void _applyFilters() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    // Convert selected property types to URL-friendly format
    final propertyTypesStr =
        selectedPropertyTypes.join(',').toLowerCase().replaceAll(' ', '-');
    final facilitiesStr =
        selectedFacilities.join(',').toLowerCase().replaceAll(' ', '-');
    final servicesStr =
        selectedServices.join(',').toLowerCase().replaceAll(' ', '-');

    // Fix star ratings to send correct value (5 star should send 5)
    final starRates =
        selectedHotelStar != -1 ? (6 - selectedHotelStar).toString() : '';
    final reviewScores =
        selectedReviewScore != -1 ? (6 - selectedReviewScore).toString() : '';

    // Create attributes map
    Map<String, String> attrs = {};
    if (propertyTypesStr.isNotEmpty) attrs['5'] = propertyTypesStr;
    if (facilitiesStr.isNotEmpty) attrs['6'] = facilitiesStr;
    if (servicesStr.isNotEmpty) attrs['7'] = servicesStr;

    final provider = Provider.of<HomeProvider>(context, listen: false);

    // Update search parameters and navigate back
    provider.setSelectedHomeTab(1); // Set hotel tab as active

    // Use the existing hotellistapi with search parameters
    await provider.hotellistapi(1, searchParams: {
      'location': homeProvider.searchController.value.text.isEmpty
          ? ""
          : homeProvider.searchController.value.text,
      'star_rate': starRates,
      'review_score': reviewScores,
      'property_type': propertyTypesStr,
      'facilities': facilitiesStr,
      'services': servicesStr,
      'price_range': '${_minPrice.round()};${_maxPrice.round()}',
      'check_in':
          startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '',
      'check_out':
          endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '',
    });

    Navigator.pop(context); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filters'.tr,
          style: TextStyle(
              color: kPrimaryColor,
              fontFamily: 'Inter'.tr,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              controller: homeProvider.searchController,
              hint: "Search locations, cities".tr,
              onChanged: (value) {
                setState(() {
                  searchLocation = value.trim();
                });
              },
            ),
            SizedBox(height: 18),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(height: 10),

            SectionTitle(ktext: "Check in - Check out".tr),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showCustomDateRangePicker(
                  context,
                  dismissible: true,
                  minimumDate: DateTime.now(),
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
                    SvgPicture.asset('assets/icons/calendar.svg'),
                    SizedBox(width: 12),
                    Text(
                      "${startDate != null ? DateFormat("MMM dd").format(startDate!) : ''} - ${endDate != null ? DateFormat("MMM dd").format(endDate!) : 'Choose Date'.tr}",
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
            SizedBox(height: 18),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            Text('Filter Price'.tr,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter'.tr,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor)),
            const SizedBox(height: 10),
            // ignore: sized_box_for_whitespace
            Container(
              width: 350, // Set your desired width here
              child: RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 100,
                max: 900,
                divisions: 100,
                labels: RangeLabels(
                    '\$${_minPrice.round()}', '\$${_maxPrice.round()}'),
                activeColor:
                    kSecondaryColor, // Set the active color to kSecondaryColor
                inactiveColor: Colors.grey[300],
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInputField('Minimum'.tr, _minPrice),
                _buildPriceInputField('Maximum'.tr, _maxPrice),
              ],
            ),

            SizedBox(
              height: 18,
            ),

            const Divider(
              thickness: 1,
            ),

            SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Hotel Star'.tr),
            const SizedBox(
              height: 18,
            ),
            _buildStarSelection(),
            const SizedBox(
              height: 18,
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Review Score'.tr),
            const SizedBox(
              height: 18,
            ),
            _buildReviewScoreSelection(),
            const SizedBox(
              height: 18,
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Property Type'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: propertyTypes,
              selectedItems: selectedPropertyTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedPropertyTypes = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Facilities'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: facilities,
              selectedItems: selectedFacilities,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFacilities = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Hotel Service'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: hotelServices,
              selectedItems: selectedServices,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedServices = selected;
                });
              },
            ),
            const Divider(thickness: 1),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  bool check =
                      await Provider.of<HomeProvider>(context, listen: false)
                          .hotellistapi(1, searchParams: {});
        
                  if (check == true) {
                    setState(() {
                      selectedPropertyTypes.clear();
                      selectedFacilities.clear();
                      selectedServices.clear();
                      selectedHotelStar = -1;
                      selectedReviewScore = -1;
                    });
        
                    Navigator.pop(context);
                  }
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
                  onPressed: _applyFilters,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 8,
                    ),
                    child: Row(
                      children: [
                        // Icon(
                        //   Icons.search,
                        //   color: Colors.white,
                        // ),
                        // SizedBox(
                        //   width: 8,
                        // ),
                        Text(
                          "Next".tr,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build price input field
  Widget _buildPriceInputField(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          width: 145,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                label,
                style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 12), // Adjust font size if needed
              ),
              // const SizedBox(height: 4), // Space between label and price
              Text('\$${value.round()}'.tr),
            ],
          ),
        ),
      ],
    );
  }

  // Build section titles
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontFamily: 'Inter'.tr,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kPrimaryColor));
  }

  // Build star selection row
  Widget _buildStarSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int starValue = 5 - index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedHotelStar = index + 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      selectedHotelStar == index + 1 ? kSecondaryColor : grey,
                  width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  '$starValue',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  color: selectedHotelStar == index + 1
                      ? kSecondaryColor
                      : Colors.black,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Build review score selection row
  Widget _buildReviewScoreSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int starValue = 5 - index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedReviewScore = index + 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      selectedReviewScore == index + 1 ? kSecondaryColor : grey,
                  width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  '$starValue',
                  style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  color: selectedReviewScore == index + 1
                      ? kSecondaryColor
                      : Colors.black,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const FilterChipWidget({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(
            item,
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 14,
                fontFamily: 'Inter'.tr,
                fontWeight: FontWeight.w400),
          ),
          selected: isSelected,
          side: BorderSide(
            color: isSelected ? Colors.black : kColor1,
            width: 1.3,
          ),
          backgroundColor: kBackgroundColor,
          selectedColor: Colors.white,
          checkmarkColor: Colors.transparent,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onSelected: (bool selected) {
            List<String> updatedSelection = List.from(selectedItems);
            if (selected) {
              updatedSelection.add(item);
            } else {
              updatedSelection.remove(item);
            }
            onSelectionChanged(updatedSelection);
          },
        );
      }).toList(),
    );
  }
}
