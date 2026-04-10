import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/Provider/activity_provider.dart';
import 'package:moonbnd/Provider/currency_provider.dart';
import 'package:moonbnd/Provider/hotel_destination_provider.dart';
import 'package:moonbnd/modals/hotel_destination_model.dart';
import 'package:moonbnd/screens/activities/activity_results_screen.dart';
import 'package:moonbnd/widgets/app_snackbar.dart';
import 'package:moonbnd/widgets/hotel_destination_selection_sheet.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ActivitySearchWidget extends StatefulWidget {
  const ActivitySearchWidget({super.key});

  @override
  State<ActivitySearchWidget> createState() => _ActivitySearchWidgetState();
}

class _ActivitySearchWidgetState extends State<ActivitySearchWidget> {
  final TextEditingController _destinationController = TextEditingController();
  HotelDestinationResult? _selectedDestination;
  DateTime _selectedDate = DateTime.now();
  int _participants = 1;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
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
          // ── Destination field ──────────────────────────────────────────────
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
                controller: _destinationController,
                readOnly: true,
                onTap: () {
                  // Open the hotel destination selection sheet
                  HotelDestinationSelectionSheet.show(
                    context,
                    onDestinationSelected: (destination) {
                      setState(() {
                        _selectedDestination = destination;
                        _destinationController.text =
                            destination.displayName ?? '';
                      });
                      log('[ActivitySearchWidget] Selected destination: ${destination.displayName}');
                      log('[ActivitySearchWidget] City: ${destination.city}');
                      log('[ActivitySearchWidget] Destination field: ${destination.destination}');
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
                  suffixIcon: _destinationController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: kMutedColor),
                          onPressed: () {
                            setState(() {
                              _destinationController.clear();
                              _selectedDestination = null;
                            });
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
                if (_selectedDestination == null) {
                  AppSnackbar.error('Please select a destination first'.tr);
                  return;
                }

                // Extract city name for API call
                // Prefer city field, fallback to destination field
                final destinationForApi =
                    _selectedDestination!.city?.isNotEmpty == true
                        ? _selectedDestination!.city!
                        : (_selectedDestination!.destination?.isNotEmpty == true
                            ? _selectedDestination!.destination!
                            : _selectedDestination!.displayName ?? '');

                log('[ActivitySearchWidget] === Search Activities ===');
                log('[ActivitySearchWidget] Display value: ${_selectedDestination!.displayName}');
                log('[ActivitySearchWidget] City: ${_selectedDestination!.city}');
                log('[ActivitySearchWidget] Destination field: ${_selectedDestination!.destination}');
                log('[ActivitySearchWidget] Final API parameter: $destinationForApi');

                final provider = context.read<ActivityProvider>();
                final currency =
                    context.read<CurrencyProvider>().selectedCurrency;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityResultsScreen(
                      destination: destinationForApi,
                      selectedDate: _selectedDate,
                      participants: _participants,
                    ),
                  ),
                );
                await provider.searchActivities(
                    destination: destinationForApi, currency: currency);
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
