import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/constants.dart';

/// Shown when Stripe payment was received but the booking status did not reach
/// a terminal state within the polling window. This happens when the Stripe
/// webhook (checkout.session.completed) is delayed in updating the order record.
///
/// The user sees their booking reference and clear next-steps guidance.
class HotelBookingProcessingScreen extends StatelessWidget {
  final String bookingCode;

  const HotelBookingProcessingScreen({
    Key? key,
    required this.bookingCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
                child: Column(
                  children: [
                    _buildIconBadge(),
                    const SizedBox(height: 24),
                    _buildBookingCodeCard(context),
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                    _buildBackToHomeButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8A500), Color(0xFFF0C040)],
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
            'Booking Processing',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your payment was received. We're confirming your reservation.",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE8A500), width: 2),
      ),
      child: const Icon(
        Icons.hourglass_top_rounded,
        color: Color(0xFFE8A500),
        size: 36,
      ),
    );
  }

  Widget _buildBookingCodeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Booking Reference',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bookingCode,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kHeadingColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: bookingCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Booking code copied!',
                        style: GoogleFonts.spaceGrotesk(),
                      ),
                      backgroundColor: kPrimaryColor,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFFE8A500), size: 20),
              const SizedBox(width: 8),
              Text(
                'What happens next?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF78350F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined,
              'You will receive a confirmation email once your booking is approved.'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.schedule_rounded,
              'This usually takes a few minutes. Please allow up to 30 minutes.'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.bookmark_border_rounded,
              'You can check the status under My Bookings at any time.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFB45309)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: const Color(0xFF78350F),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Back to Home',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
