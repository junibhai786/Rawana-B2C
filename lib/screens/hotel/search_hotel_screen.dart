import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/search_hotel_provider.dart';
import 'package:moonbnd/Provider/currency_provider.dart';
import 'package:moonbnd/modals/hotel_search_response_model.dart';
import 'package:moonbnd/screens/hotel/room_detail_screen.dart';
import 'package:moonbnd/constants.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FILTER / SORT STATE (file-private)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum _SortBy { price, stars, name }

enum _StarFilter { any, five, fourPlus, threePlus }

enum _ProviderFilter { all, local, b2b }

class _FilterState {
  final double minPrice;
  final double maxPrice;
  final _StarFilter starFilter;
  final _ProviderFilter providerFilter;

  const _FilterState({
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.starFilter = _StarFilter.any,
    this.providerFilter = _ProviderFilter.all,
  });

  bool get isActive =>
      minPrice != 0 ||
      maxPrice != 50000 ||
      starFilter != _StarFilter.any ||
      providerFilter != _ProviderFilter.all;

  _FilterState copyWith({
    double? minPrice,
    double? maxPrice,
    _StarFilter? starFilter,
    _ProviderFilter? providerFilter,
  }) =>
      _FilterState(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        starFilter: starFilter ?? this.starFilter,
        providerFilter: providerFilter ?? this.providerFilter,
      );
}

class HotelSearchResultsScreen extends StatefulWidget {
  final String? cityName;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final int adults;
  final int children;
  final int rooms;

  const HotelSearchResultsScreen({
    super.key,
    this.cityName,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
    this.adults = 1,
    this.children = 0,
    this.rooms = 1,
  });

  @override
  State<HotelSearchResultsScreen> createState() =>
      _HotelSearchResultsScreenState();
}

class _HotelSearchResultsScreenState extends State<HotelSearchResultsScreen> {
  late ScrollController _scrollController;
  _FilterState _activeFilter = const _FilterState();
  _SortBy _sortBy = _SortBy.price;

  // â”€â”€ Filter / sort helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Safely converts any numeric-like value to double. Returns 0 on failure.
  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  /// Normalises raw API provider strings to a canonical token:
  ///   - anything containing "b2b"  â†’ "b2b"  (covers travolyo_b2b, b2b, etc.)
  ///   - "local"                    â†’ "local"
  ///   - anything else              â†’ lowercased raw value
  static String _normalizeProvider(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final lower = raw.toLowerCase().trim();
    if (lower.contains('b2b')) return 'b2b';
    if (lower == 'local') return 'local';
    return lower;
  }

  List<HotelSearchResult> _filtered(List<HotelSearchResult> src) {
    final out = src.where((h) {
      // â”€â”€ Price filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      // Hotels with unknown/zero price are allowed through; we can't filter
      // what we don't know. Only filter when a positive price is present.
      final price = _asDouble(h.lowestPrice);
      if (price > 0 &&
          (price < _activeFilter.minPrice || price > _activeFilter.maxPrice)) {
        return false;
      }

      // â”€â”€ Star rating filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      final stars = _asDouble(h.starRating).round();
      switch (_activeFilter.starFilter) {
        case _StarFilter.five:
          if (stars < 5) return false;
          break;
        case _StarFilter.fourPlus:
          if (stars < 4) return false;
          break;
        case _StarFilter.threePlus:
          if (stars < 3) return false;
          break;
        case _StarFilter.any:
          break;
      }

      // â”€â”€ Provider filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      // Use normalised value so "travolyo_b2b" correctly matches _ProviderFilter.b2b.
      final provNorm = _normalizeProvider(h.provider);
      switch (_activeFilter.providerFilter) {
        case _ProviderFilter.local:
          if (provNorm != 'local') return false;
          break;
        case _ProviderFilter.b2b:
          if (provNorm != 'b2b') return false;
          break;
        case _ProviderFilter.all:
          break;
      }

      return true;
    }).toList();

    switch (_sortBy) {
      case _SortBy.price:
        out.sort((a, b) =>
            _asDouble(a.lowestPrice).compareTo(_asDouble(b.lowestPrice)));
        break;
      case _SortBy.stars:
        out.sort((a, b) =>
            _asDouble(b.starRating).compareTo(_asDouble(a.starRating)));
        break;
      case _SortBy.name:
        out.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
    }
    return out;
  }

