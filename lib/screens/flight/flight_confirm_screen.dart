// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_string_interpolations

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// SUCCESS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SvgPicture.asset('assets/icons/greentick.svg', height: 56),
                  const SizedBox(height: 12),
                  Text(
                    'Booking Confirmed'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary.withOpacity(0.700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Confirmation sent to'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    flightbookingdata.bookingResponse?.data?.booking?.email ?? '',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BOOKING SUMMARY
            _infoCard(
              title: 'Booking Summary'.tr,
              children: [
                _infoRow('Booking Number'.tr,
                    '${flightbookingdata.bookingResponse?.data?.booking?.id ?? ''}'),
        _infoRow(
          'Booking Date'.tr,
          DateFormat('dd MMM yyyy').format(
            DateTime.parse(
              (flightbookingdata.bookingResponse
                  ?.data
                  ?.booking
                  ?.startDate ??
                  DateTime.now().toIso8601String())
                  .toString(),
            ),
          ),
        ),
        _infoRow('Payment Method'.tr,
                    flightbookingdata.bookingResponse?.data?.booking?.gateway ?? ''),
                _statusChip(
                    flightbookingdata.bookingResponse?.data?.booking?.status ?? ''),
              ],
            ),

            const SizedBox(height: 20),

            /// FLIGHT DETAILS
            _infoCard(
              title: 'Your Booking'.tr,
              children: [_buildBookingDetails()],
            ),

            const SizedBox(height: 20),

            /// USER DETAILS
            _infoCard(
              title: 'Your Information'.tr,
              children: [_buildUserInfo()],
            ),

            const SizedBox(height: 24),

            /// ACTION BUTTONS
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingHistoryScreen()),
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

            const SizedBox(height: 12),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => BottomNav()),
                      (route) => false,
                );
              },
              child: Text(
                'Back to Home'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }






  Widget _infoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
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
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.grey[600],
              )),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTotal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
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
        /// ====== TOP FLIGHT CARD ======
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
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${flightbookingdata.bookingResponse?.data?.booking?.service?.title ?? ''}'
                        ' | ${flightbookingdata.flightDetail?.data?.code ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Wrap(
                    children: [
                      Text(
                        flightbookingdata.bookingResponse?.data?.booking?.service
                            ?.airportFrom?.name ??
                            '',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: grey,
                        ),
                      ),
                      Text(
                        ' → ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: grey,
                        ),
                      ),
                      Text(
                        flightbookingdata.bookingResponse?.data?.booking?.service
                            ?.airportTo?.name ??
                            '',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${flightbookingdata.bookingResponse?.data?.booking?.service?.duration ?? ''} hrs',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// ====== FLIGHT TIMES ======
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFlightInfo(
              'Take Off'.tr,
              DateFormat('HH:mm').format(
                DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                  flightbookingdata.flightDetail?.data?.departureTime ?? '',
                ),
              ),
              DateFormat('dd MMM, yyyy').format(
                DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                  flightbookingdata.flightDetail?.data?.departureTime ?? '',
                ),
              ),
              flightbookingdata.flightDetail?.data?.airportTo?.name ?? '',
            ),
            _buildFlightInfo(
              'Landing'.tr,
              DateFormat('HH:mm').format(
                DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                  flightbookingdata.flightDetail?.data?.arrivalTime ?? '',
                ),
              ),
              DateFormat('dd MMM, yyyy').format(
                DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                  flightbookingdata.flightDetail?.data?.arrivalTime ?? '',
                ),
              ),
              flightbookingdata.flightDetail?.data?.airportFrom?.name ?? '',
            ),
          ],
        ),

        const SizedBox(height: 10),
        const Divider(),

        /// ====== START DATE ======
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start Date'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              DateFormat("dd/MM/yyyy").format(
                DateTime.parse(
                  (flightbookingdata.bookingResponse?.data?.booking?.startDate ??
                      '2000-01-01')
                      .toString(),
                ),
              ),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// ====== INFO ROWS ======
        _buildInfoRow(
          'Duration'.tr,
          '${flightbookingdata.bookingResponse?.data?.booking?.service?.duration ?? 0} hrs',
        ),

        ...(flightbookingdata.bookingResponse?.data?.booking?.seatDetails ?? [])
            .map(
              (seat) => _buildInfoRow(
            seat.seatType?.code?.capitalizeFirst ?? '',
            '${seat.number ?? 0}',
          ),
        ),

        const SizedBox(height: 10),

        ...(flightbookingdata.bookingResponse?.data?.booking?.seatDetails ?? [])
            .map(
              (seat) => _buildInfoRow(
            '${seat.seatType?.code?.capitalizeFirst ?? ''}: '
                '${seat.number ?? 0} × \$${seat.price ?? 0}',
            '\$${(int.parse(seat.number?.toString() ?? '0') * double.parse(seat.price?.toString() ?? '0')).toStringAsFixed(2)}',
          ),
        ),

        const Divider(),

        /// ====== TOTALS ======
        _buildTotal(
          'Total'.tr,
          double.parse(
              flightbookingdata.bookingResponse?.data?.booking?.total ?? '0')
              .toStringAsFixed(2),
        ),
        _buildTotal(
          'Paid'.tr,
          double.parse(
              flightbookingdata.bookingResponse?.data?.booking?.paid ?? '0')
              .toStringAsFixed(2),
        ),
        _buildTotal(
          'Remain'.tr,
          double.parse(
              flightbookingdata.bookingResponse?.data?.booking?.payNow ?? '0')
              .toStringAsFixed(2),
        ),

        const Divider(),
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
