// lib/screens/activities/activity_results_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/modals/activity_model.dart';
import 'package:moonbnd/Provider/activity_provider.dart';
import 'package:moonbnd/screens/activities/activity_checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/constants.dart';

enum _SortOption {
  recommended('Recommended'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low');

  final String label;
  const _SortOption(this.label);
}

const _kActivityCategories = <String>[
  'All Categories',
  'City Tour',
  'Cruise',
  'Cultural',
  'Desert',
  'Family',
  'Sightseeing',
];

class _ActivityFilterDraft {
  final double minPrice;
  final double maxPrice;
  final String category;
  final bool instantOnly;

  const _ActivityFilterDraft({
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.category = 'All Categories',
    this.instantOnly = false,
  });

  bool get isActive =>
      minPrice != 0 ||
      maxPrice != 1000 ||
      category != 'All Categories' ||
      instantOnly;

  _ActivityFilterDraft copyWith({
    double? minPrice,
    double? maxPrice,
    String? category,
    bool? instantOnly,
  }) =>
      _ActivityFilterDraft(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        category: category ?? this.category,
        instantOnly: instantOnly ?? this.instantOnly,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ActivityResultsScreen extends StatefulWidget {
  final String destination;
  final DateTime selectedDate;
  final int participants;

  const ActivityResultsScreen({
    super.key,
    required this.destination,
    required this.selectedDate,
    required this.participants,
  });

  @override
  State<ActivityResultsScreen> createState() => _ActivityResultsScreenState();
}

class _ActivityResultsScreenState extends State<ActivityResultsScreen> {
  _SortOption _sortOption = _SortOption.recommended;
  _ActivityFilterDraft _filter = const _ActivityFilterDraft();

  // ── Derive unique category list from loaded activities ──────────────────
  static List<String> _deriveCategories(List<ActivityModel> activities) {
    final seen = <String>{};
    final result = <String>['All Categories'];
    for (final a in activities) {
      final cat = a.category?.trim();
      if (cat != null && cat.isNotEmpty && seen.add(cat.toLowerCase())) {
        result.add(cat);
      }
    }
    return result;
  }

  // ── Derived list: filter + sort in memory ──────────────────────────────
  List<ActivityModel> _buildDerivedList(List<ActivityModel> source) {
    // Normalize selected category once
    final selectedCat = _filter.category.trim().toLowerCase();
    final filterByCategory = selectedCat != 'all categories';

    // 1. Filter
    var result = source.where((a) {
      final price = a.pricePerPerson ?? 0.0;
      final actCat = (a.category ?? '').trim().toLowerCase();
      final pricePass = price >= _filter.minPrice && price <= _filter.maxPrice;
      final catPass = !filterByCategory || actCat == selectedCat;
      final instantPass = !_filter.instantOnly || a.instantConfirmation;

      return pricePass && catPass && instantPass;
    }).toList();

    // 2. Sort
    switch (_sortOption) {
      case _SortOption.priceLow:
        result.sort(
          (a, b) => (a.pricePerPerson ?? 0).compareTo(b.pricePerPerson ?? 0),
        );
      case _SortOption.priceHigh:
        result.sort(
          (a, b) => (b.pricePerPerson ?? 0).compareTo(a.pricePerPerson ?? 0),
        );
      case _SortOption.recommended:
        break; // preserve original API order
    }

    return result;
  }

  void _openFilterSheet() {
    final activities = context.read<ActivityProvider>().activities;
    final categories = activities.isNotEmpty
        ? _deriveCategories(activities)
        : _kActivityCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityFilterSheet(
        draft: _filter,
        categories: categories,
        onApply: (d) {
          setState(() {
            _filter = d;
          });
          Navigator.of(context).pop();
        },
        onClear: () {
          setState(() => _filter = const _ActivityFilterDraft());
          Navigator.of(context).pop();
        },
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activities in ${widget.destination}'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Filter / Sort top row ────────────────────────────────────
          // ── Filter / Sort top row ────────────────────────────────────
          Consumer<ActivityProvider>(
            builder: (context, provider, _) => _FilterSortBar(
              activityCount: provider.isLoading ? null : provider.totalCount,
              filterActive: _filter.isActive,
              sortLabel: _sortOption.label,
              onFilterTap: _openFilterSheet,
              onSortTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _SortSheet(
                    selected: _sortOption,
                    onSelect: (v) => setState(() => _sortOption = v),
                  ),
                );
              },
            ),
          ),

          // ── Results ──────────────────────────────────────────────────
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const _LoadingState();
                }
                if (provider.error != null) {
                  return _ErrorState(error: provider.error!);
                }
                if (provider.activities.isEmpty) {
                  return _EmptyState(destination: widget.destination);
                }

                // Apply filtering and sorting
                final derived = _buildDerivedList(provider.activities);
                if (derived.isEmpty) {
                  return const _FilterEmptyState();
                }
                return _ResultsList(
                  activities: derived,
                  selectedDate: widget.selectedDate,
                  participants: widget.participants,
                  destination: widget.destination,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: 4,
      itemBuilder: (_, __) => const _ActivityCardSkeleton(),
    );
  }
}

class _ActivityCardSkeleton extends StatelessWidget {
  const _ActivityCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 60, color: Colors.grey.shade100),
                const SizedBox(height: 8),
                Container(
                    height: 18,
                    width: double.infinity,
                    color: Colors.grey.shade100),
                const SizedBox(height: 6),
                Container(height: 14, width: 140, color: Colors.grey.shade100),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 24, width: 100, color: Colors.grey.shade100),
                    Container(
                        height: 36, width: 100, color: Colors.grey.shade100),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Something went wrong'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kMutedColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'Go Back'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String destination;
  const _EmptyState({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Activities Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any activities in ${destination}.\nTry searching for another destination.'
                  .tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kSubtitleColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'Search Again'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Empty ─────────────────────────────────────────────────────────

class _FilterEmptyState extends StatelessWidget {
  const _FilterEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off_rounded,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Matches Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: kHeadingColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No activities match your current filters.\nTry adjusting or clearing them.'
                  .tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kSubtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results List ─────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<ActivityModel> activities;
  final DateTime selectedDate;
  final int participants;
  final String destination;

  const _ResultsList({
    required this.activities,
    required this.selectedDate,
    required this.participants,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _ActivityCard(
          activity: activities[index],
          selectedDate: selectedDate,
          participants: participants,
          destination: destination,
        );
      },
    );
  }
}

// ── Activity Card ─────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final DateTime selectedDate;
  final int participants;
  final String destination;

  const _ActivityCard({
    required this.activity,
    required this.selectedDate,
    required this.participants,
    required this.destination,
  });

  void _handleViewDeal(BuildContext context) async {
    // Use the date and participants from search context (already selected)
    final activityDate = selectedDate;
    final participantCount = participants;
    final city = destination;

    // Call prebook API
    EasyLoading.show(status: 'Loading activity details...'.tr);
    final provider = context.read<ActivityProvider>();
    final preBookResponse = await provider.preBookActivity(
      activity: activity,
      selectedDate: activityDate.toString().split(' ')[0], // Format: YYYY-MM-DD
      participants: participantCount,
    );
    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (preBookResponse == null || !preBookResponse.success!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            preBookResponse?.message ??
                'Failed to prepare booking. Please try again.'.tr,
            style: GoogleFonts.spaceGrotesk(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Prepare checkout data using search context
    final checkoutData = {
      'activity_id': activity.id,
      'activity_title': activity.title,
      'provider': activity.provider,
      'city': city,
      'country': activity.country ?? '',
      'category': activity.category ?? '',
      'duration': activity.duration ?? '',
      'activity_date': activityDate.toString().split(' ')[0],
      'participants': participantCount,
      'unit_price': preBookResponse.unitPrice,
      'total_price': preBookResponse.totalPrice,
      'currency': preBookResponse.currency ?? 'AED',
      'checkout_token': preBookResponse.checkoutToken,
      'checkout_url': preBookResponse.checkoutUrl,
    };

    // Navigate to checkout screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityCheckoutScreen(
          activityData: checkoutData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image / Placeholder ──────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                ? Image.network(
                    activity.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category badge + Instant confirmation ────────────
                Row(
                  children: [
                    if (activity.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimaryTintColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activity.category!.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (activity.instantConfirmation)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSuccessTintColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 12, color: Color(0xff4CAF50)),
                            const SizedBox(width: 4),
                            Text(
                              'Instant'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kSuccessColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Title ────────────────────────────────────────────
                Text(
                  activity.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: kHeadingColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // ── City + Country ───────────────────────────────────
                if (activity.city != null || activity.country != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: kMutedColor),
                      const SizedBox(width: 4),
                      Text(
                        [activity.city, activity.country]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', '),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ),

                if (activity.address != null &&
                    activity.address!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.map_outlined,
                            size: 14, color: kVeryMutedColor),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.address!,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: kVeryMutedColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: kCardDividerColor),
                const SizedBox(height: 10),

                // ── Duration + Max Participants ──────────────────────
                Row(
                  children: [
                    if (activity.duration != null) ...[
                      const Icon(Icons.access_time,
                          size: 14, color: kMutedColor),
                      const SizedBox(width: 4),
                      Text(
                        activity.duration!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kSubtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (activity.maxParticipants != null) ...[
                      const Icon(Icons.people_outline,
                          size: 14, color: kMutedColor),
                      const SizedBox(width: 4),
                      Text(
                        'Up to ${activity.maxParticipants}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: kSubtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ── Price + View Deal ───────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Per person'.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: kVeryMutedColor,
                          ),
                        ),
                        if (activity.pricePerPerson != null)
                          Text(
                            '${activity.currency ?? ''} ${activity.pricePerPerson!.toStringAsFixed(0)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryColor,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    _ViewDealButton(
                      onPressed: () => _handleViewDeal(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurfaceColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.08),
            kPrimaryColor.withOpacity(0.03)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hiking_rounded,
              size: 48,
              color: kPrimaryColor.withOpacity(0.25),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSortBar extends StatelessWidget {
  final int? activityCount;
  final bool filterActive;
  final String sortLabel;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;

  const _FilterSortBar({
    required this.activityCount,
    required this.filterActive,
    required this.sortLabel,
    required this.onFilterTap,
    required this.onSortTap,
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
              activityCount == null
                  ? 'Searching...'.tr
                  : '$activityCount ${'Activities '.tr}',
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
            onTap: onSortTap,
          ),
          const SizedBox(width: 8),
          _Pill(
            icon: Icons.tune_rounded,
            label: 'Filter'.tr,
            active: filterActive,
            onTap: onFilterTap,
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
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : kPrimaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final _SortOption selected;
  final ValueChanged<_SortOption> onSelect;

  const _SortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort By'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kHeadingColor,
            ),
          ),
          const SizedBox(height: 16),
          ..._SortOption.values.map((option) => ListTile(
                onTap: () {
                  onSelect(option);
                  Navigator.pop(context);
                },
                title: Text(
                  option.label.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight:
                        selected == option ? FontWeight.w600 : FontWeight.w400,
                    color: selected == option ? kPrimaryColor : kHeadingColor,
                  ),
                ),
                trailing: selected == option
                    ? const Icon(Icons.check_circle_rounded,
                        color: kPrimaryColor)
                    : null,
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW DEAL BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ViewDealButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ViewDealButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View Deal',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5),
            // const Icon(Icons.arrow_forward_ios_rounded,
            //     size: 11, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY FILTER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityFilterSheet extends StatefulWidget {
  final _ActivityFilterDraft draft;
  final List<String> categories;
  final ValueChanged<_ActivityFilterDraft> onApply;
  final VoidCallback onClear;

  const _ActivityFilterSheet({
    required this.draft,
    required this.categories,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<_ActivityFilterSheet> {
  late _ActivityFilterDraft _d;

  @override
  void initState() {
    super.initState();
    _d = widget.draft;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 18, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Activities'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kHeadingColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kSurfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: kMutedColor),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: kCardDividerColor),

            // ── Scrollable content ───────────────────────────────────
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                children: [
                  // A. Price Per Person
                  const _SheetSectionLabel(text: 'PRICE PER PERSON'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceLabel(
                          caption: 'Min', value: 'AED ${_d.minPrice.toInt()}'),
                      _PriceLabel(
                          caption: 'Max',
                          value: 'AED ${_d.maxPrice.toInt()}',
                          alignRight: true),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: kPrimaryColor,
                      inactiveTrackColor: kPrimaryColor.withOpacity(0.15),
                      thumbColor: kPrimaryColor,
                      overlayColor: kPrimaryColor.withOpacity(0.12),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 9),
                    ),
                    child: RangeSlider(
                      values: RangeValues(_d.minPrice, _d.maxPrice),
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      onChanged: (v) => setState(() =>
                          _d = _d.copyWith(minPrice: v.start, maxPrice: v.end)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: kCardDividerColor),
                  const SizedBox(height: 20),

                  // B. Category (list derived dynamically from API data)
                  const _SheetSectionLabel(text: 'CATEGORY'),
                  const SizedBox(height: 10),
                  ...widget.categories.map(
                    (cat) => _RadioRow(
                      label: cat,
                      // Normalized comparison so casing/whitespace never breaks selection
                      selected: _d.category.trim().toLowerCase() ==
                          cat.trim().toLowerCase(),
                      onTap: () =>
                          setState(() => _d = _d.copyWith(category: cat)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: kCardDividerColor),
                  const SizedBox(height: 20),

                  // C. Booking Options
                  const _SheetSectionLabel(text: 'BOOKING OPTIONS'),
                  const SizedBox(height: 10),
                  _CheckRow(
                    label: 'Instant Confirmation',
                    value: _d.instantOnly,
                    onChanged: (v) =>
                        setState(() => _d = _d.copyWith(instantOnly: v)),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ── Action buttons ────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).viewPadding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Clear
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kMutedColor,
                        side: const BorderSide(color: kBorderColor),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Clear'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => widget.onApply(_d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Apply Filters'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SHEET SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSectionLabel extends StatelessWidget {
  final String text;
  const _SheetSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: Colors.grey.shade500,
        ),
      );
}

class _PriceLabel extends StatelessWidget {
  final String caption;
  final String value;
  final bool alignRight;

  const _PriceLabel({
    required this.caption,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(caption,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10, color: Colors.grey.shade400)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kPrimaryColor,
              )),
        ],
      );
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? kHeadingColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? kPrimaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: value ? kPrimaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: value ? kHeadingColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
