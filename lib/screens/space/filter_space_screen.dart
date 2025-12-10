// ignore_for_file: prefer_const_constructors

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';

import 'package:moonbnd/widgets/search_field.dart';
import 'package:moonbnd/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilterSpaceScreen extends StatefulWidget {
  const FilterSpaceScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterSpaceScreenState createState() => _FilterSpaceScreenState();
}

class _FilterSpaceScreenState extends State<FilterSpaceScreen> {
  DateTime? startDate;
  DateTime? endDate;
  double _minPrice = 100;
  double _maxPrice = 900;
  int selectedReviewScore = -1;
  List<String> selectedSpaceTypes = [];
  List<String> selectedAmenities = [];
  List<String> selectedServices = [];
  String searchLocation = '';

  final List<String> spaceTypes = [
    "Auditorium".tr,
    "Bar".tr,
    "Cafe".tr,
    "Ballroom".tr,
    "Dance Studio".tr,
    "Office".tr,
    "Party Hall".tr,
    "Recording Studio".tr,
    "Yoga Studio".tr,
    "Villa".tr,
    "Warehouse".tr,
  ];

  final List<String> amenities = [
    "Air Conditioning".tr,
    "Breakfast".tr,
    "Kitchen".tr,
    "Parking".tr,
    "Pool".tr,
    "Internet – Wifi".tr,
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
    final spaceTypesStr =
        selectedSpaceTypes.join(',').toLowerCase().replaceAll(' ', '-');
    final amenitiesStr =
        selectedAmenities.join(',').toLowerCase().replaceAll(' ', '-');

    // Fix star ratings to send correct value (5 star should send 5)
    final reviewScores =
        selectedReviewScore != -1 ? (6 - selectedReviewScore).toString() : '';

    // Create attributes map
    Map<String, String> attrs = {};

    if (amenitiesStr.isNotEmpty) attrs['3'] = amenitiesStr;
    if (spaceTypesStr.isNotEmpty) attrs['4'] = spaceTypesStr;

    final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
    // Update search parameters and navigate back
    // Note: Removed setSelectedHomeTab call since it doesn't exist in TourProvider

    // Use the existing tourlistapi with search parameters
    await spaceProvider.spacelistapi(3, searchParams: {
      'location': homeProvider.searchController.value.text.isEmpty
          ? ""
          : homeProvider.searchController.value.text,
      'star_rate': '',
      'review_score': reviewScores,
      'space_types': spaceTypesStr,
      'amenities': amenitiesStr,
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

            SectionTitle(ktext: "From - To".tr),
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
            // ignore: duplicate_ignore
            // ignore: prefer_const_constructors
            SizedBox(
              height: 18,
            ),

            const Divider(
              thickness: 1,
            ),

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
            _buildSectionTitle('Space Type'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: spaceTypes,
              selectedItems: selectedSpaceTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedSpaceTypes = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Amenities'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: amenities,
              selectedItems: selectedAmenities,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedAmenities = selected;
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
                final check =
                    await Provider.of<SpaceProvider>(context, listen: false)
                        .spacelistapi(3, searchParams: {});

                if (check ?? false) {
                  setState(() {
                    selectedSpaceTypes.clear();
                    selectedAmenities.clear();
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
                        "Apply".tr,
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
