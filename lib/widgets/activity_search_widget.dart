import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/Provider/activity_provider.dart';
import 'package:moonbnd/Provider/hotel_city_provider.dart';
import 'package:moonbnd/Provider/hotel_country_provider.dart';
import 'package:moonbnd/screens/activities/activity_results_screen.dart';
import 'package:moonbnd/widgets/app_snackbar.dart';
import 'package:moonbnd/widgets/hotel_city_selection_sheet.dart';
import 'package:moonbnd/widgets/hotel_country_selection_sheet.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ActivitySearchWidget extends StatefulWidget {
  const ActivitySearchWidget({super.key});

  @override
  State<ActivitySearchWidget> createState() => _ActivitySearchWidgetState();
}

class _ActivitySearchWidgetState extends State<ActivitySearchWidget> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _participants = 1;

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showCountrySelection(BuildContext context) {
    HotelCountrySelectionSheet.show(
      context,
      onCountrySelected: (country) {
        _countryController.text = country.countryName;
        _cityController.clear();
        context.read<HotelCityProvider>().clearOnCountryChange();
      },
    );
  }

  void _showCitySelection(BuildContext context) {
    final countryCode =
        context.read<HotelCountryProvider>().selectedCountryCode;
    HotelCitySelectionSheet.show(
      context,
      countryCode: countryCode,
      onCitySelected: (city) {
        _cityController.text = city.cityName;
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kHeadingColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required Widget prefixIcon,
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

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Country field ──────────────────────────────────────────────
          Text(
            'Country'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kHeadingColor,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _countryController,
            readOnly: true,
            onTap: () => _showCountrySelection(context),
            decoration: _fieldDecoration(
              hint: 'Select country'.tr,
              prefixIcon: const Icon(
                Icons.language,
                size: 20,
                color: kMutedColor,
              ),
            ),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: kHeadingColor,
            ),
          ),

          const SizedBox(height: 12),

          // ── City field ────────────────────────────────────────────────
          Text(
            'City'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kHeadingColor,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _cityController,
            readOnly: true,
            onTap: () => _showCitySelection(context),
            decoration: _fieldDecoration(
              hint: 'Select city'.tr,
              prefixIcon: SvgPicture.asset(
                'assets/icons/location.svg',
                width: 20,
                height: 20,
                color: kMutedColor,
              ),
            ),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: kHeadingColor,
            ),
          ),

          const SizedBox(height: 12),

          // ── Date field ─────────────────────────────────────────────────
          Text(
            'Date'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kHeadingColor,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            readOnly: true,
            onTap: _pickDate,
            controller: TextEditingController(
              text: DateFormat('MM/dd/yyyy').format(_selectedDate),
            ),
            decoration: _fieldDecoration(
              hint: 'Select date'.tr,
              prefixIcon: SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: 20,
                height: 20,
                color: kMutedColor,
              ),
            ),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: kHeadingColor,
            ),
          ),

          const SizedBox(height: 12),

          // ── Participants field ──────────────────────────────────────────
          Text(
            'Participants'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kHeadingColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Icon(Icons.people_outline, color: kMutedColor, size: 20),
                ),
                Expanded(
                  child: Text(
                    '$_participants',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: kHeadingColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        if (_participants < 20) _participants++;
                      }),
                      child: const Icon(Icons.keyboard_arrow_up,
                          size: 18, color: kMutedColor),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (_participants > 1) _participants--;
                      }),
                      child: const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: kMutedColor),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Search Activities button ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final city = _cityController.text.trim();
                if (city.isEmpty) {
                  AppSnackbar.error('Please select a city first'.tr);
                  return;
                }
                final provider = context.read<ActivityProvider>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityResultsScreen(
                      destination: city,
                      selectedDate: _selectedDate,
                      participants: _participants,
                    ),
                  ),
                );
                await provider.searchActivities(destination: city);
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
                    'Search Activities'.tr,
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
}
