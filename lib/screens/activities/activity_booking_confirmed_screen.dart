// lib/screens/activities/activity_booking_confirmed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/activity_order_model.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';

class ActivityBookingConfirmedScreen extends StatelessWidget {
  final ActivityOrderData data;

  const ActivityBookingConfirmedScreen({Key? key, required this.data})
      : super(key: key);

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatPrice(double? price, String? currency) {
    if (price == null) return '-';
    return '${currency ?? 'AED'} ${price.toStringAsFixed(2)}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final passenger = data.passengers.isNotEmpty ? data.passengers.first : null;

    return WillPopScope(
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
                    const SizedBox(height: 20),
                    _buildOverviewCard(context),
                    if (passenger != null) ...[
                      const SizedBox(height: 16),
                      _buildTravelerCard(passenger),
                    ],
                    if (data.specialRequests != null &&
                        data.specialRequests!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSpecialRequestsCard(),
                    ],
                    const SizedBox(height: 28),
                    _buildBackToHomeButton(context),
                    const SizedBox(height: 12),
                    _buildBrowseActivitiesButton(context),
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
          const SizedBox(height: 12),
          Text(
            'Booking Confirmed'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your activity has been booked successfully.'.tr,
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

  // ── Overview card ─────────────────────────────────────────────────────────

  Widget _buildOverviewCard(BuildContext context) {
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
          // Card header — kPrimaryColor with white text + copyable order ID
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
                  'Booking Overview'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                _row('Activity'.tr, data.activityTitle),
                _row('City'.tr, data.city),
                _row('Activity Date'.tr, data.activityDate),
                _row('Participants'.tr, data.participants?.toString()),
                _row('Duration'.tr, data.duration),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xffF1F5F9), height: 1),
                ),
                _row('Contact Name'.tr, data.guest?.fullName),
                _row('Email'.tr, data.guest?.email),
                _row('Phone'.tr, data.guest?.phone),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xffF1F5F9), height: 1),
                ),
                _row('Payment Method'.tr, 'STRIPE'),
                _row('Price / Person'.tr,
                    _formatPrice(data.unitPrice, data.currency)),
                _row('Total Price'.tr,
                    _formatPrice(data.totalPrice, data.currency)),
                if (data.provider != null && data.provider!.isNotEmpty)
                  _row('Provider'.tr, data.provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Traveler card ─────────────────────────────────────────────────────────

  Widget _buildTravelerCard(ActivityOrderPassenger p) {
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Traveler Details'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.label != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      p.label!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
                _row('Title'.tr, p.title),
                _row('First Name'.tr, p.firstName),
                _row('Last Name'.tr, p.lastName),
                _row('Date of Birth'.tr, p.dob),
                _row('Nationality'.tr, p.nationality),
                _row('Gender'.tr, p.gender),
                _row('Passport Number'.tr, p.passport),
                _row('Passport Expiry'.tr, p.passportExpiry),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Special requests card ─────────────────────────────────────────────────

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
            'Special Requests'.tr,
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

  // ── Row helper (matches hotel screen exactly) ─────────────────────────────

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

  Widget _buildBrowseActivitiesButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => BottomNav()),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimaryColor, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, color: kPrimaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Browse Activities'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
