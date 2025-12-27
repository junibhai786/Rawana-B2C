// ignore_for_file: prefer_const_constructors

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FilterFlightScreen extends StatefulWidget {
  const FilterFlightScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterFlightScreenState createState() => _FilterFlightScreenState();
}

class _FilterFlightScreenState extends State<FilterFlightScreen> {
  double _minPrice = 10;
  double _maxPrice = 90;
  List<String> selectedFlightTypes = [];
  List<String> selectedFacilities = [];

  final List<String> flightTypes = [
    "Business".tr,
    "First Class".tr,
    "Economy".tr,
    "Premium Economy".tr,
  ];

  final List<String> facilities = [
    "Inflight Dining".tr,
    "Seats & Cabin".tr,
    "Sky Shopping".tr,
    "Music".tr,
  ];

  void _applyFilters() async {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    // Convert selected property types to URL-friendly format
    final flightTypesStr =
        selectedFlightTypes.join(',').toLowerCase().replaceAll(' ', '-');
    final facilitiesStr = selectedFacilities
        .join(',')
        .toLowerCase()
        .replaceAll(' ', '-'); // Create attributes map
    Map<String, String> attrs = {};

    if (flightTypesStr.isNotEmpty) attrs['12'] = flightTypesStr;
    if (facilitiesStr.isNotEmpty) attrs['13'] = facilitiesStr;

    Provider.of<FlightProvider>(context, listen: false);

    await flightProvider.flightlistapi(6, searchParams: {
      'flight_types': flightTypesStr,
      'facilities': facilitiesStr,
      'price_range': '${_minPrice.round()};${_maxPrice.round()}',
    });

    Navigator.pop(context); // Return to previous screen
  }

  @override
  void initState() {
    super.initState();
    _minPrice = 10;
    _maxPrice = 90;
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Filter Price'.tr,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                )

            ),
            const SizedBox(height: 10),
            // ignore: sized_box_for_whitespace
            Container(
              width: 350, // Set your desired width here
              child: RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 10,
                max: 90,
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

            const SizedBox(
              height: 18,
            ),

            _buildSectionTitle('Flight Type'.tr),
            const SizedBox(
              height: 10,
            ),
            FilterChipWidget(
              items: flightTypes,
              selectedItems: selectedFlightTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFlightTypes = selected;
                });
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(
              height: 18,
            ),
            _buildSectionTitle('Inflight Experience'.tr),
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
                    await Provider.of<FlightProvider>(context, listen: false)
                        .flightlistapi(6, searchParams: {});

                if (check != null) {
                  setState(() {
                    selectedFlightTypes.clear();
                    selectedFacilities.clear();
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
                ) // Adjust fo
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
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ) // Adjust fo
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
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ) // Adjust fofont size if needed
              ),
              // const SizedBox(height: 4), // Space between label and price
              Text('\$${value.round()}'.tr,style: GoogleFonts.spaceGrotesk(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ) )// Adjust fo,),
            ],
          ),
        ),
      ],
    );
  }

  // Build section titles
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style:GoogleFonts.spaceGrotesk(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ) // Adjust fo


    );
  }

  // Build star selection row

  // Build review score selection row
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
            style:GoogleFonts.spaceGrotesk(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ) // Adjust fo
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
