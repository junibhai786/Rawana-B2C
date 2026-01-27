import 'package:flutter_svg/svg.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/flight/flight_booking_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FlightDetailsScreen extends StatefulWidget {
  final int flightId;
  const FlightDetailsScreen({super.key, required this.flightId});

  @override
  _FlightDetailsState createState() => _FlightDetailsState();
}

class _FlightDetailsState extends State<FlightDetailsScreen> {
  bool loading = false;
  double totalPrice = 0.0;

  final Map<String, GlobalKey<_AirlineTicketBookingState>> _ticketKeys = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    Provider.of<FlightProvider>(context, listen: false)
        .fetchFlightDetails(widget.flightId)
        .then((_) {
      // Initialize GlobalKeys after fetching flight details
      final flightData = Provider.of<FlightProvider>(context, listen: false)
          .flightDetail
          ?.data;
      flightData?.flightSeat?.forEach((seat) {
        // Use seat ID to ensure unique keys
        final seatKey = 'seat_${seat.id}';
        if (!_ticketKeys.containsKey(seatKey)) {
          _ticketKeys[seatKey] = GlobalKey<_AirlineTicketBookingState>();
        }
      });
      setState(() {
        loading = false;
      });
    });
  }

  void calculateTotalPrice() {
    if (mounted) {
      setState(() {
        final flightData = Provider.of<FlightProvider>(context, listen: false)
            .flightDetail
            ?.data;
        totalPrice = 0.0;

        flightData?.flightSeat?.forEach((seat) {
          double seatPrice = double.tryParse(seat.price ?? '0.0') ?? 0.0;
          int passengerCount =
              _ticketKeys['seat_${seat.id}']?.currentState?._number ?? 0;
          totalPrice += seatPrice * passengerCount;
        });
      });
    }
  }

  Future<void> _handleBookNow() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => CustomBottomSheet(
          title: 'Log in to add to'.tr,
          content: 'your booking'.tr,
          onCancel: () {
            Navigator.of(context).pop();
          },
          onLogin: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInScreen()),
            );
          },
        ),
      );
      return;
    }

    final flightData =
        Provider.of<FlightProvider>(context, listen: false).flightDetail?.data;
    if (flightData == null) return;

    List<Map<String, dynamic>> flightSeats = [];

    flightData.flightSeat?.forEach((seat) {
      final seatKey = _ticketKeys['seat_${seat.id}'];
      final number = seatKey?.currentState?._number ?? 0;

      if (number > 0) {
        flightSeats.add({
          'id': seat.id,
          'price': seat.price,
          'seat_type': {
            'id': seat.seatType?.id,
            'code': seat.seatType?.code,
          },
          'number': number,
        });
      }
    });

    if (flightSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one seat'.tr)),
      );
      return;
    }

    try {
      final result = await Provider.of<FlightProvider>(context, listen: false)
          .addToCartForFlight(
        serviceId: flightData.id.toString(),
        flightSeats: flightSeats,
      );

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FlightBookingScreen(bookingCode: result['booking_code']),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added to booking'.tr)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to booking'.tr)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<FlightProvider>(context, listen: true);
    final flightData = item.flightDetail?.data;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Make sure text aligns left
                                children: [
                                  Text(
                                    item.flightDetail?.data?.title ?? "",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.flightDetail?.data?.code ?? "",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/location.svg',
                                        width: 16,
                                        height: 16,
                                        color: Color(0xff65758B),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            item.flightDetail?.data?.airline
                                                    ?.name ??
                                                "",
                                            style: GoogleFonts.spaceGrotesk(
                                                color: Colors.grey)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${item.flightDetail?.data?.reviewScore ?? 0} Reviews',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: const Color(0xFF65758B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 330,
                            child: PageView.builder(
                              onPageChanged: (value) {
                                setState(() {});
                              },
                              itemBuilder: (context, index) => Image.network(
                                item.flightDetail?.data?.airline?.imageUrl ??
                                    '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/haven/tour_descripation.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Flight Info Card
                          buildFlightInfoCard(item),

                          SizedBox(height: 24),
                          // Flight Route
                          _buildFlightRoute(item),
                          SizedBox(height: 32),

                          // Seat Selection Title
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Select Your Seat'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1D2025),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Seat Options
                          ...flightData?.flightSeat
                                  ?.map((seat) => Column(
                                        children: [
                                          AirlineTicketBooking(
                                            key: _ticketKeys['seat_${seat.id}'],
                                            baggage: seat.person ?? '1 person',
                                            checkIn:
                                                '${seat.baggageCheckIn ?? 6} kgs',
                                            cabin:
                                                '${seat.baggageCabin ?? 6} kgs',
                                            price: double.tryParse(
                                                    seat.price ?? '22.0') ??
                                                22.0,
                                            name: seat.seatType?.name ??
                                                'Premium',
                                            onNumberChanged: (value) {
                                              calculateTotalPrice();
                                            },
                                          ),
                                          SizedBox(height: 16),
                                        ],
                                      ))
                                  .toList() ??
                              [],

                          // Total Price
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xffF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xffE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff1D2025),
                                  ),
                                ),
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: kSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Book Now Button
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(0xffE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TertiaryButton(
                      text: "Book Now bbb".tr,
                      press: _handleBookNow,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildFlightInfoCard(FlightProvider item) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(
            Icons.schedule,
            'Duration'.tr,
            '${item.flightDetail?.data?.duration ?? '0'} hrs',
          ),
          Container(
            width: 1,
            height: 40,
            color: Color(0xffE2E8F0),
          ),
          _buildInfoItem(
            Icons.airplane_ticket,
            'Starting from'.tr,
            '\$${item.flightDetail?.data?.minPrice ?? '0'}',
          ),
          Container(
            width: 1,
            height: 40,
            color: Color(0xffE2E8F0),
          ),
          _buildInfoItem(
            Icons.star,
            'Rating'.tr,
            item.flightDetail?.data?.reviewScore ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: kSecondaryColor,
            size: 20,
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xff65758B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff1D2025),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightRoute(FlightProvider item) {
    DateTime? departureTime;
    DateTime? arrivalTime;

    if (item.flightDetail?.data?.departureTime != null) {
      try {
        departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ')
            .parse(item.flightDetail!.data!.departureTime!);
      } catch (e) {
        departureTime = null;
      }
    }

    if (item.flightDetail?.data?.arrivalTime != null) {
      try {
        arrivalTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ')
            .parse(item.flightDetail!.data!.arrivalTime!);
      } catch (e) {
        arrivalTime = null;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Route Timeline
          SizedBox(
            height: 20, // Give the Stack a height
            child: Stack(
              children: [
                Container(
                  height: 2,
                  color: Color(0xffE2E8F0),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Departure and Arrival Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Departure'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff65758B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      departureTime != null
                          ? DateFormat('HH:mm').format(departureTime!)
                          : '--:--',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1D2025),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      departureTime != null
                          ? DateFormat('dd MMM, yyyy').format(departureTime!)
                          : '-- ---, ----',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff65758B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xff65758B),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.flightDetail?.data?.airportFrom?.name ??
                                'Unknown Airport',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff65758B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Duration in center
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.flight,
                      color: kSecondaryColor,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${item.flightDetail?.data?.duration ?? '0'} hrs'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Arrival'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff65758B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      arrivalTime != null
                          ? DateFormat('HH:mm').format(arrivalTime!)
                          : '--:--',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1D2025),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      arrivalTime != null
                          ? DateFormat('dd MMM, yyyy').format(arrivalTime!)
                          : '-- ---, ----',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff65758B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            item.flightDetail?.data?.airportTo?.name ??
                                'Unknown Airport',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff65758B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.location_on,
                          color: Color(0xff65758B),
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildFlightInfoCard(
    String title, String? time, String? location, Color color) {
  DateTime? dateTime;
  if (time != null) {
    try {
      dateTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(time);
    } catch (e) {
      dateTime = null;
    }
  }

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff65758B),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          dateTime != null ? DateFormat('HH:mm').format(dateTime!) : '--:--',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xff1D2025),
          ),
        ),
        SizedBox(height: 4),
        Text(
          dateTime != null
              ? DateFormat('dd MMM, yyyy').format(dateTime!)
              : '-- ---, ----',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff65758B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          location ?? '---',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff65758B),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildDurationCard(FlightProvider item) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: kSecondaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Icon(
          Icons.schedule,
          color: kSecondaryColor,
          size: 16,
        ),
        SizedBox(height: 4),
        Text(
          '${item.flightDetail?.data?.duration} hrs'.tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ],
    ),
  );
}

class AirlineTicketBooking extends StatefulWidget {
  final String baggage;
  final String checkIn;
  final String cabin;
  final double price;
  final String name;
  final Function(int) onNumberChanged;

  const AirlineTicketBooking({
    super.key,
    required this.baggage,
    required this.checkIn,
    required this.cabin,
    required this.price,
    required this.name,
    required this.onNumberChanged,
  });

  @override
  _AirlineTicketBookingState createState() => _AirlineTicketBookingState();
}

class _AirlineTicketBookingState extends State<AirlineTicketBooking> {
  int _number = 0;
  bool isExpanded = false;

  void _updateNumber(int newValue) {
    setState(() {
      _number = newValue;
      widget.onNumberChanged(_number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xffE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_extra,
                        color: kSecondaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        widget.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1D2025),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${widget.price.toStringAsFixed(2)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kSecondaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Color(0xff65758B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Baggage Info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          Icons.luggage,
                          'Baggage'.tr,
                          widget.baggage,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xffE2E8F0),
                        ),
                        _buildInfoItem(
                          Icons.check_circle,
                          'Check In'.tr,
                          widget.checkIn,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xffE2E8F0),
                        ),
                        _buildInfoItem(
                          Icons.business,
                          'Cabin'.tr,
                          widget.cabin,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Passenger Counter
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Number of Passengers'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1D2025),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                if (_number > 0) {
                                  _updateNumber(_number - 1);
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _number > 0
                                      ? kSecondaryColor.withOpacity(0.1)
                                      : Color(0xffE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: _number > 0
                                      ? kSecondaryColor
                                      : Color(0xff94A3B8),
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '$_number',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1D2025),
                              ),
                            ),
                            SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                _updateNumber(_number + 1);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: kSecondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: kSecondaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: kSecondaryColor,
          size: 20,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff65758B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1D2025),
          ),
        ),
      ],
    );
  }
}

