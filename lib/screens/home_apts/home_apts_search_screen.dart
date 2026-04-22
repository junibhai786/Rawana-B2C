import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/Provider/hotel_destination_provider.dart';
import 'package:moonbnd/widgets/hotel_destination_selection_sheet.dart';
import 'package:moonbnd/screens/home_apts/home_apts_search_result_screen.dart';

/// Home & Apartments Search Screen
/// Displays search form and featured homes/apartments
/// Matches Hotel screen design system exactly

class HomeAptsSearchScreen extends StatefulWidget {
  const HomeAptsSearchScreen({Key? key}) : super(key: key);

  @override
  State<HomeAptsSearchScreen> createState() => _HomeAptsSearchScreenState();
}

class _HomeAptsSearchScreenState extends State<HomeAptsSearchScreen> {
  // State variables
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _units = 1;
  int _adults = 1;
  int _children = 0;
  List<int> _childrenAges = [];
  String _destination = ''; // displayName — shown in text field & screen title
  String _city = ''; // city name — sent to API

  late TextEditingController _destinationController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _validationAttempted = false;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  /// Show guest selector bottom sheet
  void _showUnitAndGuestSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Select Units & Guests'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kHeadingColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Units selector
                    _buildGuestRow(
                      label: 'Units'.tr,
                      value: _units,
                      onAdd: () => setState(() {
                        if (_units < 10) _units++;
                      }),
                      onRemove: () => setState(() {
                        if (_units > 1) _units--;
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Adults selector
                    _buildGuestRow(
                      label: 'Adults'.tr,
                      value: _adults,
                      onAdd: () => setState(() {
                        if (_adults < 10) _adults++;
                      }),
                      onRemove: () => setState(() {
                        if (_adults > 1) _adults--;
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Children selector
                    _buildGuestRow(
                      label: 'Children'.tr,
                      value: _children,
                      onAdd: () => setState(() {
                        if (_children < 10) {
                          _children++;
                          _childrenAges.add(0);
                        }
                      }),
                      onRemove: () => setState(() {
                        if (_children > 0) {
                          _children--;
                          _childrenAges.removeLast();
                        }
                      }),
                    ),

                    // Children ages (if children > 0)
                    if (_children > 0) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Children Ages'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kHeadingColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildChildrenAgeFields(setState),
                    ],

                    const SizedBox(height: 24),

                    // Done button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          this.setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Done'.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build a guest/unit selector row
  Widget _buildGuestRow({
    required String label,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: kHeadingColor,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: kPrimaryColor,
              iconSize: 24,
            ),
            SizedBox(
              width: 40,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kHeadingColor,
                ),
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              color: kPrimaryColor,
              iconSize: 24,
            ),
          ],
        ),
      ],
    );
  }

