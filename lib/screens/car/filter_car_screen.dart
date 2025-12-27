// ignore_for_file: prefer_const_constructors

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
// ignore: unused_import
import 'package:moonbnd/modals/car_list_model.dart';
import 'package:moonbnd/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FilterCarScreen extends StatefulWidget {
  const FilterCarScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterCarScreen> {
  double _minPrice = 250;
  double _maxPrice = 450;
  String searchLocation = '';

  int selectedReviewScore = -1;
  List<String> selectedPropertyTypes = [];
  List<String> selectedFacilities = [];

  final List<String> carTypes = [
    "Convertibles".tr,
    "Coupes".tr,
    "Hatchbacks".tr,
    "Minivans".tr,
    "Sedan".tr,
    "SUVs".tr,
    "Trucks".tr,
    "Wagons".tr,
  ];

  final List<String> carFeatures = [
    "Airbag".tr,
    "FM Radio".tr,
    "Sensor".tr,
    "Speed KM".tr,
    "Power Windows".tr,
    "Steering Wheel".tr,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).searchController =
        TextEditingController();
  }

  void _applyFilters() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    // Convert selected property types to URL-friendly format
    final propertyTypesStr =
        selectedPropertyTypes.join(',').toLowerCase().replaceAll(' ', '-');
    final facilitiesStr =
        selectedFacilities.join(',').toLowerCase().replaceAll(' ', '-');

    // Fix star ratings to send correct value (5 star should send 5)

    final reviewScores =
        selectedReviewScore != -1 ? (6 - selectedReviewScore).toString() : '';

    // Create attributes map
    Map<String, String> attrs = {};
    if (propertyTypesStr.isNotEmpty) attrs['9'] = propertyTypesStr;
    if (facilitiesStr.isNotEmpty) attrs['10'] = facilitiesStr;

    final provider = Provider.of<HomeProvider>(context, listen: false);

    // Update search parameters and navigate back
    provider.setSelectedHomeTab(4); // Set hotel tab as active

    // Use the existing hotellistapi with search parameters
    await provider.carlistapi(4, searchParams: {
      'location': homeProvider.searchController.value.text.isEmpty
          ? ""
          : homeProvider.searchController.value.text,
      'review_score': reviewScores,
      'car_type': propertyTypesStr,
      'car_features': facilitiesStr,
      'price_range': '${_minPrice.round()};${_maxPrice.round()}',
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filters'.tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
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
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),),
            const SizedBox(height: 10),
            // ignore: sized_box_for_whitespace
            Container(
              width: 350, // Set your desired width here
              child: RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 250,
                max: 450,
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

            const SizedBox(height: 18),
            _buildSectionTitle('Review Score'.tr),
            const SizedBox(height: 18),
            _buildReviewScoreSelection(),
            const SizedBox(height: 18),
            const Divider(thickness: 1),
            const SizedBox(height: 18),
            _buildSectionTitle('Car Type'.tr),
            const SizedBox(height: 10),
            FilterChipWidget(
              items: carTypes,
              selectedItems: selectedPropertyTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedPropertyTypes = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 18),
            _buildSectionTitle('Car Features'.tr),
            const SizedBox(height: 10),
            FilterChipWidget(
                items: carFeatures,
                selectedItems: selectedFacilities,
                onSelectionChanged: (selected) {
                  setState(() {
                    selectedFacilities = selected;
                  });
                }),

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
                        .carlistapi(4, searchParams: {});

                if (check == true) {
                  setState(() {
                    selectedPropertyTypes.clear();
                    selectedFacilities.clear();

                    selectedReviewScore = -1;
                  });

                  Navigator.pop(context);
                }
              },
              child: Text(
                "Clear all".tr,
                style: GoogleFonts.spaceGrotesk(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                )
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
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),);
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
                style:  GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ) // Adjust // Adjust font size if needed
              ),
              // const SizedBox(height: 4), // Space between label and price
              Text('\$${value.round()}'.tr,style: GoogleFonts.spaceGrotesk(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              )),
            ],
          ),
        ),
      ],
    );
  }

  // Build section titles
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.spaceGrotesk(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ));
  }

  /// Build review score selection row
  Widget _buildReviewScoreSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(5, (index) {
        int starValue = 5 - index;
        final isSelected = selectedReviewScore == index + 1;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedReviewScore = index + 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? kSecondaryColor : grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // ⭐ critical
              children: [
                Text(
                  '$starValue',
                  style: GoogleFonts.spaceGrotesk(

                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 14,
                  color: isSelected ? kSecondaryColor : Colors.black,
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
            style: GoogleFonts.spaceGrotesk(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            )
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
