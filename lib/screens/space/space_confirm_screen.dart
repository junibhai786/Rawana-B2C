// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
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

class SpaceConfirmScreen extends StatefulWidget {
  final String bookingCode;
  final int txdaysDifference;

  const SpaceConfirmScreen({
    super.key,
    required this.bookingCode,
    required this.txdaysDifference,
  });

  @override
  State<SpaceConfirmScreen> createState() => _SpaceConfirmScreenState();
}

class _SpaceConfirmScreenState extends State<SpaceConfirmScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.fetchBookingDetails(widget.bookingCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<HomeProvider>(context);

    return Scaffold(
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
            onPressed: () async {
              await Share.share(
                data.bookingResponse?.data?.booking?.shareUrl ?? '',
              );
            },
          ),
        ],
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
                      color: Colors.green,
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
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Booking Details'),
                  _infoRow(
                    'Booking Number'.tr,
                    '${data.bookingResponse?.data?.booking?.id ?? ''}',
                  ),
                  _infoRow(
                    'Booking Date'.tr,
                    DateFormat('dd MMM yyyy').format(
                      DateTime.parse(
                        '${data.bookingResponse?.data?.booking?.createdAt}',
                      ),
                    ),
                  ),
                  _infoRow(
                    'Payment Method'.tr,
                    data.bookingResponse?.data?.booking?.gateway ?? '',
                  ),
                  SizedBox(height: 8),
                  _statusRow(
                    'Status'.tr,
                    data.bookingResponse?.data?.booking?.status ?? '',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            /// ================= YOUR BOOKING =================
            _sectionTitle('Your Booking'),
            _card(child: _buildBookingDetails()),

            SizedBox(height: 24),

            /// ================= USER INFO =================
            _sectionTitle('Your Information'),
            _card(child: _buildUserInfo()),

            SizedBox(height: 24),

            /// ================= ACTION BUTTONS =================
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

  /// ================= UI HELPERS =================
  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title.tr,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
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

  Widget _statusRow(String label, String status) {
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
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= BOOKING DETAILS =================
  Widget _buildBookingDetails() {
    final data = Provider.of<HomeProvider>(context);

    final price =
        (data.bookingResponse?.data?.booking?.service?.salePrice == "0"
            ? int.tryParse(
            data.bookingResponse?.data?.booking?.service?.price ??
                '0')
            ?? 0
            : int.tryParse(
            data.bookingResponse?.data?.booking?.service?.salePrice .toString()??
                '0')
            ?? 0) *
            widget.txdaysDifference;

    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                data.bookingResponse?.data?.booking?.service?.gallery?.first ??
                    '',
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
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _infoRow(
          'Start Date'.tr,
          DateFormat('dd/MM/yyyy').format(
            DateTime.parse(
                '${data.bookingResponse?.data?.booking?.startDate}'),
          ),
        ),
        _infoRow(
          'End Date'.tr,
          DateFormat('dd/MM/yyyy').format(
            DateTime.parse(
                '${data.bookingResponse?.data?.booking?.endDate}'),
          ),
        ),
        Divider(),
        _infoRow('Rental Price'.tr, '\$$price'),
        Divider(),
        _infoRow('Total'.tr,
            '\$${data.bookingResponse?.data?.booking?.total ?? ''}'),
        _infoRow('Paid'.tr,
            '\$${data.bookingResponse?.data?.booking?.paid ?? '0'}'),
        _infoRow('Remain'.tr,
            '\$${data.bookingResponse?.data?.booking?.payNow ?? ''}'),
      ],
    );
  }

  /// ================= USER INFO =================
  Widget _buildUserInfo() {
    final data = Provider.of<HomeProvider>(context);

    return Column(
      children: [
        _infoRow('First Name'.tr, data.bookingResponse?.data?.booking?.firstName ?? ''),
        _infoRow('Last Name'.tr, data.bookingResponse?.data?.booking?.lastName ?? ''),
        _infoRow('Email'.tr, data.bookingResponse?.data?.booking?.email ?? ''),
        _infoRow('Phone'.tr, data.bookingResponse?.data?.booking?.phone ?? ''),
        _infoRow('Address line 1'.tr, data.bookingResponse?.data?.booking?.address ?? ''),
        _infoRow('Address line 2'.tr, data.bookingResponse?.data?.booking?.address2 ?? ''),
        _infoRow('City'.tr, data.bookingResponse?.data?.booking?.city ?? ''),
        _infoRow('State/Province/Region'.tr, data.bookingResponse?.data?.booking?.state ?? ''),
        _infoRow('ZIP code/Postal code'.tr, data.bookingResponse?.data?.booking?.zipCode ?? ''),
        _infoRow('Country'.tr, data.bookingResponse?.data?.booking?.country ?? ''),
        _infoRow('Special Requirements'.tr,
            data.bookingResponse?.data?.booking?.customerNotes ?? ''),
      ],
    );
  }
}
