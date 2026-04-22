// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'event_detail_screen.dart';

// ignore: must_be_immutable
class BookingConfirmedScreenForEvent extends StatefulWidget {
  final String bookingCode;
  List<PersonTypeForEvent> txpersonTypes;

  BookingConfirmedScreenForEvent({
    super.key,
    required this.bookingCode,
    required this.txpersonTypes,
  });

  @override
  State<BookingConfirmedScreenForEvent> createState() =>
      _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState
    extends State<BookingConfirmedScreenForEvent> {
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => BottomNav()),
                  (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/shareicon.svg'),
            onPressed: () async {
              await Share.share(
                data.bookingResponse?.data?.booking?.shareUrl ?? '',
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= CONFIRMATION HEADER =================
            Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/icons/greentick.svg',
                    height: 64,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Booking Confirmed'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your booking was successful'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            /// ================= BOOKING DETAILS =================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    'Booking Number'.tr,
                    '${data.bookingResponse?.data?.booking?.id ?? ''}',
                  ),
                  _buildInfoRow(
                    'Booking Date'.tr,
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(
                        '${data.bookingResponse?.data?.booking?.createdAt}',
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    'Payment Method'.tr,
                    data.bookingResponse?.data?.booking?.gateway ?? '',
                  ),
                  SizedBox(height: 8),
                  _buildStatusRow(
                    'Status'.tr,
                    data.bookingResponse?.data?.booking?.status ?? '',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            /// ================= YOUR BOOKING =================
            Text(
              'Your Booking'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: _buildBookingDetails(),
            ),

            SizedBox(height: 24),

            /// ================= USER INFO =================
            Text(
              'Your Information'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: _buildUserInfo(),
            ),

            SizedBox(height: 24),

            /// ================= BUTTONS =================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 52),
                backgroundColor: kSecondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingHistoryScreen(),
                  ),
                );
              },
              child: Text(
                'Booking History'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 14),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNav()),
                      (route) => false,
                );
              },
              child: Text(
                'Back to Home'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= INFO ROW =================
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= STATUS =================
  Widget _buildStatusRow(String label, String status) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= BOOKING DETAILS =================
  Widget _buildBookingDetails() {
    final data = Provider.of<HomeProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            data.bookingResponse?.data?.booking?.service?.gallery?.first ?? '',
            width: 90,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.bookingResponse?.data?.booking?.service?.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                data.bookingResponse?.data?.booking?.service?.address ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ================= USER INFO =================
  Widget _buildUserInfo() {
    final data = Provider.of<HomeProvider>(context);

    return Column(
      children: [
        _buildInfoRow('First Name'.tr,
            data.bookingResponse?.data?.booking?.firstName ?? ''),
        _buildInfoRow('Last Name'.tr,
            data.bookingResponse?.data?.booking?.lastName ?? ''),
        _buildInfoRow(
            'Email'.tr, data.bookingResponse?.data?.booking?.email ?? ''),
        _buildInfoRow(
            'Phone'.tr, data.bookingResponse?.data?.booking?.phone ?? ''),
        _buildInfoRow('Address line 1'.tr,
            data.bookingResponse?.data?.booking?.address ?? ''),
        _buildInfoRow('Address line 2'.tr,
            data.bookingResponse?.data?.booking?.address2 ?? ''),
        _buildInfoRow(
            'City'.tr, data.bookingResponse?.data?.booking?.city ?? ''),
        _buildInfoRow('State/Province/Region'.tr,
            data.bookingResponse?.data?.booking?.state ?? ''),
        _buildInfoRow('ZIP code/Postal code'.tr,
            data.bookingResponse?.data?.booking?.zipCode ?? ''),
        _buildInfoRow(
            'Country'.tr, data.bookingResponse?.data?.booking?.country ?? ''),
        _buildInfoRow('Special Requirements'.tr,
            data.bookingResponse?.data?.booking?.customerNotes ?? ''),
      ],
    );
  }
}
