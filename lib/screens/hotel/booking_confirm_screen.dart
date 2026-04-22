// Redesigned BookingConfirmedScreen
// Uses GoogleFonts.spaceGrotesk everywhere
// Fixes image overflow, improves layout, spacing, and hierarchy

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final String bookingCode;
  const BookingConfirmedScreen({super.key, required this.bookingCode});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
  }

  TextStyle get titleStyle => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: kPrimaryColor,
  );

  TextStyle get labelStyle => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: kPrimaryColor,
  );

  TextStyle get valueStyle => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey[700],
  );

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/shareicon.svg'),
            onPressed: () {
              Share.share(provider.bookingResponse?.data?.booking?.shareUrl ?? '');
            },
          ),
        ],
      ),
      body: provider.bookingResponse == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Booking Information'.tr,
              child: Column(
                children: [
                  _infoRow('Booking Number'.tr,
                      provider.bookingResponse!.data!.booking!.id.toString()),
                  _infoRow(
                    'Booking Date'.tr,
                    DateFormat('d MMM yyyy').format(DateTime.parse(
                        provider.bookingResponse!.data!.booking!.createdAt!)),
                  ),
                  _infoRow('Payment Method'.tr,
                      provider.bookingResponse!.data!.booking!.gateway ?? ''),
                  _statusRow('Status'.tr,
                      provider.bookingResponse!.data!.booking!.status ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBookingCard(provider),
            const SizedBox(height: 16),
            _buildUserCard(provider),
            const SizedBox(height: 24),
            _primaryButton(
              label: 'Booking History'.tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _secondaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Booking Confirmed'.tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          SvgPicture.asset('assets/icons/greentick.svg', height: 72),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(HomeProvider provider) {
    final booking = provider.bookingResponse!.data!.booking!;

    return _buildSectionCard(
      title: 'Your Booking'.tr,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  booking.service?.gallery?.first ?? '',
                  width: 90,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 80,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.service?.title ?? '',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(booking.service?.address ?? '',
                        style: valueStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Dates'.tr,
            '${DateFormat('d MMM').format(DateTime.parse(booking.startDate!))} - ${DateFormat('d MMM').format(DateTime.parse(booking.endDate!))}',
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(HomeProvider provider) {
    final booking = provider.bookingResponse!.data!.booking!;

    return _buildSectionCard(
      title: 'Your Information'.tr,
      child: Column(
        children: [
          _infoRow('Name'.tr, '${booking.firstName} ${booking.lastName}'),
          _infoRow('Email'.tr, booking.email ?? ''),
          _infoRow('Phone'.tr, booking.phone ?? ''),
          _infoRow('Address'.tr, booking.address ?? ''),
          _infoRow('City'.tr, booking.city ?? ''),
          _infoRow('Country'.tr, booking.country ?? ''),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: valueStyle,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value,
                style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          )
        ],
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _secondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => BottomNav()),
                (_) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('Back to Home'.tr,
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
