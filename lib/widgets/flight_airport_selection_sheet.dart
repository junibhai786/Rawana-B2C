import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/flight_airport_provider.dart';
import 'package:moonbnd/modals/flight_airport_model.dart';
import 'package:moonbnd/widgets/airport_shimmer_item.dart';
import 'package:provider/provider.dart';

class FlightAirportSelectionSheet extends StatefulWidget {
  final bool isDeparture;
  final String? otherSelectedIata;
  final void Function(FlightAirportModel airport) onAirportSelected;

  const FlightAirportSelectionSheet({
    super.key,
    required this.isDeparture,
    required this.onAirportSelected,
    this.otherSelectedIata,
  });

  static void show(
    BuildContext context, {
    required bool isDeparture,
    String? otherSelectedIata,
    required void Function(FlightAirportModel airport) onAirportSelected,
  }) {
    final provider = context.read<FlightAirportProvider>();
    provider.clearFilter();
    provider.fetchAirports();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FlightAirportSelectionSheet(
        isDeparture: isDeparture,
        otherSelectedIata: otherSelectedIata,
        onAirportSelected: onAirportSelected,
      ),
    );
  }

  @override
  State<FlightAirportSelectionSheet> createState() =>
      _FlightAirportSelectionSheetState();
}

class _FlightAirportSelectionSheetState
    extends State<FlightAirportSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
                  widget.isDeparture
                      ? 'Select Departure Airport'.tr
                      : 'Select Destination Airport'.tr,
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
              controller: _searchController,
              autofocus: false,
              onChanged: (value) {
                context.read<FlightAirportProvider>().filterAirports(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by city, airport or IATA code...'.tr,
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

          // Airport list
          Expanded(
            child: Consumer<FlightAirportProvider>(
              builder: (context, provider, _) {
                // Loading state
                if (provider.isLoading) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, __) => Column(
                      children: const [
                        AirportShimmerItem(),
                        Divider(height: 1, indent: 56),
                      ],
                    ),
                  );
                }

                // Error state
                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 48, color: Color(0xffD1D5DB)),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xff6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: provider.retryFetch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF05A8C7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Retry'.tr,
                              style:
                                  GoogleFonts.spaceGrotesk(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final airports = provider.filteredAirports;

                // Empty search state
                if (airports.isEmpty && provider.searchQuery.isNotEmpty) {
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
                            'No airports found for "${provider.searchQuery}"',
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

                // Airport list
                return ListView.separated(
                  itemCount: airports.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 56),
                  itemBuilder: (context, index) {
                    final airport = airports[index];
                    final isSameAirport = widget.otherSelectedIata != null &&
                        widget.otherSelectedIata == airport.iataCode;

                    return InkWell(
                      onTap: isSameAirport
                          ? () {
                              log('[FlightAirportProvider] Same airport selection prevented');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cannot select the same airport for both From and To fields'
                                        .tr,
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : () {
                              log('[FlightAirportProvider] Selected ${widget.isDeparture ? "FROM" : "TO"} airport = ${airport.city} / ${airport.iataCode}');
                              Navigator.pop(context);
                              widget.onAirportSelected(airport);
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSameAirport
                                    ? const Color(0xffF3F4F6)
                                    : const Color(0xffE0F7FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.flight_takeoff,
                                color: isSameAirport
                                    ? const Color(0xffD1D5DB)
                                    : const Color(0xFF05A8C7),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // City + airport name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    airport.city.isNotEmpty
                                        ? airport.city
                                        : airport.airport,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSameAirport
                                          ? const Color(0xffD1D5DB)
                                          : const Color(0xff1D2025),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (airport.airport.isNotEmpty)
                                    Text(
                                      [
                                        airport.airport,
                                        if (airport.state.isNotEmpty)
                                          airport.state,
                                      ].join(', '),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        color: isSameAirport
                                            ? const Color(0xffE5E7EB)
                                            : const Color(0xff6B7280),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // IATA badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSameAirport
                                    ? const Color(0xffF3F4F6)
                                    : const Color(0xffE0F7FA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                airport.iataCode,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSameAirport
                                      ? const Color(0xffD1D5DB)
                                      : const Color(0xFF05A8C7),
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
            ),
          ),
        ],
      ),
    );
  }
}
