// lib/widgets/hotel_country_selection_sheet.dart
// Hotel-specific country selection bottom sheet — isolated from other country flows.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/hotel_country_provider.dart';
import 'package:moonbnd/modals/hotel_country_model.dart';
import 'package:moonbnd/widgets/location_shimmer_item.dart';
import 'package:provider/provider.dart';

class HotelCountrySelectionSheet extends StatefulWidget {
  /// Called when the user taps a country. Receives the selected [HotelCountryModel].
  final void Function(HotelCountryModel country) onCountrySelected;

  const HotelCountrySelectionSheet({
    super.key,
    required this.onCountrySelected,
  });

  /// Convenience static method — mirrors the pattern used by [_showCitySelection].
  static Future<void> show(
    BuildContext context, {
    required void Function(HotelCountryModel country) onCountrySelected,
  }) async {
    // Open the sheet immediately — shimmer will show while data loads.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HotelCountrySelectionSheet(
        onCountrySelected: onCountrySelected,
      ),
    );

    // Trigger fetch after sheet is open so shimmer is visible right away.
    final provider = context.read<HotelCountryProvider>();
    if (provider.countries.isEmpty) {
      log('[HotelCountrySelectionSheet] Triggering hotel country fetch');
      provider.fetchHotelCountries();
    }
  }

  @override
  State<HotelCountrySelectionSheet> createState() =>
      _HotelCountrySelectionSheetState();
}

class _HotelCountrySelectionSheetState
    extends State<HotelCountrySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<HotelCountryModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<HotelCountryProvider>();
    _filtered = List.of(provider.countries);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final provider = context.read<HotelCountryProvider>();
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? List.of(provider.countries)
          : provider.countries
              .where((c) => c.countryName.toLowerCase().contains(query))
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
    return Consumer<HotelCountryProvider>(
      builder: (context, provider, _) {
        // Sync filtered list when provider data changes
        if (provider.countries.isNotEmpty && _filtered.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _filtered = List.of(provider.countries);
              });
            }
          });
        }

        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // ── Title ─────────────────────────────────────────────────────
              Text(
                'Select Country'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ────────────────────────────────────────────────────
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search country...'.tr,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // ── List ──────────────────────────────────────────────────────
              Expanded(
                child: provider.isLoading
                    ? ListView.builder(
                        itemCount: 10,
                        itemBuilder: (_, __) => const LocationShimmerItem(),
                      )
                    : provider.error != null && provider.countries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 40, color: Color(0xffEF4444)),
                                const SizedBox(height: 12),
                                Text(
                                  provider.error ?? 'Failed to load countries',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    color: const Color(0xff6B7280),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      provider.fetchHotelCountries(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    'Retry'.tr,
                                    style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filtered.isEmpty
                            ? Center(child: Text('No countries found'.tr))
                            : ListView.builder(
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) {
                                  final country = _filtered[index];
                                  return InkWell(
                                    onTap: () {
                                      provider.selectHotelCountry(country);
                                      widget.onCountrySelected(country);
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.language,
                                            size: 22,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              country.countryName,
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
                                              country.countryCode,
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
