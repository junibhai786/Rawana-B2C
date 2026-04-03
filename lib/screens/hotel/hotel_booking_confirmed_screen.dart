import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/hotel_booking_confirmation_model.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';

class HotelBookingConfirmedScreen extends StatelessWidget {
  final HotelBookingConfirmationData data;

  const HotelBookingConfirmedScreen({Key? key, required this.data})
      : super(key: key);

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
                    const SizedBox(height: 20),
                    _buildDetailsCard(context),
                    if (data.specialRequests != null &&
                        data.specialRequests!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSpecialRequestsCard(),
                    ],
                    const SizedBox(height: 28),
                    _buildBackToHomeButton(context),
                    const SizedBox(height: 12),
                    _buildBookAnotherButton(context),
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

  Widget _buildBookAnotherButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // Pop until hotel list or home — adjust route name as needed
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
              'Book Another Hotel'.tr,
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