  String get _sortLabel {
    switch (_sortBy) {
      case _SortBy.price:
        return 'Price';
      case _SortBy.stars:
        return 'Stars';
      case _SortBy.name:
        return 'Name';
    }
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _FilterSheet(
        initial: _activeFilter,
        onApply: (f) => setState(() => _activeFilter = f),
      ),
    );
  }

  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _SortSheet(
        selected: _sortBy,
        onSelect: (s) => setState(() => _sortBy = s),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    // Trigger API call immediately â€” no waiting on the search form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSearch();
    });
  }

  Future<void> _startSearch() async {
    if (widget.cityName == null || widget.cityName!.isEmpty) return;
    final provider = Provider.of<SearchHotelProvider>(context, listen: false);
    final currency =
        Provider.of<CurrencyProvider>(context, listen: false).selectedCurrency;
    provider.resetPagination();
    await provider.searchHotels(
      city: widget.cityName,
      checkIn: widget.checkInDate,
      checkOut: widget.checkOutDate,
      adults: widget.adults,
      children: widget.children,
      rooms: widget.rooms,
      currency: currency,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchMoreData() async {
    final provider = Provider.of<SearchHotelProvider>(context, listen: false);
    if (provider.isLoadingMore || !provider.hasMorePages) return;
    await provider.searchHotels(isLoadMore: true);
  }

  Future<void> _onRefresh() async {
    if (widget.cityName != null && widget.cityName!.isNotEmpty) {
      await Provider.of<SearchHotelProvider>(context, listen: false)
          .searchHotels(
        currency: Provider.of<CurrencyProvider>(context, listen: false)
            .selectedCurrency,
        searchParams: {
          'city': widget.cityName,
          'check_in': widget.checkInDate,
          'check_out': widget.checkOutDate,
          'guests': widget.guests,
        },
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'No Hotels Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Try adjusting your dates or location.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kSubtitleColor,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Modify Search'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: kHeadingColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotels in ${widget.cityName ?? 'Destination'}'.tr,
              style: GoogleFonts.spaceGrotesk(
                  color: kHeadingColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Consumer<SearchHotelProvider>(
        builder: (context, provider, _) {
          final filteredHotels = provider.isLoading
              ? <HotelSearchResult>[]
              : _filtered(provider.hotels);
          return Column(
            children: [
              // â”€â”€ Always-visible Filter / Sort bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _FilterSortBar(
                hotelCount: provider.isLoading ? null : provider.totalCount,
                sortLabel: _sortLabel,
                filterActive: _activeFilter.isActive,
                onFilter: _openFilter,
                onSort: _openSort,
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Loading state â€” shimmer skeleton
                    if (provider.isLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: 4,
                        itemBuilder: (_, __) => const HotelCardShimmer(),
                      );
                    }

                    // Error state
                    if (provider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 80, color: Colors.red[300]),
                              SizedBox(height: 24),
                              Text(
                                'Something went wrong'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: kHeadingColor,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                provider.error ?? 'Unknown error',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: kSubtitleColor,
                                ),
                              ),
                              SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _onRefresh,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'Try Again'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Empty state (no API results at all)
                    if (provider.hotels.isEmpty) {
                      return _buildEmptyState();
                    }

                    // No filter match
                    if (filteredHotels.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'No hotels match your filters',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kSubtitleColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(
                                  () => _activeFilter = const _FilterState()),
                              child: Text(
                                'Clear filters',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Results list
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: kPrimaryColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(12),
                        // +1 for the load-more footer
                        itemCount: filteredHotels.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredHotels.length) {
                            // Footer: spinner while loading more, or done hint
                            if (provider.isLoadingMore) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: kPrimaryColor),
                                ),
                              );
                            }
                            if (!provider.hasMorePages &&
                                provider.hotels.isNotEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'All ${provider.totalCount} hotels loaded',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          return HotelCard(
                            hotel: filteredHotels[index],
                            cityName: widget.cityName,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FILTER / SORT BAR  (always-visible row below AppBar)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterSortBar extends StatelessWidget {
  final int? hotelCount;
  final String sortLabel;
  final bool filterActive;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  const _FilterSortBar({
    required this.hotelCount,
    required this.sortLabel,
    required this.filterActive,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hotelCount == null
                  ? 'Searching...'
                  : '$hotelCount hotel${hotelCount == 1 ? '' : 's'} available',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kSubtitleColor,
              ),
            ),
          ),
          _Pill(
            icon: Icons.swap_vert_rounded,
            label: 'Sort: $sortLabel',
            active: false,
            onTap: onSort,
          ),
          const SizedBox(width: 8),
          _Pill(
            icon: Icons.tune_rounded,
            label: 'Filter',
            active: filterActive,
            onTap: onFilter,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kPrimaryColor : kPrimaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? kPrimaryColor : kPrimaryColor.withOpacity(0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : kPrimaryColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FILTER BOTTOM SHEET
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterSheet extends StatefulWidget {
  final _FilterState initial;
  final ValueChanged<_FilterState> onApply;
  const _FilterSheet({required this.initial, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _FilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      snap: true,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // drag handle
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kSheetHeadingColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade100),

            // scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  // PRICE PER NIGHT
                  _SectionLabel(text: 'PRICE PER NIGHT'),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceTag(
                          caption: 'Min',
                          value: '\$${_draft.minPrice.round()}'),
                      _PriceTag(
                          caption: 'Up to',
                          value: '\$${_draft.maxPrice.round()}',
                          alignRight: true),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: kPrimaryColor,
                      inactiveTrackColor: kPrimaryColor.withOpacity(0.15),
                      thumbColor: kPrimaryColor,
                      overlayColor: kPrimaryColor.withOpacity(0.12),
                      trackHeight: 3,
                    ),
                    child: RangeSlider(
                      values: RangeValues(_draft.minPrice, _draft.maxPrice),
                      min: 0,
                      max: 50000,
                      divisions: 100,
                      onChanged: (v) => setState(() => _draft =
                          _draft.copyWith(minPrice: v.start, maxPrice: v.end)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 24),

                  // STAR RATING
                  _SectionLabel(text: 'STAR RATING'),
                  const SizedBox(height: 12),
                  ..._StarFilter.values
                      .map((s) => _StarTile(
                            value: s,
                            group: _draft.starFilter,
                            onChange: (v) => setState(
                                () => _draft = _draft.copyWith(starFilter: v)),
                          ))
                      .toList(),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 24),

                  // PROVIDER
                  _SectionLabel(text: 'PROVIDER'),
                  const SizedBox(height: 12),
                  ..._ProviderFilter.values
                      .map((p) => _ProviderTile(
                            value: p,
                            group: _draft.providerFilter,
                            onChange: (v) => setState(() =>
                                _draft = _draft.copyWith(providerFilter: v)),
                          ))
                      .toList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // sticky action bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _draft = const _FilterState()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          color: kSheetHeadingColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_draft);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// SORT BOTTOM SHEET
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SortSheet extends StatelessWidget {
  final _SortBy selected;
  final ValueChanged<_SortBy> onSelect;
  const _SortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(text: 'SORT BY'),
          const SizedBox(height: 12),
          ..._SortBy.values
              .map((s) => _SortTile(
                    value: s,
                    selected: selected == s,
                    onTap: () {
                      onSelect(s);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final _SortBy value;
  final bool selected;
  final VoidCallback onTap;
  const _SortTile(
      {required this.value, required this.selected, required this.onTap});

  String get _label {
    switch (value) {
      case _SortBy.price:
        return 'Price (Low to High)';
      case _SortBy.stars:
        return 'Star Rating (High to Low)';
      case _SortBy.name:
        return 'Name (A â€“ Z)';
    }
  }

  IconData get _icon {
    switch (value) {
      case _SortBy.price:
        return Icons.attach_money_rounded;
      case _SortBy.stars:
        return Icons.star_rounded;
      case _SortBy.name:
        return Icons.sort_by_alpha_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = kPrimaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? teal.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? teal.withOpacity(0.40) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon,
                size: 17, color: selected ? teal : const Color(0xFF555555)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? teal : kSheetHeadingColor,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 17, color: teal),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// SHARED FILTER WIDGETS
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Colors.grey.shade500,
        ),
      );
}

class _PriceTag extends StatelessWidget {
  final String caption;
  final String value;
  final bool alignRight;
  const _PriceTag(
      {required this.caption, required this.value, this.alignRight = false});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(caption,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, color: Colors.grey.shade400)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kPrimaryColor,
              )),
        ],
      );
}

class _StarTile extends StatelessWidget {
  final _StarFilter value;
  final _StarFilter group;
  final ValueChanged<_StarFilter> onChange;
  const _StarTile(
      {required this.value, required this.group, required this.onChange});

  String get _label {
    switch (value) {
      case _StarFilter.any:
        return 'Any';
      case _StarFilter.five:
        return '5 Stars';
      case _StarFilter.fourPlus:
        return '4+ Stars';
      case _StarFilter.threePlus:
        return '3+ Stars';
    }
  }

  int get _count {
    switch (value) {
      case _StarFilter.any:
        return 0;
      case _StarFilter.five:
        return 5;
      case _StarFilter.fourPlus:
        return 4;
      case _StarFilter.threePlus:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = value == group;
    return InkWell(
      onTap: () => onChange(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _RadioDot(selected: sel),
            const SizedBox(width: 10),
            Text(
              _label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? kSheetHeadingColor : Colors.grey.shade700,
              ),
            ),
            if (_count > 0) ...[
              const SizedBox(width: 6),
              Row(
                children: List.generate(
                  _count,
                  (_) => const Icon(Icons.star_rounded,
                      size: 14, color: Color(0xFFFFC107)),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final _ProviderFilter value;
  final _ProviderFilter group;
  final ValueChanged<_ProviderFilter> onChange;
  const _ProviderTile(
      {required this.value, required this.group, required this.onChange});

  String get _label {
    switch (value) {
      case _ProviderFilter.all:
        return 'All';
      case _ProviderFilter.local:
        return 'Local';
      case _ProviderFilter.b2b:
        return 'B2B';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = value == group;
    return InkWell(
      onTap: () => onChange(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _RadioDot(selected: sel),
            const SizedBox(width: 10),
            Text(
              _label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? kSheetHeadingColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryColor,
                  ),
                ),
              )
            : null,
      );
}

class HotelCard extends StatelessWidget {
  final HotelSearchResult hotel;
  final String? cityName;

  const HotelCard({
    Key? key,
    required this.hotel,
    this.cityName,
  }) : super(key: key);

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(
          hotelId: hotel.id,
          provider: hotel.provider,
          searchData: hotel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = hotel.images != null && hotel.images!.isNotEmpty;
    final imageUrl = hasImages ? hotel.images!.first : null;

    final rawPrice = hotel.convertedLowestPrice ?? hotel.lowestPrice;
    final lowestPrice = rawPrice is String
        ? double.tryParse(rawPrice.toString()) ?? 0
        : (rawPrice ?? 0).toDouble();
    final priceStr = lowestPrice > 0 ? lowestPrice.toStringAsFixed(0) : null;
    final currency = (hotel.convertedCurrency?.isNotEmpty == true)
        ? hotel.convertedCurrency!
        : (hotel.currency ?? 'AED');

    final rating = hotel.starRating ?? 0;
    final ratingInt = (rating is num)
        ? rating.toInt()
        : (int.tryParse(rating.toString()) ?? 0);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Image â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: hasImages && imageUrl != null
                      ? _buildHotelImage(imageUrl)
                      : _buildImagePlaceholder(),
                ),

                // Provider badge â€” top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hotel.provider == 'hyperguest'
                          ? const Color(0xff059669).withOpacity(0.92)
                          : const Color(0xff0369A1).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (hotel.provider ?? 'local').toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // â”€â”€ Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    hotel.name ?? 'Hotel',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kHeadingColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.location_on_rounded,
                            size: 14, color: Color(0xff9CA3AF)),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          hotel.address ?? hotel.city ?? 'Location',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: kMutedColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Stars only (clean, no text label)
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < ratingInt
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: i < ratingInt
                            ? kStarColor
                            : const Color(0xffE5E7EB),
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Check-in / Check-out time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule_outlined,
                          size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.checkInTime ?? '14:00'} â€“ ${hotel.checkOutTime ?? '11:00'}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kVeryMutedColor,
                        ),
                      ),
                    ],
                  ),

                  // Amenities chips
                  if (hotel.amenities != null &&
                      hotel.amenities!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          hotel.amenities!.length.clamp(0, 4),
                          (i) => Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: kAmenityBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: kAmenityBorderColor, width: 0.8),
                              ),
                              child: Text(
                                hotel.amenities![i],
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xffEEF2F5)),
                  const SizedBox(height: 12),

                  // Price + CTA row (cleaner layout)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price (left) - simplified
                      if (priceStr != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'from',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: kVeryMutedColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$currency ',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: priceStr,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/night',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: kVeryMutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Price on request',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),

                      const Spacer(),

                      // CTA button - consistent pill style
                      TextButton(
                        onPressed: () => _openDetail(context),
                        style: TextButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Rooms'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            // const Icon(Icons.arrow_forward_ios_rounded,
                            //     size: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a hotel image from either a network URL or a base64 data URI.
  Widget _buildHotelImage(String imageUrl) {
    // Base64 data URI (e.g. "data:image/jpeg;base64,/9j/...")
    if (imageUrl.startsWith('data:')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = imageUrl.substring(commaIndex + 1);
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          );
        }
      } catch (_) {
        return _buildImagePlaceholder();
      }
    }

    // Only attempt to load valid http/https URLs
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return _buildImagePlaceholder();
    }

    // Standard network URL
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: kPrimaryColor,
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kPrimaryColor.withOpacity(0.05)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel,
              size: 50,
              color: kPrimaryColor.withOpacity(0.5),
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: kPrimaryColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// HOTEL CARD SHIMMER  (skeleton loading placeholder)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class HotelCardShimmer extends StatefulWidget {
  const HotelCardShimmer({super.key});

  @override
  State<HotelCardShimmer> createState() => _HotelCardShimmerState();
}

class _HotelCardShimmerState extends State<HotelCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -1.5, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end: Alignment(_anim.value, 0),
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFFAFAFA),
            Color(0xFFEEEEEE),
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        Widget shimmerBox({
          double? width,
          required double height,
          double radius = 6,
          EdgeInsetsGeometry? margin,
        }) =>
            Container(
              width: width,
              height: height,
              margin: margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: gradient,
              ),
            );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Image area with badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Stack(
                children: [
                  // Image placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: gradient,
                    ),
                  ),
                  // Provider badge placeholder
                  Positioned(
                    top: 12,
                    left: 12,
                    child: shimmerBox(width: 64, height: 22, radius: 20),
                  ),
                ],
              ),

              // â”€â”€ Content area â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel title
                    shimmerBox(width: double.infinity, height: 18, radius: 6),
                    const SizedBox(height: 6),
                    shimmerBox(width: 220, height: 14, radius: 6),
                    const SizedBox(height: 12),

                    // Address row
                    Row(
                      children: [
                        shimmerBox(width: 14, height: 14, radius: 4),
                        const SizedBox(width: 6),
                        shimmerBox(width: 180, height: 12, radius: 6),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stars row
                    Row(
                      children: List.generate(
                          5,
                          (i) => Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradient,
                                ),
                              )),
                    ),
                    const SizedBox(height: 10),

                    // Check-in/out time row
                    Row(
                      children: [
                        shimmerBox(width: 13, height: 13, radius: 4),
                        const SizedBox(width: 4),
                        shimmerBox(width: 100, height: 11, radius: 6),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider
                    Container(
                      height: 1,
                      color: kCardDividerColor,
                    ),
                    const SizedBox(height: 14),

                    // Price + CTA row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmerBox(width: 32, height: 10, radius: 5),
                            const SizedBox(height: 5),
                            shimmerBox(width: 90, height: 20, radius: 6),
                          ],
                        ),
                        const Spacer(),
                        shimmerBox(width: 110, height: 38, radius: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
