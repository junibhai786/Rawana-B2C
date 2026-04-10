import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/hotel_destination_provider.dart';
import 'package:moonbnd/modals/hotel_destination_model.dart';
import 'package:moonbnd/widgets/destination_shimmer_item.dart';
import 'package:provider/provider.dart';

class HotelDestinationSelectionSheet extends StatefulWidget {
  final void Function(HotelDestinationResult destination) onDestinationSelected;

  const HotelDestinationSelectionSheet({
    super.key,
    required this.onDestinationSelected,
  });

  static void show(
    BuildContext context, {
    required void Function(HotelDestinationResult destination)
        onDestinationSelected,
  }) {
    final provider = context.read<HotelDestinationProvider>();
    provider.clearHotelDestination();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HotelDestinationSelectionSheet(
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }

  @override
  State<HotelDestinationSelectionSheet> createState() =>
      _HotelDestinationSelectionSheetState();
}

class _HotelDestinationSelectionSheetState
    extends State<HotelDestinationSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Request focus and show keyboard when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xffE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Destination'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1D2025),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              focusNode: _focusNode,
              controller: _searchController,
              autofocus: false,
              onChanged: (value) {
                context
                    .read<HotelDestinationProvider>()
                    .onHotelDestinationChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by destination, city or region...'.tr,
                hintStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: const Color(0xff9CA3AF),
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xff9CA3AF), size: 20),
                filled: true,
                fillColor: const Color(0xffF9FAFB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF05A8C7)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Destination list
          Expanded(
            child: Consumer<HotelDestinationProvider>(
              builder: (context, provider, _) {
                // Loading state
                if (provider.isHotelDestinationLoading) {
                  return ListView.builder(
                    itemCount: 8,
                    itemBuilder: (_, __) => Column(
                      children: const [
                        DestinationShimmerItem(),
                        Divider(height: 1, indent: 56),
                      ],
                    ),
                  );
                }

                final destinations = provider.hotelDestinationSuggestions;

                // Empty search state (no API results AND no fuzzy matches)
                if (destinations.isEmpty &&
                    provider.hotelDestinationInput.trim().isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Color(0xffD1D5DB)),
                          const SizedBox(height: 12),
                          Text(
                            'No destinations found for "${provider.hotelDestinationInput}"'
                                .tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xff6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty initial state
                if (destinations.isEmpty &&
                    provider.hotelDestinationInput.trim().isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 48, color: Color(0xffD1D5DB)),
                          const SizedBox(height: 12),
                          Text(
                            'Start typing a destination'.tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xff6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Destination list
                return Column(
                  children: [
                    // ── "Did you mean …?" banner ──────────────────────────
                    if (provider.isFuzzyResult &&
                        provider.fuzzyDidYouMean != null)
                      GestureDetector(
                        onTap: () {
                          // Re-search with corrected spelling
                          _searchController.text =
                              destinations.first.destination ??
                                  destinations.first.displayName ??
                                  '';
                          _searchController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: _searchController.text.length),
                          );
                          provider.acceptFuzzySuggestion(destinations.first);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFFD54F), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  size: 18, color: Color(0xFFF9A825)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: const Color(0xff1D2025),
                                    ),
                                    children: [
                                      TextSpan(text: 'Did you mean '.tr),
                                      TextSpan(
                                        text: '${provider.fuzzyDidYouMean}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF05A8C7),
                                        ),
                                      ),
                                      const TextSpan(text: '?'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 12, color: Color(0xFF05A8C7)),
                            ],
                          ),
                        ),
                      ),

                    // ── Suggestion list ───────────────────────────────────
                    Expanded(
                      child: ListView.separated(
                        itemCount: destinations.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 56),
                        itemBuilder: (context, index) {
                          final destination = destinations[index];
                          final isCity =
                              destination.type?.toUpperCase() == 'CITY';
                          final destType =
                              destination.type?.toUpperCase() ?? '';

                          return InkWell(
                            onTap: () {
                              log('[HotelDestinationProvider] Selected destination = ${destination.displayName}');
                              if (provider.isFuzzyResult) {
                                // User tapped a fuzzy suggestion — re-search via API
                                _searchController.text =
                                    destination.destination ??
                                        destination.displayName ??
                                        '';
                                _searchController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: _searchController.text.length),
                                );
                                provider.acceptFuzzySuggestion(destination);
                                return;
                              }
                              Navigator.pop(context);
                              provider.selectHotelDestination(destination);
                              widget.onDestinationSelected(destination);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Icon container
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE0F7FA),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isCity ? Icons.location_on : Icons.public,
                                      color: const Color(0xFF05A8C7),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Destination info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display name / City name
                                        Text(
                                          destination.displayName ?? '',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff1D2025),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Region / Country info
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            _buildRegionText(destination),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12,
                                              color: const Color(0xff6B7280),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Type badge and country code on same line
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              destType,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xff05A8C7),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          if (destination.countryCode != null &&
                                              destination
                                                  .countryCode!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Text(
                                                destination.countryCode!,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xff6B7280),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build region text from destination fields
  /// Format: "Country · Region" or "City · Country · Region"
  String _buildRegionText(HotelDestinationResult destination) {
    final parts = <String>[];

    if (destination.country != null && destination.country!.isNotEmpty) {
      parts.add(destination.country!);
    }

    if (destination.region != null && destination.region!.isNotEmpty) {
      parts.add(destination.region!);
    }

    return parts.join(' · ');
  }
}
