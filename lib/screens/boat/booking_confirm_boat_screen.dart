// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingConfirmedScreenForBoat extends StatefulWidget {
  final String bookingCode;
  const BookingConfirmedScreenForBoat({super.key, required this.bookingCode});

  @override
  State<BookingConfirmedScreenForBoat> createState() =>
      _BookingConfirmedScreenForBoatState();
}

class _BookingConfirmedScreenForBoatState
    extends State<BookingConfirmedScreenForBoat> {
  int calculatedTime = 0;
  double rentalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails().then((_) {
      calculateRentalPrice();
    });
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    setState(() {});
  }

  void calculateRentalPrice() {
    final data = Provider.of<HomeProvider>(context, listen: false);
    final booking = data.bookingResponse?.data?.booking;

    if (booking?.days == 0) {
      calculatedTime = int.parse("${booking?.hours}");
      rentalPrice =
          calculatedTime * double.parse(booking?.service?.pricePerHour ?? "1");
    } else {
      calculatedTime = int.parse("${booking?.days}");
      rentalPrice =
          calculatedTime * double.parse(booking?.service?.pricePerDay ?? "1");
    }
    setState(() {});
  }

  // ---------------- SPACE GROTESK ----------------
  TextStyle sg({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }

  // ---------------- INFO ROW ----------------
  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: sg(size: 13, color: grey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: sg(size: 14, weight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STATUS CHIP ----------------
  Widget statusItem(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: sg(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // ---------------- SECTION CARD ----------------
  Widget section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: sg(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ---------------- BOOKING HEADER ----------------
  Widget bookingHeader(HomeProvider data) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            data.bookingResponse?.data?.booking?.service?.gallery?.first ?? '',
            width: 90,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.bookingResponse?.data?.booking?.service?.title ?? '',
                style: sg(size: 16, weight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                data.bookingResponse?.data?.booking?.service?.address ?? '',
                style: sg(size: 13, color: grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- BOOKING DETAILS ----------------
  Widget bookingDetails(HomeProvider data) {
    final booking = data.bookingResponse?.data?.booking;

    return section(
      'Booking Summary'.tr,
      Column(
        children: [
          bookingHeader(data),
          const SizedBox(height: 16),
          Divider(height: 1),
          infoItem(
            'Start Date'.tr,
            DateFormat('dd MMM yyyy')
                .format(DateTime.parse("${booking?.startDate}")),
          ),
          infoItem('Time'.tr, booking?.startTime ?? ''),
          infoItem(
            booking?.days == 0 ? 'Hours' : 'Days',
            '$calculatedTime',
          ),
          infoItem('Rental Price'.tr, '\$$rentalPrice'),
          Divider(height: 24),
          infoItem('Total'.tr, '\$${booking?.total ?? ""}'),
          infoItem('Paid'.tr, '\$${booking?.paid ?? ""}'),
          infoItem('Remaining'.tr, '\$${booking?.payNow ?? ""}'),
        ],
      ),
    );
  }

  // ---------------- USER INFO ----------------
  Widget userInfo(HomeProvider data) {
    final b = data.bookingResponse?.data?.booking;
    return section(
      'Customer Information'.tr,
      Column(
        children: [
          infoItem('Name'.tr, '${b?.firstName ?? ''} ${b?.lastName ?? ''}'),
          infoItem('Email'.tr, b?.email ?? ''),
          infoItem('Phone'.tr, b?.phone ?? ''),
          infoItem('Address'.tr, '${b?.address ?? ''} ${b?.address2 ?? ''}'),
          infoItem('City'.tr, b?.city ?? ''),
          infoItem('State'.tr, b?.state ?? ''),
          infoItem('ZIP'.tr, b?.zipCode ?? ''),
          infoItem('Country'.tr, b?.country ?? ''),
          infoItem('Notes'.tr, b?.customerNotes ?? ''),
        ],
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<HomeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => BottomNav()),
              (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
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
                  data.bookingResponse?.data?.booking?.shareUrl ?? "",
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SvgPicture.asset('assets/icons/greentick.svg', height: 70),
              const SizedBox(height: 12),
              Text(
                'Booking Confirmed'.tr,
                style: sg(size: 22, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Confirmation sent to'.tr,
                style: sg(size: 13, color: grey),
              ),
              Text(
                data.bookingResponse?.data?.booking?.email ?? '',
                style: sg(size: 14, weight: FontWeight.w500),
              ),
              const SizedBox(height: 14),
              statusItem(
                data.bookingResponse?.data?.booking?.status ?? '',
              ),
              const SizedBox(height: 24),
              bookingDetails(data),
              userInfo(data),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => BookingHistoryScreen()),
                  );
                },
                child: Text(
                  'Booking History'.tr,
                  style: sg(color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => BottomNav()),
                        (route) => false,
                  );
                },
                child: Text(
                  'Back to Home'.tr,
                  style: sg(weight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
