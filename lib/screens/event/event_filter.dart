// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/search_field.dart';
import 'package:moonbnd/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilterEventScreen extends StatefulWidget {
  const FilterEventScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterEventScreen> {
  double _minPrice = 0;
  double _maxPrice = 2000;
  DateTime? startDate;
  String assignStartDate = "";

  String searchLocation = '';

  int selectedReviewScore = -1;
  List<String> selectedBoatTypes = [];

  List<String> selectedAmeneties = [];

  final List<String> boatTypes = [
    "field day".tr,
    "green man".tr,
    "latitude".tr,
    "boomtown".tr,
    "wilderness".tr,
    "exit festival".tr,
    "primavera sound".tr,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<EventProvider>(context, listen: false).searchController =
        TextEditingController();
  }

  void _applyFilters() async {
    final homeProvider = Provider.of<EventProvider>(context, listen: false);
    // Convert selected property types to URL-friendly format
    final boatTypesStr =
        selectedBoatTypes.join(',').toLowerCase().replaceAll(' ', '-');

    final reviewScores =
        selectedReviewScore != -1 ? (6 - selectedReviewScore).toString() : '';

    // Create attributes map
    Map<String, String> attrs = {};
    if (boatTypesStr.isNotEmpty) attrs['11'] = boatTypesStr;

    final provider = Provider.of<EventProvider>(context, listen: false);

    // Update search parameters and navigate back
    provider.setSelectedHomeTab(5); // Set boat tab as active

    // Use the existing hotellistapi with search parameters
    bool check = await provider.eventlistapi(5, searchParams: {
      'location': homeProvider.searchController.value.text.isEmpty
          ? ""
          : homeProvider.searchController.value.text,
      'review_score': reviewScores,
      'startDate': startDate,
      'event_type': boatTypesStr,
      'price_range': '${_minPrice.round()};${_maxPrice.round()}',
    });

    if (check) {
      Navigator.pop(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<EventProvider>(context, listen: true);
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

            SizedBox(height: 10),
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
                min: 0,
                max: 2000,
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

            SizedBox(height: 18),

            const Divider(thickness: 1),

            SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(ktext: "Start Date".tr),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                        assignStartDate = picked.toString();
                        log(assignStartDate);
                      });
                    }
                    // showCustomDateRangePicker(
                    //   context,
                    //   dismissible: true,
                    //   minimumDate: DateTime.now(),
                    //   maximumDate: DateTime.now().add(Duration(days: 365)),
                    //   endDate: null,
                    //   startDate: startDate,
                    //   backgroundColor: kBackgroundColor,
                    //   primaryColor: kPrimaryColor,
                    //   onApplyClick: (start, end) {
                    //     setState(() {
                    //       startDate = start;
                    //     });
                    //   },
                    //   onCancelClick: () {
                    //     setState(() {
                    //       startDate = null;
                    //     });
                    //   },
                    // );
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

            const SizedBox(height: 18),
            _buildSectionTitle('Review Score'.tr),
            const SizedBox(height: 18),
            _buildReviewScoreSelection(),
            const SizedBox(height: 18),
            const Divider(thickness: 1),
            const SizedBox(height: 18),
            _buildSectionTitle('Event Type'.tr),
            const SizedBox(height: 10),
            FilterChipWidget(
              items: boatTypes,
              selectedItems: selectedBoatTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedBoatTypes = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 18),
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
                    await Provider.of<EventProvider>(context, listen: false)
                        .eventlistapi(5, searchParams: {});

                if (check == true) {
                  setState(() {
                    selectedBoatTypes.clear();
                    selectedAmeneties.clear();

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

  /// Build review score selection row
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
