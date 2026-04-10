import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/hotel_booking_confirmation_model.dart';
import 'package:moonbnd/modals/activity_model.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/Provider/activity_provider.dart';
import 'package:moonbnd/screens/activities/activity_results_screen.dart';

class HotelBookingConfirmedScreen extends StatefulWidget {
  final HotelBookingConfirmationData data;
  final String? city;

  const HotelBookingConfirmedScreen({
    Key? key,
    required this.data,
    this.city,
  }) : super(key: key);

  @override
  State<HotelBookingConfirmedScreen> createState() =>
      _HotelBookingConfirmedScreenState();
}

class _HotelBookingConfirmedScreenState
    extends State<HotelBookingConfirmedScreen> {
  late HotelBookingConfirmationData data;
  List<ActivityModel> _recommendedActivities = [];
  bool _activitiesLoading = true;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _fetchRecommendedActivities();
  }

  Future<void> _fetchRecommendedActivities() async {
    // Determine destination: prefer explicit city, fallback to hotel name
    final destination = widget.city ?? data.hotelName;
    if (destination == null || destination.isEmpty) {
      log('[BookingConfirmed] No destination available for activities');
      if (mounted) setState(() => _activitiesLoading = false);
      return;
    }

    final currency = data.currency ?? 'USD';
    log('[BookingConfirmed] Fetching activities for: $destination ($currency)');

    try {
      final provider = context.read<ActivityProvider>();
      final success = await provider.searchActivities(
        destination: destination,
        currency: currency,
      );

      if (mounted) {
        setState(() {
          if (success) {
            _recommendedActivities = provider.activities.take(3).toList();
          }
          _activitiesLoading = false;
        });
        log('[BookingConfirmed] Loaded ${_recommendedActivities.length} recommended activities');
      }
    } catch (e) {
      log('[BookingConfirmed] Error fetching activities: $e');
      if (mounted) setState(() => _activitiesLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEE, d MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatGuests(int? adults, int? children) {
    final a = adults ?? 0;
    final c = children ?? 0;
    final adultStr = a == 1 ? '1 Adult' : '$a Adults';
    if (c == 0) return adultStr;
    final childStr = c == 1 ? '1 Child' : '$c Children';
    return '$adultStr, $childStr';
  }

  String _formatPrice(double? price, String? currency) {
    if (price == null) return '-';
    final cur = currency ?? 'USD';
    return '$cur ${price.toStringAsFixed(2)}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent accidental back — user should use the buttons
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(height: 10),
                    _buildDetailsCard(context),
                    if (data.specialRequests != null &&
                        data.specialRequests!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSpecialRequestsCard(),
                    ],
                    const SizedBox(height: 28),
                    _buildBackToHomeButton(context),
                    // const SizedBox(height: 12),
                    // _buildBookAnotherButton(context),
                    const SizedBox(height: 28),
                    _buildRecommendedActivitiesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, Color(0xFF01C4A8)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Icon(Icons.check_circle_rounded,
          //  color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'Booking Confirmed',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your hotel reservation has been submitted successfully.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status badge ──────────────────────────────────────────────────────────

  Widget _buildStatusBadge() {
    final status = (data.status ?? 'confirmed').toUpperCase();
    final isConfirmed = status == 'CONFIRMED' || status == 'COMPLETED';
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color:
                isConfirmed ? const Color(0xffDCFCE7) : const Color(0xffFEF9C3),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isConfirmed
                  ? const Color(0xff16A34A)
                  : const Color(0xffCA8A04),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConfirmed
                      ? const Color(0xff16A34A)
                      : const Color(0xffCA8A04),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isConfirmed
                      ? const Color(0xff15803D)
                      : const Color(0xff92400E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Details card ──────────────────────────────────────────────────────────

  Widget _buildDetailsCard(BuildContext context) {
    final nights = data.nights ?? 1;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Overview',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Copyable booking code
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: data.orderId ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking code copied'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        data.orderId ?? '-',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded,
                          size: 14, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                _row('Hotel', data.hotelName),
                _row('Room', data.roomName),
                _row('Check-in', _formatDate(data.checkIn)),
                _row('Check-out', _formatDate(data.checkOut)),
                _row('Guests', _formatGuests(data.adults, data.children)),
                _row('Rooms / Nights',
                    '1 Room, $nights ${nights == 1 ? 'Night' : 'Nights'}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xffF1F5F9), height: 1),
                ),
                _row('Guest Name', data.guest?.fullName),
                _row('Email', data.guest?.email),
                _row('Phone', data.guest?.phone),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xffF1F5F9), height: 1),
                ),
                _row('Total Price',
                    _formatPrice(data.totalPrice, data.currency)),
                if (data.provider != null && data.provider!.isNotEmpty)
                  _row('Provider', data.provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: const Color(0xff94A3B8),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value ?? '-',
              textAlign: TextAlign.right,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Special requests ──────────────────────────────────────────────────────

  Widget _buildSpecialRequestsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.specialRequests!,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: const Color(0xff64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────

  Widget _buildBackToHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => BottomNav()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          'Back to Home'.tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Widget _buildBookAnotherButton(BuildContext context) {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 52,
  //     child: OutlinedButton(
  //       onPressed: () {
  //         // Pop until hotel list or home — adjust route name as needed
  //         Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (_) => BottomNav()),
  //           (route) => false,
  //         );
  //       },
  //       style: OutlinedButton.styleFrom(
  //         side: const BorderSide(color: kPrimaryColor, width: 1.5),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.search_rounded, color: kPrimaryColor, size: 18),
  //           const SizedBox(width: 8),
  //           Text(
  //             'Book Another Hotel'.tr,
  //             style: GoogleFonts.spaceGrotesk(
  //               fontSize: 15,
  //               fontWeight: FontWeight.w600,
  //               color: kPrimaryColor,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ── Recommended Activities ─────────────────────────────────────────────────

  Widget _buildRecommendedActivitiesSection() {
    // Hide completely if no activities and done loading
    if (!_activitiesLoading && _recommendedActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    final destination = widget.city ?? data.hotelName ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Recommended Activities'.tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Top things to do in $destination',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: const Color(0xff64748B),
          ),
        ),
        const SizedBox(height: 16),

        // Loading state
        if (_activitiesLoading)
          ...List.generate(3, (_) => _buildActivityCardSkeleton())
        // Activity cards
        else
          ..._recommendedActivities.map(_buildActivityCard),

        // Explore More button
        if (!_activitiesLoading && _recommendedActivities.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToAllActivities(),
              icon: const Icon(Icons.explore_rounded,
                  size: 18, color: kPrimaryColor),
              label: Text(
                'Explore More Activities'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    // Price display: prefer converted, fallback to base
    final price = activity.convertedPricePerPerson ?? activity.pricePerPerson;
    final curr = activity.convertedCurrency ?? activity.currency ?? 'USD';
    final priceText =
        price != null ? '$curr ${price.toStringAsFixed(2)}' : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToAllActivities(),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xffF1F5F9),
                  child:
                      activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                          ? Image.network(
                              activity.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_outlined,
                                    color: Color(0xffCBD5E1), size: 28),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.image_outlined,
                                  color: Color(0xffCBD5E1), size: 28),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Location
                    if (activity.city != null)
                      Text(
                        [activity.city, activity.country]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(', '),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: const Color(0xff64748B),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Category + Duration row
                    Row(
                      children: [
                        if (activity.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity.category!,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        if (activity.category != null &&
                            activity.duration != null)
                          const SizedBox(width: 8),
                        if (activity.duration != null) ...[
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: Color(0xff94A3B8)),
                          const SizedBox(width: 3),
                          Text(
                            activity.duration!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: const Color(0xff64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price + Book Now row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'from',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: const Color(0xff94A3B8),
                              ),
                            ),
                            Text(
                              priceText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: kPrimaryColor, width: 1.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Book Now'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
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
      ),
    );
  }

  Widget _buildActivityCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xffF1F5F9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xffF1F5F9),
                    )),
                const SizedBox(height: 8),
                Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xffF1F5F9),
                    )),
                const SizedBox(height: 10),
                Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xffF1F5F9),
                    )),
                const SizedBox(height: 10),
                Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xffF1F5F9),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAllActivities() {
    final destination = widget.city ?? data.hotelName ?? 'Activities';
    DateTime activityDate = DateTime.now().add(const Duration(days: 1));
    if (data.checkOut != null && data.checkOut!.isNotEmpty) {
      try {
        activityDate = DateTime.parse(data.checkOut!);
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityResultsScreen(
          destination: destination,
          selectedDate: activityDate,
          participants: (data.adults ?? 1) + (data.children ?? 0),
        ),
      ),
    );
  }
}
