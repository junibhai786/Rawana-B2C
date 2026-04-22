import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_apts_search_provider.dart';
import 'package:moonbnd/Provider/currency_provider.dart';
import 'package:moonbnd/modals/home_apts_model.dart';
import 'package:moonbnd/constants.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FILTER / SORT STATE (file-private)
// ─────────────────────────────────────────────────────────────────────────────

enum _SortBy { price, name }

class _FilterState {
  final double minPrice;
  final double maxPrice;

  const _FilterState({
    this.minPrice = 0,
    this.maxPrice = 50000,
  });

  bool get isActive => minPrice != 0 || maxPrice != 50000;

  _FilterState copyWith({double? minPrice, double? maxPrice}) => _FilterState(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HomeAptsSearchResultScreen extends StatefulWidget {
  final String?
      destination; // display name (e.g. "Dubai, UAE") — used for AppBar title
  final String? city; // city name sent to API (e.g. "Dubai")
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int adults;
  final int children;
  final int infants;

  const HomeAptsSearchResultScreen({
    super.key,
    this.destination,
    this.city,
    this.checkInDate,
    this.checkOutDate,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
  });

  @override
  State<HomeAptsSearchResultScreen> createState() =>
      _HomeAptsSearchResultScreenState();
}

class _HomeAptsSearchResultScreenState
    extends State<HomeAptsSearchResultScreen> {
  late ScrollController _scrollController;
  _FilterState _activeFilter = const _FilterState();
  _SortBy _sortBy = _SortBy.price;

  // ── Filter / sort helpers ────────────────────────────────────────────

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  List<HomeAptsModel> _filtered(List<HomeAptsModel> src) {
    final out = src.where((homeApt) {
      final price = _asDouble(homeApt.convertedPricePerNight);
      if (price > 0 &&
          (price < _activeFilter.minPrice || price > _activeFilter.maxPrice)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case _SortBy.price:
        out.sort((a, b) => _asDouble(a.convertedPricePerNight)
            .compareTo(_asDouble(b.convertedPricePerNight)));
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
        return 'Price'.tr;
      case _SortBy.name:
        return 'Name'.tr;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSearch();
    });
  }

  Future<void> _startSearch() async {
    if (widget.destination == null || widget.destination!.isEmpty) return;
    final provider =
        Provider.of<HomeAptsSearchProvider>(context, listen: false);
    final currency =
        Provider.of<CurrencyProvider>(context, listen: false).selectedCurrency;
    // Use city name for API; fall back to destination if city not provided
    final apiCity = (widget.city != null && widget.city!.isNotEmpty)
        ? widget.city!
        : widget.destination!;
    provider.resetPagination();
    await provider.searchHomeApts(
      destination: apiCity,
      city: apiCity,
      checkIn: widget.checkInDate,
      checkOut: widget.checkOutDate,
      adults: widget.adults,
      children: widget.children,
      infants: widget.infants,
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
    final provider =
        Provider.of<HomeAptsSearchProvider>(context, listen: false);
    if (provider.isLoadingMore || !provider.hasMorePages) return;
    await provider.searchHomeApts(isLoadMore: true);
  }

  Future<void> _onRefresh() async {
    if (widget.destination != null && widget.destination!.isNotEmpty) {
      final currency = Provider.of<CurrencyProvider>(context, listen: false)
          .selectedCurrency;
      final apiCity = (widget.city != null && widget.city!.isNotEmpty)
          ? widget.city!
          : widget.destination!;
      await Provider.of<HomeAptsSearchProvider>(context, listen: false)
          .searchHomeApts(
        destination: apiCity,
        city: apiCity,
        checkIn: widget.checkInDate,
        checkOut: widget.checkOutDate,
        adults: widget.adults,
        children: widget.children,
        infants: widget.infants,
        currency: currency,
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
              Icons.home_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Homes & Apts Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your dates or location.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kSubtitleColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
              'Homes & Apts in ${widget.destination ?? 'Destination'}'.tr,
              style: GoogleFonts.spaceGrotesk(
                  color: kHeadingColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Consumer<HomeAptsSearchProvider>(
        builder: (context, provider, _) {
          final filteredList = provider.isLoading
              ? <HomeAptsModel>[]
              : _filtered(provider.homeAptsList);
          return Column(
            children: [
              // ── Always-visible Filter / Sort bar ───────────────────
              _FilterSortBar(
                itemCount: provider.isLoading ? null : provider.totalCount,
                sortLabel: _sortLabel,
                filterActive: _activeFilter.isActive,
                onFilter: _openFilter,
                onSort: _openSort,
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Loading state — shimmer skeleton
                    if (provider.isLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: 4,
                        itemBuilder: (_, __) => const HomeAptsCardShimmer(),
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
                              const SizedBox(height: 24),
                              Text(
                                'Something went wrong'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: kHeadingColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                provider.error ?? 'Unknown error',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: kSubtitleColor,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _onRefresh,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
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

                    // Empty state
                    if (provider.homeAptsList.isEmpty) {
                      return _buildEmptyState();
                    }

                    // No filter match
                    if (filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No homes match your filters'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kSubtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(
                                  () => _activeFilter = const _FilterState()),
                              child: Text(
                                'Clear filters'.tr,
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
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredList.length) {
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
                                provider.homeAptsList.isNotEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'All ${provider.totalCount} ${'homes loaded'.tr}',
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
                          return Consumer<CurrencyProvider>(
                            builder: (context, currencyProvider, _) {
                              return HomeAptsCard(
                                homeApt: filteredList[index],
                                destination: widget.destination,
                                checkIn: provider.lastCheckIn,
                                checkOut: provider.lastCheckOut,
                                adults: provider.lastAdults,
                                children: provider.lastChildren,
                                currency: currencyProvider.selectedCurrency,
                              );
                            },
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

// ─────────────────────────────────────────────────────────────────────────────
// FILTER / SORT BAR
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSortBar extends StatelessWidget {
  final int? itemCount;
  final String sortLabel;
  final bool filterActive;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  const _FilterSortBar({
    required this.itemCount,
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
              itemCount == null
                  ? 'Searching...'.tr
                  : '$itemCount ${itemCount == 1 ? 'home available'.tr : 'homes available'.tr}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kSubtitleColor,
              ),
            ),
          ),
          _Pill(
            icon: Icons.swap_vert_rounded,
            label: '${'Sort:'.tr} $sortLabel',
            active: false,
            onTap: onSort,
          ),
          const SizedBox(width: 8),
          _Pill(
            icon: Icons.tune_rounded,
            label: 'Filter'.tr,
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

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

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
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.40,
      snap: true,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Filters'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kHeadingColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => _draft = const _FilterState());
                    },
                    child: Text('Reset'.tr,
                        style: TextStyle(color: kPrimaryColor)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    'Price Range'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kHeadingColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_draft.minPrice, _draft.maxPrice),
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    activeColor: kPrimaryColor,
                    inactiveColor: kPrimaryColor.withOpacity(0.2),
                    labels: RangeLabels(
                      _draft.minPrice.toStringAsFixed(0),
                      _draft.maxPrice.toStringAsFixed(0),
                    ),
                    onChanged: (v) => setState(() => _draft =
                        _draft.copyWith(minPrice: v.start, maxPrice: v.end)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _draft.minPrice.toStringAsFixed(0),
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, color: kSubtitleColor),
                      ),
                      Text(
                        _draft.maxPrice.toStringAsFixed(0),
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, color: kSubtitleColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_draft);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SORT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              'Sort By'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kHeadingColor,
              ),
            ),
          ),
          const Divider(height: 1),
          ..._SortBy.values.map((s) {
            final label = s == _SortBy.price ? 'Price'.tr : 'Name'.tr;
            return ListTile(
              title: Text(label,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kHeadingColor)),
              trailing: selected == s
                  ? Icon(Icons.check_rounded, color: kPrimaryColor)
                  : null,
              onTap: () {
                onSelect(s);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME APTS CARD
// ─────────────────────────────────────────────────────────────────────────────

class HomeAptsCard extends StatelessWidget {
  final HomeAptsModel homeApt;
  final String? destination;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int adults;
  final int children;
  final String currency;

  const HomeAptsCard({
    Key? key,
    required this.homeApt,
    this.destination,
    this.checkIn,
    this.checkOut,
    this.adults = 1,
    this.children = 0,
    this.currency = 'USD',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImages = homeApt.images.isNotEmpty;
    final imageUrl = hasImages ? homeApt.images.first : null;

    final rawPrice = homeApt.convertedPricePerNight;
    final pricePerNight = rawPrice is String
        ? double.tryParse(rawPrice.toString()) ?? 0
        : (rawPrice ?? 0).toDouble();
    final priceStr =
        pricePerNight > 0 ? pricePerNight.toStringAsFixed(0) : null;
    final displayCurrency = (homeApt.convertedCurrency?.isNotEmpty == true)
        ? homeApt.convertedCurrency!
        : currency;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${homeApt.name ?? 'property'}...'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
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
            // ── Image ─────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: hasImages && imageUrl != null
                  ? _buildImage(imageUrl)
                  : _buildImagePlaceholder(),
            ),

            // ── Content ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    homeApt.name ?? 'Home & Apt',
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
                          homeApt.address ?? homeApt.city ?? 'Location',
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

                  // Property info row
                  Row(
                    children: [
                      if (homeApt.bedrooms != null) ...[
                        Icon(Icons.bed_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${homeApt.bedrooms} bed${homeApt.bedrooms! != 1 ? 's' : ''}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12, color: kSubtitleColor),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (homeApt.bathrooms != null) ...[
                        Icon(Icons.bathtub_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${homeApt.bathrooms} bath${homeApt.bathrooms! != 1 ? 's' : ''}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12, color: kSubtitleColor),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (homeApt.maxGuests != null) ...[
                        Icon(Icons.people_outline,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${homeApt.maxGuests} guests',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12, color: kSubtitleColor),
                        ),
                      ],
                    ],
                  ),

                  // Amenities chips
                  if (homeApt.amenities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          homeApt.amenities.length.clamp(0, 4),
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
                                homeApt.amenities[i],
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

                  // Price + CTA row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                                    text: '$displayCurrency ',
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

                      // CTA button
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Opening ${homeApt.name ?? 'property'}...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
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
                        child: SizedBox(
                          width: 80,
                          child: Center(
                            child: Text(
                              'View Home'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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

  Widget _buildImage(String imageUrl) {
    // Base64 data URI
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

    // Relative path — prepend base domain (e.g. "uploads/hotel-room/xyz.jpg")
    String resolvedUrl = imageUrl;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      resolvedUrl =
          'https://rawana.com/${imageUrl.replaceAll(RegExp(r'^/+'), '')}';
    }

    return Image.network(
      resolvedUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: kPrimaryColor,
            ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kPrimaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 50,
              color: kPrimaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// HOME APTS CARD SHIMMER
// ─────────────────────────────────────────────────────────────────────────────

class HomeAptsCardShimmer extends StatefulWidget {
  const HomeAptsCardShimmer({super.key});

  @override
  State<HomeAptsCardShimmer> createState() => _HomeAptsCardShimmerState();
}

class _HomeAptsCardShimmerState extends State<HomeAptsCardShimmer>
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
              // Image area
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  gradient: gradient,
                ),
              ),
              // Content area
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(width: double.infinity, height: 18, radius: 6),
                    const SizedBox(height: 6),
                    shimmerBox(width: 220, height: 14, radius: 6),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        shimmerBox(width: 14, height: 14, radius: 4),
                        const SizedBox(width: 6),
                        shimmerBox(width: 180, height: 12, radius: 6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        shimmerBox(width: 60, height: 12, radius: 6),
                        const SizedBox(width: 12),
                        shimmerBox(width: 60, height: 12, radius: 6),
                        const SizedBox(width: 12),
                        shimmerBox(width: 60, height: 12, radius: 6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: kCardDividerColor),
                    const SizedBox(height: 14),
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