// import 'dart:developer';
//
// import 'package:moonbnd/Provider/flight_provider.dart';
// import 'package:moonbnd/screens/auth/signin_screen.dart';
// import 'package:moonbnd/screens/flight/flight_booking_screen.dart';
// import 'package:moonbnd/widgets/popup_login.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:moonbnd/constants.dart';
// import 'package:moonbnd/widgets/tertiary_button.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FlightDetailsScreen extends StatefulWidget {
//   final int flightId;
//   const FlightDetailsScreen({super.key, required this.flightId});
//
//   @override
//   _FlightDetailsState createState() => _FlightDetailsState();
// }
//
// class _FlightDetailsState extends State<FlightDetailsScreen> {
//   bool loading = false;
//   double totalPrice = 0.0;
//
//   final Map<String, GlobalKey<_AirlineTicketBookingState>> _ticketKeys = {};
//
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<FlightProvider>(context, listen: false)
//         .fetchFlightDetails(widget.flightId);
//   }
//
//   void calculateTotalPrice() {
//     if (mounted) {
//       setState(() {
//         final flightData = Provider.of<FlightProvider>(context, listen: false)
//             .flightDetail
//             ?.data;
//         totalPrice = 0.0;
//
//         flightData?.flightSeat?.forEach((seat) {
//           double seatPrice = double.tryParse(seat.price ?? '0.0') ?? 0.0;
//           int passengerCount =
//               _ticketKeys[seat.seatType?.name ?? '']?.currentState?._number ??
//                   1;
//           totalPrice += seatPrice * passengerCount;
//         });
//       });
//     }
//   }
//
//   Future<void> _handleBookNow() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('userToken');
//
//     if (token == null) {
//       // Show the custom bottom sheet
//       showModalBottomSheet(
//         context: context,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         builder: (context) => CustomBottomSheet(
//           title: 'Log in to add to'.tr,
//           content: 'your booking'.tr,
//           onCancel: () {
//             Navigator.of(context).pop(); // Close the bottom sheet
//           },
//           onLogin: () {
//             // Close the bottom sheet
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => SignInScreen()),
//             ); // Navigate to SignInScreen
//           },
//         ),
//       );
//       return; // Exit the function if token is null
//     }
//
//     final flightData =
//         Provider.of<FlightProvider>(context, listen: false).flightDetail?.data;
//     if (flightData == null) return;
//
//     List<Map<String, dynamic>> flightSeats = [];
//
//     // Prepare flight seats data
//     flightData.flightSeat?.forEach((seat) {
//       final seatKey = _ticketKeys[seat.seatType?.name ?? ''];
//       final number = seatKey?.currentState?._number ?? 0;
//
//       if (number > 0) {
//         flightSeats.add({
//           'id': seat.id,
//           'price': seat.price,
//           'seat_type': {
//             'id': seat.seatType?.id,
//             'code': seat.seatType?.code,
//           },
//           'number': number,
//         });
//       }
//     });
//
//     if (flightSeats.isEmpty) {
//       // Show error message if no seats selected
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select at least one seat')),
//       );
//       return;
//     }
//
//     try {
//       final result = await Provider.of<FlightProvider>(context, listen: false)
//           .addToCartForFlight(
//         serviceId: flightData.id.toString(),
//         flightSeats: flightSeats,
//       );
//
//       if (result != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 FlightBookingScreen(bookingCode: result['booking_code']),
//           ),
//         );
//         // Success - Navigate to cart or show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Successfully added to booking'.tr)),
//         );
//       } else {
//         // Error handling
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add to booking'.tr)),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final item = Provider.of<FlightProvider>(context, listen: true);
//     final flightData = item.flightDetail?.data;
//
//     // Initialize keys for each seat type
//     flightData?.flightSeat?.forEach((seat) {
//       final seatName = seat.seatType?.name ?? '';
//       if (!_ticketKeys.containsKey(seatName)) {
//         _ticketKeys[seatName] = GlobalKey<_AirlineTicketBookingState>();
//       }
//     });
//
//     return Scaffold(
//       body: loading
//           ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
//           : SafeArea(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.all(25),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Image.network(
//                             item.flightDetail?.data?.airline?.imageUrl ?? '',
//                             width: 68,
//                             height: 52,
//                           ),
//                           SizedBox(width: 8),
//                           SizedBox(
//                             width: 200,
//                             child: Text(
//                                 '${item.flightDetail?.data?.title} | ${item.flightDetail?.data?.code}'),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildFlightInfo(
//                               'Take Off'.tr,
//                               DateFormat('HH:mm').format(
//                                   DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
//                                       item.flightDetail?.data?.departureTime ??
//                                           '')),
//                               DateFormat('dd MMM, yyyy').format(
//                                   DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
//                                       item.flightDetail?.data?.departureTime ??
//                                           '')),
//                               item.flightDetail?.data?.airportTo?.name ?? ''),
//                           Center(
//                             child: Text(
//                               '${item.flightDetail?.data?.duration} hrs'.tr,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: kPrimaryColor,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                           _buildFlightInfo(
//                               'Landing'.tr,
//                               DateFormat('HH:mm').format(
//                                   DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
//                                       item.flightDetail?.data?.arrivalTime ??
//                                           '')),
//                               DateFormat('dd MMM, yyyy').format(
//                                   DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
//                                       item.flightDetail?.data?.arrivalTime ??
//                                           '')),
//                               item.flightDetail?.data?.airportFrom?.name ?? ''),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       ...flightData?.flightSeat
//                               ?.map((seat) => Column(
//                                     children: [
//                                       AirlineTicketBooking(
//                                         key: _ticketKeys[
//                                             seat.seatType?.name ?? ''],
//                                         baggage: seat.person ?? 'person',
//                                         checkIn:
//                                             '${seat.baggageCheckIn ?? 6} kgs',
//                                         cabin: '${seat.baggageCabin ?? 6} kgs',
//                                         price: double.tryParse(
//                                                 seat.price ?? '22.0') ??
//                                             22.0,
//                                         name: seat.seatType?.name ?? 'Premium',
//                                         onNumberChanged: (value) {
//                                           calculateTotalPrice();
//                                         },
//                                       ),
//                                       SizedBox(height: 20),
//                                     ],
//                                   ))
//                               .toList() ??
//                           [],
//                       Divider(
//                         height: 20,
//                         thickness: 1,
//                         color: kColor1,
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Total'.tr,
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                           Text('\$${totalPrice.toStringAsFixed(2)}',
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       SizedBox(height: 25),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 0,
//                         ),
//                         child: TertiaryButton(
//                           text: "Book Now".tr,
//                           press: _handleBookNow,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   Widget _buildFlightInfo(
//       String title, String time, String date, String location) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//                 fontFamily: 'Inter',
//                 color: kSecondaryColor)),
//         SizedBox(height: 5),
//         Text(time,
//             style: TextStyle(
//                 color: kPrimaryColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 fontFamily: 'Inter')),
//         SizedBox(height: 5),
//         Text(date,
//             style: TextStyle(
//                 color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
//         Text(location,
//             style: TextStyle(
//                 color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
//       ],
//     );
//   }
// }
//
// class AirlineTicketBooking extends StatefulWidget {
//   final String baggage;
//   final String checkIn;
//   final String cabin;
//   final double price;
//   final String name;
//   final Function(int) onNumberChanged;
//
//   const AirlineTicketBooking({
//     super.key,
//     required this.baggage,
//     required this.checkIn,
//     required this.cabin,
//     required this.price,
//     required this.name,
//     required this.onNumberChanged,
//   });
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _AirlineTicketBookingState createState() => _AirlineTicketBookingState();
// }
//
// class _AirlineTicketBookingState extends State<AirlineTicketBooking> {
//   int _number = 0;
//   bool isExpanded = false;
//
//   void _updateNumber(int newValue) {
//     setState(() {
//       _number = newValue;
//       widget.onNumberChanged(_number); // Call the callback when number changes
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: kColor1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ExpansionPanelList(
//         dividerColor: Colors.transparent,
//         expandedHeaderPadding: EdgeInsets.zero,
//         elevation: 0,
//         expansionCallback: (int index, bool isExpanded) {
//           setState(() {
//             this.isExpanded = !this.isExpanded;
//           });
//         },
//         children: [
//           ExpansionPanel(
//             backgroundColor: Colors.transparent,
//             headerBuilder: (BuildContext context, bool isExpanded) {
//               return ListTile(
//                 title: Text(widget.name),
//               );
//             },
//             body: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildInfoColumn('Baggage'.tr, widget.baggage),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child:
//                                 _buildInfoColumn('Check In'.tr, widget.checkIn),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Divider(color: kColor1, height: 1),
//                     Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildInfoColumn('Cabin'.tr, widget.cabin),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: _buildInfoColumn('Price'.tr,
//                                 '\$${widget.price.toStringAsFixed(2)}'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Number'.tr),
//                       Row(
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               if (_number > 1) {
//                                 _updateNumber(_number - 1);
//                               }
//                             },
//                             child: Container(
//                               height: 32,
//                               width: 32,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: kColor1),
//                                 borderRadius: BorderRadius.circular(5),
//                                 color: kBackgroundColor,
//                               ),
//                               child: Icon(Icons.remove,
//                                   size: 20, color: kPrimaryColor),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text('$_number'),
//                           SizedBox(width: 10),
//                           InkWell(
//                             onTap: () {
//                               _updateNumber(_number + 1);
//                             },
//                             child: Container(
//                               height: 32,
//                               width: 32,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: kColor1),
//                                 borderRadius: BorderRadius.circular(5),
//                                 color: kBackgroundColor,
//                               ),
//                               child: Icon(Icons.add,
//                                   size: 20, color: kPrimaryColor),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // ListTile(
//                 //   title: Text('Number'),
//                 //   trailing: Row(
//                 //     mainAxisSize: MainAxisSize.min,
//                 //     children: [
//                 //       IconButton(
//                 //         icon: Icon(Icons.remove),
//                 //         onPressed: () {
//                 //           setState(() {
//                 //             if (_number > 1) {
//                 //               _number--;
//                 //             }
//                 //           });
//                 //         },
//                 //       ),
//                 //       Text('$_number'),
//                 //       IconButton(
//                 //         icon: Icon(Icons.add),
//                 //         onPressed: () {
//                 //           setState(() {
//                 //             _number++;
//                 //           });
//                 //         },
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//               ],
//             ),
//             isExpanded: isExpanded,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoColumn(String title1, String info) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title1, style: TextStyle(fontWeight: FontWeight.bold)),
//         SizedBox(height: 5),
//         Text(info, style: TextStyle(color: Colors.grey)),
//       ],
//     );
//   }
// }