  /// Build children age input fields
  List<Widget> _buildChildrenAgeFields(StateSetter setState) {
    return List.generate(_children, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Child ${index + 1}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: kHeadingColor,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  final age = int.tryParse(value) ?? 0;
                  if (index < _childrenAges.length) {
                    setState(() {
                      _childrenAges[index] = age;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String checkInText = _checkInDate != null
        ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
        : 'dd/mm/yyyy'.tr;

    String checkOutText = _checkOutDate != null
        ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
        : 'dd/mm/yyyy'.tr;

    final String guestSummary =
        '$_units ${'Unit'.tr}${_units > 1 ? 's' : ''} • $_adults ${'Adult'.tr}${_adults > 1 ? 's' : ''} • $_children ${'Child'.tr}${_children != 1 ? 'ren' : ''}';

    // Border style helper
    OutlineInputBorder _border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        );

    // Field decoration helper
    InputDecoration _fieldDecoration({
      required String hint,
      required Widget prefixIcon,
      bool hasError = false,
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // SEARCH FORM SECTION
          // ═══════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Form(
              key: _formKey,
              autovalidateMode: _validationAttempted
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Destination field ──────────────────────────────────
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
                        validator: (_) {
                          if (!destProvider.hasValidHotelDestination) {
                            return 'Please select a destination'.tr;
                          }
                          return null;
                        },
                        onTap: () {
                          HotelDestinationSelectionSheet.show(
                            context,
                            onDestinationSelected: (destination) {
                              _destinationController.text =
                                  destination.displayName ?? '';
                              setState(() {
                                _destination = destination.displayName ?? '';
                                _city = destination.city ??
                                    destination.destination ??
                                    destination.displayName ??
                                    '';
                              });
                            },
                          );
                        },
                        decoration: _fieldDecoration(
                          hint: 'Search destination'.tr,
                          prefixIcon: const Icon(
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
                                    _destinationController.clear();
                                    destProvider.clearHotelDestination();
                                    setState(() {
                                      _destination = '';
                                      _city = '';
                                    });
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

                  // ── Check-in / Check-out row ────────────────────────────
                  Row(
                    children: [
                      // Check-in
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kHeadingColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FormField<DateTime>(
                              initialValue: _checkInDate,
                              validator: (_) {
                                if (_checkInDate == null) return 'Required'.tr;
                                return null;
                              },
                              builder: (formFieldState) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _checkInDate = picked;
                                            formFieldState.didChange(picked);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 47,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: formFieldState.hasError
                                                  ? Colors.red
                                                  : kBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/calendar.svg',
                                              width: 16,
                                              height: 16,
                                              color: kMutedColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                checkInText,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: _checkInDate != null
                                                      ? kHeadingColor
                                                      : kMutedColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (formFieldState.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, top: 4),
                                        child: Text(
                                          formFieldState.errorText ?? '',
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 11),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Check-out
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-out'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kHeadingColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FormField<DateTime>(
                              initialValue: _checkOutDate,
                              validator: (_) {
                                if (_checkOutDate == null) return 'Required'.tr;
                                if (_checkInDate != null &&
                                    _checkOutDate != null &&
                                    (_checkOutDate!.isBefore(_checkInDate!) ||
                                        _checkOutDate!
                                            .isAtSameMomentAs(_checkInDate!))) {
                                  return 'After check-in'.tr;
                                }
                                return null;
                              },
                              builder: (formFieldState) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _checkInDate ?? DateTime.now(),
                                          firstDate:
                                              _checkInDate ?? DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _checkOutDate = picked;
                                            formFieldState.didChange(picked);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 47,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: formFieldState.hasError
                                                  ? Colors.red
                                                  : kBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/calendar.svg',
                                              width: 16,
                                              height: 16,
                                              color: kMutedColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                checkOutText,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: _checkOutDate != null
                                                      ? kHeadingColor
                                                      : kMutedColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (formFieldState.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, top: 4),
                                        child: Text(
                                          formFieldState.errorText ?? '',
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 11),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Units & Guests field ────────────────────────────────
                  Text(
                    'Units & Guests'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kHeadingColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _showUnitAndGuestSelector,
                    child: Container(
                      height: 47,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/user.svg',
                            width: 20,
                            height: 20,
                            color: kMutedColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              guestSummary,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: kHeadingColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: kMutedColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Search Button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _validationAttempted = true;
                        });
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        // Read city from the provider's selected destination
                        // (same pattern as Hotel search in home_screen.dart)
                        final destProvider =
                            Provider.of<HotelDestinationProvider>(context,
                                listen: false);
                        final selected = destProvider.selectedHotelDestination;
                        final apiCity = selected?.city?.isNotEmpty == true
                            ? selected!.city!
                            : (selected?.destination?.isNotEmpty == true
                                ? selected!.destination!
                                : _destination);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeAptsSearchResultScreen(
                              destination: _destination,
                              city: apiCity,
                              checkInDate: _checkInDate,
                              checkOutDate: _checkOutDate,
                              adults: _adults,
                              children: _children,
                              infants: 0,
                            ),
                          ),
                        );
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
                            'Search Homes'.tr,
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
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // FEATURED SECTION (COMMENTED OUT)
          // ═══════════════════════════════════════════════════════════════
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       // Header
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             'Featured Homes & Apartments',
          //             style: GoogleFonts.spaceGrotesk(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //               color: kHeadingColor,
          //             ),
          //           ),
          //           GestureDetector(
          //             onTap: () {
          //               // TODO: Navigate to view all
          //             },
          //             child: Text(
          //               'View all',
          //               style: GoogleFonts.spaceGrotesk(
          //                 fontSize: 13,
          //                 fontWeight: FontWeight.w500,
          //                 color: kPrimaryColor,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 16),
          //
          //       // Featured cards
          //       ..._buildFeaturedCards(),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // /// Build featured homes cards
  // List<Widget> _buildFeaturedCards() {
  //   final List<Map<String, dynamic>> featuredHomes = [
  //     {
  //       'name': 'Modern Luxury Apartment',
  //       'location': 'Downtown Dubai',
  //       'price': 450,
  //       'rating': 4.8,
  //       'type': 'Apartment',
  //       'image': 'assets/icons/hotel.png',
  //     },
  //     {
  //       'name': 'Cozy Studio in Marina',
  //       'location': 'Dubai Marina',
  //       'price': 280,
  //       'rating': 4.6,
  //       'type': 'Studio',
  //       'image': 'assets/icons/hotel.png',
  //     },
  //     {
  //       'name': 'Beachfront Villa',
  //       'location': 'Palm Jumeirah',
  //       'price': 850,
  //       'rating': 4.9,
  //       'type': 'Villa',
  //       'image': 'assets/icons/hotel.png',
  //     },
  //   ];
  //
  //   return featuredHomes.map((home) {
  //     return Padding(
  //       padding: const EdgeInsets.only(bottom: 14),
  //       child: GestureDetector(
  //         onTap: () {
  //           // TODO: Navigate to detail screen
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.1),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //             color: Colors.white,
  //           ),
  //           clipBehavior: Clip.antiAlias,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Image section with badge and wishlist
  //               Stack(
  //                 children: [
  //                   // Image placeholder
  //                   Container(
  //                     height: 180,
  //                     color: Colors.grey[200],
  //                     child: Center(
  //                       child: Icon(
  //                         Icons.image,
  //                         size: 50,
  //                         color: Colors.grey[400],
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Type badge
  //                   Positioned(
  //                     top: 10,
  //                     left: 10,
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 10, vertical: 5),
  //                       decoration: BoxDecoration(
  //                         color: kPrimaryColor,
  //                         borderRadius: BorderRadius.circular(6),
  //                       ),
  //                       child: Text(
  //                         home['type'],
  //                         style: GoogleFonts.spaceGrotesk(
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w600,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Wishlist icon
  //                   Positioned(
  //                     top: 10,
  //                     right: 10,
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         shape: BoxShape.circle,
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.grey.withOpacity(0.2),
  //                             blurRadius: 4,
  //                           ),
  //                         ],
  //                       ),
  //                       padding: const EdgeInsets.all(8),
  //                       child: Icon(
  //                         Icons.favorite_border,
  //                         color: kPrimaryColor,
  //                         size: 20,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               // Content section
  //               Padding(
  //                 padding: const EdgeInsets.all(12),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Name
  //                     Text(
  //                       home['name'],
  //                       style: GoogleFonts.spaceGrotesk(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         color: kHeadingColor,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //
  //                     const SizedBox(height: 4),
  //
  //                     // Location
  //                     Row(
  //                       children: [
  //                         Icon(
  //                           Icons.location_on_outlined,
  //                           size: 14,
  //                           color: kMutedColor,
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Expanded(
  //                           child: Text(
  //                             home['location'],
  //                             style: GoogleFonts.spaceGrotesk(
  //                               fontSize: 12,
  //                               color: kMutedColor,
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //
  //                     const SizedBox(height: 8),
  //
  //                     // Price and rating row
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         // Price
  //                         Text(
  //                           'from \$${home['price']}/night',
  //                           style: GoogleFonts.spaceGrotesk(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                             color: kPrimaryColor,
  //                           ),
  //                         ),
  //
  //                         // Rating
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.star_rounded,
  //                               size: 16,
  //                               color: AppColors.accent.withOpacity(0.600),
  //                             ),
  //                             const SizedBox(width: 4),
  //                             Text(
  //                               '${home['rating']}',
  //                               style: GoogleFonts.spaceGrotesk(
  //                                 fontSize: 13,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: kHeadingColor,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }).toList();
  // }
}
