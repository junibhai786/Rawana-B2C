import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class TourConfirmScreen extends StatefulWidget {
  final String bookingCode;
  const TourConfirmScreen({super.key, required this.bookingCode});

  @override
  State<TourConfirmScreen> createState() => _TourConfirmScreenState();
}

class _TourConfirmScreenState extends State<TourConfirmScreen> {
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
    final bookingData = Provider.of<HomeProvider>(context).bookingResponse?.data?.booking;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/shareicon.svg'),
            onPressed: () {
              if (bookingData?.shareUrl != null) {
                Share.share('Check out my booking details: ${bookingData!.shareUrl}');
              }
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
            Center(
              child: Column(
                children: [
                  Text(
                    'Booking Confirmed'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                  SvgPicture.asset('assets/icons/greentick.svg', height: 60),
                  SizedBox(height: 16),
                  Text(
                    'Booking details have been sent to'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: kPrimaryColor,
                    ),
                  ),
                  Text(
                    bookingData?.email ?? '',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            /// Booking Summary Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Booking Number'.tr, bookingData?.id.toString() ?? ''),
                    _buildInfoRow(
                        'Booking Date'.tr,
                        bookingData?.createdAt != null
                            ? DateFormat('d MMM yyyy').format(DateTime.parse(bookingData!.createdAt!))
                            : ''),
                    _buildInfoRow('Payment Method'.tr, bookingData?.gateway ?? ''),
                    _buildStatusRow('Booking Status'.tr, bookingData?.status ?? ''),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            /// Your Booking Details
            Text('Your Booking'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                )),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildBookingDetails(),
              ),
            ),
            SizedBox(height: 20),

            /// User Information
            Text('Your Information'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                )),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildUserInfo(),
              ),
            ),
            SizedBox(height: 30),

            /// Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Booking History'.tr,
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                side: BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => BottomNav()), (route) => false);
              },
              child: Text(
                'Back to Home'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(label,
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryColor))),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.spaceGrotesk(fontSize: 16, color: grey))),
        ],
      ),
    );
  }

  Widget _buildTotal(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor)),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryColor)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    final bookingData = Provider.of<HomeProvider>(context).bookingResponse?.data?.booking;

    if (bookingData == null) return SizedBox();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                bookingData.service?.gallery?.first ?? 'assets/haven/house.png',
                width: 96,
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
                    bookingData.service?.title ?? '',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    bookingData.service?.address ?? '',
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildInfoRow('Dates'.tr,
            '${DateFormat('d MMM').format(DateTime.parse(bookingData.startDate ?? DateTime.now().toString()))} - ${DateFormat('d MMM').format(DateTime.parse(bookingData.endDate ?? DateTime.now().toString()))}'),
        ...(bookingData.personTypes ?? []).map((p) {
          double total = (double.tryParse(p.number ?? '0') ?? 0) * (double.tryParse(p.price ?? '0') ?? 0);
          return _buildInfoRow('${p.name}: ${p.number} x \$${p.price}', '\$${total.toStringAsFixed(2)}');
        }),
        ...(bookingData.buyerFees ?? []).map((f) => _buildInfoRow(f.name ?? '', '\$${f.price}')),
        ...(bookingData.extraPrice ?? []).map((f) => _buildInfoRow(f.name ?? '', '\$${f.price}')),
        Divider(),
        _buildTotal('Total'.tr, '\$${bookingData.total ?? '0'}'),
        _buildTotal('Paid'.tr, '\$${bookingData.paid ?? '0'}'),
        _buildTotal('Remain'.tr, '\$${bookingData.payNow ?? '0'}'),
      ],
    );
  }

  Widget _buildUserInfo() {
    final bookingData = Provider.of<HomeProvider>(context).bookingResponse?.data?.booking;
    if (bookingData == null) return SizedBox();

    return Column(
      children: [
        _buildInfoRow('First Name'.tr, bookingData.firstName ?? ''),
        _buildInfoRow('Last Name'.tr, bookingData.lastName ?? ''),
        _buildInfoRow('Email'.tr, bookingData.email ?? ''),
        _buildInfoRow('Phone'.tr, bookingData.phone ?? ''),
        _buildInfoRow('Address line 1'.tr, bookingData.address ?? ''),
        _buildInfoRow('Address line 2'.tr, bookingData.address2 ?? ''),
        _buildInfoRow('Country'.tr, bookingData.country ?? ''),
        _buildInfoRow('State/Province/Region'.tr, bookingData.state ?? ''),
        _buildInfoRow('City'.tr, bookingData.city ?? ''),
        _buildInfoRow('ZIP code/Postal code'.tr, bookingData.zipCode ?? ''),
        _buildInfoRow('Special Requirements'.tr, bookingData.customerNotes ?? ''),
      ],
    );
  }
}
