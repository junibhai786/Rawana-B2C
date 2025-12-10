// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_string_interpolations

import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class FlightConfirmScreen extends StatefulWidget {
  final String bookingCode;
  const FlightConfirmScreen({super.key, required this.bookingCode});

  @override
  State<FlightConfirmScreen> createState() => _FlightConfirmScreenState();
}

class _FlightConfirmScreenState extends State<FlightConfirmScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    await flightProvider.fetchFlightBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final flightbookingdata =
        Provider.of<FlightProvider>(context, listen: true);
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
              Share.share(
                  'Check out my booking details: ${flightbookingdata.bookingResponse?.data?.booking?.shareUrl}');
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Booking Confirmed'.tr,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/icons/greentick.svg')),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Booking details has been sent to'.tr,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter'.tr,
                    color: kPrimaryColor),
              ),
              Text(
                flightbookingdata.bookingResponse?.data?.booking?.email ?? '',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter'.tr,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w400,
                    color: kPrimaryColor),
              ),
              _buildInfoRow(
                  'Booking Number'.tr,
                  (flightbookingdata.bookingResponse?.data?.booking?.id ?? 0)
                      .toString()),
              _buildInfoRow(
                  'Booking Date'.tr,
                  DateFormat('d MMM yyyy').format(DateTime.parse(
                      flightbookingdata
                              .bookingResponse?.data?.booking?.startDate
                              .toString() ??
                          DateTime.now().toString()))),
              _buildInfoRow(
                  'Payment Method'.tr,
                  (flightbookingdata.bookingResponse?.data?.booking?.gateway ??
                      '')),
              SizedBox(height: 10),
              _buildStatusRow(
                  'Booking Status'.tr,
                  (flightbookingdata.bookingResponse?.data?.booking?.status ??
                      "")),
              SizedBox(height: 20),
              Divider(
                thickness: 1,
              ),
              SizedBox(height: 20),
              Text('Your Booking'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor)),
              SizedBox(height: 10),
              _buildBookingDetails(),
              SizedBox(height: 20),
              Text('Your Information'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor)),
              SizedBox(height: 10),
              _buildUserInfo(),
              SizedBox(height: 20),
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Booking History'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kSecondaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingHistoryScreen(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 1, color: Colors.black12)),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) {
                        return BottomNav();
                      },
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Home".tr,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter'.tr,
                  color: grey)),
        ],
      ),
    );
  }

  Widget _buildTotal(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: kPrimaryColor,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w500)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'.tr,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    final flightbookingdata =
        Provider.of<FlightProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                flightbookingdata.bookingResponse?.data?.booking?.service
                        ?.airportImageUrl ??
                    'assets/haven/house.png',
                width: 96,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                      flightbookingdata
                              .bookingResponse?.data?.booking?.service?.title ??
                          '' +
                              ' | ${flightbookingdata.flightDetail?.data?.code}',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    Text(
                      flightbookingdata.bookingResponse?.data?.booking?.service
                              ?.airportFrom?.name ??
                          "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: grey,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                    Text(
                      " to ".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: grey,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                    Text(
                      flightbookingdata.bookingResponse?.data?.booking?.service
                              ?.airportTo?.name ??
                          "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: grey,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${flightbookingdata.bookingResponse?.data?.booking?.service?.duration ?? ""} hrs",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                    fontFamily: 'Inter'.tr,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFlightInfo(
                'Take Off'.tr,
                DateFormat('HH:mm').format(
                    DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                        flightbookingdata.flightDetail?.data?.departureTime ??
                            '')),
                DateFormat('dd MMM, yyyy').format(
                    DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                        flightbookingdata.flightDetail?.data?.departureTime ??
                            '')),
                flightbookingdata.flightDetail?.data?.airportTo?.name ?? ''),
            // Center(
            //   child: Text(
            //     '${flightbookingdata.flightDetail?.data?.duration} hrs'.tr,
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //       color: kPrimaryColor,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),
            _buildFlightInfo(
                'Landing'.tr,
                DateFormat('HH:mm').format(
                    DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                        flightbookingdata.flightDetail?.data?.arrivalTime ??
                            '')),
                DateFormat('dd MMM, yyyy').format(
                    DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                        flightbookingdata.flightDetail?.data?.arrivalTime ??
                            '')),
                flightbookingdata.flightDetail?.data?.airportFrom?.name ?? ''),
          ],
        ),
        SizedBox(height: 10),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start Date'.tr,
              style: TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor),
            ),
            Text(
                DateFormat("dd/MM/yyyy").format(DateTime.parse((flightbookingdata
                            .bookingResponse?.data?.booking?.startDate ??
                        '2000-01-01')
                    .toString())), // Using a valid default date instead of empty string
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter'.tr,
                    fontWeight: FontWeight.w400,
                    color: grey)),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoRow('Duration'.tr,
            "${flightbookingdata.bookingResponse?.data?.booking?.service?.duration ?? 0} hrs"),
        ...(flightbookingdata.bookingResponse?.data?.booking?.seatDetails ?? [])
            .map((seat) => Column(
                  children: [
                    _buildInfoRow(
                        '${seat.seatType?.code?.capitalizeFirst ?? ""}'.tr,
                        '${seat.number ?? 0}'),
                  ],
                )),
        SizedBox(height: 10),
        ...(flightbookingdata.bookingResponse?.data?.booking?.seatDetails ?? [])
            .map((seat) => Column(
                  children: [
                    _buildInfoRow(
                        '${seat.seatType?.code?.capitalizeFirst ?? ""}: ${seat.number ?? 0} * \$${seat.price ?? 0}',
                        "\$${(int.parse(seat.number?.toString() ?? "0") * double.parse(seat.price?.toString() ?? "0")).toStringAsFixed(2)} "),
                  ],
                )),
        Divider(),
        _buildTotal(
            'Total'.tr,
            double.parse(
                    flightbookingdata.bookingResponse?.data?.booking?.total ??
                        '0')
                .toStringAsFixed(2)),
        _buildTotal(
            'Paid'.tr,
            double.parse(
                    flightbookingdata.bookingResponse?.data?.booking?.paid ??
                        '0')
                .toStringAsFixed(2)),
        _buildTotal(
            'Remain'.tr,
            double.parse(
                    flightbookingdata.bookingResponse?.data?.booking?.payNow ??
                        '0')
                .toStringAsFixed(2)),
        Divider(),
      ],
    );
  }

  Widget _buildUserInfo() {
    final flightbookingdata =
        Provider.of<FlightProvider>(context, listen: true);
    return Column(
      children: [
        _buildInfoRow('First Name'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.firstName ?? ''),
        _buildInfoRow('Last Name'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.lastName ?? ''),
        _buildInfoRow('Email'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.email ?? ''),
        _buildInfoRow('Phone'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.phone ?? ''),
        _buildInfoRow('Address line 1'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.address ?? ''),
        _buildInfoRow('Address line 2'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.address2 ?? ''),
        _buildInfoRow('Country'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.country ?? ''),
        _buildInfoRow('State/Province/Region'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.state ?? ''),
        _buildInfoRow('City'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.city ?? ''),
        _buildInfoRow('ZIP code/Postal code'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.zipCode ?? ''),
        _buildInfoRow(
            'Special Requirements'.tr,
            flightbookingdata.bookingResponse?.data?.booking?.customerNotes ??
                ''),
      ],
    );
  }
}

Widget _buildFlightInfo(
    String title, String time, String date, String location) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Inter',
              color: kSecondaryColor)),
      SizedBox(height: 5),
      Text(time,
          style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              fontFamily: 'Inter')),
      SizedBox(height: 5),
      Text(date,
          style:
              TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
      Text(location,
          style:
              TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
    ],
  );
}
