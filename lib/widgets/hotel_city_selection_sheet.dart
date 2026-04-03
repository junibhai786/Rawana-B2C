// lib/widgets/hotel_city_selection_sheet.dart
// Hotel-specific city selection bottom sheet — isolated from other city flows.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/hotel_city_provider.dart';
import 'package:moonbnd/modals/hotel_city_model.dart';
import 'package:moonbnd/widgets/location_shimmer_item.dart';
import 'package:provider/provider.dart';

class HotelCitySelectionSheet extends StatefulWidget {
  /// Called when the user taps a city.
  final void Function(HotelCityModel city) onCitySelected;

  const HotelCitySelectionSheet({
    super.key,
    required this.onCitySelected,
  });

  /// Convenience static method. Checks country selection, fetches cities if
  /// needed, then shows the bottom sheet.
  ///
  /// [countryCode] — the code of the currently selected hotel country.
  static Future<void> show(
    BuildContext context, {
    required String countryCode,
    required void Function(HotelCityModel city) onCitySelected,
  }) async {
    if (countryCode.isEmpty) {
      log('[HotelCitySelectionSheet] No country selected — aborting');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a country first'.tr)),
      );
      return;
    }

    final provider = context.read<HotelCityProvider>();
    await provider.fetchHotelCities(countryCode);

    if (!context.mounted) return;

    if (provider.error != null && provider.cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to load cities')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HotelCitySelectionSheet(onCitySelected: onCitySelected),
    );
  }

  @override
  State<HotelCitySelectionSheet> createState() =>
      _HotelCitySelectionSheetState();
}

class _HotelCitySelectionSheetState extends State<HotelCitySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<HotelCityModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<HotelCityProvider>();
    _filtered = List.of(provider.cities);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final provider = context.read<HotelCityProvider>();
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? List.of(provider.cities)
          : provider.cities
              .where((c) => c.cityName.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HotelCityProvider>(
      builder: (context, provider, _) {
        // Sync filtered list when provider data arrives
        if (provider.cities.isNotEmpty &&
            _filtered.isEmpty &&
            _searchController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _filtered = List.of(provider.cities));
            }
          });
        }

        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // ── Title ────────────────────────────────────────────────────
              Text(
                'Select City'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ───────────────────────────────────────────────────
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city...'.tr,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // ── List ─────────────────────────────────────────────────────
              Expanded(
                child: provider.isLoading
                    ? ListView.builder(
                        itemCount: 10,
                        itemBuilder: (_, __) => const LocationShimmerItem(),
                      )
                    : _filtered.isEmpty
                        ? Center(child: Text('No cities found'.tr))
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final city = _filtered[index];
                              return InkWell(
                                onTap: () {
                                  provider.selectHotelCity(city);
                                  widget.onCitySelected(city);
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 22,
                                        color: Color(0xFF05A8C7),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          city.cityName,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xff1D2025),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          city.cityCode,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
